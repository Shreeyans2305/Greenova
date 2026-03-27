"""
GreenNova Backend — FastAPI server that proxies AI requests to Ollama
and fetches real product data from Open Food Facts.
"""
import base64
import json
import os
import time
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
        # Try to find JSON object in the text
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
    """Extract only the essential fields from product data for AI context."""
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


def _sustainability_prompt(context: str) -> str:
    return f"""{context}

Respond in JSON format with the following structure:
{{
  "productName": "Product name or description",
  "brand": "Brand name if identifiable, otherwise null",
  "carbonScore": 0-100 (lower is better, be realistic),
  "sustainabilityGrade": "A/B/C/D/F",
  "positiveFactors": ["list of positive environmental factors"],
  "negativeFactors": ["list of negative environmental factors"],
  "recommendations": ["sustainability recommendations"],
  "detailedAnalysis": "Detailed sustainability analysis text (2-3 paragraphs)",
  "ecoEquivalents": {{
    "treesNeeded": number (trees needed to offset this product's CO2),
    "carMiles": number (equivalent car miles driven),
    "plasticBags": number (equivalent plastic bags),
    "lightBulbHours": number (hours a 60W bulb could run)
  }}
}}"""


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
    prompt = _sustainability_prompt(
        f"Analyze these product ingredients for sustainability and environmental impact.\n"
        f"Product Name: {label}\nIngredients: {req.text}"
    )
    data = await _ollama_generate(prompt)
    data.setdefault("productName", label)
    return data


# ---- Image analysis -------------------------------------------------------
@app.post("/api/image")
async def analyze_image(image: UploadFile = File(...)):
    contents = await image.read()
    b64 = base64.b64encode(contents).decode("utf-8")
    prompt = _sustainability_prompt(
        "Analyze this product image and provide a detailed sustainability report.\n"
        "Identify the brand and product if visible.\n"
        "[Image data is provided separately]"
    )
    data = await _ollama_generate(prompt, images=[b64])
    return data


# ---- Text search with AI --------------------------------------------------
@app.post("/api/search")
async def search_text(req: SearchRequest):
    prompt = _sustainability_prompt(
        f"Provide a sustainability report for the product or product category: {req.query}\n"
        "This should cover environmental considerations for this type of product."
    )
    data = await _ollama_generate(prompt)
    data.setdefault("productName", req.query)
    data["isGeneralized"] = True
    return data


# ---- Compare two products -------------------------------------------------
@app.post("/api/compare")
async def compare_products(req: CompareRequest):
    # Trim product data to essentials to avoid LLM context overflow
    extra1 = _trim_product_data(req.product1_data) if req.product1_data else ""
    extra2 = _trim_product_data(req.product2_data) if req.product2_data else ""

    ctx1 = f"\nProduct 1 info: {extra1}" if extra1 else ""
    ctx2 = f"\nProduct 2 info: {extra2}" if extra2 else ""

    prompt = f"""Compare these two products for sustainability and environmental impact:
Product 1: {req.product1}{ctx1}
Product 2: {req.product2}{ctx2}

Respond in JSON format:
{{
  "winner": "product1 or product2",
  "winnerName": "name of better product",
  "summary": "2-3 sentence summary of which is better and why",
  "product1": {{
    "productName": "{req.product1}",
    "carbonScore": 0-100,
    "sustainabilityGrade": "A/B/C/D/F",
    "positiveFactors": ["..."],
    "negativeFactors": ["..."]
  }},
  "product2": {{
    "productName": "{req.product2}",
    "carbonScore": 0-100,
    "sustainabilityGrade": "A/B/C/D/F",
    "positiveFactors": ["..."],
    "negativeFactors": ["..."]
  }},
  "comparisonFactors": [
    {{"factor": "Factor name", "product1Score": 0-10, "product2Score": 0-10, "explanation": "..."}}
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

Suggest 3 eco-friendly alternative products that are better for the environment.
For each alternative, explain WHY it is better.

Respond in JSON format:
{{
  "alternatives": [
    {{
      "name": "Alternative product name (be specific with brand if possible)",
      "brand": "Brand name",
      "estimatedCarbonScore": 0-100 (should be lower than {int(req.carbon_score)}),
      "sustainabilityGrade": "A/B/C",
      "whyBetter": "1-2 sentence explanation of why this is better",
      "keyBenefits": ["benefit1", "benefit2"]
    }}
  ],
  "generalTip": "A short general tip for choosing sustainable products in this category"
}}"""
    data = await _ollama_generate(prompt)
    return data


# ---- Carbon summary -------------------------------------------------------
@app.post("/api/carbon-summary")
async def carbon_summary(req: CarbonSummaryRequest):
    history_json = json.dumps(req.purchase_history[:50])  # limit size
    prompt = f"""Analyze this purchase history and generate a carbon footprint summary.
Purchase History: {history_json}

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
                          "nova_group,quantity",
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
        }
    except Exception as e:
        return {"barcode": barcode, "error": str(e)}


# ---------------------------------------------------------------------------
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
