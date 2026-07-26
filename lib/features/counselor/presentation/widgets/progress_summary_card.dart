import 'package:flutter/material.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/features/parent/domain/entities/child_progress_entity.dart';

/// Card summarizing course completion metrics, student strength milestones, and clinical focus topics.
class ProgressSummaryCard extends StatelessWidget {
  /// Asynchronous progress metrics.
  final ChildProgressEntity progress;

  /// Creates a [ProgressSummaryCard] instance.
  const ProgressSummaryCard({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Progress summary for ${progress.childName}. Completion is ${progress.progressPercentage.toInt()} percent. Strengths are ${progress.strengths.join(", ")}.',
      container: true,
      child: Card(
        color: Colors.white,
        elevation: 1,
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
              Text(
                'Learning Progress Analytics',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Course Completion', style: TextStyle(color: AppColors.textSecondary)),
                  Text(
                    '${progress.progressPercentage.toInt()}%',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.progressPercentage / 100.0,
                  minHeight: 10,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: AppConstants.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Completed Lessons', style: TextStyle(color: AppColors.textSecondary)),
                  Text(
                    '${progress.completedLessons.length} Topics',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.lg),
              
              // Strengths
              const Text(
                'Identified Excelling Areas',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 13),
              ),
              const SizedBox(height: AppConstants.xs),
              ...progress.strengths.map((str) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.check_rounded, color: AppColors.success, size: 14),
                    const SizedBox(width: 6),
                    Expanded(child: Text(str, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              )),

              const SizedBox(height: AppConstants.md),

              // Focus areas
              const Text(
                'Cognitive Reinforcement Areas',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 13),
              ),
              const SizedBox(height: AppConstants.xs),
              ...progress.improvementAreas.map((imp) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.secondary, size: 14),
                    const SizedBox(width: 6),
                    Expanded(child: Text(imp, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
