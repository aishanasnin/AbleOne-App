import 'package:flutter/material.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/features/counselor/domain/entities/counselor_student_entity.dart';

/// Card summarizing student profile information, active needs, and progress.
class StudentCard extends StatelessWidget {
  /// Active student progress data.
  final CounselorStudentEntity student;

  /// Callback when card is selected.
  final VoidCallback onTap;

  /// Creates a [StudentCard] instance.
  const StudentCard({super.key, required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Student ${student.studentName}. Cognitive level ${student.learningLevel}. Course progress is ${student.progress.toInt()} percent. Tap to view student case file.',
      button: true,
      child: Card(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: const EdgeInsets.only(bottom: AppConstants.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      student.studentName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondary),
                  ],
                ),
                const SizedBox(height: AppConstants.xs),
                Text(
                  'Level: ${student.learningLevel}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppConstants.sm),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: student.supportNeeds.map((need) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                      ),
                      child: Text(
                        need,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.accentDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppConstants.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Progress', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    Text('${student.progress.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: student.progress / 100.0,
                    minHeight: 8,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
