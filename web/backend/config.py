"""
EcoTrack Backend - Configuration Management
"""

import os

# --- Ollama / AI Settings ---
OLLAMA_URL = "http://localhost:11434"
MODEL_NAME = "gemma3:4b"

# --- Cache Settings ---
CACHE_TTL = 3600
CACHE_ENABLED = True

# --- Server Settings ---
HOST = "0.0.0.0"
PORT = 8000
CORS_ORIGINS = ["http://localhost:5173", "http://localhost:3000"]

# --- Logging ---
LOG_LEVEL = "INFO"
