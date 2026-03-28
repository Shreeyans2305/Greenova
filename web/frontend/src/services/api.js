/**
 * EcoTrack - API Service
 * Connects the React frontend to the FastAPI backend (Ollama + Gemma 3).
 *
 * Flow:
 *   1. Try calling the real backend API.
 *   2. If the backend is unreachable or errors, fall back to local mock data.
 *   3. Expose a healthCheck() poller so the UI can show backend status.
 */

import { mockProducts, mockRecentSearches } from "../data/mockData";

const API_BASE = import.meta.env.VITE_API_BASE_URL || "http://localhost:8000";
const FORCE_MOCK = import.meta.env.VITE_MOCK_MODE === "true";

// ---------- Helpers ----------

async function apiFetch(path, options = {}) {
  const timeout = options.timeout || 30000;
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

// ---------- Mock fallbacks ----------

function mockAnalyze(text) {
  const lower = (text || "").toLowerCase();

  const matched = mockProducts.find(
    (p) =>
      lower.includes(p.name.toLowerCase()) ||
      lower.includes(p.brand?.toLowerCase()) ||
      lower.includes(p.category?.toLowerCase()) ||
      p.name.toLowerCase().includes(lower)
  );

  const product = matched || mockProducts[0];

  return {
    product_name: product.name,
    brand: product.brand,
    category: product.category,
    score: product.score,
    tier: product.tier,
    badge: product.badge,
    carbon_footprint: product.carbonFootprint,
    description: product.description,
    ingredients_analysis: (product.ingredients || []).map((ing) => ({
      name: ing.name,
      sustainability: ing.sustainability,
      impact: ing.impact,
      score: ing.score,
    })),
    alternatives: (product.alternatives || []).map((alt) => ({
      name: alt.name,
      score: alt.score,
      price: alt.price,
      reason: alt.reason,
    })),
  };
}

function mockSearch(query) {
  const lower = (query || "").toLowerCase();
  const filtered = mockProducts.filter(
    (p) =>
      p.name.toLowerCase().includes(lower) ||
      (p.brand || "").toLowerCase().includes(lower) ||
      (p.category || "").toLowerCase().includes(lower)
  );

  const results = (filtered.length ? filtered : mockProducts).map((p) => ({
    id: p.id,
    name: p.name,
    brand: p.brand,
    category: p.category,
    score: p.score,
    tier: p.tier,
    badge: p.badge,
    carbon_footprint: p.carbonFootprint,
    description: p.description,
  }));

  return { type: "GENERALIZED", results };
}

// ---------- Public API (existing) ----------

/**
 * POST /api/analyze — Analyze a product's sustainability
 */
export async function analyzeProduct({ text, image_b64, barcode } = {}) {
  if (FORCE_MOCK) {
    return mockAnalyze(text);
  }

  try {
    return await apiFetch("/api/analyze", {
      method: "POST",
      body: JSON.stringify({ text, image_b64, barcode }),
    });
  } catch (err) {
    console.warn("Backend analyze failed, using mock:", err.message);
    return mockAnalyze(text);
  }
}

/**
 * POST /api/search — Search products with sustainability scores
 */
export async function searchProducts(query) {
  if (FORCE_MOCK) {
    return mockSearch(query);
  }

  try {
    return await apiFetch("/api/search", {
      method: "POST",
      body: JSON.stringify({ query }),
    });
  } catch (err) {
    console.warn("Backend search failed, using mock:", err.message);
    return mockSearch(query);
  }
}

/**
 * GET /health — Check if backend + Ollama are reachable
 */
export async function healthCheck() {
  if (FORCE_MOCK) {
    return { status: "mock", mock_mode: true, model: "mock", ollama_url: "N/A" };
  }

  try {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 5000);

    const res = await fetch(`${API_BASE}/health`, { signal: controller.signal });
    clearTimeout(timeout);

    if (!res.ok) throw new Error("Backend unreachable");
    return await res.json();
  } catch {
    return { status: "offline", mock_mode: true, model: "N/A", ollama_url: "N/A" };
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

// ---------- New AI Content Endpoints ----------

/**
 * GET /api/ui-text?section=... — Fetch AI-generated UI strings
 * Falls back to null if backend is unreachable (caller uses defaults).
 */
export async function fetchUIText(section) {
  if (FORCE_MOCK) return null;

  try {
    return await apiFetch(`/api/ui-text?section=${encodeURIComponent(section)}`, {
      timeout: 10000,
    });
  } catch (err) {
    console.warn(`UI text fetch failed for section "${section}":`, err.message);
    return null;
  }
}

/**
 * POST /api/calculator/score — AI-powered calculator scoring
 */
export async function fetchCalculatorScore(answers, totalCO2) {
  if (FORCE_MOCK) return null;

  try {
    return await apiFetch("/api/calculator/score", {
      method: "POST",
      body: JSON.stringify({ answers, total_co2: totalCO2 }),
      timeout: 15000,
    });
  } catch (err) {
    console.warn("Calculator score fetch failed:", err.message);
    return null;
  }
}

/**
 * POST /api/content/generate — Generic AI content generation
 */
export async function generateContent(contentType, context = "") {
  if (FORCE_MOCK) return null;

  try {
    return await apiFetch("/api/content/generate", {
      method: "POST",
      body: JSON.stringify({ content_type: contentType, context }),
      timeout: 10000,
    });
  } catch (err) {
    console.warn("Content generation failed:", err.message);
    return null;
  }
}

export { API_BASE, FORCE_MOCK as MOCK_MODE };
