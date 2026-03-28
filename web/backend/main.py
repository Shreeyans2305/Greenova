"""
GreenNova Backend - FastAPI Application
Main entry point with CORS, routes, and health check.
"""

import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware

from config import CORS_ORIGINS, MOCK_MODE, MODEL_NAME, OLLAMA_URL, HOST, PORT, LOG_LEVEL, CACHE_ENABLED, CACHE_TTL
from models import (
    AnalyzeRequest,
    SearchRequest,
    CalculatorScoreRequest,
    ProductGenerateRequest,
    ContentGenerateRequest,
    SustainabilityReport,
    SearchResponse,
    HealthResponse,
    UITextResponse,
    CalculatorScoreResponse,
    ContentGenerateResponse,
)
from ai_service import (
    analyze_product_text,
    analyze_product_image,
    search_products,
    generate_ui_text,
    generate_calculator_insights,
    generate_content,
)
from cache_service import cache

# --- Logging setup ---
logging.basicConfig(
    level=getattr(logging, LOG_LEVEL.upper(), logging.INFO),
    format="%(asctime)s | %(levelname)-7s | %(name)s | %(message)s",
    datefmt="%H:%M:%S",
)
logger = logging.getLogger("greenNova")


# --- Lifespan ---
@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("=" * 60)
    logger.info("🌱 GreenNova Backend Starting")
    logger.info("  MOCK_MODE  : %s", MOCK_MODE)
    logger.info("  MODEL      : %s", MODEL_NAME)
    logger.info("  OLLAMA_URL : %s", OLLAMA_URL)
    logger.info("  CACHE      : %s (TTL=%ds)", CACHE_ENABLED, CACHE_TTL)
    logger.info("  CORS       : %s", CORS_ORIGINS)
    logger.info("=" * 60)
    yield
    logger.info("🌱 GreenNova Backend Shutting Down")


# --- App ---
app = FastAPI(
    title="GreenNova API",
    description="AI-powered sustainability reports and eco-friendly product recommendations.",
    version="2.0.0",
    lifespan=lifespan,
)

# --- CORS ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ===== Routes =====

@app.get("/", tags=["Health"])
async def root():
    return {"message": "🌱 GreenNova API is running", "docs": "/docs"}


@app.get("/health", response_model=HealthResponse, tags=["Health"])
async def health_check():
    """Health check endpoint for monitoring and frontend connectivity tests."""
    return HealthResponse(
        status="ok",
        mock_mode=MOCK_MODE,
        model=MODEL_NAME,
        ollama_url=OLLAMA_URL,
    )


@app.post("/api/analyze", response_model=SustainabilityReport, tags=["Analysis"])
async def analyze_product(request: AnalyzeRequest):
    """
    Analyze a product's sustainability.
    
    - Send `text` for ingredient/name/barcode analysis.
    - Send `image_b64` for label image analysis (with optional `text` context).
    - At least one of `text` or `image_b64` must be provided.
    """
    if not request.text and not request.image_b64:
        raise HTTPException(
            status_code=400,
            detail="At least one of 'text' or 'image_b64' must be provided.",
        )

    try:
        if request.image_b64:
            report = await analyze_product_image(request.image_b64, request.text)
        else:
            input_text = request.text
            if request.barcode:
                input_text += f" (barcode: {request.barcode})"
            report = await analyze_product_text(input_text)

        logger.info("Analyze → %s | Score: %d | Tier: %s",
                     report.product_name, report.score, report.tier)
        return report

    except Exception as e:
        logger.error("Analyze endpoint error: %s", e)
        raise HTTPException(status_code=500, detail=f"Analysis failed: {str(e)}")


@app.post("/api/search", response_model=SearchResponse, tags=["Search"])
async def search(request: SearchRequest):
    """Search for products and get sustainability-rated results."""
    if not request.query or not request.query.strip():
        raise HTTPException(status_code=400, detail="'query' must not be empty.")

    try:
        results = await search_products(request.query.strip())
        logger.info("Search → '%s' | %d results", request.query, len(results.results))
        return results

    except Exception as e:
        logger.error("Search endpoint error: %s", e)
        raise HTTPException(status_code=500, detail=f"Search failed: {str(e)}")


# ===== New AI Content Endpoints =====

@app.get("/api/ui-text", response_model=UITextResponse, tags=["AI Content"])
async def get_ui_text(section: str = Query(..., description="UI section: navbar, home, search, report, calculator, history, profile, ingredients, alternatives, chart, footer")):
    """Fetch AI-generated UI strings for a specific section."""
    try:
        result = await generate_ui_text(section)
        logger.info("UI Text → section=%s | cached=%s", section, result.cached)
        return result
    except Exception as e:
        logger.error("UI text endpoint error: %s", e)
        raise HTTPException(status_code=500, detail=f"UI text generation failed: {str(e)}")


@app.post("/api/calculator/score", response_model=CalculatorScoreResponse, tags=["AI Content"])
async def calculator_score(request: CalculatorScoreRequest):
    """AI-powered calculator scoring with personalized insights."""
    try:
        result = await generate_calculator_insights(request.answers, request.total_co2)
        logger.info("Calculator → CO2=%.1f | Badge=%s", result.total_co2, result.badge)
        return result
    except Exception as e:
        logger.error("Calculator endpoint error: %s", e)
        raise HTTPException(status_code=500, detail=f"Calculator scoring failed: {str(e)}")


@app.post("/api/content/generate", response_model=ContentGenerateResponse, tags=["AI Content"])
async def content_generate(request: ContentGenerateRequest):
    """Generic AI content generation (notifications, tips, descriptions, errors)."""
    try:
        result = await generate_content(request.content_type, request.context)
        logger.info("Content → type=%s | cached=%s", request.content_type, result.cached)
        return result
    except Exception as e:
        logger.error("Content generate endpoint error: %s", e)
        raise HTTPException(status_code=500, detail=f"Content generation failed: {str(e)}")


# ===== Cache Management =====

@app.delete("/api/cache", tags=["Cache"])
async def clear_cache():
    """Clear the AI response cache."""
    count = cache.clear()
    return {"message": f"Cache cleared ({count} entries removed)"}


@app.get("/api/cache/stats", tags=["Cache"])
async def cache_stats():
    """Get cache statistics."""
    return cache.stats()


# --- Run with: uvicorn main:app --reload ---
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host=HOST, port=PORT, reload=True)
