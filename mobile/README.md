# GreenNova Mobile App

A smart sustainable product recommendation app built with Flutter. Features AI-powered sustainability reports and carbon footprint tracking using local Gemma 3:12b model via Ollama.

## Features

### 1. Product Scanning
- **Barcode Scanner** - Scan product barcodes for instant sustainability analysis
- **Ingredient Scanner** - OCR-based ingredient list scanning
- **AI-Generated Reports** - Sustainability grades (A-F) and carbon footprint scores

### 2. Image/Text Search (Google Lens-like)
- **Text Search** - Search for product categories (e.g., "phone case") for generalized sustainability reports
- **Image Search** - Capture product images for detailed brand-specific analysis
- **Recent Search History** - Quick access to previous searches

### 3. Purchase History & Carbon Tracking
- **Manual Entry** - Add purchases manually with custom details
- **Scan to History** - Add scanned products directly to your history
- **Carbon Dashboard** - View trends, category breakdowns, and monthly statistics
- **Gamification** - Earn badges and achievements for sustainable choices
- **Rewards & Warnings** - Get rewarded for low footprint, warned for high impact

## Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Android SDK (for Android development)
- Ollama with Gemma 3:12b model (optional - mock mode available for testing)

### Installation

1. **Navigate to mobile folder**
   ```bash
   cd mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters** (already generated, run if needed)
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Configuration

### AI Backend Toggle

Edit `lib/core/config/api_config.dart`:

```dart
class ApiConfig {
  // Set to false to connect to real Ollama backend
  static const bool useMockAi = true;

  // Update with your Ollama server address
  static const String ollamaBaseUrl = 'http://192.168.1.100:11434';
  static const String ollamaModel = 'gemma3:12b';
}
```

### Running with Real Ollama Backend

1. Install and start Ollama:
   ```bash
   ollama run gemma3:12b
   ```

2. Set `useMockAi = false` in `api_config.dart`

3. Update `ollamaBaseUrl` with your server's IP address

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # MaterialApp configuration
├── core/
│   ├── config/
│   │   ├── api_config.dart      # Ollama API settings
│   │   └── app_config.dart      # App-wide constants
│   ├── router/
│   │   └── app_router.dart      # Navigation routes
│   └── services/
│       ├── ai_service.dart      # AI service interface
│       ├── mock_ai_service.dart # Mock implementation
│       ├── ollama_ai_service.dart # Real Ollama implementation
│       └── ai_service_provider.dart # Riverpod provider
├── data/
│   ├── models/
│   │   ├── sustainability_report_model.dart
│   │   ├── purchase_record_model.dart
│   │   ├── user_profile_model.dart
│   │   └── search_history_model.dart
│   └── datasources/
│       └── local/
│           └── hive_boxes.dart  # Local database management
└── presentation/
    ├── screens/
    │   ├── home/                # Home screen with stats
    │   ├── scan/                # Barcode & ingredient scanning
    │   ├── search/              # Text & image search
    │   ├── history/             # Purchase history
    │   └── dashboard/           # Carbon footprint dashboard
    ├── widgets/
    │   └── shell_scaffold.dart  # Bottom navigation shell
    └── theme/
        └── app_theme.dart       # Green/sustainable theming
```

## Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform UI |
| **Riverpod** | State management |
| **go_router** | Declarative navigation |
| **Hive** | Local NoSQL database |
| **mobile_scanner** | Barcode scanning |
| **google_mlkit_text_recognition** | OCR for ingredients |
| **fl_chart** | Carbon footprint charts |
| **Dio** | HTTP client for Ollama API |

## Screenshots

The app includes:
- Green/sustainable themed UI
- Bottom navigation (Home, Scan, Search, History, Dashboard)
- Visual carbon score indicators
- Achievement badges
- Monthly trend charts
- Category breakdown pie charts

## Testing

### Mock Mode (Default)
The app runs with `useMockAi = true` by default, which returns realistic dummy data for all AI operations without needing an Ollama server.

### With Real AI
1. Start Ollama with Gemma model
2. Toggle `useMockAi = false`
3. Test barcode scanning, ingredient OCR, and image analysis

## License

Part of the Greenova sustainability platform.
