import 'package:ableone_app/features/communication/domain/entities/notification_entity.dart';
import 'package:ableone_app/features/communication/domain/entities/message_entity.dart';

abstract class CommunicationRepository {
  Stream<List<NotificationEntity>> getNotifications(String userId);
  Future<void> markNotificationAsRead(String notificationId);
  Stream<List<MessageEntity>> getChatMessages(String senderId, String receiverId);
  Future<void> sendChatMessage(String senderId, String receiverId, String text);
  Stream<List<Map<String, dynamic>>> getConversations(String userId);
}
