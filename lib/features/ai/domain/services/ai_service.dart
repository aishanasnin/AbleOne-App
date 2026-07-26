import 'package:ableone_app/features/ai/domain/entities/ai_context_entity.dart';

/// Abstract service defining text generation contract for AI engines.
abstract class AIService {
  /// Generates a personalized text response based on a [prompt] and the student's active [context].
  Future<String> generateResponse(String prompt, AIContextEntity context);
}
