import 'package:ableone_app/features/ai/domain/entities/ai_message_entity.dart';

/// Data model representing an AI chat message record, supporting database mapping and copying.
class AIMessageModel extends AIMessageEntity {
  /// Creates an [AIMessageModel] instance.
  const AIMessageModel({
    required super.id,
    required super.role,
    required super.message,
    required super.timestamp,
  });

  /// Factory method to reconstruct an [AIMessageModel] from a key-value map.
  factory AIMessageModel.fromMap(Map<String, dynamic> map) {
    return AIMessageModel(
      id: map['id'] as String? ?? '',
      role: map['role'] as String? ?? 'user',
      message: map['message'] as String? ?? '',
      timestamp: map['timestamp'] is String
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch),
    );
  }

  /// Converts the [AIMessageModel] instance into a serializable key-value map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Creates a copy of this [AIMessageModel] with replacement field values.
  AIMessageModel copyWith({
    String? id,
    String? role,
    String? message,
    DateTime? timestamp,
  }) {
    return AIMessageModel(
      id: id ?? this.id,
      role: role ?? this.role,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Creates an [AIMessageModel] from a standard [AIMessageEntity].
  factory AIMessageModel.fromEntity(AIMessageEntity entity) {
    return AIMessageModel(
      id: entity.id,
      role: entity.role,
      message: entity.message,
      timestamp: entity.timestamp,
    );
  }
}
