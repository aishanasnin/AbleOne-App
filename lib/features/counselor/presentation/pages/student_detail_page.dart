import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/features/counselor/domain/entities/counselor_student_entity.dart';
import 'package:ableone_app/features/parent/data/repositories/parent_repository_impl.dart';
import 'package:ableone_app/features/counselor/presentation/widgets/progress_summary_card.dart';
import 'package:ableone_app/features/counselor/presentation/pages/counselor_notes_page.dart';

/// Screen executing the rendering of visual diagnostic analytics and case note lists for specific students.
class StudentDetailPage extends ConsumerWidget {
  /// Selected student record.
  final CounselorStudentEntity student;

  /// Creates a [StudentDetailPage] instance.
  const StudentDetailPage({super.key, required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progressAsync = ref.watch(childProgressProvider(student.studentId));

    return Scaffold(
      appBar: AppBar(
        title: Text(student.studentName),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.lg),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Student Profile Header Card
                  Card(
                    color: AppColors.accent.withValues(alpha: 0.05),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    margin: const EdgeInsets.only(bottom: AppConstants.md),
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.account_circle_outlined, color: AppColors.accentDark, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'Case File: ${student.studentName}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildDetailRow('Cognitive Level', student.learningLevel),
                          const SizedBox(height: 8),
                          _buildDetailRow('Last Consultation Session', student.lastSession),
                          const SizedBox(height: 12),
                          const Text(
                            'Active Accessibility Support Needs:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: student.supportNeeds.map((need) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  need,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Progress Summary
                  progressAsync.when(
                    data: (progress) {
                      if (progress == null) return const SizedBox.shrink();
                      return ProgressSummaryCard(progress: progress);
                    },
                    error: (err, _) => Center(child: Text('Failed to load progress details: $err')),
                    loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
                  ),

                  // AI Diagnostic Support Summary
                  Card(
                    color: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    margin: const EdgeInsets.only(bottom: AppConstants.md),
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'AI Support Summary',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.md),
                          Text(
                            'Based on ${student.studentName}\'s learning statistics, they excel in interactive lessons. '
                            'We suggest adding extra descriptive diagram check points in upcoming counseling lessons. '
                            'Avoid pure text or unstructured slides to maximize retention.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.md),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CounselorNotesPage(student: student),
                              ),
                            );
                          },
                          icon: const Icon(Icons.description_outlined),
                          label: const Text('View Case Notes'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            minimumSize: const Size(120, 50), // Touch targets >= 48px
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13)),
      ],
    );
  }
}
