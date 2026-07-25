/// Domain entity representing a single chat message exchanged with the AI tutor.
class AIMessageEntity {
  /// Unique identifier of the chat message.
  final String id;

  /// Role of the message creator (e.g. 'user' or 'assistant').
  final String role;

  /// String content of the message body.
  final String message;

  /// Time point when this message was recorded.
  final DateTime timestamp;

  /// Creates an [AIMessageEntity] instance.
  const AIMessageEntity({
    required this.id,
    required this.role,
    required this.message,
    required this.timestamp,
  });
}
