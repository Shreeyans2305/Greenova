"""
EcoTrack Backend - Pydantic Models
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


class CalculatorScoreRequest(BaseModel):
    """Request body for POST /api/calculator/score"""
    answers: dict = Field(..., description="User answers keyed by question ID with numeric values")
    total_co2: float = Field(..., description="Total calculated CO2 in tons")


class ProductGenerateRequest(BaseModel):
    """Request body for POST /api/products/generate"""
    context: str = Field("general", description="Product category or context for generation")
    count: int = Field(3, ge=1, le=10, description="Number of products to generate")


class ContentGenerateRequest(BaseModel):
    """Request body for POST /api/content/generate"""
    content_type: str = Field(..., description="Type of content: 'notification', 'tip', 'description', 'error'")
    context: str = Field("", description="Context for the content generation")


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


class UITextResponse(BaseModel):
    """Response for GET /api/ui-text"""
    section: str
    content: dict
    cached: bool = False


class CalculatorScoreResponse(BaseModel):
    """Response for POST /api/calculator/score"""
    total_co2: float
    badge: str
    badge_color: str
    insights: list[str] = []
    tips: list[str] = []
    comparison: str = ""


class ContentGenerateResponse(BaseModel):
    """Response for POST /api/content/generate"""
    content_type: str
    text: str
    cached: bool = False
