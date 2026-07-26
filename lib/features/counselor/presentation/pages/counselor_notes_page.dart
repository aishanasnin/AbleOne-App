import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/features/counselor/domain/entities/counselor_student_entity.dart';
import 'package:ableone_app/features/counselor/data/repositories/counselor_repository_impl.dart';
import 'package:ableone_app/features/counselor/presentation/widgets/note_card.dart';

/// Interactive workspace for writing and viewing clinical session observation logs.
class CounselorNotesPage extends ConsumerStatefulWidget {
  /// Associated student data.
  final CounselorStudentEntity student;

  /// Creates a [CounselorNotesPage] instance.
  const CounselorNotesPage({super.key, required this.student});

  @override
  ConsumerState<CounselorNotesPage> createState() => _CounselorNotesPageState();
}

class _CounselorNotesPageState extends ConsumerState<CounselorNotesPage> {
  final TextEditingController _noteController = TextEditingController();
  bool _isSaving = false;

  Future<void> _submitNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(counselorNotesProvider(widget.student.studentId).notifier).addNote(text);
      _noteController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note added successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save note: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(counselorNotesProvider(widget.student.studentId));

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.student.studentName} - Session Notes'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // List of active notes
            Expanded(
              child: notesAsync.when(
                data: (notes) {
                  if (notes.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppConstants.xl),
                        child: Text(
                          'No observations notes recorded yet.',
                          style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.lg),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      return NoteCard(note: notes[index]);
                    },
                  );
                },
                error: (err, _) => Center(child: Text('Error loading notes: $err')),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),

            // Write Note Form Panel
            Container(
              padding: const EdgeInsets.all(AppConstants.md),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          label: 'Write counselor note input field',
                          child: TextField(
                            controller: _noteController,
                            decoration: InputDecoration(
                              hintText: 'Add clinical observation note...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            maxLines: null,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.sm),
                      Semantics(
                        label: 'Save note button',
                        child: _isSaving
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              )
                            : CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.accent,
                                child: IconButton(
                                  icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                                  onPressed: _submitNote,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
