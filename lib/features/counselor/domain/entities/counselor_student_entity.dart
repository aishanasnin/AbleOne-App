/// Domain entity representing a student under a counselor's supervision.
class CounselorStudentEntity {
  /// Unique identifier of the student.
  final String studentId;

  /// Display name of the student.
  final String studentName;

  /// The cognitive or instruction level of the student.
  final String learningLevel;

  /// List of student support/accessibility requirements.
  final List<String> supportNeeds;

  /// Overall learning course progress percentage.
  final double progress;

  /// Timestamp description of the last counseling consultation session.
  final String lastSession;

  /// Creates a [CounselorStudentEntity] instance.
  const CounselorStudentEntity({
    required this.studentId,
    required this.studentName,
    required this.learningLevel,
    required this.supportNeeds,
    required this.progress,
    required this.lastSession,
  });
}
