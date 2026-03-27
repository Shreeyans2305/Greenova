/// API Configuration for GreenNova
/// Backend server handles both AI (Ollama) and product data (Open Food Facts)
class ApiConfig {
  ApiConfig._();

  /// Set to false to connect to real backend
  static const bool useMockAi = false;

  /// Python backend server configuration
  /// For emulator: 10.0.2.2 maps to host machine's localhost
  /// For physical device: use your computer's local IP
  static const String backendBaseUrl = 'http://10.0.2.2:8000';

  /// Ollama model names (displayed in settings, used by backend)
  static const String ollamaTextModel = 'gemma3:latest';
  static const String ollamaVisionModel = 'gemma3:12b';

  /// Backend API endpoints
  static const String analyzeEndpoint = '/api/analyze';
  static const String imageEndpoint = '/api/image';
  static const String searchEndpoint = '/api/search';
  static const String compareEndpoint = '/api/compare';
  static const String carbonSummaryEndpoint = '/api/carbon-summary';
  static const String alternativesEndpoint = '/api/alternatives';
  static const String productsSearchEndpoint = '/api/products/search';
  static const String productsDetailEndpoint = '/api/products';
  static const String healthEndpoint = '/api/health';

  /// Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 180);
}
