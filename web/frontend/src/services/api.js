/**
 * GreenNova - API Service
 * Connects the React frontend to the FastAPI backend (Ollama + Gemma 3).
 */

const API_BASE = "http://localhost:8000";

async function apiFetch(path, options = {}) {
  const timeout = options.timeout || 60000;
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeout);

  try {
    const res = await fetch(`${API_BASE}${path}`, {
      ...options,
      signal: controller.signal,
      headers: {
        "Content-Type": "application/json",
        ...(options.headers || {}),
      },
    });

    if (!res.ok) {
      const err = await res.json().catch(() => ({ detail: `HTTP ${res.status}` }));
      throw new Error(err.detail || `Request failed (${res.status})`);
    }

    return await res.json();
  } finally {
    clearTimeout(timer);
  }
}

/**
 * POST /api/analyze — Analyze a product's sustainability
 */
export async function analyzeProduct({ text, image_b64, barcode } = {}) {
  return await apiFetch("/api/analyze", {
    method: "POST",
    body: JSON.stringify({ text, image_b64, barcode }),
  });
}

/**
 * POST /api/search — Search products with sustainability scores
 */
export async function searchProducts(query) {
  return await apiFetch("/api/search", {
    method: "POST",
    body: JSON.stringify({ query }),
  });
}

/**
 * GET /health — Check if backend is reachable
 */
export async function healthCheck() {
  try {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 5000);

    const res = await fetch(`${API_BASE}/health`, { signal: controller.signal });
    clearTimeout(timeout);

    if (!res.ok) throw new Error("Backend unreachable");
    return await res.json();
  } catch {
    return { status: "offline", model: "N/A", ollama_url: "N/A" };
  }
}

/**
 * Convert a File object to base64 for image upload
 */
export function fileToBase64(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = () => {
      const base64 = reader.result.split(",")[1];
      resolve(base64);
    };
    reader.onerror = (err) => reject(err);
  });
}

/**
 * GET /api/ui-text?section=... — Fetch AI-generated UI strings
 */
export async function fetchUIText(section) {
  try {
    return await apiFetch(`/api/ui-text?section=${encodeURIComponent(section)}`, {
      timeout: 15000,
    });
  } catch (err) {
    console.warn(`UI text fetch failed:`, err.message);
    return null;
  }
}

/**
 * POST /api/calculator/score — AI-powered calculator scoring
 */
export async function fetchCalculatorScore(answers, totalCO2) {
  try {
    return await apiFetch("/api/calculator/score", {
      method: "POST",
      body: JSON.stringify({ answers, total_co2: totalCO2 }),
      timeout: 30000,
    });
  } catch (err) {
    console.warn("Calculator score failed:", err.message);
    return null;
  }
}

/**
 * POST /api/content/generate — Generic AI content generation
 */
export async function generateContent(contentType, context = "") {
  try {
    return await apiFetch("/api/content/generate", {
      method: "POST",
      body: JSON.stringify({ content_type: contentType, context }),
      timeout: 15000,
    });
  } catch (err) {
    console.warn("Content generation failed:", err.message);
    return null;
  }
}

/**
 * POST /api/compare — Compare two products for sustainability
 */
export async function compareProducts({ product1, product2, product1_data, product2_data } = {}) {
  return await apiFetch("/api/compare", {
    method: "POST",
    body: JSON.stringify({
      product1: product1 || "",
      product2: product2 || "",
      product1_data: product1_data || null,
      product2_data: product2_data || null,
    }),
    timeout: 90000,
  });
}

export { API_BASE };
