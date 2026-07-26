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
import 'package:ableone_app/features/parent/domain/entities/child_progress_entity.dart';
import 'package:ableone_app/features/parent/data/repositories/parent_repository_impl.dart';
import 'package:ableone_app/features/parent/presentation/widgets/progress_card.dart';
import 'package:ableone_app/features/parent/presentation/widgets/activity_card.dart';
import 'package:ableone_app/features/parent/presentation/widgets/insight_card.dart';
import 'package:ableone_app/features/accessibility/presentation/pages/accessibility_controls_page.dart';
import 'package:ableone_app/shared/widgets/premium_widgets.dart';

/// Parent portal dashboard providing streaks, completed lessons, counselor updates, and AI recommendations.
class ParentDashboardPage extends ConsumerStatefulWidget {
  /// Creates a [ParentDashboardPage] instance.
  const ParentDashboardPage({super.key});

  @override
  ConsumerState<ParentDashboardPage> createState() => _ParentDashboardPageState();
}

class _ParentDashboardPageState extends ConsumerState<ParentDashboardPage> {
  int _currentIndex = 0;

  final List<String> _titles = ['Parent Home', 'Child Analytics', 'Therapist Consults', 'Preferences'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width <= 900 && size.width > 600;

    // Watch parent insight providers for child ID 'c1'
    final progressAsync = ref.watch(childProgressProvider('c1'));
    final activitiesAsync = ref.watch(parentRecentActivitiesProvider('c1'));
    final updatesAsync = ref.watch(parentCounselorUpdatesProvider('c1'));
    final insightsAsync = ref.watch(parentAIInsightsProvider('c1'));

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          Semantics(
            label: 'Logout from parent account',
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
            _buildHomeTab(theme, isDesktop, isTablet, progressAsync, activitiesAsync, updatesAsync, insightsAsync),
            _buildProgressTab(theme, isDesktop, isTablet),
            _buildConsultTab(theme, isDesktop, isTablet),
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
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_rounded),
            selectedIcon: Icon(Icons.trending_up_rounded),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Counseling',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(
    ThemeData theme,
    bool isDesktop,
    bool isTablet,
    AsyncValue<ChildProgressEntity?> progressAsync,
    AsyncValue<List<String>> activitiesAsync,
    AsyncValue<List<String>> updatesAsync,
    AsyncValue<List<String>> insightsAsync,
  ) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.lg),
      children: [
        ProfileHeader(
          name: 'Hello, Parent! 👪',
          description: 'Track your child\'s learning and review diagnostic feedback.',
          streakDays: progressAsync.value?.streak ?? 0,
        ),
        const SizedBox(height: AppConstants.md),

        const SectionTitle(title: 'Child Profile & Progress'),
        const SizedBox(height: AppConstants.sm),

        progressAsync.when(
          data: (progress) {
            if (progress == null) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(AppConstants.lg),
                  child: Text('No active profile found.'),
                ),
              );
            }
            return ProgressCard(progress: progress);
          },
          error: (err, _) => Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.lg),
              child: Text('Error loading progress: $err'),
            ),
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.lg),
              child: CircularProgressIndicator(),
            ),
          ),
        ),

        const SizedBox(height: AppConstants.md),

        const SectionTitle(title: 'AI Insights & Strengths'),
        const SizedBox(height: AppConstants.sm),

        progressAsync.when(
          data: (progress) {
            if (progress == null) return const SizedBox.shrink();
            return insightsAsync.when(
              data: (insights) => InsightCard(
                strengths: progress.strengths,
                improvements: progress.improvementAreas,
                aiInsights: insights,
              ),
              error: (err, _) => const SizedBox.shrink(),
              loading: () => const Center(child: CircularProgressIndicator()),
            );
          },
          error: (err, _) => const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
        ),

        const SizedBox(height: AppConstants.md),

        const SectionTitle(title: 'Counselor Updates'),
        const SizedBox(height: AppConstants.sm),

        updatesAsync.when(
          data: (updates) => ActivityCard(
            title: 'Counselor Recommendations',
            icon: Icons.supervisor_account_rounded,
            iconColor: AppColors.accent,
            activities: updates,
          ),
          error: (err, _) => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),

        const SizedBox(height: AppConstants.md),

        const SectionTitle(title: 'Recent Activities'),
        const SizedBox(height: AppConstants.sm),

        activitiesAsync.when(
          data: (activities) => ActivityCard(
            title: 'Recent Timeline',
            icon: Icons.history_rounded,
            iconColor: AppColors.primary,
            activities: activities,
          ),
          error: (err, _) => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  Widget _buildProgressTab(ThemeData theme, bool isDesktop, bool isTablet) {
    final gridCount = isDesktop ? 3 : (isTablet ? 2 : 1);
    
    return ListView(
      padding: const EdgeInsets.all(AppConstants.lg),
      children: [
        const SectionTitle(title: 'Activity Progress Analytics'),
        const Text(
          'Diagnostic scoring trends over the last 14 days.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppConstants.lg),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: gridCount,
          crossAxisSpacing: AppConstants.md,
          mainAxisSpacing: AppConstants.md,
          childAspectRatio: isDesktop ? 1.4 : 1.5,
          children: [
            _buildProgressCard(
              title: 'Speech & Phonetics',
              score: '84%',
              color: Colors.blue,
              icon: Icons.keyboard_voice_rounded,
            ),
            _buildProgressCard(
              title: 'Cognitive Sequence Games',
              score: '72%',
              color: Colors.purple,
              icon: Icons.extension_rounded,
            ),
            _buildProgressCard(
              title: 'Social/Emotional Expression',
              score: '90%',
              color: Colors.pink,
              icon: Icons.favorite_rounded,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressCard({
    required String title,
    required String score,
    required Color color,
    required IconData icon,
  }) {
    return StatCard(
      label: '$title • Accuracy',
      value: score,
      icon: icon,
      color: color,
    );
  }

  Widget _buildConsultTab(ThemeData theme, bool isDesktop, bool isTablet) {
    final gridCount = isDesktop ? 2 : 1;

    return ListView(
      padding: const EdgeInsets.all(AppConstants.lg),
      children: [
        const SectionTitle(title: 'Active Consultations'),
        const Text(
          'Message your counseling team or review report charts.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppConstants.lg),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: gridCount,
          crossAxisSpacing: AppConstants.md,
          mainAxisSpacing: AppConstants.md,
          childAspectRatio: isDesktop ? 1.8 : 2.2,
          children: [
            DashboardCard(
              title: 'Dr. Jane Doe',
              subtitle: 'Lead Therapist • Active now',
              icon: Icons.supervisor_account_rounded,
              color: AppColors.accent,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening counselor chat...')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.lg),
      child: Column(
        children: [
          const SizedBox(height: AppConstants.xl),
          const CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.secondary,
            child: Icon(Icons.family_restroom_rounded, size: 48, color: Colors.white),
          ),
          const SizedBox(height: AppConstants.md),
          Text(
            'Parent Account Manager',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'parent@ableone.org',
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppConstants.xl),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.people_rounded, color: AppColors.secondary),
            title: const Text('Manage Child Accounts'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications_rounded, color: AppColors.secondary),
            title: const Text('Notification Preferences'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings_accessibility_rounded, color: AppColors.secondary),
            title: const Text('Accessibility Settings'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccessibilityControlsPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
