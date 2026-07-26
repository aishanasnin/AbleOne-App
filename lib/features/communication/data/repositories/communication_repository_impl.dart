import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:ableone_app/features/communication/domain/entities/notification_entity.dart';
import 'package:ableone_app/features/communication/domain/entities/message_entity.dart';
import 'package:ableone_app/features/communication/domain/repositories/communication_repository.dart';
import 'package:ableone_app/features/communication/data/models/notification_model.dart';
import 'package:ableone_app/features/communication/data/models/message_model.dart';
import 'package:ableone_app/core/services/firebase_service.dart';

class CommunicationRepositoryImpl implements CommunicationRepository {
  final FirebaseFirestore _firestore;

  CommunicationRepositoryImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _notificationsCollection =>
      _firestore.collection('notifications');

  CollectionReference<Map<String, dynamic>> get _messagesCollection =>
      _firestore.collection('messages');

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  String _getChatId(String id1, String id2) {
    final list = [id1, id2]..sort();
    return list.join('_');
  }

  @override
  Stream<List<NotificationEntity>> getNotifications(String userId) {
    return _notificationsCollection
        .where('recipientId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
          .toList();
      // Sort chronologically descending
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).update({'isRead': true});
    } catch (e) {
      throw Exception('Failed to update notification: $e');
    }
  }

  @override
  Stream<List<MessageEntity>> getChatMessages(String senderId, String receiverId) {
    final chatId = _getChatId(senderId, receiverId);
    return _messagesCollection
        .where('chatId', isEqualTo: chatId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
          .toList();
      // Sort chronologically ascending
      list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return list;
    });
  }

  @override
  Future<void> sendChatMessage(String senderId, String receiverId, String text) async {
    try {
      final id = const Uuid().v4();
      final chatId = _getChatId(senderId, receiverId);
      await _messagesCollection.doc(id).set({
        'chatId': chatId,
        'senderId': senderId,
        'receiverId': receiverId,
        'message': text,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'sent',
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> getConversations(String userId) {
    // Queries users so user can select any other system user to trigger chats
    return _usersCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.id != userId)
          .map((doc) {
            final data = doc.data();
            return {
              'uid': doc.id,
              'name': data['name'] as String? ?? 'User',
              'role': data['role'] as String? ?? 'student',
              'email': data['email'] as String? ?? '',
            };
          })
          .toList();
    });
  }

  /// Helper to send progress notification alerts automatically
  Future<void> triggerAlert(String recipientId, String title, String msg, String type) async {
    final id = const Uuid().v4();
    await _notificationsCollection.doc(id).set({
      'recipientId': recipientId,
      'title': title,
      'message': msg,
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }
}

// Riverpod Providers
final communicationRepositoryProvider = Provider<CommunicationRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return CommunicationRepositoryImpl(firestore);
});

final notificationsStreamProvider = StreamProvider.family<List<NotificationEntity>, String>((ref, userId) {
  final repo = ref.watch(communicationRepositoryProvider);
  return repo.getNotifications(userId);
});

class ChatParams {
  final String senderId;
  final String receiverId;
  ChatParams({required this.senderId, required this.receiverId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatParams &&
          runtimeType == other.runtimeType &&
          senderId == other.senderId &&
          receiverId == other.receiverId;

  @override
  int get hashCode => senderId.hashCode ^ receiverId.hashCode;
}

final messagesStreamProvider = StreamProvider.family<List<MessageEntity>, ChatParams>((ref, params) {
  final repo = ref.watch(communicationRepositoryProvider);
  return repo.getChatMessages(params.senderId, params.receiverId);
});

final conversationsStreamProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userId) {
  final repo = ref.watch(communicationRepositoryProvider);
  return repo.getConversations(userId);
});
