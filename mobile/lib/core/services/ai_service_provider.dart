import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import 'ai_service.dart';
import 'mock_ai_service.dart';
import 'ollama_ai_service.dart';

/// Provider for AI Service
/// Automatically switches between Mock and Real implementation based on config
final aiServiceProvider = Provider<AiService>((ref) {
  if (ApiConfig.useMockAi) {
    return MockAiService();
  }
  return OllamaAiService();
});
