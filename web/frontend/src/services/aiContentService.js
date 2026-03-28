/**
 * EcoTrack - AI Content Service
 * Handles fetching, caching, and serving AI-generated UI text.
 * Uses localStorage for persistence and provides fallback defaults.
 */

import { fetchUIText } from "./api";

const CACHE_PREFIX = "gn_ai_text_";
const CACHE_TTL = 60 * 60 * 1000; // 1 hour in milliseconds

// ---------- LocalStorage Cache ----------

function getCached(section) {
  try {
    const raw = localStorage.getItem(`${CACHE_PREFIX}${section}`);
    if (!raw) return null;
    const { content, timestamp } = JSON.parse(raw);
    if (Date.now() - timestamp > CACHE_TTL) {
      localStorage.removeItem(`${CACHE_PREFIX}${section}`);
      return null;
    }
    return content;
  } catch {
    return null;
  }
}

function setCached(section, content) {
  try {
    localStorage.setItem(
      `${CACHE_PREFIX}${section}`,
      JSON.stringify({ content, timestamp: Date.now() })
    );
  } catch {
    // localStorage full or unavailable — ignore
  }
}

// ---------- Public API ----------

/**
 * Get AI-generated UI text for a section.
 * Priority: localStorage cache → backend API → fallback defaults.
 * @param {string} section - UI section name (e.g., "home", "navbar", "search")
 * @returns {Promise<object>} The text content dict for the section
 */
export async function getUIText(section) {
  // 1. Check localStorage cache
  const cached = getCached(section);
  if (cached) return cached;

  // 2. Fetch from backend
  try {
    const response = await fetchUIText(section);
    if (response && response.content) {
      setCached(section, response.content);
      return response.content;
    }
  } catch {
    // Network error — fall through to fallback
  }

  // 3. Return null — let caller use inline defaults
  return null;
}

/**
 * Pre-fetch multiple sections for the app.
 * Called on app load to warm the cache.
 * @param {string[]} sections - Array of section names to prefetch
 * @returns {Promise<object>} Map of section → content
 */
export async function prefetchUIText(sections) {
  const results = {};
  const promises = sections.map(async (section) => {
    const content = await getUIText(section);
    if (content) results[section] = content;
  });
  await Promise.allSettled(promises);
  return results;
}

/**
 * Clear all cached AI text from localStorage.
 */
export function clearUITextCache() {
  const keys = [];
  for (let i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i);
    if (key && key.startsWith(CACHE_PREFIX)) {
      keys.push(key);
    }
  }
  keys.forEach((k) => localStorage.removeItem(k));
}
