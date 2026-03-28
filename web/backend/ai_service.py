"""
GreenNova Backend - AI Service
Centralized AI interaction layer. Calls Ollama (Gemma 3) for live analysis,
or returns mock data when MOCK_MODE is enabled.
All responses are cached with TTL to reduce API calls.
"""

import json
import logging
import re
from typing import Optional

import ollama

from config import OLLAMA_URL, MODEL_NAME, MOCK_MODE
from models import (
    SustainabilityReport,
    IngredientAnalysis,
    Alternative,
    SearchResponse,
    SearchResultItem,
    UITextResponse,
    CalculatorScoreResponse,
    ContentGenerateResponse,
)
from mock_data import get_mock_report, get_mock_search, get_fallback_ui_text, get_fallback_calculator, FALLBACK_UI_TEXT
from cache_service import cache, CacheService

logger = logging.getLogger("greenNova.ai_service")


# ===== Prompts =====

ANALYZE_PROMPT = """You are GreenNova, an expert environmental sustainability analyst.
Analyze the following product and provide a detailed sustainability report.

Product information: {product_info}

You MUST respond with valid JSON only, no markdown fences, matching this exact structure:
{{
  "product_name": "Name of the product",
  "brand": "Brand name or null",
  "category": "Product category",
  "score": 0-100 integer (sustainability score, higher = better),
  "tier": "GREEN" if score >= 75, "AMBER" if score >= 50, "RED" if score < 50,
  "badge": "Eco Champion 🌱" if score >= 85, "Getting Greener 🌿" if score >= 70, null otherwise,
  "carbon_footprint": "Very Low" | "Low" | "Medium" | "High" | "Very High",
  "description": "Brief product description and sustainability assessment",
  "ingredients_analysis": [
    {{
      "name": "Ingredient name",
      "sustainability": "High" | "Medium" | "Low",
      "impact": "Very Low" | "Low" | "Moderate" | "High",
      "score": 0-100 integer
    }}
  ],
  "alternatives": [
    {{
      "name": "Alternative product name",
      "score": 0-100 integer,
      "price": "$X.XX or null",
      "reason": "Why this is a better choice"
    }}
  ]
}}
"""

SEARCH_PROMPT = """You are GreenNova, an expert environmental sustainability analyst.
A user is searching for: "{query}"

Provide 3-5 sustainability-rated product results for this search query.

You MUST respond with valid JSON only, no markdown fences, matching this exact structure:
{{
  "type": "GENERALIZED",
  "results": [
    {{
      "id": "unique_id_string",
      "name": "Product name",
      "brand": "Brand name",
      "category": "Category",
      "score": 0-100 integer,
      "tier": "GREEN" | "AMBER" | "RED",
      "badge": "badge or null",
      "carbon_footprint": "Very Low" | "Low" | "Medium" | "High" | "Very High",
      "description": "Brief description"
    }}
  ]
}}
"""

IMAGE_ANALYZE_PROMPT = """You are GreenNova, an expert environmental sustainability analyst.
A user has uploaded a product label image. Analyze the visible product information
(brand, ingredients, packaging type) and provide a detailed sustainability report.

You MUST respond with valid JSON only, no markdown fences, matching the same structure
as a standard product analysis with: product_name, brand, category, score, tier, badge,
carbon_footprint, description, ingredients_analysis, and alternatives.
"""

UI_TEXT_PROMPT = """You are GreenNova, generating English UI text for a sustainability web app.
Rewrite the default UI text for the "{section}" section to make it more engaging and sustainability-focused.

You MUST respond with valid JSON only, no markdown fences.
The JSON must contain short, natural English strings for each UI element.

Section: {section}
Default text to rewrite (maintain these exact JSON keys):
{keys}

IMPORTANT RULES:
1. Maintain exactly the same JSON keys.
2. If a value contains placeholder variables like {{average_score}} or {{earned}}, you MUST keep them exactly as they are. Do not invent new placeholders.
3. Keep text concise and friendly.
4. Do NOT include any markdown or code fences in your response.
"""

CALCULATOR_PROMPT = """You are GreenNova, an environmental sustainability expert.
A user completed a carbon footprint calculator with these results:
- Total CO2 emissions: {total_co2} tons/year
- Answers: {answers}

Provide personalized insights about their carbon footprint.

You MUST respond with valid JSON only, no markdown fences:
{{
  "badge": "A short badge name (e.g. 'Eco Champion 🌿', 'Conscious Citizen 🌎', 'Needs Improvement 🏭')",
  "badge_color": "green" | "yellow" | "red",
  "insights": ["2-3 short personalized insights about their footprint"],
  "tips": ["2-3 actionable tips to reduce their footprint"],
  "comparison": "A brief sentence comparing to average (world avg ~4.5 tons/year)"
}}
"""

CONTENT_PROMPT = """You are GreenNova, generating engaging content for a sustainability web app.
Generate a {content_type} message.
Context: {context}

You MUST respond with valid JSON only, no markdown fences:
{{
  "text": "The generated content text"
}}
"""


# ===== Helper: Parse AI Response =====

def _parse_json_response(raw: str) -> dict:
    """Extract JSON from a model response, stripping markdown fences if present."""
    cleaned = re.sub(r"```(?:json)?\s*", "", raw)
    cleaned = cleaned.strip().rstrip("`")
    return json.loads(cleaned)


def _call_ollama(prompt: str, temperature: float = 0.3) -> str:
    """Call Ollama and return the raw response content."""
    response = ollama.chat(
        model=MODEL_NAME,
        messages=[{"role": "user", "content": prompt}],
        options={"temperature": temperature},
    )
    return response["message"]["content"]


# ===== Core Functions (existing, now with cache) =====

async def analyze_product_text(text: str) -> SustainabilityReport:
    """Analyze product text and return a sustainability report. Cached."""
    if MOCK_MODE:
        logger.info("[MOCK] Returning mock analyze report for: %s", text[:50])
        return get_mock_report(text)

    cache_key = CacheService.make_key("analyze_text", text)
    cached = cache.get(cache_key)
    if cached:
        logger.info("[CACHE HIT] analyze_text: %s", text[:50])
        return SustainabilityReport(**cached)

    try:
        logger.info("[LIVE] Calling Ollama (%s) for text analysis: %s", MODEL_NAME, text[:50])
        raw = _call_ollama(ANALYZE_PROMPT.format(product_info=text))
        data = _parse_json_response(raw)
        cache.set(cache_key, data)
        return SustainabilityReport(**data)
    except Exception as e:
        logger.error("Ollama analyze failed: %s. Falling back to mock.", e)
        return get_mock_report(text)


async def analyze_product_image(image_b64: str, text: Optional[str] = None) -> SustainabilityReport:
    """Analyze a product image (base64) and return a sustainability report."""
    if MOCK_MODE:
        logger.info("[MOCK] Returning mock analyze report for image upload")
        return get_mock_report(text)

    try:
        logger.info("[LIVE] Calling Ollama (%s) for image analysis", MODEL_NAME)
        messages = [{"role": "user", "content": IMAGE_ANALYZE_PROMPT, "images": [image_b64]}]
        if text:
            messages[0]["content"] += f"\n\nAdditional context: {text}"

        response = ollama.chat(
            model=MODEL_NAME,
            messages=messages,
            options={"temperature": 0.3},
        )
        raw = response["message"]["content"]
        data = _parse_json_response(raw)
        return SustainabilityReport(**data)
    except Exception as e:
        logger.error("Ollama image analyze failed: %s. Falling back to mock.", e)
        return get_mock_report(text)


async def search_products(query: str) -> SearchResponse:
    """Search for products and return sustainability-scored results. Cached."""
    if MOCK_MODE:
        logger.info("[MOCK] Returning mock search results for: %s", query[:50])
        return get_mock_search(query)

    cache_key = CacheService.make_key("search", query)
    cached = cache.get(cache_key)
    if cached:
        logger.info("[CACHE HIT] search: %s", query[:50])
        return SearchResponse(**cached)

    try:
        logger.info("[LIVE] Calling Ollama (%s) for search: %s", MODEL_NAME, query[:50])
        raw = _call_ollama(SEARCH_PROMPT.format(query=query), temperature=0.5)
        data = _parse_json_response(raw)
        cache.set(cache_key, data)
        return SearchResponse(**data)
    except Exception as e:
        logger.error("Ollama search failed: %s. Falling back to mock.", e)
        return get_mock_search(query)


# ===== New AI Functions =====

async def generate_ui_text(section: str) -> UITextResponse:
    """Generate UI text for a specific section. Cached with TTL."""
    cache_key = CacheService.make_key("ui_text", section)
    cached = cache.get(cache_key)
    if cached:
        logger.info("[CACHE HIT] ui_text: %s", section)
        return UITextResponse(section=section, content=cached, cached=True)

    if MOCK_MODE:
        content = get_fallback_ui_text(section)
        return UITextResponse(section=section, content=content, cached=False)

    default_text = get_fallback_ui_text(section)
    keys = json.dumps(default_text, indent=2)

    try:
        logger.info("[LIVE] Generating UI text for section: %s", section)
        raw = _call_ollama(
            UI_TEXT_PROMPT.format(section=section, keys=keys),
            temperature=0.4,
        )
        data = _parse_json_response(raw)
        cache.set(cache_key, data)
        return UITextResponse(section=section, content=data, cached=False)
    except Exception as e:
        logger.error("UI text generation failed for %s: %s. Using fallback.", section, e)
        content = get_fallback_ui_text(section)
        return UITextResponse(section=section, content=content, cached=False)


async def generate_calculator_insights(answers: dict, total_co2: float) -> CalculatorScoreResponse:
    """Generate AI-powered calculator scoring and insights. Cached."""
    cache_key = CacheService.make_key("calculator", answers, total_co2)
    cached = cache.get(cache_key)
    if cached:
        logger.info("[CACHE HIT] calculator insights")
        return CalculatorScoreResponse(**cached)

    if MOCK_MODE:
        return get_fallback_calculator(total_co2)

    try:
        logger.info("[LIVE] Generating calculator insights (CO2: %s)", total_co2)
        raw = _call_ollama(
            CALCULATOR_PROMPT.format(total_co2=total_co2, answers=json.dumps(answers)),
            temperature=0.5,
        )
        data = _parse_json_response(raw)
        data["total_co2"] = total_co2
        cache.set(cache_key, data)
        return CalculatorScoreResponse(**data)
    except Exception as e:
        logger.error("Calculator insights failed: %s. Using fallback.", e)
        return get_fallback_calculator(total_co2)


async def generate_content(content_type: str, context: str) -> ContentGenerateResponse:
    """Generate generic content (notifications, tips, errors). Cached."""
    cache_key = CacheService.make_key("content", content_type, context)
    cached = cache.get(cache_key)
    if cached:
        return ContentGenerateResponse(content_type=content_type, text=cached, cached=True)

    if MOCK_MODE:
        return ContentGenerateResponse(
            content_type=content_type,
            text=f"Sample {content_type}: {context}",
            cached=False,
        )

    try:
        logger.info("[LIVE] Generating content: %s", content_type)
        raw = _call_ollama(
            CONTENT_PROMPT.format(content_type=content_type, context=context),
            temperature=0.6,
        )
        data = _parse_json_response(raw)
        text = data.get("text", str(data))
        cache.set(cache_key, text)
        return ContentGenerateResponse(content_type=content_type, text=text, cached=False)
    except Exception as e:
        logger.error("Content generation failed: %s", e)
        return ContentGenerateResponse(
            content_type=content_type,
            text=f"Sample {content_type}: {context}",
            cached=False,
        )
