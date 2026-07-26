import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ableone_app/core/services/firebase_service.dart';
import 'package:ableone_app/features/personalization/data/repositories/personalization_repository_impl.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';

class AIStudyPlannerPage extends ConsumerStatefulWidget {
  const AIStudyPlannerPage({super.key});

  @override
  ConsumerState<AIStudyPlannerPage> createState() => _AIStudyPlannerPageState();
}

class _AIStudyPlannerPageState extends ConsumerState<AIStudyPlannerPage> {
  final DateTime _selectedDate = DateTime.now();

  Future<void> _toggleTask(String uid, String task) async {
    try {
      final repo = ref.read(personalizationRepositoryProvider);
      await repo.toggleTaskCompletion(uid, _selectedDate, task);
      
      final param = StudyPlanParam(userId: uid, date: _selectedDate);
      ref.invalidate(studyPlanProvider(param));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update task: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(firebaseAuthProvider).currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your planner.')),
      );
    }

    final param = StudyPlanParam(userId: currentUser.uid, date: _selectedDate);
    final planAsync = ref.watch(studyPlanProvider(param));

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Daily Planner'),
      ),
      body: SafeArea(
        child: planAsync.when(
          data: (plan) {
            final completedCount = plan.completionStatus.values.where((v) => v).length;
            final progress = plan.tasks.isEmpty ? 0.0 : completedCount / plan.tasks.length;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Header Card
                  Card(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.15)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.calendar_month_rounded, color: Colors.white),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('EEEE, MMMM d').format(_selectedDate),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                const Text('Study checklist tailored by Gemini AI.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.lg),

                  // Progress Panel
                  const Text('Today\'s Progress', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: AppConstants.xs),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('${(progress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: AppConstants.xl),

                  // Tasks Checklist Header
                  const Text('Planner Checklist', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: AppConstants.sm),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: plan.tasks.length,
                    itemBuilder: (context, index) {
                      final task = plan.tasks[index];
                      final isCompleted = plan.completionStatus[task] ?? false;

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: CheckboxListTile(
                          activeColor: AppColors.primary,
                          title: Text(
                            task,
                            style: TextStyle(
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              color: isCompleted ? AppColors.textLight : AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          value: isCompleted,
                          onChanged: (_) => _toggleTask(currentUser.uid, task),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error loading planner: $err')),
        ),
      ),
    );
  }
}
