# 🌱 GreenNova Backend

FastAPI backend for AI-powered sustainability analysis. Uses **Ollama** with **Gemma 3 12B** locally for privacy-first product analysis.

## Quick Start

```bash
# 1. Create virtual env
python -m venv venv
source venv/bin/activate      # Linux/Mac
venv\Scripts\activate         # Windows

# 2. Install dependencies
pip install -r requirements.txt

# 3. Configure
cp .env.example .env          # Edit if needed

# 4. Run
uvicorn main:app --reload
# → http://localhost:8000
# → Swagger Docs: http://localhost:8000/docs
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET`  | `/health` | Health check + config info |
| `POST` | `/api/analyze` | Analyze product sustainability |
| `POST` | `/api/search` | Search products by name/category |

## Mock Mode

By default, `MOCK_MODE=true` — the server returns hardcoded responses without needing Ollama.

To use **live AI analysis**:
1. Install Ollama: https://ollama.com
2. Pull the model: `ollama pull gemma3:12b`
3. Set `MOCK_MODE=false` in `.env`
4. Restart the server

## File Structure

```
backend/
├── main.py          # FastAPI app, routes, CORS
├── config.py        # Environment variable management
├── models.py        # Pydantic request/response schemas
├── ai_service.py    # Ollama/Gemma 3 integration + mock toggle
├── mock_data.py     # Hardcoded mock responses
├── requirements.txt # Python dependencies
├── .env             # Local config (gitignored)
└── .env.example     # Config template
```
