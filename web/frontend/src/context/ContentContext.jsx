/**
 * ContentContext — Global AI content provider
 * Pre-fetches critical UI text on app load and makes it available to all components.
 */

import { createContext, useContext, useEffect, useState, useCallback } from "react";
import { prefetchUIText } from "../services/aiContentService";

const ContentContext = createContext(null);

// Sections to pre-fetch on app load
const CRITICAL_SECTIONS = [
  "navbar",
  "home",
  "search",
  "footer",
  "report",
  "calculator",
  "history",
  "profile",
  "ingredients",
  "alternatives",
  "chart",
];

export function ContentProvider({ children }) {
  const [content, setContent] = useState({});
  const [isLoading, setIsLoading] = useState(true);

  const refreshContent = useCallback(async () => {
    setIsLoading(true);
    try {
      const data = await prefetchUIText(CRITICAL_SECTIONS);
      setContent(data);
    } catch (err) {
      console.warn("Content prefetch failed:", err);
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    refreshContent();
  }, [refreshContent]);

  /**
   * Get text for a section with fallback.
   * @param {string} section - Section name
   * @param {string} key - Text key within the section
   * @param {string} fallback - Fallback text if AI text unavailable
   * @returns {string}
   */
  const getText = useCallback(
    (section, key, fallback = "") => {
      return content[section]?.[key] ?? fallback;
    },
    [content]
  );

  return (
    <ContentContext.Provider
      value={{ content, isLoading, refreshContent, getText }}
    >
      {children}
    </ContentContext.Provider>
  );
}

export function useContent() {
  const ctx = useContext(ContentContext);
  if (!ctx)
    throw new Error("useContent must be used within <ContentProvider>");
  return ctx;
}
