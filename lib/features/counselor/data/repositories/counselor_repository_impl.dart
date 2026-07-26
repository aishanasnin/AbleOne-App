import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/features/counselor/domain/entities/counselor_student_entity.dart';
import 'package:ableone_app/features/counselor/domain/entities/counselor_note_entity.dart';
import 'package:ableone_app/features/counselor/domain/repositories/counselor_repository.dart';

/// In-memory repository implementing [CounselorRepository] to manage notes and students mock logs.
class CounselorRepositoryImpl implements CounselorRepository {
  final List<CounselorNoteEntity> _notes = [
    CounselorNoteEntity(
      id: 'n1',
      studentId: 'c1',
      note: 'Alex demonstrated strong focus during visual sequencing tests. He responds well to illustrative diagrams.',
      createdDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    CounselorNoteEntity(
      id: 'n2',
      studentId: 'c1',
      note: 'Noticed a slight slowdown when answering pure audio-guided descriptions. Recommended incorporating visual subtitles.',
      createdDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Future<List<CounselorStudentEntity>> getStudents() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const [
      CounselorStudentEntity(
        studentId: 'c1',
        studentName: 'Alex Smith',
        learningLevel: 'Beginner',
        supportNeeds: ['Visual support', 'Frequent structural breaks'],
        progress: 80.0,
        lastSession: 'Today, 10:24 AM',
      ),
      CounselorStudentEntity(
        studentId: 'c2',
        studentName: 'Emily Davis',
        learningLevel: 'Intermediate',
        supportNeeds: ['Slow reading speed options', 'Text simplification'],
        progress: 45.0,
        lastSession: 'Yesterday, 2:30 PM',
      ),
      CounselorStudentEntity(
        studentId: 'c3',
        studentName: 'Chloe Clark',
        learningLevel: 'Advanced',
        supportNeeds: ['Text-only simple layout', 'Keyboard focus markers'],
        progress: 95.0,
        lastSession: '3 days ago',
      ),
    ];
  }

  @override
  Future<List<CounselorNoteEntity>> getNotes(String studentId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _notes.where((n) => n.studentId == studentId).toList()
      ..sort((a, b) => b.createdDate.compareTo(a.createdDate));
  }

  @override
  Future<void> addNote(String studentId, String note) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _notes.add(
      CounselorNoteEntity(
        id: const Uuid().v4(),
        studentId: studentId,
        note: note,
        createdDate: DateTime.now(),
      ),
    );
  }

  @override
  Future<List<Map<String, String>>> getSessions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      {
        'time': '2:30 PM - 3:15 PM',
        'student': 'Alex Smith',
        'type': 'Cognitive Review',
        'room': 'Virtual Room A',
      },
      {
        'time': '4:00 PM - 4:45 PM',
        'student': 'Emily Davis (Parent Consult)',
        'type': 'Monthly Progress Evaluation',
        'room': 'Virtual Room B',
      },
      {
        'time': '5:00 PM - 5:45 PM',
        'student': 'Chloe Clark',
        'type': 'Diagnostic Feedback',
        'room': 'Virtual Room A',
      },
    ];
  }
}

// Riverpod Providers

/// Provider exposing Counselor repository singleton.
final counselorRepositoryProvider = Provider<CounselorRepository>((ref) {
  return CounselorRepositoryImpl();
});

/// StateNotifier managing asynchronous loading and saving of observations notes.
class CounselorNotesNotifier extends StateNotifier<AsyncValue<List<CounselorNoteEntity>>> {
  final CounselorRepository _repository;
  final String _studentId;

  /// Creates a [CounselorNotesNotifier] instance.
  CounselorNotesNotifier(this._repository, this._studentId) : super(const AsyncValue.loading()) {
    loadNotes();
  }

  /// Loads clinical review notes.
  Future<void> loadNotes() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repository.getNotes(_studentId);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Appends a new note.
  Future<void> addNote(String text) async {
    try {
      await _repository.addNote(_studentId, text);
      await loadNotes();
    } catch (_) {}
  }
}

/// Provider managing lists of clinical notes.
final counselorNotesProvider = StateNotifierProvider.family<CounselorNotesNotifier, AsyncValue<List<CounselorNoteEntity>>, String>((ref, studentId) {
  final repo = ref.watch(counselorRepositoryProvider);
  return CounselorNotesNotifier(repo, studentId);
});

/// FutureProvider that exposes the list of active students.
final counselorStudentsProvider = FutureProvider<List<CounselorStudentEntity>>((ref) {
  return ref.watch(counselorRepositoryProvider).getStudents();
});

/// FutureProvider that exposes scheduled sessions lists.
final counselorSessionsProvider = FutureProvider<List<Map<String, String>>>((ref) {
  return ref.watch(counselorRepositoryProvider).getSessions();
});
