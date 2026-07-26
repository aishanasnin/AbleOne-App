import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:ableone_app/features/ai/domain/entities/ai_message_entity.dart';
import 'package:ableone_app/features/ai/domain/entities/ai_user_context.dart';
import 'package:ableone_app/features/ai/domain/repositories/ai_repository.dart';
import 'package:ableone_app/features/ai/domain/services/ai_service.dart';
import 'package:ableone_app/features/ai/data/models/ai_message_model.dart';

/// Implementation of [AIRepository] using Hive local storage and [AIService] abstraction.
class GeminiRepositoryImpl implements AIRepository {
  final AIService _aiService;
  final String _boxName = 'ai_chat_history';

  /// Creates a [GeminiRepositoryImpl] instance.
  GeminiRepositoryImpl(this._aiService);

  Future<Box<dynamic>> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box(_boxName);
    }
    return await Hive.openBox(_boxName);
  }

  @override
  Future<List<AIMessageEntity>> getChatHistory() async {
    try {
      final box = await _openBox();
      final messages = box.values
          .map((item) => AIMessageModel.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
      // Sort messages chronologically by timestamp
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    } catch (e) {
      throw Exception('Failed to load chat history: ${e.toString()}');
    }
  }

  @override
  Future<AIMessageEntity> sendMessage(String message, AIUserContext context) async {
    try {
      final box = await _openBox();
      const uuid = Uuid();

      // Create and save user message
      final userMessage = AIMessageModel(
        id: uuid.v4(),
        role: 'user',
        message: message,
        timestamp: DateTime.now(),
      );
      await box.put(userMessage.id, userMessage.toMap());

      // Fetch simulated response from service abstraction layer
      final responseText = await _aiService.generateResponse(message, context);

      // Create and save AI response
      final assistantMessage = AIMessageModel(
        id: uuid.v4(),
        role: 'assistant',
        message: responseText,
        timestamp: DateTime.now(),
      );
      await box.put(assistantMessage.id, assistantMessage.toMap());

      return assistantMessage;
    } catch (e) {
      throw Exception('Failed to complete AI tutor query: ${e.toString()}');
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      final box = await _openBox();
      await box.clear();
    } catch (e) {
      throw Exception('Failed to clear chat logs: ${e.toString()}');
    }
  }
}
