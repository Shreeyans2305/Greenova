"""
GreenNova Backend - FastAPI Application
Main entry point with CORS, routes, and health check.
"""

import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from config import CORS_ORIGINS, MOCK_MODE, MODEL_NAME, OLLAMA_URL, HOST, PORT, LOG_LEVEL
from models import (
    AnalyzeRequest,
    SearchRequest,
    SustainabilityReport,
    SearchResponse,
    HealthResponse,
)
from ai_service import analyze_product_text, analyze_product_image, search_products

# --- Logging setup ---
logging.basicConfig(
    level=getattr(logging, LOG_LEVEL.upper(), logging.INFO),
    format="%(asctime)s | %(levelname)-7s | %(name)s | %(message)s",
    datefmt="%H:%M:%S",
)
logger = logging.getLogger("greennova")


# --- Lifespan ---
@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("=" * 60)
    logger.info("🌱 GreenNova Backend Starting")
    logger.info("  MOCK_MODE  : %s", MOCK_MODE)
    logger.info("  MODEL      : %s", MODEL_NAME)
    logger.info("  OLLAMA_URL : %s", OLLAMA_URL)
    logger.info("  CORS       : %s", CORS_ORIGINS)
    logger.info("=" * 60)
    yield
    logger.info("🌱 GreenNova Backend Shutting Down")


# --- App ---
app = FastAPI(
    title="GreenNova API",
    description="AI-powered sustainability reports and eco-friendly product recommendations.",
    version="1.0.0",
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
            # Image analysis (multimodal)
            report = await analyze_product_image(request.image_b64, request.text)
        else:
            # Text-only analysis
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
    """
    Search for products and get sustainability-rated results.
    Uses Ollama for live searches, or returns mock data in MOCK_MODE.
    """
    if not request.query or not request.query.strip():
        raise HTTPException(status_code=400, detail="'query' must not be empty.")

    try:
        results = await search_products(request.query.strip())
        logger.info("Search → '%s' | %d results", request.query, len(results.results))
        return results

    except Exception as e:
        logger.error("Search endpoint error: %s", e)
        raise HTTPException(status_code=500, detail=f"Search failed: {str(e)}")


# --- Run with: uvicorn main:app --reload ---
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host=HOST, port=PORT, reload=True)
