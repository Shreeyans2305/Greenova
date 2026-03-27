# Installation Guide - GreenNova

## 1. Prerequisites
- **Node.js**: v18 or later.
- **Python**: v3.10 or later.
- **Ollama**: (Optional for Dev, required for AI functions) Download from [ollama.com](https://ollama.com).
- **Gemma 3 12B**: Once Ollama is installed, run:
  ```bash
  ollama pull gemma3:12b
  ```

## 2. Backend Setup (FastAPI)

1. **Navigate** to the backend folder:
   ```bash
   cd backend
   ```
2. **Create** a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```
3. **Install Dependencies**:
   ```bash
   pip install -r requirements.txt
   ```
4. **Environment Config**:
   - Create a `config.py` from the template provided in the docs.
   - Set `MOCK_MODE=True` for initial testing.
5. **Start Server**:
   ```bash
   uvicorn main:app --reload
   ```

## 3. Frontend Setup (React)

1. **Navigate** to the frontend folder:
   ```bash
   cd frontend
   ```
2. **Install Dependencies**:
   ```bash
   npm install
   ```
3. **Environment Config**:
   - Create a `.env` file.
   - Set `VITE_API_BASE_URL=http://localhost:8000`
   - Set `VITE_MOCK_MODE=true`
4. **Launch Application**:
   ```bash
   npm run dev
   ```

## 4. Troubleshooting

| Issue | Resolution |
|---|---|
| CORS Error | Ensure FastAPI has CORS middleware enabled for `http://localhost:5173`. |
| Ollama Connection | Verify Ollama is running (`curl http://localhost:11434/api/tags`). |
| Empty Charts | Ensure initial data exists in `localStorage` or check Recharts props. |

## 5. Mock Mode Testing
To verify the UI without AI latency:
- Set **VITE_MOCK_MODE=true** in the frontend `.env`.
- Set **MOCK_MODE=True** in the backend `config.py`.
- This ensures near-instant responses for rapid design validation.
