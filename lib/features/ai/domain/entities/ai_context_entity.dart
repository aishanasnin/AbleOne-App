import 'package:ableone_app/features/learning/domain/entities/course_entity.dart';
import 'package:ableone_app/features/learning/domain/entities/lesson_entity.dart';

/// Domain entity representing the user's complete AI tutoring context, including active course/lesson.
class AIContextEntity {
  /// The user's cognitive or explanation level.
  final String userLevel;

  /// The preferred explanation style.
  final String learningPreference;

  /// List of active accessibility/support needs.
  final List<String> accessibilityNeeds;

  /// The course currently being studied, if any.
  final CourseEntity? currentCourse;

  /// The lesson currently being viewed, if any.
  final LessonEntity? currentLesson;

  /// The preferred response language.
  final String language;

  /// Creates an [AIContextEntity] instance.
  const AIContextEntity({
    required this.userLevel,
    required this.learningPreference,
    required this.accessibilityNeeds,
    this.currentCourse,
    this.currentLesson,
    required this.language,
  });
}
