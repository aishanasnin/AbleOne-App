import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/router/route_names.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/shared/widgets/section_title.dart';
import 'package:ableone_app/shared/widgets/loading_widget.dart';
import 'package:ableone_app/shared/widgets/empty_state.dart';
import 'package:ableone_app/shared/widgets/primary_button.dart';
import 'package:ableone_app/features/learning/data/repositories/course_repository_impl.dart';
import 'package:ableone_app/core/services/firebase_service.dart';

/// Screen listing all learning courses with details like title, difficulty, progress, and continue options.
class CourseListPage extends ConsumerWidget {
  /// Creates a [CourseListPage] instance.
  const CourseListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width <= 900 && size.width > 600;

    final coursesAsync = ref.watch(coursesListProvider);
    final currentUser = ref.watch(firebaseAuthProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Modules'),
      ),
      body: SafeArea(
        child: coursesAsync.when(
          data: (courses) {
            if (courses.isEmpty) {
              return const EmptyState(
                title: 'No Courses Found',
                message: 'No learning modules are available at the moment.',
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.lg),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(
                        title: 'All Active Courses',
                        semanticsLabel: 'All Active learning modules header',
                      ),
                      const SizedBox(height: AppConstants.md),
                      _buildResponsiveGrid(context, ref, courses, currentUser?.uid, isDesktop, isTablet, theme),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const LoadingWidget(message: 'Loading courses catalog...'),
          error: (e, _) => EmptyState(
            title: 'Failed to load catalog',
            message: e.toString().replaceAll('Exception: ', ''),
            actionText: 'Retry',
            onActionPressed: () => ref.refresh(coursesListProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveGrid(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> courses,
    String? uid,
    bool isDesktop,
    bool isTablet,
    ThemeData theme,
  ) {
    final cols = isDesktop ? 3 : (isTablet ? 2 : 1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courses.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: AppConstants.lg,
        mainAxisSpacing: AppConstants.lg,
        childAspectRatio: isDesktop ? 0.78 : (isTablet ? 0.8 : 0.88),
      ),
      itemBuilder: (context, index) {
        final course = courses[index];
        
        // Progress watcher
        final progressAsync = uid != null
            ? ref.watch(userProgressProvider(ProgressParam(uid: uid, courseId: course.id)))
            : const AsyncValue<dynamic>.loading();

        return progressAsync.maybeWhen(
          data: (progress) {
            final double percent = progress?.completionPercentage ?? 0.0;
            return _buildCourseCard(context, course, percent, theme);
          },
          orElse: () => _buildCourseCard(context, course, 0.0, theme),
        );
      },
    );
  }

  Widget _buildCourseCard(BuildContext context, dynamic course, double percent, ThemeData theme) {
    return Semantics(
      container: true,
      label: 'Course: ${course.title}. Difficulty: ${course.difficulty}. Progress: ${percent.toInt()}% complete.',
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail image representation
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: Image.network(
                  course.thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.book_rounded, size: 48, color: AppColors.primary),
                    );
                  },
                ),
              ),
            ),
            
            // Text contents
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Difficulty badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(course.difficulty).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            course.difficulty,
                            style: TextStyle(
                              color: _getDifficultyColor(course.difficulty),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppConstants.sm),
                        Text(
                          course.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress bar details
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${percent.toInt()}%',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: percent / 100.0,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          minHeight: 6,
                        ),
                        const SizedBox(height: AppConstants.md),
                        
                        PrimaryButton(
                          text: 'Continue',
                          onPressed: () {
                            context.push(RouteNames.courseDetailsPath.replaceAll(':courseId', course.id));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }
}
