// ===== Badge Definitions and Earning Logic =====

export const BADGE_DEFINITIONS = [
  {
    id: "green_starter",
    name: "Green Starter",
    icon: "🌿",
    description: "Analyzed your first product",
    emoji: "🌿",
    check: (stats) => stats.totalAnalyzed >= 1,
    progress: (stats) => Math.min(stats.totalAnalyzed / 1 * 100, 100),
  },
  {
    id: "eco_curious",
    name: "Eco Curious",
    icon: "🔍",
    emoji: "🔍",
    description: "Analyzed 5 products",
    check: (stats) => stats.totalAnalyzed >= 5,
    progress: (stats) => Math.min(stats.totalAnalyzed / 5 * 100, 100),
  },
  {
    id: "eco_explorer",
    name: "Eco Explorer",
    icon: "🧭",
    emoji: "🧭",
    description: "Analyzed 10 products",
    check: (stats) => stats.totalAnalyzed >= 10,
    progress: (stats) => Math.min(stats.totalAnalyzed / 10 * 100, 100),
  },
  {
    id: "sustainability_sage",
    name: "Sustainability Sage",
    icon: "🧙",
    emoji: "🧙",
    description: "Analyzed 25 products",
    check: (stats) => stats.totalAnalyzed >= 25,
    progress: (stats) => Math.min(stats.totalAnalyzed / 25 * 100, 100),
  },
  {
    id: "eco_champion",
    name: "Eco Champion",
    icon: "🏆",
    emoji: "🏆",
    description: "Maintained 80+ average score",
    check: (stats) => stats.avgScore >= 80 && stats.totalAnalyzed >= 3,
    progress: (stats) => {
      if (stats.totalAnalyzed < 3) return (stats.totalAnalyzed / 3) * 50;
      return Math.min(stats.avgScore / 80 * 100, 100);
    },
  },
  {
    id: "planet_protector",
    name: "Planet Protector",
    icon: "🌍",
    emoji: "🌍",
    description: "Added 10 products to history",
    check: (stats) => stats.totalHistory >= 10,
    progress: (stats) => Math.min(stats.totalHistory / 10 * 100, 100),
  },
  {
    id: "green_guru",
    name: "Green Guru",
    icon: "🌟",
    emoji: "🌟",
    description: "Average score above 85",
    check: (stats) => stats.avgScore >= 85 && stats.totalAnalyzed >= 5,
    progress: (stats) => {
      if (stats.totalAnalyzed < 5) return (stats.totalAnalyzed / 5) * 50;
      return Math.min(stats.avgScore / 85 * 100, 100);
    },
  },
  {
    id: "eco_warrior",
    name: "Eco Warrior",
    icon: "⚔️",
    emoji: "⚔️",
    description: "All recent 5 products scored 75+",
    check: (stats) => stats.recentAllGreen,
    progress: (stats) => {
      if (stats.recentScores.length === 0) return 0;
      const greenCount = stats.recentScores.filter(s => s >= 75).length;
      return (greenCount / Math.max(stats.recentScores.length, 5)) * 100;
    },
  },
  {
    id: "zero_waste_hero",
    name: "Zero Waste Hero",
    icon: "♻️",
    emoji: "♻️",
    description: "10 products with 85+ score",
    check: (stats) => stats.greenProducts >= 10,
    progress: (stats) => Math.min(stats.greenProducts / 10 * 100, 100),
  },
  {
    id: "carbon_cutter",
    name: "Carbon Cutter",
    icon: "✂️",
    emoji: "✂️",
    description: "50% of products scored 80+",
    check: (stats) => stats.totalAnalyzed >= 10 && stats.greenPercentage >= 50,
    progress: (stats) => {
      if (stats.totalAnalyzed < 10) return (stats.totalAnalyzed / 10) * 50;
      return Math.min(stats.greenPercentage / 50 * 100, 100);
    },
  },
];

// ===== Calculate User Stats =====

export function calculateUserStats() {
  const history = getHistory();
  
  const totalAnalyzed = history.length;
  const totalHistory = history.length;
  
  const scores = history.map(h => h.score || 0);
  const avgScore = totalAnalyzed > 0 
    ? Math.round(scores.reduce((a, b) => a + b, 0) / totalAnalyzed) 
    : 0;
  
  const recentScores = scores.slice(0, 5);
  const recentAllGreen = recentScores.length >= 5 && recentScores.every(s => s >= 75);
  
  const greenProducts = scores.filter(s => s >= 85).length;
  const greenPercentage = totalAnalyzed > 0 ? (greenProducts / totalAnalyzed) * 100 : 0;
  
  const lowImpactProducts = scores.filter(s => s < 50).length;
  const highImpactProducts = scores.filter(s => s >= 75).length;
  
  return {
    totalAnalyzed,
    totalHistory,
    avgScore,
    recentScores,
    recentAllGreen,
    greenProducts,
    greenPercentage,
    lowImpactProducts,
    highImpactProducts,
    scores,
  };
}

// ===== Check and Award Badges =====

export function checkAndAwardBadges() {
  const stats = calculateUserStats();
  const earnedBadges = getEarnedBadges();
  const earnedIds = new Set(earnedBadges.map(b => b.id));
  
  const newlyEarned = [];
  
  for (const def of BADGE_DEFINITIONS) {
    if (!earnedIds.has(def.id) && def.check(stats)) {
      const badge = {
        id: def.id,
        name: def.name,
        icon: def.emoji,
        description: def.description,
        earned: true,
        earnedDate: new Date().toISOString().split("T")[0],
        progress: 100,
      };
      earnedBadges.push(badge);
      newlyEarned.push(badge);
    }
  }
  
  if (earnedBadges.length > 0) {
    saveEarnedBadges(earnedBadges);
  }
  
  return { earnedBadges, newlyEarned, stats };
}

// ===== Get All Badges with Progress =====

export function getAllBadgesWithProgress() {
  const earnedBadges = getEarnedBadges();
  const earnedMap = new Map(earnedBadges.map(b => [b.id, b]));
  const stats = calculateUserStats();
  
  return BADGE_DEFINITIONS.map(def => {
    const earned = earnedMap.get(def.id);
    if (earned) {
      return { ...def, ...earned };
    }
    return {
      ...def,
      earned: false,
      earnedDate: null,
      progress: def.progress(stats),
    };
  });
}

// ===== LocalStorage Helpers =====

const EARNED_BADGES_KEY = "greennova_earned_badges";

function getEarnedBadges() {
  try {
    const data = localStorage.getItem(EARNED_BADGES_KEY);
    return data ? JSON.parse(data) : [];
  } catch {
    return [];
  }
}

function saveEarnedBadges(badges) {
  localStorage.setItem(EARNED_BADGES_KEY, JSON.stringify(badges));
}

function getHistory() {
  try {
    const data = localStorage.getItem("green_nova_history");
    return data ? JSON.parse(data) : [];
  } catch {
    return [];
  }
}

// ===== Get Stats for Display =====

export function getUserStatsDisplay() {
  const stats = calculateUserStats();
  const badges = getAllBadgesWithProgress();
  const earnedCount = badges.filter(b => b.earned).length;
  
  return {
    ...stats,
    earnedBadges: earnedCount,
    totalBadges: badges.length,
  };
}

// ===== Check for New Badges After Analysis =====

export function onProductAnalyzed() {
  return checkAndAwardBadges();
}

// ===== Reset All Badges (for testing) =====

export function resetAllBadges() {
  localStorage.removeItem(EARNED_BADGES_KEY);
}
