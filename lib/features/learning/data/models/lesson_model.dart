import 'package:ableone_app/features/learning/domain/entities/lesson_entity.dart';

/// Data model representing a Lesson record, supporting database mapping and copying.
class LessonModel extends LessonEntity {
  /// Creates a [LessonModel] instance.
  const LessonModel({
    required super.id,
    required super.moduleId,
    required super.courseId,
    required super.title,
    required super.type,
    required super.content,
    required super.order,
    required super.duration,
  });

  /// Factory method to reconstruct a [LessonModel] from a key-value map.
  factory LessonModel.fromMap(Map<String, dynamic> map, String docId) {
    return LessonModel(
      id: docId,
      moduleId: map['moduleId'] as String? ?? '',
      courseId: map['courseId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      type: map['type'] as String? ?? 'text',
      content: map['content'] as String? ?? '',
      order: map['order'] as int? ?? 0,
      duration: map['duration'] as String? ?? '',
    );
  }

  /// Converts the [LessonModel] instance into a serializable key-value map.
  Map<String, dynamic> toMap() {
    return {
      'moduleId': moduleId,
      'courseId': courseId,
      'title': title,
      'type': type,
      'content': content,
      'order': order,
      'duration': duration,
    };
  }

  /// Creates a copy of this [LessonModel] with replacement field values.
  LessonModel copyWith({
    String? id,
    String? moduleId,
    String? courseId,
    String? title,
    String? type,
    String? content,
    int? order,
    String? duration,
  }) {
    return LessonModel(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      type: type ?? this.type,
      content: content ?? this.content,
      order: order ?? this.order,
      duration: duration ?? this.duration,
    );
  }

  /// Creates a [LessonModel] from a standard [LessonEntity].
  factory LessonModel.fromEntity(LessonEntity entity) {
    return LessonModel(
      id: entity.id,
      moduleId: entity.moduleId,
      courseId: entity.courseId,
      title: entity.title,
      type: entity.type,
      content: entity.content,
      order: entity.order,
      duration: entity.duration,
    );
  }
}
