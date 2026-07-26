import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ableone_app/features/communication/data/models/notification_model.dart';
import 'package:ableone_app/features/communication/data/models/message_model.dart';

void main() {
  group('Communication System Unit Tests', () {
    test('NotificationModel should correctly map fields from database map', () {
      final now = DateTime.now();
      final map = {
        'title': 'Alert Title',
        'message': 'This is a test notification message.',
        'type': 'reminder',
        'createdAt': Timestamp.fromDate(now),
        'isRead': false,
      };

      final model = NotificationModel.fromMap(map, 'notif_123');

      expect(model.id, 'notif_123');
      expect(model.title, 'Alert Title');
      expect(model.message, 'This is a test notification message.');
      expect(model.type, 'reminder');
      expect(model.createdAt, now);
      expect(model.isRead, false);
    });

    test('MessageModel should correctly map fields from database map', () {
      final now = DateTime.now();
      final map = {
        'senderId': 'user_a',
        'receiverId': 'user_b',
        'message': 'Hello world',
        'timestamp': Timestamp.fromDate(now),
        'status': 'sent',
      };

      final model = MessageModel.fromMap(map, 'msg_999');

      expect(model.id, 'msg_999');
      expect(model.senderId, 'user_a');
      expect(model.receiverId, 'user_b');
      expect(model.message, 'Hello world');
      expect(model.timestamp, now);
      expect(model.status, 'sent');
    });
  });
}
