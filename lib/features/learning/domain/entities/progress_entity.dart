/// Domain entity representing a user's progress in a course, including metrics and stats.
class ProgressEntity {
  /// Unique identifier of the user.
  final String uid;

  /// Identifier of the course this progress tracks.
  final String courseId;

  /// List of completed lesson identifiers under this course.
  final List<String> completedLessons;

  /// Percentage of course completion (from 0.0 to 100.0).
  final double completionPercentage;

  /// Total Experience Points (XP) accumulated by the user.
  final int xp;

  /// Number of consecutive days the user has been active.
  final int streak;

  /// Creates a [ProgressEntity] instance.
  const ProgressEntity({
    required this.uid,
    required this.courseId,
    required this.completedLessons,
    required this.completionPercentage,
    required this.xp,
    required this.streak,
  });
}
