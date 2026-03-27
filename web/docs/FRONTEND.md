# Frontend Specification - GreenNova

## 1. Project Setup
- **Framework**: React 18 + Vite
- **Styling**: Tailwind CSS for high-quality, nature-inspired design.
- **Charts**: Recharts for visualizing eco-data trends.
- **Navigation**: React Router for seamless page transitions.

## 2. Core Components

### 2.1 `<SustainabilityScoreCard />`
- **Location**: `/src/components/`
- **Props**:
  - `score`: `number` (0-100)
  - `tier`: `string` ('GREEN', 'AMBER', 'RED')
  - `description`: `string`
  - `badge`: `string` (e.g., "Eco Champion 🌱")
- **Purpose**: Unified summary card used in Search and Purchase History.

### 2.2 Reusable UI Elements
- **`<LayoutContainer />`**: Base wrapper for all screens.
- **`<SearchInput />`**: Handles text strings and image uploads/drag-and-drop.
- **`<HistoryChart />`**: A Recharts-powered line/bar chart for carbon tracking.

## 3. Screen Hierarchy

1. **Home / Search** (`/`)
   - Text input & Image upload.
   - Recent searches list.
   - Eco-greeting/Status banner.

2. **Report Detail** (`/report/:id`)
   - Detailed product sustainability metrics.
   - Ingredient-by-ingredient environmental impact report.
   - "Add to Purchase History" button.
   - Alternatives list.

3. **Purchase History** (`/history`)
   - List of logged products from local device.
   - Total Carbon Footprint summary.
   - Weekly/Monthly trend chart (Recharts).

4. **Badges / Profile** (`/profile`)
   - Gamified rewards (Badges/Achievements) stored locally.
   - Sustainability warnings for high-carbon footprint patterns.

## 4. Environment Configuration
Environment variables are managed in `.env`.
- `VITE_API_BASE_URL`: Base backend URL (default: `http://localhost:8000`).
- `VITE_MOCK_MODE`: If `true`, the frontend returns mock data.

## 5. State & Data Persistence
- **LocalStorage**:
  - `green_nova_history`: Array of JSON objects for logged items.
  - `green_nova_badges`: Array of strings for earned achievement names.
