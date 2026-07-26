import 'package:ableone_app/features/counselor/domain/entities/counselor_student_entity.dart';
import 'package:ableone_app/features/counselor/domain/entities/counselor_note_entity.dart';

/// Repository interface defining clinical case operations for counselors.
abstract class CounselorRepository {
  /// Fetches students assigned to this counselor.
  Future<List<CounselorStudentEntity>> getStudents();

  /// Fetches observation notes logged for a student.
  Future<List<CounselorNoteEntity>> getNotes(String studentId);

  /// Saves a new clinical note for a student.
  Future<void> addNote(String studentId, String note);

  /// Fetches scheduled virtual consult sessions list.
  Future<List<Map<String, String>>> getSessions();
}
