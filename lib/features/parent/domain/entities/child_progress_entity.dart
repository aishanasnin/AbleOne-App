/// Domain entity representing a child's learning progress and insights for parent views.
class ChildProgressEntity {
  /// Unique identifier of the child.
  final String childId;

  /// Display name of the child.
  final String childName;

  /// List of completed lesson IDs or names.
  final List<String> completedLessons;

  /// Overall completion percentage.
  final double progressPercentage;

  /// Active learning streak in days.
  final int streak;

  /// List of student strengths recognized by the system or AI.
  final List<String> strengths;

  /// List of academic areas needing improvement or focus.
  final List<String> improvementAreas;

  /// Creates a [ChildProgressEntity] instance.
  const ChildProgressEntity({
    required this.childId,
    required this.childName,
    required this.completedLessons,
    required this.progressPercentage,
    required this.streak,
    required this.strengths,
    required this.improvementAreas,
  });
}
