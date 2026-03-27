"""
GreenNova Backend - Pydantic Models
Request/Response schemas for all API endpoints.
"""

from pydantic import BaseModel, Field
from typing import Optional


# ===== Request Models =====

class AnalyzeRequest(BaseModel):
    """Request body for POST /api/analyze"""
    text: Optional[str] = Field(None, description="Product name, ingredients, or barcode number")
    image_b64: Optional[str] = Field(None, description="Base64-encoded product label image (JPEG/PNG)")
    barcode: Optional[str] = Field(None, description="Barcode number for product lookup")


class SearchRequest(BaseModel):
    """Request body for POST /api/search"""
    query: str = Field(..., description="Search query — product name, category, or brand")


# ===== Response Models =====

class IngredientAnalysis(BaseModel):
    """Single ingredient sustainability analysis"""
    name: str
    sustainability: str  # "High", "Medium", "Low"
    impact: str          # "Very Low", "Low", "Moderate", "High"
    score: int = Field(ge=0, le=100)


class Alternative(BaseModel):
    """An eco-friendly product alternative"""
    name: str
    score: int = Field(ge=0, le=100)
    price: Optional[str] = None
    reason: str


class SustainabilityReport(BaseModel):
    """Full sustainability analysis report"""
    product_name: str
    brand: Optional[str] = None
    category: Optional[str] = None
    score: int = Field(ge=0, le=100)
    tier: str             # "GREEN", "AMBER", "RED"
    badge: Optional[str] = None
    carbon_footprint: str  # "Very Low", "Low", "Medium", "High", "Very High"
    description: str
    ingredients_analysis: list[IngredientAnalysis] = []
    alternatives: list[Alternative] = []


class SearchResultItem(BaseModel):
    """A single search result"""
    id: str
    name: str
    brand: Optional[str] = None
    category: Optional[str] = None
    score: int = Field(ge=0, le=100)
    tier: str
    badge: Optional[str] = None
    carbon_footprint: str
    description: str


class SearchResponse(BaseModel):
    """Response body for POST /api/search"""
    type: str  # "GENERALIZED" or "DETAILED"
    results: list[SearchResultItem] = []


class HealthResponse(BaseModel):
    """Health check response"""
    status: str
    mock_mode: bool
    model: str
    ollama_url: str
