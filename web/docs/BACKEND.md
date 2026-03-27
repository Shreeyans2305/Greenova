# Backend Specification - GreenNova

## 1. Project Overview
The GreenNova backend is a FastAPI application that serves as the AI-orchestration layer. It processes product data and interfaces with **Ollama** to analyze environmental impacts.

## 2. Core Service: `ai_service.py`
All AI calls are centralized in `ai_service.py`.
- **MOCK_MODE**: A boolean flag in `config.py`.
- **Functions**:
  - `analyze_product_text()`: Handles product name or ingredient strings.
  - `analyze_product_image()`: Processes image files (labels/barcodes) for identification.
- **AI Model**: Gemma 3 12B via the `ollama` Python client.

## 3. Configuration Management (`config.py`)
Configuration is handled through environment variables:
- `OLLAMA_URL`: URL of the local Ollama instance (default: `http://localhost:11434`).
- `MODEL_NAME`: The model used (default: `gemma3:12b`).
- `MOCK_MODE`: If `true`, returns static JSON reports (Default for Dev).

## 4. API Endpoints

### 4.1 `POST /api/analyze`
Submits product data for sustainability analysis.
- **Payload**: `{ "text": string, "image_b64": string? }`
- **Response**: Full `SustainabilityReport` JSON.

### 4.2 `POST /api/search`
Generalized product search.
- **Payload**: `{ "query": string }`
- **Response**: Sustainability report card (generalized vs detailed results).

### 4.3 `POST /api/history/add` (Deleted)
- No user history is synced to the backend to ensure an Auth-free and privacy-first design.

### 4.4 `GET /api/history` (Deleted)
- No history retrieval from backend.

## 5. Development Strategy
- **Step 1**: Use `MOCK_MODE=true` to test end-to-end frontend integration without dependency on Ollama performance.
- **Step 2**: Create a `.env` file from `.env.example`.
- **Step 3**: Launch with `uvicorn main:app --reload`.
