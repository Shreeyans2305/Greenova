// ===== GreenNova Mock Data =====
// All hardcoded data for the frontend demo

export const mockProducts = [
  {
    id: "1",
    name: "EcoClean All-Purpose Cleaner",
    brand: "GreenLife Co.",
    category: "Household",
    score: 87,
    tier: "GREEN",
    badge: "Eco Champion 🌱",
    carbonFootprint: "Low",
    description: "A plant-based cleaner with biodegradable ingredients and recyclable packaging.",
    ingredients: [
      { name: "Water (Aqua)", sustainability: "High", impact: "Very Low", score: 95 },
      { name: "Sodium Lauryl Sulfate", sustainability: "Medium", impact: "Moderate", score: 55 },
      { name: "Citric Acid", sustainability: "High", impact: "Low", score: 88 },
      { name: "Essential Oil Blend", sustainability: "High", impact: "Low", score: 92 },
      { name: "Sodium Chloride", sustainability: "High", impact: "Very Low", score: 96 },
    ],
    alternatives: [
      { name: "PureNature Spray", score: 94, price: "$8.99", reason: "Uses 100% organic ingredients" },
      { name: "EarthFirst Cleaner", score: 91, price: "$7.49", reason: "Carbon-neutral manufacturing" },
      { name: "BioWash Concentrate", score: 89, price: "$6.99", reason: "Zero-waste packaging" },
    ],
  },
  {
    id: "2",
    name: "QuickShine Floor Polish",
    brand: "SparkleHome",
    category: "Household",
    score: 42,
    tier: "RED",
    badge: null,
    carbonFootprint: "High",
    description: "Contains petroleum-based solvents and non-recyclable aerosol packaging.",
    ingredients: [
      { name: "Petroleum Distillates", sustainability: "Low", impact: "High", score: 15 },
      { name: "Silicone Emulsion", sustainability: "Low", impact: "High", score: 22 },
      { name: "Propane (Propellant)", sustainability: "Low", impact: "High", score: 18 },
      { name: "Fragrance (Synthetic)", sustainability: "Low", impact: "Moderate", score: 30 },
      { name: "Water", sustainability: "High", impact: "Very Low", score: 96 },
    ],
    alternatives: [
      { name: "EcoShine Natural Polish", score: 82, price: "$9.99", reason: "Plant-based formula" },
      { name: "GreenGlow Floor Care", score: 78, price: "$8.49", reason: "Refillable container" },
    ],
  },
  {
    id: "3",
    name: "FreshBreeze Shampoo",
    brand: "NaturaCare",
    category: "Personal Care",
    score: 71,
    tier: "AMBER",
    badge: "Getting Greener 🌿",
    carbonFootprint: "Medium",
    description: "Partially organic formula with some synthetic preservatives.",
    ingredients: [
      { name: "Water (Aqua)", sustainability: "High", impact: "Very Low", score: 95 },
      { name: "Cocamidopropyl Betaine", sustainability: "Medium", impact: "Low", score: 68 },
      { name: "Sodium Benzoate", sustainability: "Medium", impact: "Moderate", score: 52 },
      { name: "Aloe Vera Extract", sustainability: "High", impact: "Low", score: 90 },
      { name: "Methylparaben", sustainability: "Low", impact: "Moderate", score: 35 },
    ],
    alternatives: [
      { name: "PureLeaf Shampoo Bar", score: 93, price: "$11.99", reason: "Zero plastic, all natural" },
      { name: "Herbiva Liquid Shampoo", score: 85, price: "$9.49", reason: "Certified organic" },
    ],
  },
  {
    id: "4",
    name: "SunGlow Organic Sunscreen",
    brand: "EcoDerm",
    category: "Personal Care",
    score: 92,
    tier: "GREEN",
    badge: "Planet Protector 🌍",
    carbonFootprint: "Very Low",
    description: "Reef-safe, mineral-based sunscreen with recycled ocean plastic packaging.",
    ingredients: [
      { name: "Zinc Oxide", sustainability: "High", impact: "Very Low", score: 94 },
      { name: "Coconut Oil", sustainability: "High", impact: "Low", score: 88 },
      { name: "Shea Butter", sustainability: "High", impact: "Low", score: 90 },
      { name: "Vitamin E", sustainability: "High", impact: "Very Low", score: 95 },
    ],
    alternatives: [],
  },
  {
    id: "5",
    name: "PowerMax Energy Drink",
    brand: "TurboFuel",
    category: "Food & Beverage",
    score: 28,
    tier: "RED",
    badge: null,
    carbonFootprint: "Very High",
    description: "Single-use aluminum can with synthetic ingredients and high carbon supply chain.",
    ingredients: [
      { name: "Carbonated Water", sustainability: "Medium", impact: "Low", score: 70 },
      { name: "High Fructose Corn Syrup", sustainability: "Low", impact: "High", score: 20 },
      { name: "Taurine (Synthetic)", sustainability: "Low", impact: "Moderate", score: 35 },
      { name: "Artificial Colors", sustainability: "Low", impact: "High", score: 15 },
      { name: "Caffeine (Synthetic)", sustainability: "Medium", impact: "Moderate", score: 45 },
    ],
    alternatives: [
      { name: "GreenBoost Organic Tea", score: 91, price: "$3.99", reason: "Organic, compostable packaging" },
      { name: "VitaFlow Electrolyte Water", score: 85, price: "$2.49", reason: "Recyclable bottle, natural" },
      { name: "EcoEnergy Sparkling", score: 79, price: "$4.49", reason: "Carbon offset program" },
    ],
  },
];

export const mockHistoryEntries = [
  { id: "h1", productName: "EcoClean All-Purpose Cleaner", category: "Household", score: 87, date: "2024-03-15", quantity: 1 },
  { id: "h2", productName: "QuickShine Floor Polish", category: "Household", score: 42, date: "2024-03-14", quantity: 1 },
  { id: "h3", productName: "FreshBreeze Shampoo", category: "Personal Care", score: 71, date: "2024-03-12", quantity: 2 },
  { id: "h4", productName: "SunGlow Organic Sunscreen", category: "Personal Care", score: 92, date: "2024-03-10", quantity: 1 },
  { id: "h5", productName: "PowerMax Energy Drink", category: "Food & Beverage", score: 28, date: "2024-03-08", quantity: 3 },
  { id: "h6", productName: "PureLeaf Shampoo Bar", category: "Personal Care", score: 93, date: "2024-03-05", quantity: 1 },
  { id: "h7", productName: "GreenBoost Organic Tea", category: "Food & Beverage", score: 91, date: "2024-03-03", quantity: 2 },
  { id: "h8", productName: "BioWash Concentrate", category: "Household", score: 89, date: "2024-03-01", quantity: 1 },
];

export const mockWeeklyTrend = [
  { week: "Week 1", score: 62, purchases: 4 },
  { week: "Week 2", score: 71, purchases: 3 },
  { week: "Week 3", score: 68, purchases: 5 },
  { week: "Week 4", score: 78, purchases: 3 },
  { week: "Week 5", score: 74, purchases: 4 },
  { week: "Week 6", score: 82, purchases: 2 },
  { week: "Week 7", score: 85, purchases: 3 },
  { week: "Week 8", score: 79, purchases: 4 },
];

export const mockCategoryBreakdown = [
  { category: "Household", avgScore: 73, count: 3, color: "#10b981" },
  { category: "Personal Care", avgScore: 85, count: 4, color: "#06b6d4" },
  { category: "Food & Beverage", avgScore: 60, count: 5, color: "#f59e0b" },
];

export const mockBadges = [
  { id: "b1", name: "Eco Champion", icon: "🌱", description: "Maintained 80+ avg score for a month", earned: true, earnedDate: "2024-03-01" },
  { id: "b2", name: "Planet Protector", icon: "🌍", description: "Chose eco alternatives 10+ times", earned: true, earnedDate: "2024-02-15" },
  { id: "b3", name: "Green Starter", icon: "🌿", description: "Analyzed your first product", earned: true, earnedDate: "2024-01-20" },
  { id: "b4", name: "Zero Waste Hero", icon: "♻️", description: "All purchases scored 85+ for 2 weeks", earned: false, earnedDate: null },
  { id: "b5", name: "Carbon Cutter", icon: "✂️", description: "Reduced footprint by 20% in a month", earned: false, earnedDate: null },
  { id: "b6", name: "Sustainability Sage", icon: "🧙", description: "Analyzed 50+ products", earned: false, earnedDate: null },
];

export const mockRecentSearches = [
  "Organic shampoo",
  "Eco-friendly detergent",
  "Bamboo toothbrush",
  "Natural deodorant",
];

export function getTierColor(tier) {
  switch (tier) {
    case "GREEN": return { text: "#10b981", bg: "rgba(16, 185, 129, 0.15)", border: "rgba(16, 185, 129, 0.3)" };
    case "AMBER": return { text: "#f59e0b", bg: "rgba(245, 158, 11, 0.15)", border: "rgba(245, 158, 11, 0.3)" };
    case "RED": return { text: "#ef4444", bg: "rgba(239, 68, 68, 0.15)", border: "rgba(239, 68, 68, 0.3)" };
    default: return { text: "#94a3b8", bg: "rgba(148, 163, 184, 0.15)", border: "rgba(148, 163, 184, 0.3)" };
  }
}

export function getTierLabel(score) {
  if (score >= 75) return "GREEN";
  if (score >= 50) return "AMBER";
  return "RED";
}
