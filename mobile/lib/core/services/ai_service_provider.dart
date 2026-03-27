import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import 'ai_service.dart';
import 'backend_ai_service.dart';
import 'mock_ai_service.dart';

/// Provider for AI Service
/// Uses BackendAiService (Python backend) or MockAiService
final aiServiceProvider = Provider<AiService>((ref) {
  if (ApiConfig.useMockAi) {
    return MockAiService();
  }
  return BackendAiService();
});
