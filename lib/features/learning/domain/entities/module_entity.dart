/// Domain entity representing a learning module under a course.
class ModuleEntity {
  /// Unique identifier of the module.
  final String id;

  /// Identifier of the course this module belongs to.
  final String courseId;

  /// Display title of the module.
  final String title;

  /// Short summary description of the module content.
  final String description;

  /// Sequence index order of the module.
  final int order;

  /// Creates a [ModuleEntity] instance.
  const ModuleEntity({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.order,
  });
}
