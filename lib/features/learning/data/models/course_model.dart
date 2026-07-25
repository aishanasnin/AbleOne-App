import 'package:ableone_app/features/learning/domain/entities/course_entity.dart';

/// Data model representing a Course record, supporting database mapping and copying.
class CourseModel extends CourseEntity {
  /// Creates a [CourseModel] instance.
  const CourseModel({
    required super.id,
    required super.title,
    required super.description,
    required super.difficulty,
    required super.thumbnail,
    required super.modulesCount,
    required super.lessonsCount,
    required super.duration,
  });

  /// Factory method to reconstruct a [CourseModel] from a key-value map.
  factory CourseModel.fromMap(Map<String, dynamic> map, String docId) {
    return CourseModel(
      id: docId,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      difficulty: map['difficulty'] as String? ?? 'Beginner',
      thumbnail: map['thumbnail'] as String? ?? '',
      modulesCount: map['modulesCount'] as int? ?? 0,
      lessonsCount: map['lessonsCount'] as int? ?? 0,
      duration: map['duration'] as String? ?? '',
    );
  }

  /// Converts the [CourseModel] instance into a serializable key-value map.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'thumbnail': thumbnail,
      'modulesCount': modulesCount,
      'lessonsCount': lessonsCount,
      'duration': duration,
    };
  }

  /// Creates a copy of this [CourseModel] with replacement field values.
  CourseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? difficulty,
    String? thumbnail,
    int? modulesCount,
    int? lessonsCount,
    String? duration,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      thumbnail: thumbnail ?? this.thumbnail,
      modulesCount: modulesCount ?? this.modulesCount,
      lessonsCount: lessonsCount ?? this.lessonsCount,
      duration: duration ?? this.duration,
    );
  }

  /// Creates a [CourseModel] from a standard [CourseEntity].
  factory CourseModel.fromEntity(CourseEntity entity) {
    return CourseModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      difficulty: entity.difficulty,
      thumbnail: entity.thumbnail,
      modulesCount: entity.modulesCount,
      lessonsCount: entity.lessonsCount,
      duration: entity.duration,
    );
  }
}
