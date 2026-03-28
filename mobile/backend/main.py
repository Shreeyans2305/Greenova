"""
GreenNova Backend — FastAPI server that proxies AI requests to Ollama
and fetches real product data from Open Food Facts.

Improvements:
- Two-step image analysis: identify first, then look up real data
- Calibrated carbon scores using IPCC AR6 reference data with fallback
- Cross-references Open Food Facts for all analyses
- Eco-equivalent calculations grounded in IPCC/EPA science
"""
import base64
import json
import os
from typing import Optional

import httpx
from fastapi import FastAPI, File, Form, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
OLLAMA_BASE = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434")
OLLAMA_TEXT_MODEL = os.getenv("OLLAMA_TEXT_MODEL", "gemma3:latest")
OLLAMA_VISION_MODEL = os.getenv("OLLAMA_VISION_MODEL", "gemma3:12b")
OFF_BASE = "https://world.openfoodfacts.org"

app = FastAPI(title="GreenNova Backend")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
_http = httpx.AsyncClient(timeout=180.0)

# ---------------------------------------------------------------------------
# IPCC AR6 Reference Data (with fallback to ad-hoc benchmarks)
# Sources: IPCC AR6 WG1 Ch.7 (GWP), Poore & Nemecek 2018 (food LCA),
#          IPCC AR6 WG3 (transport/energy), EPA GHG Equivalencies Calculator
# ---------------------------------------------------------------------------
try:
    IPCC_REFERENCE_DATA = {
        "source": "IPCC Sixth Assessment Report (AR6), 2021-2023",
        "methodology": "GWP100 (100-year Global Warming Potential)",

        # --- GWP100 values (kg CO2e per kg of gas) ---
        # Source: IPCC AR6 WG1, Chapter 7, Table 7.15
        "gwp100": {
            "CO2": 1,
            "CH4_fossil": 29.8,
            "CH4_biogenic": 27.0,
            "N2O": 273,
            "SF6": 25200,
            "HFC-134a": 1526,
            "CF4": 7380,
        },

        # --- Food lifecycle emission factors (kg CO2e per kg of product) ---
        # Source: Poore & Nemecek 2018 (cited in IPCC AR6 WG3 Ch.7)
        "food_emission_factors": {
            "beef_herd":       {"kg_co2e_per_kg": 60.0,  "range": [36, 100], "note": "Beef from dedicated herds"},
            "beef_dairy_herd": {"kg_co2e_per_kg": 33.0,  "range": [17, 60],  "note": "Beef from dairy cattle"},
            "lamb_mutton":     {"kg_co2e_per_kg": 24.0,  "range": [12, 52],  "note": "Sheep meat"},
            "cheese":          {"kg_co2e_per_kg": 21.0,  "range": [8, 42],   "note": "Average cheese"},
            "chocolate":       {"kg_co2e_per_kg": 19.0,  "range": [7, 47],   "note": "Dark chocolate"},
            "coffee":          {"kg_co2e_per_kg": 17.0,  "range": [6, 29],   "note": "Roasted coffee beans"},
            "prawns_shrimp":   {"kg_co2e_per_kg": 12.0,  "range": [4, 27],   "note": "Farmed shrimp"},
            "pork":            {"kg_co2e_per_kg": 7.0,   "range": [4, 12],   "note": "Pig meat"},
            "chicken":         {"kg_co2e_per_kg": 6.0,   "range": [3, 10],   "note": "Poultry meat"},
            "fish_farmed":     {"kg_co2e_per_kg": 5.0,   "range": [3, 9],    "note": "Farmed fish average"},
            "eggs":            {"kg_co2e_per_kg": 4.5,   "range": [2, 7],    "note": "Per kg of eggs"},
            "rice":            {"kg_co2e_per_kg": 4.0,   "range": [2, 7],    "note": "Paddy rice (methane)"},
            "milk":            {"kg_co2e_per_kg": 3.2,   "range": [1.5, 5],  "note": "Cow's milk per liter"},
            "wheat":           {"kg_co2e_per_kg": 1.4,   "range": [0.7, 2.5],"note": "Wheat and flour"},
            "bread":           {"kg_co2e_per_kg": 1.6,   "range": [0.8, 3],  "note": "Wheat bread"},
            "tofu":            {"kg_co2e_per_kg": 3.0,   "range": [1.5, 5],  "note": "Soybean curd"},
            "oat_milk":        {"kg_co2e_per_kg": 0.9,   "range": [0.5, 1.5],"note": "Oat-based milk"},
            "soy_milk":        {"kg_co2e_per_kg": 1.0,   "range": [0.5, 1.7],"note": "Soy-based milk"},
            "bananas":         {"kg_co2e_per_kg": 0.7,   "range": [0.3, 1.2],"note": "Fresh bananas"},
            "apples":          {"kg_co2e_per_kg": 0.4,   "range": [0.2, 0.8],"note": "Fresh apples"},
            "potatoes":        {"kg_co2e_per_kg": 0.5,   "range": [0.2, 0.9],"note": "Fresh potatoes"},
            "tomatoes":        {"kg_co2e_per_kg": 1.4,   "range": [0.5, 3],  "note": "Fresh tomatoes"},
            "vegetables_avg":  {"kg_co2e_per_kg": 0.7,   "range": [0.2, 2],  "note": "Average vegetables"},
            "nuts":            {"kg_co2e_per_kg": 0.3,   "range": [0.1, 1],  "note": "Tree nuts average"},
            "sugar":           {"kg_co2e_per_kg": 3.2,   "range": [1, 6],    "note": "Cane/beet sugar"},
            "olive_oil":       {"kg_co2e_per_kg": 6.0,   "range": [3, 10],   "note": "Extra virgin olive oil"},
        },

        # --- Non-food product factors (kg CO2e per unit) ---
        # Sources: Various LCA studies, EPA data
        "non_food_emission_factors": {
            "cotton_tshirt":      {"kg_co2e_per_unit": 8.0,   "unit": "1 shirt",  "note": "Conventional cotton"},
            "polyester_tshirt":   {"kg_co2e_per_unit": 5.5,   "unit": "1 shirt",  "note": "Polyester/synthetic"},
            "jeans":              {"kg_co2e_per_unit": 33.4,  "unit": "1 pair",   "note": "Cotton denim jeans"},
            "smartphone":         {"kg_co2e_per_unit": 70.0,  "unit": "1 device", "note": "Manufacturing + materials"},
            "laptop":             {"kg_co2e_per_unit": 300.0, "unit": "1 device", "note": "Full lifecycle"},
            "plastic_bag":        {"kg_co2e_per_unit": 0.033, "unit": "1 bag",    "note": "HDPE bag"},
            "glass_bottle":       {"kg_co2e_per_unit": 0.55,  "unit": "1 bottle", "note": "500ml glass"},
            "aluminum_can":       {"kg_co2e_per_unit": 0.17,  "unit": "1 can",    "note": "330ml aluminum"},
            "shampoo_bottle":     {"kg_co2e_per_unit": 0.8,   "unit": "1 bottle", "note": "250ml plastic bottle"},
            "bar_soap":           {"kg_co2e_per_unit": 0.3,   "unit": "1 bar",    "note": "100g soap bar"},
            "laundry_detergent":  {"kg_co2e_per_unit": 1.5,   "unit": "1 liter",  "note": "Liquid detergent"},
        },

        # --- Transport emission factors (kg CO2e per passenger-km) ---
        # Source: IPCC AR6 WG3, Chapter 10
        "transport_factors": {
            "car_petrol":    {"kg_co2e_per_km": 0.21,  "note": "Average petrol car"},
            "car_diesel":    {"kg_co2e_per_km": 0.17,  "note": "Average diesel car"},
            "car_electric":  {"kg_co2e_per_km": 0.05,  "note": "BEV, global avg grid"},
            "bus":           {"kg_co2e_per_km": 0.089, "note": "Urban bus per passenger"},
            "train":         {"kg_co2e_per_km": 0.041, "note": "Rail per passenger"},
            "airplane":      {"kg_co2e_per_km": 0.255, "note": "Short-haul flight per pax"},
            "bicycle":       {"kg_co2e_per_km": 0.0,   "note": "Zero direct emissions"},
        },

        # --- Energy emission factors (kg CO2e per kWh) ---
        # Source: IPCC AR6 WG3, Annex III
        "energy_factors": {
            "coal":          {"kg_co2e_per_kwh": 0.91,  "note": "Hard coal power"},
            "natural_gas":   {"kg_co2e_per_kwh": 0.41,  "note": "Gas-fired power"},
            "oil":           {"kg_co2e_per_kwh": 0.73,  "note": "Oil-fired power"},
            "solar_pv":      {"kg_co2e_per_kwh": 0.041, "note": "Solar photovoltaic"},
            "wind_onshore":  {"kg_co2e_per_kwh": 0.011, "note": "Onshore wind"},
            "nuclear":       {"kg_co2e_per_kwh": 0.012, "note": "Nuclear power"},
            "hydropower":    {"kg_co2e_per_kwh": 0.024, "note": "Reservoir hydro"},
            "grid_world_avg":{"kg_co2e_per_kwh": 0.475, "note": "Global average 2020"},
        },

        # --- Equivalency factors for eco-impact visualization ---
        # Source: EPA Greenhouse Gas Equivalencies Calculator
        "equivalency_factors": {
            "tree_absorption_kg_per_year": 22.0,
            "car_kg_co2_per_mile":         0.404,
            "car_kg_co2_per_km":           0.251,
            "plastic_bag_kg_co2":          0.033,
            "lightbulb_60w_kg_co2_per_hr": 0.042,
            "smartphone_charge_kg_co2":    0.008,
            "shower_minute_liters":        9.5,
            "beef_water_liters_per_kg":    15415,
            "chicken_water_liters_per_kg": 4325,
            "rice_water_liters_per_kg":    2500,
            "vegetable_water_liters_per_kg": 322,
        },
    }
    _IPCC_AVAILABLE = True
except Exception:
    IPCC_REFERENCE_DATA = {}
    _IPCC_AVAILABLE = False


def _get_ipcc_value(path: str, default=None):
    """Safely retrieve a nested value from IPCC_REFERENCE_DATA.
    Path format: 'section.key.subkey' e.g. 'gwp100.CH4_fossil'
    Falls back to default if IPCC data is unavailable."""
    try:
        obj = IPCC_REFERENCE_DATA
        for key in path.split("."):
            obj = obj[key]
        return obj
    except (KeyError, TypeError):
        return default


# ---------------------------------------------------------------------------
# Carbon benchmarks — IPCC-sourced with fallback to ad-hoc values
# ---------------------------------------------------------------------------
def _build_carbon_benchmarks() -> str:
    """Build calibration guide. Uses IPCC data when available, falls back to
    hand-picked benchmarks otherwise."""
    if _IPCC_AVAILABLE:
        food = IPCC_REFERENCE_DATA.get("food_emission_factors", {})
        return f"""CARBON SCORE CALIBRATION GUIDE (use these as anchors — 0=best, 100=worst):
Based on IPCC AR6 & Poore and Nemecek 2018 lifecycle data (kg CO2e/kg product):
- Fresh local vegetables ({food.get('vegetables_avg',{}).get('kg_co2e_per_kg','~0.7')} kg CO2e/kg): score 5-12
- Tap water: score 2
- Fresh fruit — apples ({food.get('apples',{}).get('kg_co2e_per_kg','~0.4')}), bananas ({food.get('bananas',{}).get('kg_co2e_per_kg','~0.7')} kg CO2e/kg): score 8-15
- Oat milk ({food.get('oat_milk',{}).get('kg_co2e_per_kg','~0.9')} kg CO2e/kg): score 10-15
- Bread ({food.get('bread',{}).get('kg_co2e_per_kg','~1.6')} kg CO2e/kg): score 12-18
- Rice ({food.get('rice',{}).get('kg_co2e_per_kg','~4.0')} kg CO2e/kg): score 15-22
- Cow's milk ({food.get('milk',{}).get('kg_co2e_per_kg','~3.2')} kg CO2e/kg per liter): score 20-28
- Eggs ({food.get('eggs',{}).get('kg_co2e_per_kg','~4.5')} kg CO2e/kg): score 22-30
- Juice, soft drinks: score 18-28
- Chocolate ({food.get('chocolate',{}).get('kg_co2e_per_kg','~19')} kg CO2e/kg): score 25-35
- Cheese ({food.get('cheese',{}).get('kg_co2e_per_kg','~21')} kg CO2e/kg): score 30-42
- Chicken ({food.get('chicken',{}).get('kg_co2e_per_kg','~6')} kg CO2e/kg): score 30-40
- Coffee ({food.get('coffee',{}).get('kg_co2e_per_kg','~17')} kg CO2e/kg): score 35-45
- Pork ({food.get('pork',{}).get('kg_co2e_per_kg','~7')} kg CO2e/kg): score 35-50
- Fish — farmed ({food.get('fish_farmed',{}).get('kg_co2e_per_kg','~5')} kg CO2e/kg): score 30-45
- Shampoo, soap, cosmetics: score 15-30
- Clothing (cotton t-shirt ~8 kg CO2e): score 35-50
- Beef ({food.get('beef_herd',{}).get('kg_co2e_per_kg','~60')} kg CO2e/kg): score 55-75
- Electronics (smartphone ~70 kg CO2e): score 50-70
- Air-freighted produce: score 60-80
- Fast fashion item: score 55-70
- Single-use plastics: score 65-85

SCIENTIFIC REFERENCE: These kg CO2e values come from IPCC AR6 & Poore/Nemecek 2018.
A tree absorbs ~{_get_ipcc_value('equivalency_factors.tree_absorption_kg_per_year', 22)} kg CO2/year.
1 car mile ≈ {_get_ipcc_value('equivalency_factors.car_kg_co2_per_mile', 0.404)} kg CO2.

ECOSCORE GRADE MAPPING:
- Ecoscore A → carbonScore 5-20, sustainabilityGrade A
- Ecoscore B → carbonScore 18-35, sustainabilityGrade B
- Ecoscore C → carbonScore 30-50, sustainabilityGrade C
- Ecoscore D → carbonScore 45-65, sustainabilityGrade D
- Ecoscore E → carbonScore 60-80, sustainabilityGrade F
- No ecoscore → Use your best judgment based on ingredients/category

BE BALANCED: Most everyday consumer products should score between 15-45.
Only truly harmful products (beef, fast fashion, heavy plastics) score above 55.
Organic, local, minimal-packaging products should score 5-20."""
    else:
        # Fallback: original ad-hoc benchmarks
        return """CARBON SCORE CALIBRATION GUIDE (use these as anchors — 0=best, 100=worst):
- Fresh local vegetables (carrots, lettuce): 5-12
- Tap water: 2
- Fresh local fruit (apples, bananas): 8-15
- Oat milk, soy milk: 10-15
- Bread (local bakery): 12-18
- Rice, pasta, grains: 15-22
- Cow's milk (1L): 20-28
- Eggs (dozen): 22-30
- Juice, soft drinks (Coca-Cola, Pepsi): 18-28
- Chocolate bar: 25-35
- Cheese: 30-42
- Chicken meat: 30-40
- Coffee (per kg): 35-45
- Pork meat: 35-50
- Fish (wild-caught): 30-45
- Shampoo, soap, cosmetics: 15-30
- Clothing (cotton t-shirt): 35-50
- Beef meat: 55-75
- Electronics (small gadgets): 50-70
- Air-freighted produce: 60-80
- Fast fashion item: 55-70
- Single-use plastics: 65-85

ECOSCORE GRADE MAPPING:
- Ecoscore A → carbonScore 5-20, sustainabilityGrade A
- Ecoscore B → carbonScore 18-35, sustainabilityGrade B
- Ecoscore C → carbonScore 30-50, sustainabilityGrade C
- Ecoscore D → carbonScore 45-65, sustainabilityGrade D
- Ecoscore E → carbonScore 60-80, sustainabilityGrade F
- No ecoscore → Use your best judgment based on ingredients/category

BE BALANCED: Most everyday consumer products should score between 15-45.
Only truly harmful products (beef, fast fashion, heavy plastics) score above 55.
Organic, local, minimal-packaging products should score 5-20."""


# Build once at startup
CARBON_BENCHMARKS = _build_carbon_benchmarks()


def _clean_json(raw: str) -> dict:
    """Strip markdown fences and parse JSON from LLM output."""
    text = raw.strip()
    if text.startswith("```json"):
        text = text[7:]
    elif text.startswith("```"):
        text = text[3:]
    if text.endswith("```"):
        text = text[:-3]
    text = text.strip()
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        start = text.find("{")
        end = text.rfind("}") + 1
        if start != -1 and end > start:
            return json.loads(text[start:end])
        return {"error": "Failed to parse AI response", "raw": text[:500]}


async def _ollama_generate(prompt: str, *, model: str | None = None,
                           images: list[str] | None = None) -> dict:
    """Call Ollama /api/generate and return parsed JSON."""
    use_model = model or OLLAMA_TEXT_MODEL
    if images:
        use_model = OLLAMA_VISION_MODEL

    body: dict = {
        "model": use_model,
        "prompt": prompt,
        "stream": False,
        "format": "json",
    }
    if images:
        body["images"] = images

    resp = await _http.post(f"{OLLAMA_BASE}/api/generate", json=body)
    resp.raise_for_status()
    raw_text = resp.json().get("response", "{}")
    return _clean_json(raw_text)


def _trim_product_data(data: dict | None) -> str:
    """Extract only essential fields from product data for AI context."""
    if not data:
        return ""
    essentials = {
        "name": data.get("name", ""),
        "brand": data.get("brand", ""),
        "ecoscoreGrade": data.get("ecoscoreGrade", ""),
        "nutriscoreGrade": data.get("nutriscoreGrade", ""),
        "packaging": str(data.get("packaging", ""))[:200],
        "ingredients": str(data.get("ingredients", ""))[:300],
    }
    return json.dumps(essentials)


async def _lookup_product_off(query: str) -> dict | None:
    """Search Open Food Facts for a product and return the best match."""
    try:
        resp = await _http.get(
            f"{OFF_BASE}/cgi/search.pl",
            params={
                "search_terms": query,
                "search_simple": 1,
                "action": "process",
                "json": 1,
                "page": 1,
                "page_size": 3,
                "fields": "code,product_name,brands,ecoscore_grade,ecoscore_score,"
                          "nutriscore_grade,categories_tags,ingredients_text,"
                          "packaging,nova_group,labels_tags,origins_tags,"
                          "manufacturing_places_tags",
            },
            timeout=10.0,
        )
        resp.raise_for_status()
        data = resp.json()
        products = data.get("products", [])
        for p in products:
            name = p.get("product_name", "").strip()
            if name:
                return {
                    "name": name,
                    "brand": p.get("brands", ""),
                    "ecoscoreGrade": p.get("ecoscore_grade", ""),
                    "ecoscoreScore": p.get("ecoscore_score"),
                    "nutriscoreGrade": p.get("nutriscore_grade", ""),
                    "categories": p.get("categories_tags", [])[:5],
                    "ingredients": (p.get("ingredients_text", "") or "")[:400],
                    "packaging": p.get("packaging", ""),
                    "novaGroup": p.get("nova_group"),
                    "labels": p.get("labels_tags", [])[:10],
                    "origins": p.get("origins_tags", [])[:5],
                    "manufacturing": p.get("manufacturing_places_tags", [])[:3],
                }
    except Exception:
        pass
    return None


def _build_off_context(off_data: dict | None) -> str:
    """Build a context string from Open Food Facts data."""
    if not off_data:
        return ""
    parts = ["\n--- REAL PRODUCT DATA FROM OPEN FOOD FACTS DATABASE ---"]
    if off_data.get("name"):
        parts.append(f"Product: {off_data['name']}")
    if off_data.get("brand"):
        parts.append(f"Brand: {off_data['brand']}")
    if off_data.get("ecoscoreGrade"):
        parts.append(f"Official Ecoscore Grade: {off_data['ecoscoreGrade'].upper()}")
    if off_data.get("ecoscoreScore"):
        parts.append(f"Official Ecoscore Score: {off_data['ecoscoreScore']}/100")
    if off_data.get("nutriscoreGrade"):
        parts.append(f"Nutriscore: {off_data['nutriscoreGrade'].upper()}")
    if off_data.get("novaGroup"):
        parts.append(f"NOVA food processing group: {off_data['novaGroup']}")
    if off_data.get("ingredients"):
        parts.append(f"Ingredients: {off_data['ingredients'][:300]}")
    if off_data.get("packaging"):
        parts.append(f"Packaging: {off_data['packaging']}")
    if off_data.get("labels"):
        parts.append(f"Labels/Certifications: {', '.join(off_data['labels'][:8])}")
    if off_data.get("origins"):
        parts.append(f"Origins: {', '.join(off_data['origins'])}")
    parts.append("--- END REAL DATA ---")
    parts.append("IMPORTANT: Use this real data to calibrate your carbon score. "
                 "If an official ecoscore exists, your sustainabilityGrade MUST closely match it. "
                 "Use the product name from this data, not a guess.")
    return "\n".join(parts)


def _build_ipcc_prompt_context() -> str:
    """Build a compact IPCC context block for AI prompts.
    Returns empty string if IPCC data is unavailable (fallback)."""
    if not _IPCC_AVAILABLE:
        return ""
    food = IPCC_REFERENCE_DATA.get("food_emission_factors", {})
    selected = {k: v["kg_co2e_per_kg"] for k, v in list(food.items())[:12]}
    return (
        "\n--- IPCC AR6 REFERENCE DATA ---\n"
        f"Key food emission factors (kg CO2e/kg, Poore & Nemecek 2018): {json.dumps(selected)}\n"
        f"GWP100 values: CO2=1, CH4(fossil)=29.8, N2O=273 (IPCC AR6 WG1)\n"
        "Use these scientifically sourced factors to anchor your carbon score.\n"
        "--- END IPCC DATA ---\n"
    )


def _sustainability_prompt(context: str, off_context: str = "") -> str:
    ipcc_ctx = _build_ipcc_prompt_context()
    tree_abs = _get_ipcc_value("equivalency_factors.tree_absorption_kg_per_year", 22)
    car_mile = _get_ipcc_value("equivalency_factors.car_kg_co2_per_mile", 0.404)
    bag_co2 = _get_ipcc_value("equivalency_factors.plastic_bag_kg_co2", 0.033)
    bulb_co2 = _get_ipcc_value("equivalency_factors.lightbulb_60w_kg_co2_per_hr", 0.042)

    return f"""{context}
{off_context}
{ipcc_ctx}
{CARBON_BENCHMARKS}

Respond in JSON format with the following structure:
{{
  "productName": "Exact product name (use real data if available)",
  "brand": "Brand name if known, otherwise null",
  "carbonScore": <number 0-100> (MUST be calibrated using the IPCC benchmarks above; lower is better),
  "sustainabilityGrade": "A/B/C/D/F" (if ecoscore data exists, match it closely),
  "positiveFactors": ["list of genuine positive environmental aspects"],
  "negativeFactors": ["list of genuine negative environmental aspects"],
  "recommendations": ["actionable sustainability tips for this specific product"],
  "detailedAnalysis": "Detailed, balanced, fact-based sustainability analysis (2-3 paragraphs). Mention both positives and negatives fairly. Cite IPCC data where relevant.",
  "ecoEquivalents": {{
    "treesNeeded": <number> (a tree absorbs ~{tree_abs}kg CO2/year — IPCC/EPA),
    "carMiles": <number> (1 mile ≈ {car_mile}kg CO2 — EPA),
    "plasticBags": <number> (1 bag ≈ {bag_co2}kg CO2),
    "lightBulbHours": <number> (60W bulb = {bulb_co2}kg CO2/hour)
  }}
}}"""


def _compute_eco_equivalents(carbon_score: float) -> dict:
    """Compute realistic eco-equivalents from a carbon score.
    Uses IPCC/EPA equivalency factors when available, falls back to
    hard-coded constants otherwise.
    """
    # Map score to approximate kg CO2e (0-10kg range)
    kg_co2 = (carbon_score / 100) * 8.0

    # Pull constants from IPCC data with fallback defaults
    tree_abs = _get_ipcc_value("equivalency_factors.tree_absorption_kg_per_year", 22.0)
    car_mile = _get_ipcc_value("equivalency_factors.car_kg_co2_per_mile", 0.404)
    bag_co2  = _get_ipcc_value("equivalency_factors.plastic_bag_kg_co2", 0.033)
    bulb_co2 = _get_ipcc_value("equivalency_factors.lightbulb_60w_kg_co2_per_hr", 0.042)
    charge   = _get_ipcc_value("equivalency_factors.smartphone_charge_kg_co2", 0.008)

    return {
        "treesNeeded": round(kg_co2 / tree_abs, 3),
        "carMiles": round(kg_co2 / car_mile, 1),
        "plasticBags": max(1, round(kg_co2 / bag_co2)),
        "lightBulbHours": max(1, round(kg_co2 / bulb_co2)),
        "smartphoneCharges": max(1, round(kg_co2 / charge)),
        "_ipccSourced": _IPCC_AVAILABLE,
    }


# ---------------------------------------------------------------------------
# Pydantic models
# ---------------------------------------------------------------------------
class AnalyzeRequest(BaseModel):
    text: str
    product_name: Optional[str] = None


class SearchRequest(BaseModel):
    query: str


class CompareRequest(BaseModel):
    product1: str
    product2: str
    product1_data: Optional[dict] = None
    product2_data: Optional[dict] = None


class CarbonSummaryRequest(BaseModel):
    purchase_history: list[dict]


class AlternativesRequest(BaseModel):
    product_name: str
    carbon_score: float
    sustainability_grade: str
    category: Optional[str] = None
    negative_factors: Optional[list[str]] = None


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------
@app.get("/api/health")
async def health():
    """Health check — also pings Ollama."""
    ollama_ok = False
    try:
        r = await _http.get(f"{OLLAMA_BASE}/api/tags", timeout=5.0)
        ollama_ok = r.status_code == 200
    except Exception:
        pass
    return {
        "status": "ok",
        "ollama_connected": ollama_ok,
        "text_model": OLLAMA_TEXT_MODEL,
        "vision_model": OLLAMA_VISION_MODEL,
    }


# ---- Analyze (text / ingredients) -----------------------------------------
@app.post("/api/analyze")
async def analyze(req: AnalyzeRequest):
    label = req.product_name or "Product"
    
    # Cross-reference with Open Food Facts
    off_data = await _lookup_product_off(label)
    off_context = _build_off_context(off_data)
    
    prompt = _sustainability_prompt(
        f"Analyze these product ingredients for sustainability and environmental impact.\n"
        f"Product Name: {label}\nIngredients: {req.text}",
        off_context,
    )
    data = await _ollama_generate(prompt)
    
    # Use OFF product name if available for accuracy
    if off_data and off_data.get("name"):
        data.setdefault("productName", off_data["name"])
    else:
        data.setdefault("productName", label)
    
    # Ensure eco-equivalents are realistic
    score = data.get("carbonScore", 50)
    if isinstance(score, (int, float)):
        data["ecoEquivalents"] = _compute_eco_equivalents(float(score))
    
    return data


# ---- Image analysis (TWO-STEP) -------------------------------------------
@app.post("/api/image")
async def analyze_image(image: UploadFile = File(...)):
    contents = await image.read()
    b64 = base64.b64encode(contents).decode("utf-8")
    
    # STEP 1: Identify the product from the image
    id_prompt = """Look at this product image carefully. Identify:
1. The exact product name (read any text/labels visible)
2. The brand name (read the logo or brand text)
3. The product category (food, beverage, cosmetic, household, etc.)
4. Any visible ingredients, certifications, or eco-labels
5. The packaging material (plastic, glass, cardboard, etc.)

Be as specific as possible. Read ALL visible text on the product.

Respond in JSON format:
{
  "identifiedProduct": "exact product name as read from label",
  "brand": "brand name as read from label",
  "category": "product category",
  "visibleIngredients": "any ingredients visible on label",
  "certifications": ["list of visible eco-labels or certifications"],
  "packagingType": "packaging material description",
  "confidence": "high/medium/low"
}"""
    
    id_result = await _ollama_generate(id_prompt, images=[b64])
    
    identified_name = id_result.get("identifiedProduct", "")
    identified_brand = id_result.get("brand", "")
    search_query = f"{identified_brand} {identified_name}".strip()
    
    # STEP 2: Look up the identified product in Open Food Facts
    off_data = None
    if search_query and len(search_query) > 2:
        off_data = await _lookup_product_off(search_query)
        # If brand-name search fails, try just the product name
        if not off_data and identified_name:
            off_data = await _lookup_product_off(identified_name)
    
    off_context = _build_off_context(off_data)
    
    # Build context from identification
    id_context_parts = []
    if identified_name:
        id_context_parts.append(f"Identified product: {identified_name}")
    if identified_brand:
        id_context_parts.append(f"Brand: {identified_brand}")
    if id_result.get("category"):
        id_context_parts.append(f"Category: {id_result['category']}")
    if id_result.get("visibleIngredients"):
        id_context_parts.append(f"Visible ingredients: {id_result['visibleIngredients']}")
    if id_result.get("certifications"):
        certs = id_result["certifications"]
        if isinstance(certs, list) and certs:
            id_context_parts.append(f"Certifications: {', '.join(str(c) for c in certs)}")
    if id_result.get("packagingType"):
        id_context_parts.append(f"Packaging: {id_result['packagingType']}")
    
    id_context = "\n".join(id_context_parts) if id_context_parts else "Product identification was unclear from the image."
    
    # STEP 3: Generate sustainability report with all available data
    prompt = _sustainability_prompt(
        f"Generate a sustainability report for this product based on image analysis.\n\n"
        f"IMAGE IDENTIFICATION RESULTS:\n{id_context}\n\n"
        f"Use the identified product name and brand. If Open Food Facts data is available below, "
        f"prioritize that real data over guesses.",
        off_context,
    )
    data = await _ollama_generate(prompt, images=[b64])
    
    # Ensure product name uses the best available data
    if off_data and off_data.get("name"):
        data["productName"] = off_data["name"]
        data["brand"] = off_data.get("brand") or data.get("brand")
    elif identified_name:
        data.setdefault("productName", identified_name)
        if identified_brand:
            data.setdefault("brand", identified_brand)
    
    # Calibrate eco-equivalents
    score = data.get("carbonScore", 50)
    if isinstance(score, (int, float)):
        data["ecoEquivalents"] = _compute_eco_equivalents(float(score))
    
    data["_identification"] = id_result  # include for debugging
    data["_offDataFound"] = off_data is not None
    
    return data


# ---- Text search with AI --------------------------------------------------
@app.post("/api/search")
async def search_text(req: SearchRequest):
    # Cross-reference with Open Food Facts first
    off_data = await _lookup_product_off(req.query)
    off_context = _build_off_context(off_data)
    
    prompt = _sustainability_prompt(
        f"Provide a sustainability report for: {req.query}\n"
        "Give a balanced, fact-based assessment of this product's environmental impact.",
        off_context,
    )
    data = await _ollama_generate(prompt)
    
    if off_data and off_data.get("name"):
        data["productName"] = off_data["name"]
        data.setdefault("brand", off_data.get("brand"))
    else:
        data.setdefault("productName", req.query)
    
    data["isGeneralized"] = off_data is None
    
    # Calibrate eco-equivalents
    score = data.get("carbonScore", 50)
    if isinstance(score, (int, float)):
        data["ecoEquivalents"] = _compute_eco_equivalents(float(score))
    
    return data


# ---- Compare two products -------------------------------------------------
@app.post("/api/compare")
async def compare_products(req: CompareRequest):
    extra1 = _trim_product_data(req.product1_data) if req.product1_data else ""
    extra2 = _trim_product_data(req.product2_data) if req.product2_data else ""

    # Cross-reference both products with Open Food Facts
    off1 = await _lookup_product_off(req.product1)
    off2 = await _lookup_product_off(req.product2)
    
    off1_ctx = ""
    if off1:
        off1_ctx = f"\nProduct 1 real data: ecoscore={off1.get('ecoscoreGrade','?')}, " \
                   f"nutriscore={off1.get('nutriscoreGrade','?')}, " \
                   f"packaging={off1.get('packaging','?')}"
    if extra1:
        off1_ctx += f"\nProduct 1 additional info: {extra1}"
    
    off2_ctx = ""
    if off2:
        off2_ctx = f"\nProduct 2 real data: ecoscore={off2.get('ecoscoreGrade','?')}, " \
                   f"nutriscore={off2.get('nutriscoreGrade','?')}, " \
                   f"packaging={off2.get('packaging','?')}"
    if extra2:
        off2_ctx += f"\nProduct 2 additional info: {extra2}"

    prompt = f"""Compare these two products for sustainability and environmental impact:
Product 1: {req.product1}{off1_ctx}
Product 2: {req.product2}{off2_ctx}

{CARBON_BENCHMARKS}

IMPORTANT: If one product has real ecoscore data and the other doesn't, 
use the ecoscore data to anchor your comparison. Be fair and balanced.

Respond in JSON format:
{{
  "winner": "product1 or product2",
  "winnerName": "name of the more sustainable product",
  "summary": "2-3 sentence fair summary explaining which is better and specifically why",
  "product1": {{
    "productName": "{req.product1}",
    "carbonScore": 0-100 (calibrated using benchmarks),
    "sustainabilityGrade": "A/B/C/D/F",
    "positiveFactors": ["genuine positives"],
    "negativeFactors": ["genuine negatives"]
  }},
  "product2": {{
    "productName": "{req.product2}",
    "carbonScore": 0-100 (calibrated using benchmarks),
    "sustainabilityGrade": "A/B/C/D/F",
    "positiveFactors": ["genuine positives"],
    "negativeFactors": ["genuine negatives"]
  }},
  "comparisonFactors": [
    {{"factor": "Factor name", "product1Score": 0-10, "product2Score": 0-10, "explanation": "brief explanation"}}
  ]
}}"""
    data = await _ollama_generate(prompt)
    return data


# ---- Eco-friendly alternatives -------------------------------------------
@app.post("/api/alternatives")
async def get_alternatives(req: AlternativesRequest):
    """Get eco-friendly alternatives for a high-carbon product."""
    neg = ", ".join(req.negative_factors[:5]) if req.negative_factors else "unknown"

    prompt = f"""The product "{req.product_name}" has a sustainability grade of {req.sustainability_grade} 
and a carbon score of {req.carbon_score}/100 (lower is better).
Its key environmental issues are: {neg}.
{f'Category: {req.category}' if req.category else ''}

Suggest 3 specific, real, commercially-available eco-friendly alternative products.
Each alternative MUST be a real product or brand that actually exists.

Respond in JSON format:
{{
  "alternatives": [
    {{
      "name": "Specific real product name",
      "brand": "Real brand name",
      "estimatedCarbonScore": 0-100 (should be significantly lower than {int(req.carbon_score)}),
      "sustainabilityGrade": "A/B/C",
      "whyBetter": "1-2 sentence explanation with specific environmental facts",
      "keyBenefits": ["specific benefit", "specific benefit"]
    }}
  ],
  "generalTip": "Practical tip for choosing sustainable products in this category"
}}"""
    data = await _ollama_generate(prompt)
    return data


# ---- Carbon summary -------------------------------------------------------
@app.post("/api/carbon-summary")
async def carbon_summary(req: CarbonSummaryRequest):
    history_json = json.dumps(req.purchase_history[:50])
    prompt = f"""Analyze this purchase history and generate a carbon footprint summary.
Purchase History: {history_json}

{CARBON_BENCHMARKS}

Respond in JSON format:
{{
  "totalCarbonFootprint": number,
  "averageCarbonScore": number,
  "footprintLevel": "Low/Medium/High",
  "recommendation": "Personalized recommendation text",
  "ecoEquivalents": {{
    "treesNeeded": number,
    "carMiles": number,
    "flightsEquivalent": number
  }},
  "achievements": ["earned achievement badges"]
}}"""
    data = await _ollama_generate(prompt)
    return data


# ---- Open Food Facts product search ---------------------------------------
@app.get("/api/products/search")
async def search_products(q: str, page: int = 1):
    """Search Open Food Facts for real product data."""
    try:
        resp = await _http.get(
            f"{OFF_BASE}/cgi/search.pl",
            params={
                "search_terms": q,
                "search_simple": 1,
                "action": "process",
                "json": 1,
                "page": page,
                "page_size": 20,
                "fields": "code,product_name,brands,image_url,image_small_url,"
                          "ecoscore_grade,ecoscore_score,nutriscore_grade,"
                          "categories_tags,ingredients_text,packaging,"
                          "nova_group,quantity,labels_tags",
            },
        )
        resp.raise_for_status()
        data = resp.json()
        products = []
        for p in data.get("products", []):
            name = p.get("product_name", "").strip()
            if not name:
                continue
            products.append({
                "barcode": p.get("code", ""),
                "name": name,
                "brand": p.get("brands", ""),
                "imageUrl": p.get("image_url", ""),
                "imageSmallUrl": p.get("image_small_url", ""),
                "ecoscoreGrade": p.get("ecoscore_grade", ""),
                "ecoscoreScore": p.get("ecoscore_score"),
                "nutriscoreGrade": p.get("nutriscore_grade", ""),
                "categories": p.get("categories_tags", []),
                "ingredients": p.get("ingredients_text", ""),
                "packaging": p.get("packaging", ""),
                "novaGroup": p.get("nova_group"),
                "quantity": p.get("quantity", ""),
                "labels": p.get("labels_tags", []),
            })
        return {
            "count": data.get("count", 0),
            "page": page,
            "products": products,
        }
    except Exception as e:
        return {"count": 0, "page": page, "products": [], "error": str(e)}


@app.get("/api/products/{barcode}")
async def get_product(barcode: str):
    """Fetch a single product from Open Food Facts by barcode."""
    try:
        resp = await _http.get(f"{OFF_BASE}/api/v2/product/{barcode}.json")
        resp.raise_for_status()
        data = resp.json()
        p = data.get("product", {})
        return {
            "barcode": barcode,
            "name": p.get("product_name", "Unknown"),
            "brand": p.get("brands", ""),
            "imageUrl": p.get("image_url", ""),
            "ecoscoreGrade": p.get("ecoscore_grade", ""),
            "ecoscoreScore": p.get("ecoscore_score"),
            "nutriscoreGrade": p.get("nutriscore_grade", ""),
            "ingredients": p.get("ingredients_text", ""),
            "packaging": p.get("packaging", ""),
            "novaGroup": p.get("nova_group"),
            "quantity": p.get("quantity", ""),
            "categories": p.get("categories_tags", []),
            "labels": p.get("labels_tags", []),
        }
    except Exception as e:
        return {"barcode": barcode, "error": str(e)}


# ---- IPCC Reference Data API ----------------------------------------------
@app.get("/api/ipcc-reference")
async def ipcc_reference():
    """Return the full IPCC AR6 reference dataset.
    Falls back to an error message if IPCC data failed to load."""
    if _IPCC_AVAILABLE:
        return {"available": True, "data": IPCC_REFERENCE_DATA}
    return {
        "available": False,
        "message": "IPCC reference data unavailable, using fallback benchmarks",
    }


@app.get("/api/ipcc-context/{product_type}")
async def ipcc_context(product_type: str):
    """Return IPCC data relevant to a product type.
    Supported types: food, clothing, electronics, transport, energy, packaging."""
    if not _IPCC_AVAILABLE:
        return {"available": False, "message": "IPCC data unavailable, using fallback"}

    result: dict = {
        "available": True,
        "product_type": product_type,
        "gwp100": IPCC_REFERENCE_DATA.get("gwp100", {}),
        "equivalency_factors": IPCC_REFERENCE_DATA.get("equivalency_factors", {}),
    }

    pt = product_type.lower()
    if pt == "food":
        result["emission_factors"] = IPCC_REFERENCE_DATA.get("food_emission_factors", {})
    elif pt in ("clothing", "electronics", "packaging", "cosmetics", "household"):
        result["emission_factors"] = IPCC_REFERENCE_DATA.get("non_food_emission_factors", {})
    elif pt == "transport":
        result["emission_factors"] = IPCC_REFERENCE_DATA.get("transport_factors", {})
    elif pt == "energy":
        result["emission_factors"] = IPCC_REFERENCE_DATA.get("energy_factors", {})
    else:
        # Return all factors for unknown types
        result["food_factors"] = IPCC_REFERENCE_DATA.get("food_emission_factors", {})
        result["non_food_factors"] = IPCC_REFERENCE_DATA.get("non_food_emission_factors", {})

    return result


# ---------------------------------------------------------------------------
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
