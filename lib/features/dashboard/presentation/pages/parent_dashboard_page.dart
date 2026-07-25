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

class ParentDashboardPage extends ConsumerStatefulWidget {
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
            _buildHomeTab(theme, isDesktop, isTablet),
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

  Widget _buildHomeTab(ThemeData theme, bool isDesktop, bool isTablet) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.lg),
      children: [
        // Welcome Header card
        Card(
          color: AppColors.secondary.withValues(alpha: 0.08),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
            side: const BorderSide(color: AppColors.secondary, width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          'Hello, Parent! 👪',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondaryDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.xs),
                      Text(
                        'Track your child\'s learning and review diagnostic feedback from their counselor.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppConstants.lg),

        const SectionTitle(title: 'Child\'s Active Workspaces'),
        const SizedBox(height: AppConstants.sm),
        
        DashboardCard(
          title: 'Alex Smith',
          subtitle: 'Active Profile: Student Level 2',
          icon: Icons.person_rounded,
          color: AppColors.primary,
          content: Column(
            children: [
              _buildSummaryStat('Last Active', 'Today, 10:24 AM'),
              _buildSummaryStat('Weekly Lessons Completed', '4 / 6'),
              _buildSummaryStat('Next Counseling Session', 'Tomorrow, 4:00 PM'),
            ],
          ),
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
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
