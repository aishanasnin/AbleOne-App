import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/shared/widgets/loading_widget.dart';
import 'package:ableone_app/shared/widgets/empty_state.dart';
import 'package:ableone_app/shared/widgets/primary_button.dart';
import 'package:ableone_app/features/learning/domain/entities/progress_entity.dart';
import 'package:ableone_app/features/learning/data/repositories/course_repository_impl.dart';
import 'package:ableone_app/core/services/firebase_service.dart';
import 'package:ableone_app/features/ai/presentation/providers/ai_providers.dart';

/// Screen executing the rendering of visual content for lessons depending on
/// their type (Video player layout, PDF mock viewer, Text document layout,
/// Audio player controls, or Quiz prompts).
class LessonViewerPage extends ConsumerStatefulWidget {
  /// The course identifier.
  final String courseId;
  /// The module identifier.
  final String moduleId;
  /// The lesson identifier.
  final String lessonId;

  /// Creates a [LessonViewerPage] instance.
  const LessonViewerPage({
    super.key,
    required this.courseId,
    required this.moduleId,
    required this.lessonId,
  });

  @override
  ConsumerState<LessonViewerPage> createState() => _LessonViewerPageState();
}

class _LessonViewerPageState extends ConsumerState<LessonViewerPage> {
  bool _isSaving = false;

  int _getTotalLessons(String courseId) {
    if (courseId == 'c1') return 5;
    if (courseId == 'c2') return 2;
    return 1;
  }

  Future<void> _markCompleted(dynamic lesson, String uid) async {
    setState(() {
      _isSaving = true;
    });

    try {
      final repository = ref.read(courseRepositoryProvider);
      
      // Load current progress
      final currentProgress = await repository.getProgress(uid, widget.courseId);
      
      List<String> completed = [];
      int currentXp = 0;
      int currentStreak = 0;

      if (currentProgress != null) {
        completed = List<String>.from(currentProgress.completedLessons);
        currentXp = currentProgress.xp;
        currentStreak = currentProgress.streak;
      } else {
        currentStreak = 1;
      }

      if (!completed.contains(widget.lessonId)) {
        completed.add(widget.lessonId);
        currentXp += 15; // +15 XP for every completed lesson
      }

      final total = _getTotalLessons(widget.courseId);
      final double percent = (completed.length / total) * 100.0;

      final updatedProgress = ProgressEntity(
        uid: uid,
        courseId: widget.courseId,
        completedLessons: completed,
        completionPercentage: percent > 100.0 ? 100.0 : percent,
        xp: currentXp,
        streak: currentStreak,
      );

      await repository.saveProgress(updatedProgress);

      // Refresh providers
      ref.invalidate(userProgressProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lesson Completed! +15 XP earned. Progress: ${percent.toInt()}%'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save progress: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
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
    final theme = Theme.of(context);
    final currentUser = ref.watch(firebaseAuthProvider).currentUser;

    // Load active course/lesson to set state reactively
    final courseAsync = ref.watch(courseDetailsProvider(widget.courseId));
    final lessonsAsync = ref.watch(lessonsListProvider(widget.moduleId));

    // Update active learning context reactively
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (courseAsync.hasValue && courseAsync.value != null) {
        if (ref.read(currentCourseStateProvider) != courseAsync.value) {
          ref.read(currentCourseStateProvider.notifier).state = courseAsync.value;
        }
      }
      if (lessonsAsync.hasValue) {
        final lessons = lessonsAsync.value!;
        final lessonIndex = lessons.indexWhere((l) => l.id == widget.lessonId);
        if (lessonIndex != -1) {
          final lesson = lessons[lessonIndex];
          if (ref.read(currentLessonStateProvider) != lesson) {
            ref.read(currentLessonStateProvider.notifier).state = lesson;
          }
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson Viewer'),
      ),
      body: SafeArea(
        child: lessonsAsync.when(
          data: (lessons) {
            final lessonIndex = lessons.indexWhere((l) => l.id == widget.lessonId);

            if (lessonIndex == -1) {
              return const EmptyState(
                title: 'Lesson Not Found',
                message: 'The requested lesson could not be located in this module.',
              );
            }

            final lesson = lessons[lessonIndex];

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppConstants.lg),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lesson.title,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppConstants.xs),
                            Text(
                              'Estimated time: ${lesson.duration} • Type: ${lesson.type.toUpperCase()}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppConstants.lg),
                            
                            // Render specific content layouts depending on type
                            _buildLessonTypeBody(lesson, theme),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Bottom control panel
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
                            child: PrimaryButton(
                              text: 'Mark Completed',
                              isLoading: _isSaving,
                              onPressed: _isSaving || currentUser == null
                                  ? null
                                  : () => _markCompleted(lesson, currentUser.uid),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const LoadingWidget(message: 'Loading lesson details...'),
          error: (err, _) => EmptyState(
            title: 'Failed to load lesson',
            message: err.toString().replaceAll('Exception: ', ''),
            actionText: 'Back',
            onActionPressed: () => context.pop(),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonTypeBody(dynamic lesson, ThemeData theme) {
    final type = lesson.type.toLowerCase();

    if (type == 'video') {
      return _buildVideoPlayerLayout(lesson.content, theme);
    } else if (type == 'pdf') {
      return _buildPdfViewerLayout(lesson.title, theme);
    } else if (type == 'audio') {
      return _buildAudioPlayerLayout(lesson.title, theme);
    } else if (type == 'quiz') {
      return _buildQuizLayout(theme);
    } else {
      // Default: Text Content
      return _buildTextContentLayout(lesson.content, theme);
    }
  }

  Widget _buildVideoPlayerLayout(String videoUrl, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: 'Video player area playing source content',
          child: Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_circle_fill_rounded, size: 64, color: Colors.white),
                SizedBox(height: AppConstants.sm),
                Text(
                  'Playing: Video Lesson Source',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppConstants.lg),
        Text(
          'Streaming source: $videoUrl',
          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textLight),
        ),
      ],
    );
  }

  Widget _buildPdfViewerLayout(String title, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: 'Document PDF Viewer',
          child: Container(
            height: 260,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.picture_as_pdf_rounded, size: 64, color: Colors.red),
                const SizedBox(height: AppConstants.sm),
                Text(
                  '$title Worksheet.pdf',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Mock PDF Viewer (3 Pages loaded)',
                  style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioPlayerLayout(String title, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.primaryLight, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.audiotrack_rounded, size: 40, color: AppColors.primary),
              const SizedBox(width: AppConstants.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Phonetics Spelling Guide',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.md),
          Slider(
            value: 0.35,
            onChanged: (val) {},
            activeColor: AppColors.primary,
            inactiveColor: AppColors.border,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0:45', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text('2:15', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.play_circle_filled_rounded, size: 48, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildQuizLayout(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.quiz_outlined, color: AppColors.primary),
                SizedBox(width: AppConstants.sm),
                Text(
                  'Module Checkpoint Quiz',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.md),
            Text(
              'Quiz features are currently in mock status. You can mark this lesson as completed directly to proceed to the next module.',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextContentLayout(String content, ThemeData theme) {
    return Text(
      content,
      style: theme.textTheme.bodyLarge?.copyWith(
        height: 1.6,
        color: AppColors.textPrimary,
      ),
    );
  }
}
