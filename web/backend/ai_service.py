"""
GreenNova Backend - AI Service
Centralized AI interaction layer using Ollama (Gemma 3).
All responses are cached with TTL to reduce API calls.
"""

import json
import logging
import re
from typing import Optional

import ollama

from config import OLLAMA_URL, MODEL_NAME
from models import (
    SustainabilityReport,
    SearchResponse,
    UITextResponse,
    CalculatorScoreResponse,
    ContentGenerateResponse,
    CompareRequest,
    CompareResponse,
    ProductCompareData,
    ComparisonFactor,
)
from cache_service import cache, CacheService

logger = logging.getLogger("greenNova.ai_service")

FALLBACK_UI_TEXT = {
    "navbar": {
        "brand": "GreenNova",
        "home": "Home",
        "compare": "Compare",
        "calculator": "Calculate Footprint",
        "history": "Progress",
        "badges": "Badges",
    },
    "home": {
        "badge_label": "AI-Powered Sustainability",
        "hero_title_1": "Know Your Impact.",
        "hero_title_2": "Choose Better.",
        "hero_subtitle": "Get instant sustainability reports powered by AI.",
        "loading_text": "Analyzing with AI...",
        "recent_searches": "Recent Searches",
    },
    "search": {
        "placeholder": "Search product name, ingredients...",
        "button": "Analyze",
    },
    "report": {
        "add_history": "Add to History",
        "added": "Added",
        "new_search": "New Search",
        "impact_warning": "This product has a high environmental impact.",
    },
    "footer": {
        "branding": "GreenNova — Making sustainability accessible.",
    },
}

FALLBACK_CALCULATOR = {
    "badge": "Eco Explorer",
    "badge_color": "green",
    "insights": ["Keep tracking your carbon footprint to see improvements."],
    "tips": ["Consider reducing energy usage and choosing sustainable products."],
    "comparison": "Track your progress over time.",
}


# ===== Prompts =====

ANALYZE_PROMPT = """You are GreenNova, an expert environmental sustainability analyst.
Analyze the following product and provide a detailed sustainability report.

Product information: {product_info}

Respond with valid JSON only, no markdown fences:
{{
  "product_name": "Name of the product",
  "brand": "Brand name or null",
  "category": "Product category",
  "score": 0-100 integer (sustainability score, higher = better),
  "tier": "GREEN" if score >= 75, "AMBER" if score >= 50, "RED" if score < 50,
  "badge": "Eco Champion" if score >= 85, "Getting Greener" if score >= 70, null otherwise,
  "carbon_footprint": "Very Low" | "Low" | "Medium" | "High" | "Very High",
  "description": "Brief product description and sustainability assessment",
  "ingredients_analysis": [
    {{"name": "Ingredient name", "sustainability": "High" | "Medium" | "Low", "impact": "Very Low" | "Low" | "Moderate" | "High", "score": 0-100}}
  ],
  "alternatives": [
    {{"name": "Alternative name", "score": 0-100, "price": "$X.XX or null", "reason": "Why better"}}
  ]
}}"""

SEARCH_PROMPT = """You are GreenNova, an expert environmental sustainability analyst.
A user is searching for: "{query}"

Provide 3-5 sustainability-rated product results.

Respond with valid JSON only, no markdown fences:
{{
  "type": "GENERALIZED",
  "results": [
    {{
      "id": "unique_id",
      "name": "Product name",
      "brand": "Brand name",
      "category": "Category",
      "score": 0-100,
      "tier": "GREEN" | "AMBER" | "RED",
      "badge": "badge or null",
      "carbon_footprint": "Very Low" | "Low" | "Medium" | "High" | "Very High",
      "description": "Brief description"
    }}
  ]
}}"""

IMAGE_ANALYZE_PROMPT = """You are GreenNova, an expert environmental sustainability analyst.
Analyze this product label image and provide a sustainability report.

Respond with valid JSON only, matching the same structure as product analysis:
product_name, brand, category, score, tier, badge, carbon_footprint, description, ingredients_analysis, alternatives."""

UI_TEXT_PROMPT = """You are GreenNova, generating UI text for a sustainability app.
Rewrite the text for "{section}" section. Maintain exact JSON keys.

Default text: {keys}

Respond with valid JSON only, no markdown fences."""

CALCULATOR_PROMPT = """You are GreenNova, an environmental sustainability expert.
User completed carbon footprint calculator:
- Total CO2: {total_co2} tons/year
- Answers: {answers}

Respond with valid JSON only:
{{
  "badge": "Badge name",
  "badge_color": "green" | "yellow" | "red",
  "insights": ["insight1", "insight2"],
  "tips": ["tip1", "tip2"],
  "comparison": "Comparison text"
}}"""

CONTENT_PROMPT = """You are GreenNova, generating content for a sustainability app.
Generate a {content_type} message. Context: {context}

Respond with valid JSON only:
{{
  "text": "Generated content"
}}"""

COMPARE_PROMPT = """You are GreenNova, an expert environmental sustainability analyst.
Compare these two products:

Product 1: {product1}
Product 2: {product2}

{product1_details}
{product2_details}

Score both on 0-10 scale for each factor. Generate 4-6 comparison factors.

Respond with valid JSON only:
{{
  "winner": "product1" | "product2" | "tie",
  "winnerName": "Winning product name or 'It's a tie!'",
  "summary": "2-3 sentence comparison summary",
  "comparisonFactors": [
    {{"name": "Factor", "score1": 0-10, "score2": 0-10, "winner": "product1" | "product2" | "tie"}}
  ]
}}"""


def _parse_json_response(raw: str) -> dict:
    """Extract JSON from model response, stripping markdown fences."""
    cleaned = re.sub(r"```(?:json)?\s*", "", raw)
    cleaned = cleaned.strip().rstrip("`")
    return json.loads(cleaned)


def _call_ollama(prompt: str, temperature: float = 0.3) -> str:
    """Call Ollama and return raw response."""
    response = ollama.chat(
        model=MODEL_NAME,
        messages=[{"role": "user", "content": prompt}],
        options={"temperature": temperature},
    )
    return response["message"]["content"]


async def analyze_product_text(text: str) -> SustainabilityReport:
    """Analyze product text and return sustainability report. Cached."""
    cache_key = CacheService.make_key("analyze_text", text)
    cached = cache.get(cache_key)
    if cached:
        logger.info("[CACHE] analyze_text: %s", text[:50])
        return SustainabilityReport(**cached)

    logger.info("[OLLAMA] Analyzing: %s", text[:50])
    raw = _call_ollama(ANALYZE_PROMPT.format(product_info=text))
    data = _parse_json_response(raw)
    cache.set(cache_key, data)
    return SustainabilityReport(**data)


async def analyze_product_image(image_b64: str, text: Optional[str] = None) -> SustainabilityReport:
    """Analyze product image and return sustainability report."""
    logger.info("[OLLAMA] Analyzing image")
    messages = [{"role": "user", "content": IMAGE_ANALYZE_PROMPT, "images": [image_b64]}]
    if text:
        messages[0]["content"] += f"\n\nContext: {text}"

    response = ollama.chat(model=MODEL_NAME, messages=messages, options={"temperature": 0.3})
    raw = response["message"]["content"]
    data = _parse_json_response(raw)
    return SustainabilityReport(**data)


async def search_products(query: str) -> SearchResponse:
    """Search products with sustainability scores. Cached."""
    cache_key = CacheService.make_key("search", query)
    cached = cache.get(cache_key)
    if cached:
        logger.info("[CACHE] search: %s", query[:50])
        return SearchResponse(**cached)

    logger.info("[OLLAMA] Searching: %s", query[:50])
    raw = _call_ollama(SEARCH_PROMPT.format(query=query), temperature=0.5)
    data = _parse_json_response(raw)
    cache.set(cache_key, data)
    return SearchResponse(**data)


async def generate_ui_text(section: str) -> UITextResponse:
    """Generate UI text for a section. Cached."""
    cache_key = CacheService.make_key("ui_text", section)
    cached = cache.get(cache_key)
    if cached:
        return UITextResponse(section=section, content=cached, cached=True)

    default_text = FALLBACK_UI_TEXT.get(section, {"text": section})
    keys = json.dumps(default_text)

    try:
        logger.info("[OLLAMA] Generating UI text: %s", section)
        raw = _call_ollama(UI_TEXT_PROMPT.format(section=section, keys=keys), temperature=0.4)
        data = _parse_json_response(raw)
        cache.set(cache_key, data)
        return UITextResponse(section=section, content=data, cached=False)
    except Exception as e:
        logger.error("UI text failed: %s. Using fallback.", e)
        return UITextResponse(section=section, content=default_text, cached=False)


async def generate_calculator_insights(answers: dict, total_co2: float) -> CalculatorScoreResponse:
    """Generate calculator scoring and insights. Cached."""
    cache_key = CacheService.make_key("calculator", answers, total_co2)
    cached = cache.get(cache_key)
    if cached:
        return CalculatorScoreResponse(**cached)

    try:
        logger.info("[OLLAMA] Calculator insights CO2: %s", total_co2)
        raw = _call_ollama(
            CALCULATOR_PROMPT.format(total_co2=total_co2, answers=json.dumps(answers)),
            temperature=0.5,
        )
        data = _parse_json_response(raw)
        data["total_co2"] = total_co2
        cache.set(cache_key, data)
        return CalculatorScoreResponse(**data)
    except Exception as e:
        logger.error("Calculator failed: %s. Using fallback.", e)
        result = CalculatorScoreResponse(**FALLBACK_CALCULATOR)
        result.total_co2 = total_co2
        return result


async def generate_content(content_type: str, context: str) -> ContentGenerateResponse:
    """Generate content (notifications, tips, etc). Cached."""
    cache_key = CacheService.make_key("content", content_type, context)
    cached = cache.get(cache_key)
    if cached:
        return ContentGenerateResponse(content_type=content_type, text=cached, cached=True)

    try:
        logger.info("[OLLAMA] Content: %s", content_type)
        raw = _call_ollama(
            CONTENT_PROMPT.format(content_type=content_type, context=context),
            temperature=0.6,
        )
        data = _parse_json_response(raw)
        text = data.get("text", str(data))
        cache.set(cache_key, text)
        return ContentGenerateResponse(content_type=content_type, text=text, cached=False)
    except Exception as e:
        logger.error("Content failed: %s", e)
        return ContentGenerateResponse(content_type=content_type, text=f"Content: {context}", cached=False)


async def compare_products(request: CompareRequest) -> CompareResponse:
    """Compare two products for sustainability. Cached."""
    cache_key = CacheService.make_key("compare", request.product1, request.product2)
    cached = cache.get(cache_key)
    if cached:
        logger.info("[CACHE] compare: %s vs %s", request.product1[:30], request.product2[:30])
        return CompareResponse(**cached)

    product1_details = ""
    product2_details = ""

    if request.product1_data:
        product1_details = f"Product 1: {request.product1_data.get('name', 'Unknown')}"
        if request.product1_data.get('brand'):
            product1_details += f" by {request.product1_data['brand']}"
        if request.product1_data.get('description'):
            product1_details += f". {request.product1_data['description']}"

    if request.product2_data:
        product2_details = f"Product 2: {request.product2_data.get('name', 'Unknown')}"
        if request.product2_data.get('brand'):
            product2_details += f" by {request.product2_data['brand']}"
        if request.product2_data.get('description'):
            product2_details += f". {request.product2_data['description']}"

    logger.info("[OLLAMA] Comparing: %s vs %s", request.product1[:30], request.product2[:30])
    prompt = COMPARE_PROMPT.format(
        product1=request.product1,
        product2=request.product2,
        product1_details=product1_details or "No details",
        product2_details=product2_details or "No details",
    )
    raw = _call_ollama(prompt, temperature=0.4)
    data = _parse_json_response(raw)
    cache.set(cache_key, data)

    return _build_compare_response(data, request.product1_data, request.product2_data)


def _build_compare_response(data: dict, product1_data: dict, product2_data: dict) -> CompareResponse:
    """Build CompareResponse from AI data."""
    p1 = product1_data or {}
    p2 = product2_data or {}

    product1 = ProductCompareData(
        id=p1.get('id', 'unknown'),
        name=p1.get('product_name') or p1.get('name') or data.get('product1_name', 'Product 1'),
        brand=p1.get('brand'),
        category=p1.get('category'),
        score=p1.get('score', 50),
        tier=p1.get('tier', 'AMBER'),
        carbon_footprint=p1.get('carbon_footprint', 'Medium'),
        badge=p1.get('badge'),
    )

    product2 = ProductCompareData(
        id=p2.get('id', 'unknown'),
        name=p2.get('product_name') or p2.get('name') or data.get('product2_name', 'Product 2'),
        brand=p2.get('brand'),
        category=p2.get('category'),
        score=p2.get('score', 50),
        tier=p2.get('tier', 'AMBER'),
        carbon_footprint=p2.get('carbon_footprint', 'Medium'),
        badge=p2.get('badge'),
    )

    factors = [
        ComparisonFactor(
            name=f.get('name', 'Factor'),
            score1=min(max(f.get('score1', 5), 0), 10),
            score2=min(max(f.get('score2', 5), 0), 10),
            winner=f.get('winner'),
        )
        for f in data.get('comparisonFactors', [])
    ]

    return CompareResponse(
        winner=data.get('winner'),
        winnerName=data.get('winnerName'),
        summary=data.get('summary', 'Comparison completed.'),
        product1=product1,
        product2=product2,
        comparisonFactors=factors,
    )
