import 'package:ableone_app/features/learning/domain/entities/progress_entity.dart';

/// Data model representing a user's Course Progress record, supporting database mapping and copying.
class ProgressModel extends ProgressEntity {
  /// Creates a [ProgressModel] instance.
  const ProgressModel({
    required super.uid,
    required super.courseId,
    required super.completedLessons,
    required super.completionPercentage,
    required super.xp,
    required super.streak,
  });

  /// Factory method to reconstruct a [ProgressModel] from a key-value map.
  factory ProgressModel.fromMap(Map<String, dynamic> map, String docId) {
    // Determine user ID and course ID from the docId formatted as "uid_courseId" or read directly from map
    final parts = docId.split('_');
    final uid = map['uid'] as String? ?? (parts.isNotEmpty ? parts[0] : '');
    final courseId = map['courseId'] as String? ?? (parts.length > 1 ? parts[1] : '');

    return ProgressModel(
      uid: uid,
      courseId: courseId,
      completedLessons: List<String>.from(map['completedLessons'] as List? ?? []),
      completionPercentage: (map['completionPercentage'] as num? ?? 0.0).toDouble(),
      xp: map['xp'] as int? ?? 0,
      streak: map['streak'] as int? ?? 0,
    );
  }

  /// Converts the [ProgressModel] instance into a serializable key-value map.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'courseId': courseId,
      'completedLessons': completedLessons,
      'completionPercentage': completionPercentage,
      'xp': xp,
      'streak': streak,
    };
  }

  /// Creates a copy of this [ProgressModel] with replacement field values.
  ProgressModel copyWith({
    String? uid,
    String? courseId,
    List<String>? completedLessons,
    double? completionPercentage,
    int? xp,
    int? streak,
  }) {
    return ProgressModel(
      uid: uid ?? this.uid,
      courseId: courseId ?? this.courseId,
      completedLessons: completedLessons ?? this.completedLessons,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
    );
  }

  /// Creates a [ProgressModel] from a standard [ProgressEntity].
  factory ProgressModel.fromEntity(ProgressEntity entity) {
    return ProgressModel(
      uid: entity.uid,
      courseId: entity.courseId,
      completedLessons: entity.completedLessons,
      completionPercentage: entity.completionPercentage,
      xp: entity.xp,
      streak: entity.streak,
    );
  }
}
