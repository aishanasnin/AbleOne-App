import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/features/counselor/domain/entities/counselor_note_entity.dart';

/// Card showing counselor's case observation logs.
class NoteCard extends StatelessWidget {
  /// Observation note model.
  final CounselorNoteEntity note;

  /// Creates a [NoteCard] instance.
  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('MMMM dd, yyyy • hh:mm a').format(note.createdDate);

    return Semantics(
      label: 'Note logged on $dateStr. Text content: ${note.note}',
      container: true,
      child: Card(
        color: Colors.white,
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: const EdgeInsets.only(bottom: AppConstants.md),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sticky_note_2_outlined, color: AppColors.accent, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Session Note',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.accentDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    dateStr,
                    style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.sm),
              Text(
                note.note,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
