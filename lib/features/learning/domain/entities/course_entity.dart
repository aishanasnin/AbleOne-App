/// Domain entity representing a learning course in the AbleOne system.
class CourseEntity {
  /// Unique identifier of the course.
  final String id;

  /// Display title of the course.
  final String title;

  /// Overview description of the course content.
  final String description;

  /// Difficulty level of the course (e.g. Beginner, Intermediate, Advanced).
  final String difficulty;

  /// URL or asset path referencing the course thumbnail image.
  final String thumbnail;

  /// Total count of modules contained inside this course.
  final int modulesCount;

  /// Total count of lessons contained inside this course.
  final int lessonsCount;

  /// Estimated duration required to complete this course (e.g. "2 hours").
  final String duration;

  /// Creates a [CourseEntity] instance.
  const CourseEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.thumbnail,
    required this.modulesCount,
    required this.lessonsCount,
    required this.duration,
  });
}
