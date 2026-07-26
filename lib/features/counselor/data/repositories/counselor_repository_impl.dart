import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:ableone_app/core/services/firebase_service.dart';
import 'package:ableone_app/features/counselor/domain/entities/counselor_student_entity.dart';
import 'package:ableone_app/features/counselor/domain/entities/counselor_note_entity.dart';
import 'package:ableone_app/features/counselor/domain/repositories/counselor_repository.dart';

class CounselorRepositoryImpl implements CounselorRepository {
  final FirebaseFirestore _firestore;

  CounselorRepositoryImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _notesCollection =>
      _firestore.collection('counselor_notes');

  @override
  Future<List<CounselorStudentEntity>> getStudents() async {
    try {
      final snapshot = await _usersCollection
          .where('role', isEqualTo: 'student')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final supportNeedsRaw = data['supportNeeds'] as List<dynamic>? ?? [];
        final supportNeeds = supportNeedsRaw.map((e) => e.toString()).toList();
        
        return CounselorStudentEntity(
          studentId: doc.id,
          studentName: data['name'] as String? ?? 'Student User',
          learningLevel: data['learningLevel'] as String? ?? 'Beginner',
          supportNeeds: supportNeeds,
          progress: (data['progress'] as num?)?.toDouble() ?? 50.0,
          lastSession: data['lastSession'] as String? ?? 'Today, 10:24 AM',
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load students: $e');
    }
  }

  @override
  Future<List<CounselorNoteEntity>> getNotes(String studentId) async {
    try {
      final snapshot = await _notesCollection
          .where('studentId', isEqualTo: studentId)
          .get();

      final notes = snapshot.docs.map((doc) {
        final data = doc.data();
        final timestamp = data['createdDate'] as Timestamp?;
        
        return CounselorNoteEntity(
          id: doc.id,
          studentId: data['studentId'] as String? ?? '',
          note: data['note'] as String? ?? '',
          createdDate: timestamp?.toDate() ?? DateTime.now(),
        );
      }).toList();

      // Sort by createdDate descending
      notes.sort((a, b) => b.createdDate.compareTo(a.createdDate));
      return notes;
    } catch (e) {
      throw Exception('Failed to load notes: $e');
    }
  }

  @override
  Future<void> addNote(String studentId, String note) async {
    try {
      final id = const Uuid().v4();
      await _notesCollection.doc(id).set({
        'studentId': studentId,
        'note': note,
        'createdDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add note: $e');
    }
  }

  @override
  Future<List<Map<String, String>>> getSessions() async {
    // Return standard clinical sessions
    return const [
      {
        'time': '2:30 PM - 3:15 PM',
        'student': 'Bobby Smith',
        'type': 'Cognitive Review',
        'room': 'Virtual Room A',
      },
      {
        'time': '4:00 PM - 4:45 PM',
        'student': 'Emma Watson (Parent Consult)',
        'type': 'Monthly Progress Evaluation',
        'room': 'Virtual Room B',
      },
      {
        'time': '5:00 PM - 5:45 PM',
        'student': 'Bobby Smith',
        'type': 'Diagnostic Feedback',
        'room': 'Virtual Room A',
      },
    ];
  }
}

// Riverpod Providers
final counselorRepositoryProvider = Provider<CounselorRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return CounselorRepositoryImpl(firestore);
});

class CounselorNotesNotifier extends StateNotifier<AsyncValue<List<CounselorNoteEntity>>> {
  final CounselorRepository _repository;
  final String _studentId;

  CounselorNotesNotifier(this._repository, this._studentId) : super(const AsyncValue.loading()) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repository.getNotes(_studentId);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addNote(String text) async {
    try {
      await _repository.addNote(_studentId, text);
      await loadNotes();
    } catch (_) {}
  }
}

final counselorNotesProvider = StateNotifierProvider.family<CounselorNotesNotifier, AsyncValue<List<CounselorNoteEntity>>, String>((ref, studentId) {
  final repo = ref.watch(counselorRepositoryProvider);
  return CounselorNotesNotifier(repo, studentId);
});

final counselorStudentsProvider = FutureProvider<List<CounselorStudentEntity>>((ref) {
  return ref.watch(counselorRepositoryProvider).getStudents();
});

final counselorSessionsProvider = FutureProvider<List<Map<String, String>>>((ref) {
  return ref.watch(counselorRepositoryProvider).getSessions();
});
