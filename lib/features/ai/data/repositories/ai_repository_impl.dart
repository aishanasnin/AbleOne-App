import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:ableone_app/features/ai/domain/entities/ai_message_entity.dart';
import 'package:ableone_app/features/ai/domain/entities/ai_user_context.dart';
import 'package:ableone_app/features/ai/domain/repositories/ai_repository.dart';
import 'package:ableone_app/features/ai/data/datasources/fake_ai_data_source.dart';
import 'package:ableone_app/features/ai/data/models/ai_message_model.dart';
import 'package:ableone_app/features/ai/presentation/providers/ai_providers.dart';

/// Implementation of [AIRepository] using [FakeAIDataSource] and Hive for local storage.
class AIRepositoryImpl implements AIRepository {
  final FakeAIDataSource _dataSource;
  final String _boxName = 'ai_chat_history';

  /// Creates a [AIRepositoryImpl] instance.
  AIRepositoryImpl(this._dataSource);

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

      // Fetch simulated response
      final responseText = await _dataSource.getAIResponse(message, context);

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

// Riverpod Providers

/// Provider exposing the [FakeAIDataSource] instance.
final fakeAIDataSourceProvider = Provider<FakeAIDataSource>((ref) {
  return FakeAIDataSource();
});

/// Provider exposing the [AIRepository] instance.
final aiRepositoryProvider = Provider<AIRepository>((ref) {
  final dataSource = ref.watch(fakeAIDataSourceProvider);
  return AIRepositoryImpl(dataSource);
});

/// StateProvider tracking the active typing indicator state.
final aiTypingProvider = StateProvider<bool>((ref) => false);

/// StateNotifier managing the active chat message list state.
class ChatMessagesNotifier extends StateNotifier<List<AIMessageEntity>> {
  final AIRepository _repository;
  final Ref _ref;

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

    final context = _ref.read(aiUserContextProvider);

    try {
      final assistantMessage = await _repository.sendMessage(text, context);
      state = [...state, assistantMessage];
    } catch (_) {
      // Create a warning message bubble if the operation failed
      final errorMessage = AIMessageEntity(
        id: const Uuid().v4(),
        role: 'assistant',
        message: 'Could not connect to the AI Tutor service. Please check your connection.',
        timestamp: DateTime.now(),
      );
      state = [...state, errorMessage];
    } finally {
      _ref.read(aiTypingProvider.notifier).state = false;
    }
  }

  /// Clears chat history.
  Future<void> clearHistory() async {
    await _repository.clearHistory();
    state = [];
  }
}

/// Provider managing active chat history message arrays.
final chatMessagesProvider = StateNotifierProvider<ChatMessagesNotifier, List<AIMessageEntity>>((ref) {
  final repo = ref.watch(aiRepositoryProvider);
  return ChatMessagesNotifier(repo, ref);
});
