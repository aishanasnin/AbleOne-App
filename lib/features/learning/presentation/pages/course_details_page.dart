import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/router/route_names.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/shared/widgets/dashboard_card.dart';
import 'package:ableone_app/shared/widgets/section_title.dart';
import 'package:ableone_app/shared/widgets/loading_widget.dart';
import 'package:ableone_app/shared/widgets/empty_state.dart';
import 'package:ableone_app/shared/widgets/primary_button.dart';
import 'package:ableone_app/features/learning/data/repositories/course_repository_impl.dart';

/// Screen showing specific course descriptions, milestones count, duration, and list of learning modules.
class CourseDetailsPage extends ConsumerWidget {
  /// The course identifier.
  final String courseId;

  /// Creates a [CourseDetailsPage] instance.
  const CourseDetailsPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 700;

    final courseAsync = ref.watch(courseDetailsProvider(courseId));
    final modulesAsync = ref.watch(modulesListProvider(courseId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Details'),
      ),
      body: SafeArea(
        child: courseAsync.when(
          data: (course) {
            if (course == null) {
              return const EmptyState(
                title: 'Course Not Found',
                message: 'The requested course details could not be loaded.',
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.lg),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Thumbnail card block
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                        child: Container(
                          height: isDesktop ? 280 : 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                          ),
                          child: Image.network(
                            course.thumbnail,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.book_rounded, size: 64, color: AppColors.primary),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.lg),

                      Text(
                        course.title,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.sm),
                      
                      // Metadata badges
                      Wrap(
                        spacing: AppConstants.md,
                        runSpacing: AppConstants.sm,
                        children: [
                          _buildMetaBadge(Icons.timer_rounded, course.duration, theme),
                          _buildMetaBadge(Icons.folder_open_rounded, '${course.modulesCount} Modules', theme),
                          _buildMetaBadge(Icons.play_circle_outline_rounded, '${course.lessonsCount} Lessons', theme),
                        ],
                      ),
                      const SizedBox(height: AppConstants.lg),

                      const SectionTitle(title: 'About this Course'),
                      Text(
                        course.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppConstants.xl),

                      const SectionTitle(title: 'Course Outline'),
                      const SizedBox(height: AppConstants.sm),

                      // Modules list section
                      modulesAsync.when(
                        data: (modules) {
                          if (modules.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: AppConstants.md),
                              child: Text('No modules registered yet for this course.'),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: modules.length,
                            itemBuilder: (context, index) {
                              final module = modules[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppConstants.md),
                                child: DashboardCard(
                                  title: 'Module ${module.order}: ${module.title}',
                                  subtitle: module.description,
                                  icon: Icons.label_important_outline_rounded,
                                  color: AppColors.secondary,
                                  onTap: () {
                                    context.push(
                                      RouteNames.moduleListPath
                                          .replaceAll(':courseId', courseId),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Text('Error loading modules: $err'),
                      ),
                      const SizedBox(height: AppConstants.lg),

                      PrimaryButton(
                        text: 'Start Course Learning',
                        onPressed: () {
                          context.push(
                            RouteNames.moduleListPath
                                .replaceAll(':courseId', courseId),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const LoadingWidget(message: 'Loading course parameters...'),
          error: (e, _) => EmptyState(
            title: 'Failed to load details',
            message: e.toString().replaceAll('Exception: ', ''),
            actionText: 'Retry',
            onActionPressed: () => ref.refresh(courseDetailsProvider(courseId)),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaBadge(IconData icon, String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
