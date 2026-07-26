import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:ableone_app/features/ai/domain/entities/ai_message_entity.dart';
import 'package:ableone_app/features/ai/domain/entities/ai_context_entity.dart';
import 'package:ableone_app/features/ai/domain/repositories/ai_repository.dart';
import 'package:ableone_app/features/ai/domain/services/ai_service.dart';
import 'package:ableone_app/features/ai/data/datasources/fake_ai_data_source.dart';
import 'package:ableone_app/features/ai/data/datasources/gemini_datasource.dart';
import 'package:ableone_app/features/ai/data/models/ai_message_model.dart';
import 'package:ableone_app/features/ai/presentation/providers/ai_providers.dart';

/// Implementation of [AIRepository] using Hive local storage and [AIService] abstraction.
class AIRepositoryImpl implements AIRepository {
  final AIService _aiService;
  final String _boxName = 'ai_chat_history';

  /// Creates a [AIRepositoryImpl] instance.
  AIRepositoryImpl(this._aiService);

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
  Future<AIMessageEntity> sendMessage(String message, AIContextEntity context, {bool useFallback = false}) async {
    try {
      final box = await _openBox();
      const uuid = Uuid();

      // Check if user message already exists in local storage (e.g. from previous failed attempt)
      bool userMessageExists = false;
      if (box.isNotEmpty) {
        final lastVal = box.values.last;
        if (lastVal != null) {
          final lastModel = AIMessageModel.fromMap(Map<String, dynamic>.from(lastVal as Map));
          if (lastModel.role == 'user' && lastModel.message == message) {
            userMessageExists = true;
          }
        }
      }

      if (!userMessageExists) {
        final userMessage = AIMessageModel(
          id: uuid.v4(),
          role: 'user',
          message: message,
          timestamp: DateTime.now(),
        );
        await box.put(userMessage.id, userMessage.toMap());
      }

      String responseText = '';
      if (useFallback) {
        responseText = await FakeAIDataSource().getAIResponse(message, context);
      } else {
        responseText = await _aiService.generateResponse(message, context);
      }

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
      throw Exception(e.toString().replaceAll('Exception: ', ''));
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

// Riverpod Providers

/// Provider exposing the [FakeAIDataSource] instance.
final fakeAIDataSourceProvider = Provider<FakeAIDataSource>((ref) {
  return FakeAIDataSource();
});

/// Provider exposing the [AIService] (Gemini) instance.
final geminiDatasourceProvider = Provider<AIService>((ref) {
  return GeminiDatasource();
});

/// Provider exposing the [AIRepository] instance.
final aiRepositoryProvider = Provider<AIRepository>((ref) {
  final aiService = ref.watch(geminiDatasourceProvider);
  return AIRepositoryImpl(aiService);
});

/// StateProvider tracking the active typing indicator state.
final aiTypingProvider = StateProvider<bool>((ref) => false);

/// StateProvider tracking the active chat error state.
final aiChatErrorProvider = StateProvider<String?>((ref) => null);

/// StateNotifier managing the active chat message list state.
class ChatMessagesNotifier extends StateNotifier<List<AIMessageEntity>> {
  final AIRepository _repository;
  final Ref _ref;
  String? _lastPrompt;

  /// Creates a [ChatMessagesNotifier] instance.
  ChatMessagesNotifier(this._repository, this._ref) : super([]) {
    loadHistory();
  }

  /// Loads previous messages from local Hive storage.
  Future<void> loadHistory() async {
    try {
      final history = await _repository.getChatHistory();
      state = history;
    } catch (_) {
      state = [];
    }
  }

  /// Sends a new message prompt, updating status states.
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Reset error and track prompt
    _ref.read(aiChatErrorProvider.notifier).state = null;
    _lastPrompt = text;

    final userMessage = AIMessageEntity(
      id: const Uuid().v4(),
      role: 'user',
      message: text,
      timestamp: DateTime.now(),
    );

    // Optimistically update list to show user message immediately
    state = [...state, userMessage];

    // Trigger typing indicator
    _ref.read(aiTypingProvider.notifier).state = true;

    final context = _ref.read(aiContextProvider);

    try {
      final assistantMessage = await _repository.sendMessage(text, context);
      state = [...state, assistantMessage];
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      _ref.read(aiChatErrorProvider.notifier).state = errorMsg;
    } finally {
      _ref.read(aiTypingProvider.notifier).state = false;
    }
  }

  /// Retries sending the last failed prompt if it exists.
  Future<void> retryLastMessage() async {
    final prompt = _lastPrompt;
    if (prompt == null || prompt.trim().isEmpty) return;

    // Reset error
    _ref.read(aiChatErrorProvider.notifier).state = null;

    // Trigger typing indicator
    _ref.read(aiTypingProvider.notifier).state = true;

    final context = _ref.read(aiContextProvider);

    try {
      final assistantMessage = await _repository.sendMessage(prompt, context);
      state = [...state, assistantMessage];
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      _ref.read(aiChatErrorProvider.notifier).state = errorMsg;
    } finally {
      _ref.read(aiTypingProvider.notifier).state = false;
    }
  }

  /// Uses FakeAIDataSource mock as a fallback.
  Future<void> useFallbackMock() async {
    final prompt = _lastPrompt;
    if (prompt == null || prompt.trim().isEmpty) return;

    // Reset error
    _ref.read(aiChatErrorProvider.notifier).state = null;

    // Trigger typing indicator
    _ref.read(aiTypingProvider.notifier).state = true;

    final context = _ref.read(aiContextProvider);

    try {
      final assistantMessage = await _repository.sendMessage(prompt, context, useFallback: true);
      state = [...state, assistantMessage];
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      _ref.read(aiChatErrorProvider.notifier).state = errorMsg;
    } finally {
      _ref.read(aiTypingProvider.notifier).state = false;
    }
  }

  /// Clears chat history.
  Future<void> clearHistory() async {
    await _repository.clearHistory();
    _ref.read(aiChatErrorProvider.notifier).state = null;
    _lastPrompt = null;
    state = [];
  }
}

/// Provider managing active chat history message arrays.
final chatMessagesProvider = StateNotifierProvider<ChatMessagesNotifier, List<AIMessageEntity>>((ref) {
  final repo = ref.watch(aiRepositoryProvider);
  return ChatMessagesNotifier(repo, ref);
});
