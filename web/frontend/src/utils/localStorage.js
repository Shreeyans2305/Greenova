// ===== LocalStorage Utility for GreenNova =====

const HISTORY_KEY = "green_nova_history";
const BADGES_KEY = "green_nova_badges";

// --- History ---
export function getHistory() {
  try {
    const data = localStorage.getItem(HISTORY_KEY);
    return data ? JSON.parse(data) : [];
  } catch {
    return [];
  }
}

export function addToHistory(entry) {
  const history = getHistory();
  const newEntry = {
    ...entry,
    id: `h_${Date.now()}`,
    date: new Date().toISOString().split("T")[0],
  };
  history.unshift(newEntry);
  localStorage.setItem(HISTORY_KEY, JSON.stringify(history));
  return newEntry;
}

export function clearHistory() {
  localStorage.removeItem(HISTORY_KEY);
}

// --- Badges ---
export function getBadges() {
  try {
    const data = localStorage.getItem(BADGES_KEY);
    return data ? JSON.parse(data) : [];
  } catch {
    return [];
  }
}

export function saveBadges(badges) {
  localStorage.setItem(BADGES_KEY, JSON.stringify(badges));
}

// --- Seed initial data if empty ---
export function seedInitialData(historyEntries, badges) {
  if (getHistory().length === 0 && historyEntries) {
    localStorage.setItem(HISTORY_KEY, JSON.stringify(historyEntries));
  }
  if (getBadges().length === 0 && badges) {
    localStorage.setItem(BADGES_KEY, JSON.stringify(badges));
  }
}
