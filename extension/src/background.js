const OLLAMA_ENDPOINT = "http://127.0.0.1:11434/api/generate";
const MODEL_NAME = "gemma3:latest";
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

function buildBatchPrompt(products) {
  return [
    "You are a strict environmental analyst.",
    "Analyze the product SOLELY based on its ecological footprint, sustainability, and environmental impact.",
    "DO NOT include general pros/cons like 'low cost', 'fun', or 'convenient'. Every positive_impact, negative_impact, and recommendation MUST be strictly about the Earth, emissions, waste, animals, or eco-materials.",
    "Return strict JSON which MUST be an array of objects.",
    "Each object must have this exact shape:",
    '{"id": number, "score": number, "grade": "A|B|C|D|E", "summary": string, "positive_impacts": string[], "negative_impacts": string[], "how_it_affects_environment": string, "confidence": number, "recommendations": string[]}',
    "Score rules: 0 worst, 100 best.",
    "Grade mapping: A=80-100, B=65-79, C=50-64, D=35-49, E=0-34.",
    "Be concise, practical, and avoid markdown. ONLY RETURN JSON.",
    "Products to score:",
    JSON.stringify(products)
  ].join("\n");
}

async function callOllamaBatch(products) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 300000); // 5 mins for batch

  try {
    console.log("[GreenNova BG] Fetching Ollama:", OLLAMA_ENDPOINT, "model:", MODEL_NAME, "for", products.length, "items");
    const response = await fetch(OLLAMA_ENDPOINT, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        model: MODEL_NAME,
        prompt: buildBatchPrompt(products),
        stream: false,
        options: {
          temperature: 0.2,
          num_predict: 8192,
          num_ctx: 32768
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
    console.log("[GreenNova BG] Debug: Ollama response summary", rawText.substring(0, 100) + "...");
    return parseModelBatchResponse(rawText);
  } catch (err) {
    if (err.name === "AbortError") {
      throw new OllamaRequestError("OLLAMA_TIMEOUT", "Ollama request timed out.");
    }

    if (err instanceof OllamaRequestError) {
      console.warn("[GreenNova BG] callOllamaBatch handled error:", err.code);
      throw err;
    }

    console.warn("[GreenNova BG] callOllamaBatch FAILED:", err.name, err.message);
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
    const start = text.indexOf("[");
    const end = text.lastIndexOf("]");
    if (start === -1 || end === -1 || end <= start) {
      // Fallback if returned an object instead of array
      const startObj = text.indexOf("{");
      const endObj = text.lastIndexOf("}");
      if (startObj !== -1 && endObj !== -1 && endObj > startObj) {
         const obj = JSON.parse(text.slice(startObj, endObj + 1));
         return [obj]; // Wrap in array
      }
      throw error;
    }
    return JSON.parse(text.slice(start, end + 1));
  }
}

function parseModelBatchResponse(rawText) {
  let parsedArray = extractJson(rawText);
  if (!Array.isArray(parsedArray)) {
     if (typeof parsedArray === 'object' && parsedArray.id !== undefined) {
         parsedArray = [parsedArray];
     } else {
         throw new Error("Model did not return a JSON array");
     }
  }
  
  return parsedArray.map(parsed => {
    const score = Math.round(safeNumber(parsed.score, 0, 100, 50));
    return {
      id: parsed.id,
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
  });
}

async function scoreBatch(products) {
  pruneCache();
  
  const uncachedProducts = [];
  const results = [];
  
  for (const product of products) {
    const key = fingerprintProduct(product);
    const cached = scoreCache.get(key);
    
    if (cached && now() - cached.cachedAt <= CACHE_TTL_MS) {
      results.push({ ...cached.value, cached: true, id: product.id });
    } else {
      uncachedProducts.push(product);
    }
  }

  if (uncachedProducts.length > 0) {
    console.log(`[GreenNova BG] Fetching AI for ${uncachedProducts.length} items`);
    const newReports = await callOllamaBatch(uncachedProducts);
    
    for (const report of newReports) {
      // Find the corresponding uncached product to cache it
      const matchingProduct = uncachedProducts.find(p => p.id === report.id);
      if (matchingProduct) {
        const key = fingerprintProduct(matchingProduct);
        scoreCache.set(key, { cachedAt: now(), value: report });
      }
      results.push({ ...report, cached: false });
    }
  }

  return results;
}

// Check Ollama health
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

chrome.action.onClicked.addListener((tab) => {
  if (tab.id) {
    console.log("[GreenNova BG] Action clicked. Messaging tab:", tab.id);
    chrome.tabs.sendMessage(tab.id, { type: "GREENNOVA_ACTIVATE_BATCH_SCORE" }, (resp) => {
      if (chrome.runtime.lastError) {
        console.warn("[GreenNova BG] Could not message tab:", chrome.runtime.lastError.message);
      }
    });
  }
});

function buildDeepPrompt(product, detailsText) {
  return [
    "You are a strict environmental analyst.",
    "Analyze the product SOLELY based on its ecological footprint, sustainability, and environmental impact considering the materials provided.",
    "DO NOT include general product pros/cons. Every positive_impact, negative_impact, and recommendation MUST be strictly about the Earth, emissions, recyclability, toxins, or eco-materials.",
    "Return strict JSON which MUST be an array containing EXACTLY ONE object.",
    "The object must have this exact shape:",
    '{"id": number, "score": number, "grade": "A|B|C|D|E", "summary": string, "positive_impacts": string[], "negative_impacts": string[], "how_it_affects_environment": string, "confidence": number, "recommendations": string[]}',
    "Score rules: 0 worst, 100 best.",
    "Grade mapping: A=80-100, B=65-79, C=50-64, D=35-49, E=0-34.",
    "Be highly critical and factual based on the materials provided. EXACT JSON ONLY.",
    "Product Base Info:",
    JSON.stringify(product),
    "Extracted Materials & Specs:",
    detailsText ? detailsText.substring(0, 4000) : "None"
  ].join("\n");
}

async function scoreDeepProduct(product, detailsText) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 180000); 

  try {
    const response = await fetch(OLLAMA_ENDPOINT, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        model: MODEL_NAME,
        prompt: buildDeepPrompt(product, detailsText),
        stream: false,
        options: { temperature: 0.2, num_predict: 4096, num_ctx: 16384 }
      }),
      signal: controller.signal
    });

    if (!response.ok) throw new Error("Ollama HTTP " + response.status);
    const data = await response.json();
    const parsed = parseModelBatchResponse(data.response);
    if (parsed && parsed.length > 0) {
       parsed[0].id = product.id;
       return parsed[0];
    }
    throw new Error("Empty response");
  } catch(err) {
    throw err;
  } finally {
    clearTimeout(timeout);
  }
}

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (!message || !message.type) {
    return;
  }

  if (message.type === "GREENNOVA_DEEP_SCORE") {
    scoreDeepProduct(message.payload.product, message.payload.detailsText)
      .then((report) => sendResponse({ ok: true, report }))
      .catch((err) => sendResponse({ ok: false, message: err.message }));
    return true;
  }

  if (message.type === "GREENNOVA_BATCH_SCORE") {
    scoreBatch(message.payload)
      .then((reports) => {
        sendResponse({ ok: true, reports });
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
    return true; // Keep channel open for async
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
