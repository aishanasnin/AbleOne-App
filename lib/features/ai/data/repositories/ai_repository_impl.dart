import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:ableone_app/core/services/firebase_service.dart';

/// Implementation of [AIRepository] using Hive local storage and Cloud Firestore.
class AIRepositoryImpl implements AIRepository {
  final AIService _aiService;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final String _boxName = 'ai_chat_history';

  /// Creates a [AIRepositoryImpl] instance.
  AIRepositoryImpl(this._aiService, this._firebaseAuth, this._firestore);

  Future<Box<dynamic>> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box(_boxName);
    }
    return await Hive.openBox(_boxName);
  }

  CollectionReference<Map<String, dynamic>> get _historyCollection =>
      _firestore.collection('ai_history');

  @override
  Future<List<AIMessageEntity>> getChatHistory() async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid != null) {
        final snapshot = await _historyCollection
            .where('userId', isEqualTo: uid)
            .get();

        final messages = snapshot.docs.map((doc) {
          final data = doc.data();
          final timestamp = data['timestamp'] as Timestamp?;
          return AIMessageEntity(
            id: doc.id,
            role: data['role'] as String? ?? 'user',
            message: data['message'] as String? ?? '',
            timestamp: timestamp?.toDate() ?? DateTime.now(),
          );
        }).toList();

        // Sort chronologically
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        return messages;
      }

      // Fallback to local Hive storage if user is not signed in
      final box = await _openBox();
      final messages = box.values
          .map((item) => AIMessageModel.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    } catch (e) {
      throw Exception('Failed to load chat history: ${e.toString()}');
    }
  }

  @override
  Future<AIMessageEntity> sendMessage(String message, AIContextEntity context, {bool useFallback = false}) async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      final box = await _openBox();
      const uuid = Uuid();
      final messageId = uuid.v4();
      final now = DateTime.now();

      // 1. Save user message locally
      final userMessage = AIMessageModel(
        id: messageId,
        role: 'user',
        message: message,
        timestamp: now,
      );
      await box.put(userMessage.id, userMessage.toMap());

      // 2. Save user message to Firestore
      if (uid != null) {
        await _historyCollection.doc(messageId).set({
          'userId': uid,
          'role': 'user',
          'message': message,
          'timestamp': Timestamp.fromDate(now),
        });
      }

      // 3. Generate response
      String responseText = '';
      if (useFallback) {
        responseText = await FakeAIDataSource().getAIResponse(message, context);
      } else {
        responseText = await _aiService.generateResponse(message, context);
      }

      final assistantMessageId = uuid.v4();
      final assistantNow = DateTime.now();

      // 4. Save AI response locally
      final assistantMessage = AIMessageModel(
        id: assistantMessageId,
        role: 'assistant',
        message: responseText,
        timestamp: assistantNow,
      );
      await box.put(assistantMessage.id, assistantMessage.toMap());

      // 5. Save AI response to Firestore
      if (uid != null) {
        await _historyCollection.doc(assistantMessageId).set({
          'userId': uid,
          'role': 'assistant',
          'message': responseText,
          'timestamp': Timestamp.fromDate(assistantNow),
        });
      }

      return assistantMessage;
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      final box = await _openBox();
      await box.clear();

      if (uid != null) {
        final snapshot = await _historyCollection
            .where('userId', isEqualTo: uid)
            .get();

        final batch = _firestore.batch();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    } catch (e) {
      throw Exception('Failed to clear chat logs: ${e.toString()}');
    }
  }

  @override
  Future<String> askQuestion(String question, AIContextEntity context) async {
    try {
      return await _aiService.generateResponse('Question: $question', context);
    } catch (e) {
      throw Exception('Failed to ask question: ${e.toString()}');
    }
  }

  @override
  Future<String> summarizeLesson(String lessonTitle, String content, AIContextEntity context) async {
    try {
      return await _aiService.generateResponse(
        'Summarize the lesson "$lessonTitle" with the following content:\n\n$content',
        context,
      );
    } catch (e) {
      throw Exception('Failed to summarize lesson: ${e.toString()}');
    }
  }

  @override
  Future<String> explainTopic(String topic, AIContextEntity context) async {
    try {
      return await _aiService.generateResponse('Explain the topic: $topic', context);
    } catch (e) {
      throw Exception('Failed to explain topic: ${e.toString()}');
    }
  }

  @override
  Future<String> generateQuiz(String lessonTitle, String content, AIContextEntity context) async {
    try {
      return await _aiService.generateResponse(
        'Create a multiple choice quiz of 3 questions based on the lesson "$lessonTitle" with the following content:\n\n$content',
        context,
      );
    } catch (e) {
      throw Exception('Failed to generate quiz: ${e.toString()}');
    }
  }

  @override
  Future<String> simplifyText(String text, AIContextEntity context) async {
    try {
      return await _aiService.generateResponse(
        'Simplify the following text and make it easy to understand:\n\n$text',
        context,
      );
    } catch (e) {
      throw Exception('Failed to simplify text: ${e.toString()}');
    }
  }
}

// Riverpod Providers
final fakeAIDataSourceProvider = Provider<FakeAIDataSource>((ref) {
  return FakeAIDataSource();
});

final geminiDatasourceProvider = Provider<AIService>((ref) {
  return GeminiDatasource();
});

final aiRepositoryProvider = Provider<AIRepository>((ref) {
  final aiService = ref.watch(geminiDatasourceProvider);
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firebaseFirestoreProvider);
  return AIRepositoryImpl(aiService, firebaseAuth, firestore);
});

final aiTypingProvider = StateProvider<bool>((ref) => false);
final aiChatErrorProvider = StateProvider<String?>((ref) => null);

class ChatMessagesNotifier extends StateNotifier<List<AIMessageEntity>> {
  final AIRepository _repository;
  final Ref _ref;
  String? _lastPrompt;

  ChatMessagesNotifier(this._repository, this._ref) : super([]) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final history = await _repository.getChatHistory();
      state = history;
    } catch (_) {
      state = [];
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _ref.read(aiChatErrorProvider.notifier).state = null;
    _lastPrompt = text;

    final userMessage = AIMessageEntity(
      id: const Uuid().v4(),
      role: 'user',
      message: text,
      timestamp: DateTime.now(),
    );

    state = [...state, userMessage];
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

  Future<void> retryLastMessage() async {
    final prompt = _lastPrompt;
    if (prompt == null || prompt.trim().isEmpty) return;

    _ref.read(aiChatErrorProvider.notifier).state = null;
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

  Future<void> useFallbackMock() async {
    final prompt = _lastPrompt;
    if (prompt == null || prompt.trim().isEmpty) return;

    _ref.read(aiChatErrorProvider.notifier).state = null;
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

  Future<void> clearHistory() async {
    await _repository.clearHistory();
    _ref.read(aiChatErrorProvider.notifier).state = null;
    _lastPrompt = null;
    state = [];
  }
}

final chatMessagesProvider = StateNotifierProvider<ChatMessagesNotifier, List<AIMessageEntity>>((ref) {
  final repo = ref.watch(aiRepositoryProvider);
  return ChatMessagesNotifier(repo, ref);
});
