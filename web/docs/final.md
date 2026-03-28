# GreenNova AI Integration & Hardcoded Text Removal Plan

## Objective
- **Remove all hardcoded text** from the web application
- **Integrate Ollama gemma3:latest** for generating all dynamic content
- **Single language (English)** with AI-generated text
- **Cache AI responses** with TTL to reduce API calls

---

## Phase 1: Backend Ollama Enhancement

### 1.1 Update Ollama Configuration
| Task | Description |
|------|-------------|
| 1.1.1 | Update `MODEL_NAME` to `gemma3:latest` in `.env` |
| 1.1.2 | Add cache config (`CACHE_TTL`, `CACHE_ENABLED`) in `config.py` |

### 1.2 Implement AI Response Caching
**File:** `web/backend/cache_service.py` (new)
| Task | Description |
|------|-------------|
| 1.2.1 | Create `CacheService` class with TTL-based in-memory cache |
| 1.2.2 | Implement cache key generation (hash of request parameters) |
| 1.2.3 | Add cache invalidation endpoints |

### 1.3 Expand AI Service Capabilities
| Task | Function | Purpose |
|------|----------|---------|
| 1.3.1 | `generate_ui_text()` | Labels, placeholders, headings |
| 1.3.2 | `generate_product_data()` | Product names, descriptions, badges |
| 1.3.3 | `generate_calculator_insights()` | Scoring and tips |
| 1.3.4 | `generate_error_messages()` | Dynamic error text |
| 1.3.5 | `generate_ingredient_analysis()` | Enhanced ingredient explanations |
| 1.3.6 | `generate_alternative_suggestions()` | Smart alternatives |

### 1.4 New API Endpoints
**File:** `web/backend/main.py`
| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/ui-text` | GET | Fetch AI-generated UI strings |
| `/api/calculator/score` | POST | AI-powered calculator scoring |
| `/api/products/generate` | POST | Generate demo products dynamically |
| `/api/content/generate` | POST | Generic content generation |

### 1.5 Remove Hardcoded Mock Data
**File:** `web/backend/mock_data.py`
| Task | Description |
|------|-------------|
| 1.5.1 | Replace static mock products with AI-generated ones |
| 1.5.2 | Replace static badge definitions with AI-generated badges |
| 1.5.3 | Keep fallback data as absolute last resort |

---

## Phase 2: Frontend Architecture

### 2.1 New AI Content Service
**New File:** `web/frontend/src/services/aiContentService.js`
| Task | Description |
|------|-------------|
| 2.1.1 | Fetch AI-generated UI text from backend |
| 2.1.2 | Client-side caching with localStorage persistence |
| 2.1.3 | Fallback to cached content when offline |

### 2.2 Content Context Provider
**New File:** `web/frontend/src/context/ContentContext.jsx`
| Task | Description |
|------|-------------|
| 2.2.1 | React Context for global AI content |
| 2.2.2 | Pre-fetch critical UI text on app load |
| 2.2.3 | Content refresh mechanism |

### 2.3 Custom Hooks
**New Files:** `web/frontend/src/hooks/`
| Hook | Purpose |
|------|---------|
| `useAIText(section)` | AI-generated UI text |
| `useProductContent(context)` | Product-related AI content |
| `useCalculatorInsights(answers)` | Calculator AI scoring |

---

## Phase 3: Component Updates

Replace hardcoded text in all components with `useAIText()` calls:

| Component | Changes |
|-----------|---------|
| `Navbar.jsx` | Nav items, status labels |
| `SearchInput.jsx` | Placeholder, button, upload instructions |
| `SustainabilityScoreCard.jsx` | Score label, tier descriptions |
| `IngredientBreakdown.jsx` | Headers, labels, impact descriptions |
| `AlternativesList.jsx` | Header, empty state, alternatives |
| `HistoryChart.jsx` | Chart title, legend labels, tooltips |
| `BadgeCard.jsx` | "Earned", "Locked" status |
| `NotificationBanner.jsx` | Dynamic notification content |

---

## Phase 4: Page Updates

| Page | Changes |
|------|---------|
| **Home.jsx** | Hero text, stats, error messages, section headers |
| **Calculator.jsx** | Result badges, headers; keep questions structured |
| **History.jsx** | Headers, stat labels, motivational messages |
| **Profile.jsx** | Headers, stat labels, badge progress |
| **ReportDetail.jsx** | Headers, button text, impact warnings |
| **App.jsx** | Footer branding |

### Calculator Questions
**File:** `web/frontend/src/data/calculatorData.js`
- Keep structure (7 questions with options)
- Use AI for scoring and personalized insights
- Optionally fetch AI-enhanced question variations

---

## Phase 5: Error Handling

| Scenario | Handling |
|----------|----------|
| Ollama unavailable | Fall back to cached content |
| Cache miss | Show skeleton loader, fetch fresh |
| Malformed AI response | Validate structure, use fallback |
| Network timeout | 10s timeout with retry logic |

---

## Phase 6: API Updates

**File:** `web/frontend/src/services/api.js`
| Task | Description |
|------|-------------|
| 6.1.1 | Add endpoints for AI content fetching |
| 6.1.2 | Add caching headers to requests |
| 6.1.3 | Update error handling with AI messages |

---

## Phase 7: Testing

| Area | Tests |
|------|-------|
| Backend | Ollama connection, cache hit/miss, fallback |
| Frontend | All pages render, loading states, offline fallback |
| Performance | Latency, cache hit rate, concurrent users |

---

## Files Summary

### New Files
| File |
|------|
| `web/backend/cache_service.py` |
| `web/frontend/src/services/aiContentService.js` |
| `web/frontend/src/context/ContentContext.jsx` |
| `web/frontend/src/hooks/useAIText.js` |
| `web/frontend/src/hooks/useProductContent.js` |
| `web/frontend/src/hooks/useCalculatorInsights.js` |

### Modify
| File |
|------|
| `web/backend/.env`, `config.py`, `ai_service.py`, `models.py`, `main.py`, `mock_data.py` |
| `web/frontend/src/services/api.js`, `src/components/*.jsx`, `src/pages/*.jsx` |

### Delete
| File | Reason |
|------|--------|
| `web/frontend/src/data/mockData.js` | Replaced by AI |
| `web/backend/mock_data.py` | Replaced by AI |

---

## Implementation Order
1. Phase 1: Backend Enhancement
2. Phase 2: Frontend Architecture
3. Phase 3: Component Updates
4. Phase 4: Page Updates
5. Phase 5: Error Handling
6. Phase 6: API Updates
7. Phase 7: Testing

---

## Success Criteria
- [ ] All hardcoded text removed
- [ ] All UI content generated by AI via Ollama
- [ ] AI responses cached with 1-hour TTL
- [ ] Graceful fallback when Ollama unavailable
- [ ] Calculator uses AI for scoring/insights
- [ ] Product data generated dynamically by AI
