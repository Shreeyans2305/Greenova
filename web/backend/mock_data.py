"""
GreenNova Backend - Mock / Fallback Data
Hardcoded responses used as fallbacks when Ollama is unavailable.
Also provides fallback UI text for all sections.
"""

from models import (
    SustainabilityReport,
    IngredientAnalysis,
    Alternative,
    SearchResultItem,
    SearchResponse,
    CalculatorScoreResponse,
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


# ===== Fallback UI Text =====

FALLBACK_UI_TEXT = {
    "navbar": {
        "brand": "GreenNova",
        "home": "Home",
        "calculator": "Calculator",
        "history": "History",
        "badges": "Badges",
        "status_live": "Gemma 3 · Live",
        "status_mock": "Backend Mock",
        "status_offline": "Offline · Mock",
        "status_connecting": "Connecting…",
    },
    "home": {
        "badge_label": "AI-Powered Sustainability",
        "hero_title_1": "Know Your Impact.",
        "hero_title_2": "Choose Better.",
        "hero_subtitle": "Paste ingredients, scan barcodes, or upload product labels — get instant sustainability reports powered by AI.",
        "stat_products": "Products Analyzed",
        "stat_score": "Avg Eco Score",
        "stat_alternatives": "Alternatives Found",
        "loading_text": "Analyzing with AI...",
        "recent_searches": "Recent Searches",
        "notification": "🌍 Your average eco score this week is 78 — well above the community average of 62!",
    },
    "search": {
        "placeholder": "Search product name, ingredients, or barcode...",
        "button": "Analyze",
        "upload_text": "Drag & drop a product label image, or",
        "upload_hint": "JPEG, PNG up to 10MB",
        "browse": "browse",
    },
    "report": {
        "back_button": "Back to search",
        "carbon_label": "Carbon Footprint",
        "add_history": "Add to History",
        "added": "Added ✓",
        "new_search": "New search",
        "clear_results": "Clear results",
        "impact_warning": "This product has a high environmental impact. Consider switching to one of the alternatives below.",
    },
    "calculator": {
        "result_title": "Your Carbon Footprint",
        "co2_unit": "Tons of CO2 per year",
        "skip_message": "You skipped the calculator. We couldn't calculate your accurate footprint.",
        "recalculate": "Recalculate",
        "calculating": "Calculating your impact...",
        "skip_calculator": "Skip Calculator",
        "skip_question": "Skip this question",
        "question_of": "Question {current} of {total}",
    },
    "history": {
        "title": "Purchase History",
        "subtitle": "Track your environmental footprint over time",
        "clear_all": "Clear All",
        "total_items": "Total Items",
        "avg_score": "Avg Eco Score",
        "categories": "Categories",
        "this_month": "This Month",
        "category_breakdown": "Category Breakdown",
        "purchase_log": "Purchase Log",
        "empty_state": "No purchases logged yet. Analyze a product and add it to your history!",
        "good_score_msg": "🌱 Great job! Your average eco score is above 75. You're an Eco Champion!",
        "bad_score_msg": "⚠️ Some of your recent purchases have high environmental impact. Check the alternatives!",
    },
    "profile": {
        "title": "Eco Profile",
        "subtitle": "Your sustainability journey at a glance",
        "badges_earned": "Badges Earned",
        "avg_score": "Avg Eco Score",
        "products_scanned": "Products Scanned",
        "day_streak": "Day Streak",
        "your_badges": "Your Badges",
        "progress_title": "Progress to Next Badge",
        "earned_label": "Earned",
        "locked_label": "Locked",
        "great_badges_msg": "🏆 Amazing! You've earned {earned} out of {total} badges. Keep going!",
        "low_score_msg": "🌿 Your average eco score is below 50. Try switching to eco-friendly alternatives to boost your score!",
    },
    "ingredients": {
        "title": "Ingredient Analysis",
        "sustainability_label": "Sustainability:",
        "impact_label": "Impact:",
    },
    "alternatives": {
        "title": "Eco-Friendly Alternatives",
        "empty_state": "✨ This product is already a great eco choice! No better alternatives found.",
    },
    "chart": {
        "default_title": "Carbon Footprint Trend",
        "score_legend": "Eco Score",
        "purchases_legend": "Purchases",
        "score_tooltip": "Score",
        "purchases_tooltip": "Purchases",
    },
    "footer": {
        "branding": "🌱 GreenNova — Making sustainability accessible, one product at a time.",
    },
}


def get_fallback_ui_text(section: str) -> dict:
    """Return fallback UI text for a given section."""
    return FALLBACK_UI_TEXT.get(section, {"text": f"Content for {section}"})


def get_fallback_calculator(total_co2: float) -> CalculatorScoreResponse:
    """Return fallback calculator response based on CO2 total."""
    if total_co2 < 6:
        badge = "Eco Champion 🌿"
        badge_color = "green"
    elif total_co2 < 10:
        badge = "Conscious Citizen 🌎"
        badge_color = "yellow"
    else:
        badge = "Needs Improvement 🏭"
        badge_color = "red"

    return CalculatorScoreResponse(
        total_co2=total_co2,
        badge=badge,
        badge_color=badge_color,
        insights=[
            f"Your footprint of {total_co2} tons CO2/year is {'below' if total_co2 < 4.5 else 'above'} the world average of 4.5 tons.",
            "Transportation and diet are typically the largest contributors to personal carbon footprints.",
        ],
        tips=[
            "Consider using public transport or carpooling to reduce emissions.",
            "Eating more plant-based meals can significantly lower your footprint.",
            "Switch to renewable energy sources when possible.",
        ],
        comparison=f"Your footprint is {total_co2} tons/year vs. the world average of 4.5 tons/year.",
    )
