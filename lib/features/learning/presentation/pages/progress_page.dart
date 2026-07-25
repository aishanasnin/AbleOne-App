import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/shared/widgets/stat_card.dart';
import 'package:ableone_app/shared/widgets/section_title.dart';
import 'package:ableone_app/shared/widgets/loading_widget.dart';
import 'package:ableone_app/shared/widgets/empty_state.dart';
import 'package:ableone_app/shared/widgets/dashboard_card.dart';
import 'package:ableone_app/features/learning/data/repositories/course_repository_impl.dart';
import 'package:ableone_app/core/services/firebase_service.dart';

/// Screen displaying the user's overall learning progress metrics: XP, Streak,
/// and Completion Percentages.
class ProgressPage extends ConsumerWidget {
  /// Creates a [ProgressPage] instance.
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width <= 900 && size.width > 600;

    final currentUser = ref.watch(firebaseAuthProvider).currentUser;
    final coursesAsync = ref.watch(coursesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Learning Progress'),
      ),
      body: SafeArea(
        child: currentUser == null
            ? const EmptyState(
                title: 'Not Authenticated',
                message: 'Please sign in to track and view your progress.',
              )
            : coursesAsync.when(
                data: (courses) {
                  return _buildProgressContent(context, ref, courses, currentUser.uid, isDesktop, isTablet, theme);
                },
                loading: () => const LoadingWidget(message: 'Retrieving your analytics...'),
                error: (e, _) => EmptyState(
                  title: 'Load Failed',
                  message: e.toString(),
                  actionText: 'Retry',
                  onActionPressed: () => ref.refresh(coursesListProvider),
                ),
              ),
      ),
    );
  }

  Widget _buildProgressContent(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> courses,
    String uid,
    bool isDesktop,
    bool isTablet,
    ThemeData theme,
  ) {
    int totalXp = 0;
    int maxStreak = 0;
    int completedLessonsCount = 0;

    // Load progress list for each course to calculate aggregates
    final List<Map<String, dynamic>> coursesProgress = [];

    for (final course in courses) {
      final progressAsync = ref.watch(userProgressProvider(ProgressParam(uid: uid, courseId: course.id)));
      progressAsync.whenData((progress) {
        if (progress != null) {
          totalXp += progress.xp;
          if (progress.streak > maxStreak) {
            maxStreak = progress.streak;
          }
          completedLessonsCount += progress.completedLessons.length;
          coursesProgress.add({
            'course': course,
            'percent': progress.completionPercentage,
            'completed': progress.completedLessons.length,
            'total': course.lessonsCount,
          });
        } else {
          coursesProgress.add({
            'course': course,
            'percent': 0.0,
            'completed': 0,
            'total': course.lessonsCount,
          });
        }
      });
    }

    final gridCols = isDesktop ? 3 : (isTablet ? 3 : 1);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.lg),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(title: 'Overview Metrics'),
              const SizedBox(height: AppConstants.sm),
              
              // Statistics cards row/grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: gridCols,
                crossAxisSpacing: AppConstants.md,
                mainAxisSpacing: AppConstants.md,
                childAspectRatio: isDesktop ? 1.4 : 1.3,
                children: [
                  StatCard(
                    label: 'Total XP',
                    value: '$totalXp XP',
                    icon: Icons.stars_rounded,
                    color: Colors.amber,
                  ),
                  StatCard(
                    label: 'Daily Streak',
                    value: '$maxStreak Days',
                    icon: Icons.local_fire_department_rounded,
                    color: Colors.orange,
                  ),
                  StatCard(
                    label: 'Completed Lessons',
                    value: '$completedLessonsCount Lessons',
                    icon: Icons.check_circle_rounded,
                    color: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.xl),

              const SectionTitle(title: 'Course Completions'),
              const SizedBox(height: AppConstants.sm),

              if (coursesProgress.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppConstants.lg),
                  child: Text('No active course progress to display.'),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: coursesProgress.length,
                  itemBuilder: (context, index) {
                    final item = coursesProgress[index];
                    final course = item['course'];
                    final double percent = item['percent'];
                    final int completed = item['completed'];
                    final int total = item['total'];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.md),
                      child: DashboardCard(
                        title: course.title,
                        subtitle: '$completed of $total lessons completed',
                        icon: Icons.menu_book_rounded,
                        color: AppColors.primary,
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: percent / 100.0,
                              backgroundColor: AppColors.border,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                              minHeight: 6,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${percent.toInt()}% Complete',
                              style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
