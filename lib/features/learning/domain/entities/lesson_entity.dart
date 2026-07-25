/// Domain entity representing a learning lesson inside a module.
class LessonEntity {
  /// Unique identifier of the lesson.
  final String id;

  /// Identifier of the module this lesson belongs to.
  final String moduleId;

  /// Identifier of the course this lesson belongs to.
  final String courseId;

  /// Display title of the lesson.
  final String title;

  /// Type of content (e.g. video, pdf, text, audio, quiz).
  final String type;

  /// Content details, links, text paragraphs, or placeholder information.
  final String content;

  /// Sequence index order of the lesson.
  final int order;

  /// Estimated duration required to review this lesson (e.g. "5 mins").
  final String duration;

  /// Creates a [LessonEntity] instance.
  const LessonEntity({
    required this.id,
    required this.moduleId,
    required this.courseId,
    required this.title,
    required this.type,
    required this.content,
    required this.order,
    required this.duration,
  });
}
