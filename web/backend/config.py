"""
EcoTrack Backend - Configuration Management
All environment variables and settings are managed here.
"""

import os
from dotenv import load_dotenv

load_dotenv()

# --- Ollama / AI Settings ---
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:11434")
MODEL_NAME = os.getenv("MODEL_NAME", "gemma3:latest")
MOCK_MODE = os.getenv("MOCK_MODE", "true").lower() == "true"

# --- Cache Settings ---
CACHE_TTL = int(os.getenv("CACHE_TTL", "3600"))  # seconds (default 1 hour)
CACHE_ENABLED = os.getenv("CACHE_ENABLED", "true").lower() == "true"

# --- Server Settings ---
HOST = os.getenv("HOST", "0.0.0.0")
PORT = int(os.getenv("PORT", "8000"))
CORS_ORIGINS = os.getenv("CORS_ORIGINS", "http://localhost:5173,http://localhost:3000").split(",")

# --- Logging ---
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
