import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/router/route_names.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/shared/widgets/section_title.dart';
import 'package:ableone_app/shared/widgets/loading_widget.dart';
import 'package:ableone_app/shared/widgets/empty_state.dart';
import 'package:ableone_app/features/learning/data/repositories/course_repository_impl.dart';

/// Screen listing course modules and expanding their sub-lessons sequentially.
class ModuleListPage extends ConsumerWidget {
  /// The course identifier.
  final String courseId;

  /// Creates a [ModuleListPage] instance.
  const ModuleListPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modulesAsync = ref.watch(modulesListProvider(courseId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Syllabus'),
      ),
      body: SafeArea(
        child: modulesAsync.when(
          data: (modules) {
            if (modules.isEmpty) {
              return const EmptyState(
                title: 'No Outline Found',
                message: 'This course outline is empty or still loading.',
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.lg),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(
                        title: 'Course Lessons syllabus',
                        semanticsLabel: 'Course Lessons list header',
                      ),
                      const SizedBox(height: AppConstants.md),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: modules.length,
                        itemBuilder: (context, index) {
                          final module = modules[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: AppConstants.md),
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                              side: const BorderSide(color: AppColors.border, width: 1),
                            ),
                            elevation: 0,
                            child: ExpansionTile(
                              title: Text(
                                'Module ${module.order}: ${module.title}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(module.description),
                              children: [
                                _LessonsList(
                                  moduleId: module.id,
                                  courseId: courseId,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const LoadingWidget(message: 'Loading syllabus outline...'),
          error: (err, _) => EmptyState(
            title: 'Failed to load outline',
            message: err.toString().replaceAll('Exception: ', ''),
            actionText: 'Retry',
            onActionPressed: () => ref.refresh(modulesListProvider(courseId)),
          ),
        ),
      ),
    );
  }
}

class _LessonsList extends ConsumerWidget {
  final String moduleId;
  final String courseId;

  const _LessonsList({
    required this.moduleId,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(lessonsListProvider(moduleId));

    return lessonsAsync.when(
      data: (lessons) {
        if (lessons.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(AppConstants.md),
            child: Text('No lessons in this module.'),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final lesson = lessons[index];
            return ListTile(
              leading: Icon(_getLessonIcon(lesson.type), color: AppColors.primary),
              title: Text(lesson.title),
              subtitle: Text('${lesson.type.toUpperCase()} • ${lesson.duration}'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                context.push(
                  RouteNames.lessonViewerPath
                      .replaceAll(':courseId', courseId)
                      .replaceAll(':moduleId', moduleId)
                      .replaceAll(':lessonId', lesson.id),
                );
              },
            );
          },
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(AppConstants.md),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.all(AppConstants.md),
        child: Text('Error loading lessons: $err'),
      ),
    );
  }

  IconData _getLessonIcon(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return Icons.play_circle_outline_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'audio':
        return Icons.audiotrack_rounded;
      case 'quiz':
        return Icons.quiz_outlined;
      default:
        return Icons.description_outlined;
    }
  }
}
