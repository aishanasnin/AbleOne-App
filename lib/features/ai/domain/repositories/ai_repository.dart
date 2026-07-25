import 'package:ableone_app/features/ai/domain/entities/ai_message_entity.dart';

/// Repository interface defining chat operations and local message history management.
abstract class AIRepository {
  /// Fetches all stored chat messages from local database logs.
  Future<List<AIMessageEntity>> getChatHistory();

  /// Sends a prompt to the AI engine, saves both user input and output to history, and returns the response.
  Future<AIMessageEntity> sendMessage(String message);

  /// Clears all local chat logs.
  Future<void> clearHistory();
}
