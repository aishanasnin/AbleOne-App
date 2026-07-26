/// Domain entity representing a clinical or observation note written by a counselor.
class CounselorNoteEntity {
  /// Unique identifier of the note.
  final String id;

  /// Student identifier the note is written for.
  final String studentId;

  /// The observation note description text.
  final String note;

  /// Date and time when the note was logged.
  final DateTime createdDate;

  /// Creates a [CounselorNoteEntity] instance.
  const CounselorNoteEntity({
    required this.id,
    required this.studentId,
    required this.note,
    required this.createdDate,
  });
}
