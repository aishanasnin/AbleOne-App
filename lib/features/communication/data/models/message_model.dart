import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ableone_app/features/communication/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.senderId,
    required super.receiverId,
    required super.message,
    required super.timestamp,
    required super.status,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    final timestamp = map['timestamp'] as Timestamp?;
    return MessageModel(
      id: id,
      senderId: map['senderId'] as String? ?? '',
      receiverId: map['receiverId'] as String? ?? '',
      message: map['message'] as String? ?? '',
      timestamp: timestamp?.toDate() ?? DateTime.now(),
      status: map['status'] as String? ?? 'sent',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
    };
  }
}
