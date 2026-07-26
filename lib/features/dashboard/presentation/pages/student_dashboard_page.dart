import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/router/route_names.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/shared/widgets/dashboard_card.dart';
import 'package:ableone_app/shared/widgets/stat_card.dart';
import 'package:ableone_app/shared/widgets/section_title.dart';
import 'package:ableone_app/features/authentication/data/repositories/authentication_repository_impl.dart';
import 'package:ableone_app/features/learning/data/repositories/course_repository_impl.dart';
import 'package:ableone_app/features/learning/domain/entities/course_entity.dart';
import 'package:ableone_app/core/services/firebase_service.dart';
import 'package:ableone_app/features/profile/presentation/providers/profile_providers.dart';
import 'package:ableone_app/shared/widgets/premium_widgets.dart';

/// The main dashboard screen for student users, featuring quick access tabs
/// for course overview, lesson paths, therapy schedules, and user preference profiles.
class StudentDashboardPage extends ConsumerStatefulWidget {
  /// Creates a [StudentDashboardPage] instance.
  const StudentDashboardPage({super.key});

  @override
  ConsumerState<StudentDashboardPage> createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends ConsumerState<StudentDashboardPage> {
  int _currentIndex = 0;

  final List<String> _titles = ['Student Home', 'My Lessons', 'Therapy Plan', 'My Profile'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width <= 900 && size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          Semantics(
            label: 'Log out from student account',
            child: IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Logout',
              onPressed: () {
                ref.read(authenticationRepositoryProvider).signOut();
                context.go(RouteNames.welcomePath);
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeTab(theme, isDesktop, isTablet),
            _buildLessonsTab(theme, isDesktop, isTablet),
            _buildTherapyTab(theme),
            _buildProfileTab(theme),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book_rounded),
            label: 'Lessons',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology_rounded),
            label: 'Therapy',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(ThemeData theme, bool isDesktop, bool isTablet) {
    final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;

    // Load progress for Course 1 as the default "Continue Learning" course
    final defaultCourseProgressAsync = uid != null
        ? ref.watch(userProgressProvider(ProgressParam(uid: uid, courseId: 'c1')))
        : const AsyncValue<dynamic>.loading();

    final coursesAsync = ref.watch(coursesListProvider);
    final profile = ref.watch(userProfileProvider);
    final greetingName = profile?.name ?? ref.watch(firebaseAuthProvider).currentUser?.displayName ?? 'Student';

    int streak = 0;
    if (uid != null) {
      final progressAsync = ref.watch(userProgressProvider(ProgressParam(uid: uid, courseId: 'c1')));
      progressAsync.whenData((progress) {
        if (progress != null) {
          streak = progress.streak;
        }
      });
    }

    return ListView(
      padding: const EdgeInsets.all(AppConstants.lg),
      children: [
        // Welcome Header & Streak Section
        ProfileHeader(
          name: greetingName,
          description: 'Level: ${profile?.learningLevel ?? 'Beginner'} • style: ${profile?.learningPreference ?? 'Simple explanations'}',
          streakDays: streak,
        ),
        const SizedBox(height: AppConstants.md),

        // ACTIVE LEARNING MODE
        const SectionTitle(title: 'Active Learning Mode'),
        const SizedBox(height: AppConstants.sm),
        AnimatedButton(
          onPressed: () {
            context.push(RouteNames.profilePagePath);
          },
          child: GlassCard(
            color: AppColors.secondary.withValues(alpha: 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.accessibility_new_rounded, color: AppColors.secondary, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Personalized Profile Settings',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.xs),
                Text(
                  'Level: ${profile?.learningLevel ?? 'Beginner'} • Style: ${profile?.learningPreference ?? 'Simple explanations'}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppConstants.sm),
                Wrap(
                  spacing: AppConstants.sm,
                  runSpacing: AppConstants.xs,
                  children: (profile?.supportNeeds ?? const []).isEmpty
                      ? [
                          Chip(
                            label: const Text('No specific support needs', style: TextStyle(fontSize: 12)),
                            avatar: const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.secondary),
                            backgroundColor: AppColors.secondary.withValues(alpha: 0.05),
                            side: BorderSide.none,
                          )
                        ]
                      : (profile?.supportNeeds ?? const []).map((need) {
                          return Chip(
                            label: Text(need, style: const TextStyle(fontSize: 12)),
                            avatar: Icon(_getSupportIcon(need), size: 14, color: AppColors.secondary),
                            backgroundColor: AppColors.secondary.withValues(alpha: 0.05),
                            side: BorderSide.none,
                          );
                        }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppConstants.lg),

        // RECOMMENDED ACTIONS
        const SectionTitle(title: 'Recommended Actions'),
        const SizedBox(height: AppConstants.sm),
        if (profile == null || profile.supportNeeds.isEmpty)
          DashboardCard(
            title: 'Complete Accessibility Setup',
            subtitle: 'Configure your personalized support needs and learning level for a tailored experience.',
            icon: Icons.settings_accessibility_rounded,
            color: AppColors.error,
            onTap: () {
              context.push(RouteNames.accessibilitySetupPath, extra: profile?.supportNeeds ?? const []);
            },
          ),
        DashboardCard(
          title: 'Start AI Tutor Session',
          subtitle: 'Learn with custom explanations in "${profile?.learningPreference ?? 'Simple explanations'}" style.',
          icon: Icons.chat_bubble_outline_rounded,
          color: AppColors.primary,
          onTap: () {
            context.push(RouteNames.aiHomePath);
          },
        ),
        DashboardCard(
          title: 'Perform Daily Focus Exercises',
          subtitle: 'Access therapy sessions designed for your cognitive learning profile.',
          icon: Icons.fitness_center_rounded,
          color: AppColors.secondary,
          onTap: () {
            setState(() {
              _currentIndex = 2; // Swap to Therapy Tab
            });
          },
        ),
        const SizedBox(height: AppConstants.lg),

        // CONTINUE LEARNING
        const SectionTitle(title: 'Continue Learning'),
        const SizedBox(height: AppConstants.sm),
        defaultCourseProgressAsync.maybeWhen(
          data: (progress) {
            final percent = progress?.completionPercentage ?? 0.0;
            return AnimatedButton(
              onPressed: () {
                context.push(RouteNames.courseDetailsPath.replaceAll(':courseId', 'c1'));
              },
              child: GradientCard(
                colors: const [AppColors.primary, AppColors.primaryLight],
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Introduction to Sight Words',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Module 1 • ${percent.toInt()}% Complete',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ProgressRing(
                      value: percent / 100.0,
                      size: 54,
                      strokeWidth: 4,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            );
          },
          orElse: () => DashboardCard(
            title: 'Introduction to Sight Words',
            subtitle: 'Start your learning journey now!',
            icon: Icons.play_arrow_rounded,
            color: AppColors.primary,
            onTap: () {
              context.push(RouteNames.courseDetailsPath.replaceAll(':courseId', 'c1'));
            },
          ),
        ),
        const SizedBox(height: AppConstants.lg),

        // TODAY'S TASKS
        const SectionTitle(title: "Today's Tasks"),
        const SizedBox(height: AppConstants.sm),
        DashboardCard(
          title: 'Learn Vowels & Phonetic Sounds',
          subtitle: 'Daily Attentiveness Task • 10 mins remaining',
          icon: Icons.task_alt_rounded,
          color: AppColors.secondary,
          onTap: () {
            context.push(
              RouteNames.lessonViewerPath
                  .replaceAll(':courseId', 'c1')
                  .replaceAll(':moduleId', 'c1_m1')
                  .replaceAll(':lessonId', 'c1_m1_l2'),
            );
          },
        ),
        const SizedBox(height: AppConstants.lg),

        // AI TUTOR SHORTCUT
        const SectionTitle(title: 'AI Tutor'),
        const SizedBox(height: AppConstants.sm),
        DashboardCard(
          title: 'Consult AI Tutor Assistant',
          subtitle: 'Ask questions, simplify lessons, or run quick quizzes',
          icon: Icons.smart_toy_outlined,
          color: AppColors.accent,
          onTap: () {
            context.push(RouteNames.aiHomePath);
          },
        ),
        const SizedBox(height: AppConstants.lg),

        // PROGRESS SUMMARY
        SectionTitle(
          title: 'My Progress Stats',
          actionText: 'View Details',
          onActionPressed: () => context.push(RouteNames.progressScreenPath),
        ),
        const SizedBox(height: AppConstants.sm),
        _buildProgressOverview(ref, uid, isDesktop, isTablet),
        const SizedBox(height: AppConstants.lg),

        // RECOMMENDED COURSES
        SectionTitle(
          title: 'Recommended Courses',
          actionText: 'Browse Catalog',
          onActionPressed: () => context.push(RouteNames.courseListPath),
        ),
        const SizedBox(height: AppConstants.sm),
        _buildRecommendedCourses(coursesAsync, ref, uid, isDesktop, isTablet, theme),
        const SizedBox(height: AppConstants.lg),

        // RECENT LESSONS
        const SectionTitle(title: 'Recent Lessons'),
        const SizedBox(height: AppConstants.sm),
        Column(
          children: [
            ListTile(
              leading: const Icon(Icons.description_outlined, color: AppColors.primary),
              title: const Text('What are Sight Words?'),
              subtitle: const Text('Text Lesson • Course 1'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                context.push(
                  RouteNames.lessonViewerPath
                      .replaceAll(':courseId', 'c1')
                      .replaceAll(':moduleId', 'c1_m1')
                      .replaceAll(':lessonId', 'c1_m1_l1'),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.play_circle_outline_rounded, color: AppColors.primary),
              title: const Text('Common Sight Words Video Guide'),
              subtitle: const Text('Video Lesson • Course 1'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                context.push(
                  RouteNames.lessonViewerPath
                      .replaceAll(':courseId', 'c1')
                      .replaceAll(':moduleId', 'c1_m1')
                      .replaceAll(':lessonId', 'c1_m1_l2'),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressOverview(WidgetRef ref, String? uid, bool isDesktop, bool isTablet) {
    int totalXp = 0;
    int streak = 0;

    if (uid != null) {
      final progressAsync = ref.watch(userProgressProvider(ProgressParam(uid: uid, courseId: 'c1')));
      progressAsync.whenData((progress) {
        if (progress != null) {
          totalXp = progress.xp;
          streak = progress.streak;
        }
      });
    }

    final cols = isDesktop ? 2 : 2;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: cols,
      crossAxisSpacing: AppConstants.md,
      mainAxisSpacing: AppConstants.md,
      childAspectRatio: 1.6,
      children: [
        StatCard(
          icon: Icons.local_fire_department_rounded,
          color: Colors.orange,
          value: '$streak Days',
          label: 'Daily Streak',
        ),
        StatCard(
          icon: Icons.stars_rounded,
          color: Colors.amber,
          value: '$totalXp XP',
          label: 'Experience Points',
        ),
      ],
    );
  }

  Widget _buildRecommendedCourses(
    AsyncValue<List<CourseEntity>> coursesAsync,
    WidgetRef ref,
    String? uid,
    bool isDesktop,
    bool isTablet,
    ThemeData theme,
  ) {
    return coursesAsync.when(
      data: (courses) {
        final recs = courses.where((c) => c.id != 'c1').toList();

        if (recs.isEmpty) {
          return const Text('No new course recommendations at this time.');
        }

        final count = isDesktop ? 2 : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recs.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            crossAxisSpacing: AppConstants.md,
            mainAxisSpacing: AppConstants.md,
            childAspectRatio: isDesktop ? 1.6 : 1.75,
          ),
          itemBuilder: (context, index) {
            final course = recs[index];
            final progressAsync = uid != null
                ? ref.watch(userProgressProvider(ProgressParam(uid: uid, courseId: course.id)))
                : const AsyncValue<dynamic>.loading();

            return progressAsync.maybeWhen(
              data: (progress) {
                final double percent = progress?.completionPercentage ?? 0.0;
                return _buildCourseRecommendationCard(context, course, percent, theme);
              },
              orElse: () => _buildCourseRecommendationCard(context, course, 0.0, theme),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error loading recommendations: $e'),
    );
  }

  Widget _buildCourseRecommendationCard(BuildContext context, CourseEntity course, double percent, ThemeData theme) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      elevation: 0,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              height: double.infinity,
              color: AppColors.primary.withValues(alpha: 0.1),
              child: Image.network(
                course.thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.book_rounded, color: AppColors.primary),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        course.description,
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        course.difficulty,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
                        iconSize: 18,
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
    );
  }

  Widget _buildLessonsTab(ThemeData theme, bool isDesktop, bool isTablet) {
    final gridCount = isDesktop ? 3 : (isTablet ? 2 : 1);
    final lessons = [
      _buildLessonCard(
        title: 'Introduction to Numbers',
        category: 'Mathematics',
        progress: 0.8,
        progressText: '80% Complete',
        icon: Icons.calculate_outlined,
        color: Colors.blue,
      ),
      _buildLessonCard(
        title: 'Sight Words & Phonetics',
        category: 'English Literacy',
        progress: 0.45,
        progressText: '45% Complete',
        icon: Icons.abc_rounded,
        color: Colors.teal,
      ),
      _buildLessonCard(
        title: 'Emotions and Expression',
        category: 'Social Learning',
        progress: 0.1,
        progressText: 'Started',
        icon: Icons.face_retouching_natural_rounded,
        color: Colors.purple,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(AppConstants.lg),
      children: [
        const SectionTitle(title: 'My Learning Modules'),
        const Text(
          'Custom courses configured for your accessibility preferences.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppConstants.lg),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: gridCount,
          crossAxisSpacing: AppConstants.md,
          mainAxisSpacing: AppConstants.md,
          childAspectRatio: isDesktop ? 1.3 : 1.4,
          children: lessons,
        ),
      ],
    );
  }

  Widget _buildLessonCard({
    required String title,
    required String category,
    required double progress,
    required String progressText,
    required IconData icon,
    required Color color,
  }) {
    return DashboardCard(
      title: title,
      subtitle: '$category • $progressText',
      icon: icon,
      color: color,
      onTap: () {},
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.xs),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildTherapyTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.lg),
      children: [
        const SectionTitle(title: 'Therapy Routine Path'),
        const Text(
          'Weekly cognitive and emotional exercises assigned by your counselor.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppConstants.lg),

        DashboardCard(
          title: 'Today\'s Focus Routine',
          icon: Icons.calendar_today_rounded,
          color: AppColors.primary,
          content: Column(
            children: [
              _buildRoutineItem('1. Word Association game', true),
              _buildRoutineItem('2. Focus Grid training (5 min)', false),
              _buildRoutineItem('3. Sentence completion exercise', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoutineItem(String title, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: isCompleted ? AppColors.secondary : AppColors.textLight,
            size: 20,
          ),
          const SizedBox(width: AppConstants.sm),
          Text(
            title,
            style: TextStyle(
              decoration: isCompleted ? TextDecoration.lineThrough : null,
              color: isCompleted ? AppColors.textLight : AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: AppConstants.xl),
          const CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary,
            child: Text(
              'S',
              style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: AppConstants.md),
          Text(
            'Student User',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'student@ableone.org',
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppConstants.xl),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.accessibility_rounded, color: AppColors.primary),
            title: const Text('Accessibility Settings'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              context.push(RouteNames.profilePagePath);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_rounded, color: AppColors.primary),
            title: const Text('Account Preferences'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  IconData _getSupportIcon(String need) {
    switch (need.toLowerCase()) {
      case 'visual support':
        return Icons.visibility_rounded;
      case 'hearing support':
        return Icons.hearing_rounded;
      case 'speech support':
        return Icons.record_voice_over_rounded;
      case 'physical support':
        return Icons.accessible_rounded;
      case 'learning support':
        return Icons.menu_book_rounded;
      case 'autism / neurodivergent support':
        return Icons.psychology_rounded;
      case 'multiple support needs':
        return Icons.dynamic_feed_rounded;
      default:
        return Icons.accessibility_new_rounded;
    }
  }
}
