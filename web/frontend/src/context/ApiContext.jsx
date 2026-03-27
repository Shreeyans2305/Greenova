/**
 * ApiContext — Global backend health/status provider
 * Polls /health every 15 seconds so the entire app knows if the backend + Ollama are online.
 */

import { createContext, useContext, useEffect, useState, useCallback } from "react";
import { healthCheck } from "../services/api";

const ApiContext = createContext(null);

export function ApiProvider({ children }) {
  const [backend, setBackend] = useState({
    status: "checking", // "ok" | "offline" | "mock" | "checking"
    mock_mode: false,
    model: "...",
    ollama_url: "...",
  });

  const refresh = useCallback(async () => {
    const data = await healthCheck();
    setBackend(data);
  }, []);

  useEffect(() => {
    refresh(); // initial check
    const id = setInterval(refresh, 15000); // poll every 15s
    return () => clearInterval(id);
  }, [refresh]);

  return (
    <ApiContext.Provider value={{ backend, refreshHealth: refresh }}>
      {children}
    </ApiContext.Provider>
  );
}

export function useApi() {
  const ctx = useContext(ApiContext);
  if (!ctx) throw new Error("useApi must be used within <ApiProvider>");
  return ctx;
}
