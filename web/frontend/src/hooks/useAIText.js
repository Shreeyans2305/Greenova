/**
 * useAIText — Hook for AI-generated UI text
 * Uses ContentContext for pre-fetched text, with inline fallback defaults.
 *
 * Usage:
 *   const t = useAIText("home");
 *   <h1>{t("hero_title_1", "Know Your Impact.")}</h1>
 */

import { useContent } from "../context/ContentContext";
import { useCallback } from "react";

export default function useAIText(section) {
  const { content, isLoading } = useContent();

  /**
   * Get text for a key, with fallback.
   * @param {string} key - Text key within the section
   * @param {string} fallback - Fallback text if AI text unavailable
   * @returns {string}
   */
  const t = useCallback(
    (key, fallback = "") => {
      return content[section]?.[key] ?? fallback;
    },
    [content, section]
  );

  return t;
}
