const OLLAMA_ENDPOINT = "http://127.0.0.1:11434/api/generate";
const MODEL_NAME = "gemma3:12b";
const CACHE_TTL_MS = 60 * 60 * 1000;
const MAX_CACHE_SIZE = 500;

class OllamaRequestError extends Error {
  constructor(code, message, meta) {
    super(message);
    this.name = "OllamaRequestError";
    this.code = code;
    this.meta = meta || {};
  }
}

console.log("[GreenNova BG] Service worker started. Ollama endpoint:", OLLAMA_ENDPOINT);

const scoreCache = new Map();

function now() {
  return Date.now();
}

function normalizeText(input) {
  return (input || "").toLowerCase().replace(/\s+/g, " ").trim();
}

function fingerprintProduct(product) {
  const key = [
    normalizeText(product.title),
    normalizeText(product.brand),
    normalizeText(product.price),
    normalizeText(product.category)
  ].join("|");
  return key;
}

function pruneCache() {
  const t = now();
  for (const [key, value] of scoreCache.entries()) {
    if (t - value.cachedAt > CACHE_TTL_MS) {
      scoreCache.delete(key);
    }
  }

  if (scoreCache.size <= MAX_CACHE_SIZE) {
    return;
  }

  const entries = [...scoreCache.entries()].sort((a, b) => a[1].cachedAt - b[1].cachedAt);
  const toDelete = entries.slice(0, scoreCache.size - MAX_CACHE_SIZE);
  for (const [key] of toDelete) {
    scoreCache.delete(key);
  }
}

function buildPrompt(product) {
  return [
    "You are a sustainability analyst.",
    "Return only strict JSON with this exact shape:",
    '{"score": number, "grade": "A|B|C|D|E", "summary": string, "positive_impacts": string[], "negative_impacts": string[], "how_it_affects_environment": string, "confidence": number, "recommendations": string[]}',
    "Score rules: 0 worst, 100 best.",
    "Grade mapping: A=80-100, B=65-79, C=50-64, D=35-49, E=0-34.",
    "Be concise, practical, and avoid markdown.",
    "Product context:",
    JSON.stringify(product)
  ].join("\n");
}

async function callOllama(product) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 60000);

  try {
    console.log("[GreenNova BG] Fetching Ollama:", OLLAMA_ENDPOINT, "model:", MODEL_NAME);
    const response = await fetch(OLLAMA_ENDPOINT, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        model: MODEL_NAME,
        prompt: buildPrompt(product),
        stream: false,
        options: {
          temperature: 0.2,
          num_predict: 350
        }
      }),
      signal: controller.signal
    });

    console.log("[GreenNova BG] Ollama HTTP status:", response.status);

    if (!response.ok) {
      const body = await response.text().catch(() => "");
      console.warn("[GreenNova BG] Ollama non-OK response:", response.status);

      if (response.status === 403) {
        throw new OllamaRequestError(
          "OLLAMA_FORBIDDEN",
          "Ollama rejected the extension origin. Configure OLLAMA_ORIGINS and restart Ollama.",
          { status: response.status, body: String(body || "") }
        );
      }

      throw new OllamaRequestError(
        "OLLAMA_HTTP_ERROR",
        `Ollama HTTP ${response.status}`,
        { status: response.status, body: String(body || "") }
      );
    }

    const data = await response.json();
    console.log("[GreenNova BG] Raw Ollama response length:", data?.response?.length);
    const rawText = (data && data.response ? data.response : "").trim();
    return parseModelResponse(rawText);
  } catch (err) {
    if (err.name === "AbortError") {
      throw new OllamaRequestError("OLLAMA_TIMEOUT", "Ollama request timed out.");
    }

    if (err instanceof OllamaRequestError) {
      console.warn("[GreenNova BG] callOllama handled error:", err.code);
      throw err;
    }

    console.warn("[GreenNova BG] callOllama FAILED:", err.name, err.message);
    throw new OllamaRequestError("OLLAMA_UNAVAILABLE", "Could not reach local Ollama.");
  } finally {
    clearTimeout(timeout);
  }
}

function safeNumber(value, min, max, fallback) {
  const n = Number(value);
  if (Number.isNaN(n)) {
    return fallback;
  }
  return Math.min(max, Math.max(min, n));
}

function normalizeGrade(score, grade) {
  if (typeof grade === "string" && /^[ABCDE]$/i.test(grade.trim())) {
    return grade.trim().toUpperCase();
  }

  if (score >= 80) return "A";
  if (score >= 65) return "B";
  if (score >= 50) return "C";
  if (score >= 35) return "D";
  return "E";
}

function asStringArray(value) {
  if (!Array.isArray(value)) {
    return [];
  }
  return value
    .map((item) => String(item || "").trim())
    .filter(Boolean)
    .slice(0, 6);
}

function extractJson(text) {
  try {
    return JSON.parse(text);
  } catch (error) {
    const start = text.indexOf("{");
    const end = text.lastIndexOf("}");
    if (start === -1 || end === -1 || end <= start) {
      throw error;
    }
    return JSON.parse(text.slice(start, end + 1));
  }
}

function parseModelResponse(rawText) {
  const parsed = extractJson(rawText);
  const score = Math.round(safeNumber(parsed.score, 0, 100, 50));
  return {
    score,
    grade: normalizeGrade(score, parsed.grade),
    summary: String(parsed.summary || "No summary available."),
    positiveImpacts: asStringArray(parsed.positive_impacts),
    negativeImpacts: asStringArray(parsed.negative_impacts),
    environmentImpact: String(
      parsed.how_it_affects_environment || "Impact details are unavailable."
    ),
    confidence: Math.round(safeNumber(parsed.confidence, 0, 100, 60)),
    recommendations: asStringArray(parsed.recommendations),
    generatedAt: new Date().toISOString()
  };
}

async function scoreProduct(product) {
  pruneCache();

  const key = fingerprintProduct(product);
  const cached = scoreCache.get(key);
  if (cached && now() - cached.cachedAt <= CACHE_TTL_MS) {
    return { ...cached.value, cached: true };
  }

  const report = await callOllama(product);
  scoreCache.set(key, { cachedAt: now(), value: report });
  return { ...report, cached: false };
}

async function checkOllama() {
  try {
    const response = await fetch("http://127.0.0.1:11434/api/tags", {
      method: "GET"
    });
    console.log("[GreenNova BG] Ollama health check:", response.status);
    return response.ok;
  } catch (err) {
    console.error("[GreenNova BG] Ollama health check FAILED:", err.name, err.message);
    return false;
  }
}

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (!message || !message.type) {
    return;
  }

  if (message.type === "GREENNOVA_SCORE_PRODUCT") {
    scoreProduct(message.payload)
      .then((report) => {
        sendResponse({ ok: true, report });
      })
      .catch((err) => {
        const code = err && err.code ? err.code : "OLLAMA_UNAVAILABLE";
        sendResponse({
          ok: false,
          code,
          message: err && err.message ? err.message : "Local Ollama is unavailable.",
          meta: err && err.meta ? err.meta : undefined
        });
      });
    return true;
  }

  if (message.type === "GREENNOVA_HEALTHCHECK") {
    checkOllama().then((healthy) => {
      sendResponse({ ok: true, healthy });
    });
    return true;
  }

  if (message.type === "GREENNOVA_GET_SETTINGS") {
    chrome.storage.sync.get(
      {
        domainAllowlist: ["amazon", "flipkart"]
      },
      (settings) => {
        sendResponse({ ok: true, settings });
      }
    );
    return true;
  }

  if (message.type === "GREENNOVA_SET_SETTINGS") {
    chrome.storage.sync.set(message.payload || {}, () => {
      sendResponse({ ok: true });
    });
    return true;
  }
});
