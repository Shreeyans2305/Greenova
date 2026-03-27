/// API Configuration for GreenNova
/// Toggle useMockAi to switch between dummy and real Ollama responses
class ApiConfig {
  ApiConfig._();

  /// Set to false to connect to real Ollama backend
  static const bool useMockAi = true;

  /// Ollama server configuration
  /// Update this to your network IP where Ollama is running
  static const String ollamaBaseUrl = 'http://192.168.1.100:11434';
  static const String ollamaModel = 'gemma3:12b';

  /// API endpoints
  static const String generateEndpoint = '/api/generate';
  static const String chatEndpoint = '/api/chat';

  /// Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 120);
}
