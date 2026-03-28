/**
 * useCalculatorInsights — Hook for AI-powered calculator scoring/insights
 * Calls the backend /api/calculator/score endpoint and returns results.
 */

import { useState, useCallback } from "react";
import { fetchCalculatorScore } from "../services/api";

export default function useCalculatorInsights() {
  const [insights, setInsights] = useState(null);
  const [isLoading, setIsLoading] = useState(false);

  /**
   * Fetch AI-generated insights for calculator results.
   * @param {object} answers - User answers keyed by step index
   * @param {number} totalCO2 - Calculated total CO2 in tons
   * @returns {Promise<object|null>} AI insights or null
   */
  const fetchInsights = useCallback(async (answers, totalCO2) => {
    setIsLoading(true);
    try {
      const result = await fetchCalculatorScore(answers, totalCO2);
      setInsights(result);
      return result;
    } catch (err) {
      console.warn("Calculator insights fetch failed:", err);
      return null;
    } finally {
      setIsLoading(false);
    }
  }, []);

  const reset = useCallback(() => {
    setInsights(null);
  }, []);

  return { insights, isLoading, fetchInsights, reset };
}
