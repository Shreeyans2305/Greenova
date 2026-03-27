"""
GreenNova Backend - Mock Data
Hardcoded responses returned when MOCK_MODE is enabled.
These mirror the frontend mockData.js structure for consistency.
"""

from models import (
    SustainabilityReport,
    IngredientAnalysis,
    Alternative,
    SearchResultItem,
    SearchResponse,
)


# ===== Mock Analyze Responses =====

MOCK_REPORTS = {
    "default": SustainabilityReport(
        product_name="EcoClean All-Purpose Cleaner",
        brand="GreenLife Co.",
        category="Household",
        score=87,
        tier="GREEN",
        badge="Eco Champion 🌱",
        carbon_footprint="Low",
        description="A plant-based cleaner with biodegradable ingredients and recyclable packaging.",
        ingredients_analysis=[
            IngredientAnalysis(name="Water (Aqua)", sustainability="High", impact="Very Low", score=95),
            IngredientAnalysis(name="Sodium Lauryl Sulfate", sustainability="Medium", impact="Moderate", score=55),
            IngredientAnalysis(name="Citric Acid", sustainability="High", impact="Low", score=88),
            IngredientAnalysis(name="Essential Oil Blend", sustainability="High", impact="Low", score=92),
            IngredientAnalysis(name="Sodium Chloride", sustainability="High", impact="Very Low", score=96),
        ],
        alternatives=[
            Alternative(name="PureNature Spray", score=94, price="$8.99", reason="Uses 100% organic ingredients"),
            Alternative(name="EarthFirst Cleaner", score=91, price="$7.49", reason="Carbon-neutral manufacturing"),
            Alternative(name="BioWash Concentrate", score=89, price="$6.99", reason="Zero-waste packaging"),
        ],
    ),
    "shampoo": SustainabilityReport(
        product_name="FreshBreeze Shampoo",
        brand="NaturaCare",
        category="Personal Care",
        score=71,
        tier="AMBER",
        badge="Getting Greener 🌿",
        carbon_footprint="Medium",
        description="Partially organic formula with some synthetic preservatives.",
        ingredients_analysis=[
            IngredientAnalysis(name="Water (Aqua)", sustainability="High", impact="Very Low", score=95),
            IngredientAnalysis(name="Cocamidopropyl Betaine", sustainability="Medium", impact="Low", score=68),
            IngredientAnalysis(name="Sodium Benzoate", sustainability="Medium", impact="Moderate", score=52),
            IngredientAnalysis(name="Aloe Vera Extract", sustainability="High", impact="Low", score=90),
            IngredientAnalysis(name="Methylparaben", sustainability="Low", impact="Moderate", score=35),
        ],
        alternatives=[
            Alternative(name="PureLeaf Shampoo Bar", score=93, price="$11.99", reason="Zero plastic, all natural"),
            Alternative(name="Herbiva Liquid Shampoo", score=85, price="$9.49", reason="Certified organic"),
        ],
    ),
    "energy_drink": SustainabilityReport(
        product_name="PowerMax Energy Drink",
        brand="TurboFuel",
        category="Food & Beverage",
        score=28,
        tier="RED",
        badge=None,
        carbon_footprint="Very High",
        description="Single-use aluminum can with synthetic ingredients and high carbon supply chain.",
        ingredients_analysis=[
            IngredientAnalysis(name="Carbonated Water", sustainability="Medium", impact="Low", score=70),
            IngredientAnalysis(name="High Fructose Corn Syrup", sustainability="Low", impact="High", score=20),
            IngredientAnalysis(name="Taurine (Synthetic)", sustainability="Low", impact="Moderate", score=35),
            IngredientAnalysis(name="Artificial Colors", sustainability="Low", impact="High", score=15),
            IngredientAnalysis(name="Caffeine (Synthetic)", sustainability="Medium", impact="Moderate", score=45),
        ],
        alternatives=[
            Alternative(name="GreenBoost Organic Tea", score=91, price="$3.99", reason="Organic, compostable packaging"),
            Alternative(name="VitaFlow Electrolyte Water", score=85, price="$2.49", reason="Recyclable bottle, natural"),
        ],
    ),
    "sunscreen": SustainabilityReport(
        product_name="SunGlow Organic Sunscreen",
        brand="EcoDerm",
        category="Personal Care",
        score=92,
        tier="GREEN",
        badge="Planet Protector 🌍",
        carbon_footprint="Very Low",
        description="Reef-safe, mineral-based sunscreen with recycled ocean plastic packaging.",
        ingredients_analysis=[
            IngredientAnalysis(name="Zinc Oxide", sustainability="High", impact="Very Low", score=94),
            IngredientAnalysis(name="Coconut Oil", sustainability="High", impact="Low", score=88),
            IngredientAnalysis(name="Shea Butter", sustainability="High", impact="Low", score=90),
            IngredientAnalysis(name="Vitamin E", sustainability="High", impact="Very Low", score=95),
        ],
        alternatives=[],
    ),
}


# ===== Mock Search Responses =====

MOCK_SEARCH_RESULTS = SearchResponse(
    type="GENERALIZED",
    results=[
        SearchResultItem(
            id="1",
            name="EcoClean All-Purpose Cleaner",
            brand="GreenLife Co.",
            category="Household",
            score=87,
            tier="GREEN",
            badge="Eco Champion 🌱",
            carbon_footprint="Low",
            description="A plant-based cleaner with biodegradable ingredients.",
        ),
        SearchResultItem(
            id="3",
            name="FreshBreeze Shampoo",
            brand="NaturaCare",
            category="Personal Care",
            score=71,
            tier="AMBER",
            badge="Getting Greener 🌿",
            carbon_footprint="Medium",
            description="Partially organic formula with some synthetic preservatives.",
        ),
        SearchResultItem(
            id="4",
            name="SunGlow Organic Sunscreen",
            brand="EcoDerm",
            category="Personal Care",
            score=92,
            tier="GREEN",
            badge="Planet Protector 🌍",
            carbon_footprint="Very Low",
            description="Reef-safe, mineral-based sunscreen with recycled packaging.",
        ),
    ],
)


def get_mock_report(text: str | None = None) -> SustainabilityReport:
    """Return a mock report. Tries to match keywords to specific mocks."""
    if text:
        lower = text.lower()
        if any(kw in lower for kw in ["shampoo", "hair", "conditioner"]):
            return MOCK_REPORTS["shampoo"]
        if any(kw in lower for kw in ["energy", "drink", "soda", "beverage"]):
            return MOCK_REPORTS["energy_drink"]
        if any(kw in lower for kw in ["sunscreen", "sun", "spf", "lotion"]):
            return MOCK_REPORTS["sunscreen"]
    return MOCK_REPORTS["default"]


def get_mock_search(query: str) -> SearchResponse:
    """Return mock search results, optionally filtered by query."""
    lower = query.lower()
    filtered = [
        r for r in MOCK_SEARCH_RESULTS.results
        if lower in r.name.lower()
        or lower in (r.category or "").lower()
        or lower in (r.brand or "").lower()
    ]
    if not filtered:
        filtered = MOCK_SEARCH_RESULTS.results  # fallback: return all
    return SearchResponse(type="GENERALIZED", results=filtered)
