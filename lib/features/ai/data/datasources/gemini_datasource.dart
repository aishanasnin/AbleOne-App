import 'package:ableone_app/config/app_config.dart';
import 'package:ableone_app/features/ai/data/datasources/fake_ai_data_source.dart';
import 'package:ableone_app/features/ai/data/gemini_api_service.dart';
import 'package:ableone_app/features/ai/domain/entities/ai_context_entity.dart';
import 'package:ableone_app/features/ai/domain/services/ai_service.dart';

/// Gemini implementation of [AIService], fetching real-time model responses.
class GeminiDatasource implements AIService {
  final GeminiApiService _apiService;

  /// Creates a [GeminiDatasource] instance.
  GeminiDatasource({GeminiApiService? apiService})
      : _apiService = apiService ?? GeminiApiService();

  /// Requests response content from Gemini 1.5 Flash using the compiled API key,
  /// passing the active user profile [context] within system instructions.
  /// If the API key is not configured, it falls back to the mock datasource [FakeAIDataSource].
  @override
  Future<String> generateResponse(String prompt, AIContextEntity context) async {
    final apiKey = AppConfig.geminiApiKey;
    if (apiKey.isEmpty) {
      // Fallback to FakeAIDataSource if API key is not configured
      final fallback = FakeAIDataSource();
      return await fallback.getAIResponse(prompt, context);
    }

    return _apiService.sendPrompt(prompt, context);
  }
}
