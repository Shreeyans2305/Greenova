"""
GreenNova Backend - AI Service
Centralized AI interaction layer. Calls Ollama (Gemma 3 12B) for live analysis,
or returns mock data when MOCK_MODE is enabled.

Toggle: Set MOCK_MODE=true in .env to use hardcoded responses (faster dev).
        Set MOCK_MODE=false to call Ollama locally for real AI analysis.
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
)
from mock_data import get_mock_report, get_mock_search

logger = logging.getLogger("greennova.ai_service")


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


# ===== Helper: Parse AI Response =====

def _parse_json_response(raw: str) -> dict:
    """Extract JSON from a model response, stripping markdown fences if present."""
    # Strip markdown code fences
    cleaned = re.sub(r"```(?:json)?\s*", "", raw)
    cleaned = cleaned.strip().rstrip("`")
    return json.loads(cleaned)


# ===== Core Functions =====

async def analyze_product_text(text: str) -> SustainabilityReport:
    """
    Analyze product text (name, ingredients, barcode) and return a sustainability report.
    Uses mock data when MOCK_MODE=true, otherwise calls Ollama/Gemma 3.
    """
    if MOCK_MODE:
        logger.info("[MOCK] Returning mock analyze report for: %s", text[:50])
        return get_mock_report(text)

    # TODO: replace with Ollama call — this is the LIVE path
    try:
        logger.info("[LIVE] Calling Ollama (%s) for text analysis: %s", MODEL_NAME, text[:50])
        response = ollama.chat(
            model=MODEL_NAME,
            messages=[
                {"role": "user", "content": ANALYZE_PROMPT.format(product_info=text)}
            ],
            options={"temperature": 0.3},
        )
        raw = response["message"]["content"]
        data = _parse_json_response(raw)
        return SustainabilityReport(**data)
    except Exception as e:
        logger.error("Ollama analyze failed: %s. Falling back to mock.", e)
        return get_mock_report(text)


async def analyze_product_image(image_b64: str, text: Optional[str] = None) -> SustainabilityReport:
    """
    Analyze a product image (base64 encoded) and return a sustainability report.
    Gemma 3 supports multimodal (text + image) inputs.
    """
    if MOCK_MODE:
        logger.info("[MOCK] Returning mock analyze report for image upload")
        return get_mock_report(text)

    # TODO: replace with Ollama call — this is the LIVE path
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
    """
    Search for products by name/category and return sustainability-scored results.
    """
    if MOCK_MODE:
        logger.info("[MOCK] Returning mock search results for: %s", query[:50])
        return get_mock_search(query)

    # TODO: replace with Ollama call — this is the LIVE path
    try:
        logger.info("[LIVE] Calling Ollama (%s) for search: %s", MODEL_NAME, query[:50])
        response = ollama.chat(
            model=MODEL_NAME,
            messages=[
                {"role": "user", "content": SEARCH_PROMPT.format(query=query)}
            ],
            options={"temperature": 0.5},
        )
        raw = response["message"]["content"]
        data = _parse_json_response(raw)
        return SearchResponse(**data)
    except Exception as e:
        logger.error("Ollama search failed: %s. Falling back to mock.", e)
        return get_mock_search(query)
