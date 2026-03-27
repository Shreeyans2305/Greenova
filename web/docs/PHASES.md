# Project Phases - GreenNova (5-Hour Roadmap)

## Phase 1: Foundation (Hour 1)
- **Frontend**: Setup React + Vite + Tailwind CSS. 
- **Backend**: Setup FastAPI + CORS + Ollama Python library. 
- **Configuration**: Create `.env` for frontend and `config.py` for backend.
- **Mock Mode**: Implement `ai_service.py` with mock responses for rapid prototyping.

## Phase 2: Core Components (Hour 2)
- **Frontend**: Build `<SustainabilityScoreCard />`, `<SearchBox />`, and `<ReportDetail />`.
- **Backend**: Implement the `POST /api/analyze` and `POST /api/search` endpoints.

## Phase 3: Reports & History (Hour 3)
- **Analytics**: Use **Recharts** for trend line charts (Carbon Footprint Score).
- **Storage**: Implement `localStorage` for purchase history and carbon footprint tracking.
- **Reports**: Finalize the "Add to Purchase History" button logic.

## Phase 4: AI & Visuals (Hour 4)
- **Search Lens**: Implement the image upload/paste logic for visual search.
- **AI Service**: Finalize `ai_service.py` to correctly map mock/live responses for Gemma 3 12B.
- **Profile/Badges**: Develop the badges (Eco Champion 🌱) and reward system logic.

## Phase 5: Polishing & Deployment (Hour 5)
- **UI Refinement**: Apply green-themed design tokens and responsiveness (Mobile-first).
- **Validation**: Test the full cycle from search to report to history.
- **Documentation**: Finalize README, API reference, and screenshots.

## Summary Checklist (Goal: 5 Hours)
- [ ] React project initialized
- [ ] FastAPI project initialized
- [ ] Core UI components built
- [ ] Sustainability Score logic working (mocked/live)
- [ ] History & Metrics charts (Recharts)
- [ ] Visual/Category search working
- [ ] Badges and reward system
- [ ] README & Installation Guide
