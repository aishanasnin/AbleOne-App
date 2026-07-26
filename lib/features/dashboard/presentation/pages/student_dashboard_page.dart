import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/router/route_names.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/shared/widgets/dashboard_card.dart';
import 'package:ableone_app/shared/widgets/section_title.dart';
import 'package:ableone_app/features/authentication/data/repositories/authentication_repository_impl.dart';
import 'package:ableone_app/features/learning/data/repositories/course_repository_impl.dart';
import 'package:ableone_app/features/learning/domain/entities/course_entity.dart';
import 'package:ableone_app/core/services/firebase_service.dart';
import 'package:ableone_app/features/profile/presentation/providers/profile_providers.dart';
import 'package:ableone_app/features/communication/presentation/pages/notification_center_page.dart';
import 'package:ableone_app/features/communication/presentation/pages/conversation_list_page.dart';
import 'package:ableone_app/features/gamification/data/repositories/gamification_repository_impl.dart';
import 'package:ableone_app/features/gamification/presentation/widgets/gamification_widgets.dart';
import 'package:ableone_app/features/personalization/presentation/pages/ai_study_planner_page.dart';
import 'package:ableone_app/features/personalization/presentation/pages/learning_insights_page.dart';

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
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const NotificationCenterPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.mail_outline_rounded),
            tooltip: 'Inbox Messages',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const ConversationListPage(),
                ),
              );
            },
          ),
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
    final uid = ref.watch(firebaseAuthProvider).currentUser?.uid ?? 'dummy_user';

    final xpAsync = ref.watch(xpStatsProvider(uid));
    final streakAsync = ref.watch(streakProvider(uid));
    final badgesAsync = ref.watch(badgesProvider(uid));
    final coursesAsync = ref.watch(coursesListProvider);
    final profile = ref.watch(userProfileProvider);
    final greetingName = profile?.name ?? ref.watch(firebaseAuthProvider).currentUser?.displayName ?? 'Student';

    return ListView(
      padding: const EdgeInsets.all(AppConstants.lg),
      children: [
        // Personalized Greeting Header
        Container(
          padding: const EdgeInsets.all(AppConstants.md),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back, $greetingName! 👋',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Ready to achieve your daily targets and earn extra XP today?',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.md),

        // Streaks & Level Indicators
        xpAsync.when(
          data: (xp) => Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.md),
            child: XPBar(xp: xp),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => const SizedBox(),
        ),

        streakAsync.when(
          data: (streakVal) => Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.md),
            child: StreakCard(streak: streakVal),
          ),
          loading: () => const SizedBox(),
          error: (err, _) => const SizedBox(),
        ),

        // DAILY GOALS CHECKLIST
        const SectionTitle(title: "Today's Daily Goals"),
        const SizedBox(height: AppConstants.sm),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary),
                title: const Text('Complete 1 Sight Word Lesson', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: const Text('+10 XP • Target Goal'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                onTap: () {
                  context.push(
                    RouteNames.lessonViewerPath
                        .replaceAll(':courseId', 'c1')
                        .replaceAll(':moduleId', 'c1_m1')
                        .replaceAll(':lessonId', 'c1_m1_l1'),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.check_circle_outline_rounded, color: AppColors.secondary),
                title: const Text('Consult the AI Tutor', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: const Text('+15 XP • Practice Goal'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                onTap: () => context.push(RouteNames.aiHomePath),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                title: const Text('Open AI Daily Planner', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: const Text('View and manage your weekly schedule'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const AIStudyPlannerPage(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.lightbulb_rounded, color: Colors.amber),
                title: const Text('View Learning Insights', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: const Text('Cognitive strengths, weaknesses & Gemini hints'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const LearningInsightsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.lg),

        // CONTINUE LEARNING
        const SectionTitle(title: 'Continue Learning'),
        const SizedBox(height: AppConstants.sm),
        SizedBox(
          height: 130,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              CourseProgressCard(
                title: 'Introduction to Sight Words',
                progress: 80,
                onTap: () {
                  context.push(RouteNames.courseDetailsPath.replaceAll(':courseId', 'c1'));
                },
              ),
              CourseProgressCard(
                title: 'Visual Cognitive Counting',
                progress: 45,
                onTap: () {
                  context.push(RouteNames.courseDetailsPath.replaceAll(':courseId', 'c2'));
                },
              ),
            ],
          ),
        ),
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

        // UNLOCKED ACHIEVEMENTS
        const SectionTitle(title: 'My Achievements'),
        const SizedBox(height: AppConstants.sm),
        badgesAsync.when(
          data: (badges) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 2 : (isTablet ? 2 : 1),
                crossAxisSpacing: AppConstants.md,
                mainAxisSpacing: AppConstants.md,
                childAspectRatio: 3.5,
              ),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                return AchievementCard(badge: badges[index]);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error loading achievements: $err')),
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
}
