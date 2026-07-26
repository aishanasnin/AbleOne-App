import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/router/route_names.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/shared/widgets/dashboard_card.dart';
import 'package:ableone_app/shared/widgets/section_title.dart';
import 'package:ableone_app/features/authentication/data/repositories/authentication_repository_impl.dart';
import 'package:ableone_app/shared/widgets/premium_widgets.dart';
import 'package:ableone_app/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:ableone_app/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:ableone_app/features/admin/presentation/pages/admin_users_list_page.dart';
import 'package:ableone_app/features/admin/presentation/pages/admin_course_list_page.dart';

import 'package:ableone_app/features/communication/presentation/pages/notification_center_page.dart';
import 'package:ableone_app/features/communication/presentation/pages/conversation_list_page.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  int _currentIndex = 0;

  final List<String> _titles = ['System Directory', 'Analytics Board', 'Workspaces Config', 'Admin Profile'];

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
            label: 'Logout from administrator account',
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
            _buildDirectoryTab(theme, isDesktop, isTablet),
            _buildAnalyticsTab(theme, isDesktop, isTablet),
            _buildConfigTab(theme, isDesktop, isTablet),
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
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Users',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded),
            label: 'Config',
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

  Widget _buildDirectoryTab(ThemeData theme, bool isDesktop, bool isTablet) {
    final statsAsync = ref.watch(adminStatsProvider);
    final gridCount = isDesktop ? 4 : (isTablet ? 2 : 1);

    return ListView(
      padding: const EdgeInsets.all(AppConstants.lg),
      children: [
        ProfileHeader(
          name: 'Hello, Admin! 🛡️',
          description: 'Manage system registries, review clinical updates, and configure workflows.',
          streakDays: 0,
        ),
        const SizedBox(height: AppConstants.md),

        const SectionTitle(title: 'Overview Metrics'),
        const SizedBox(height: AppConstants.sm),

        statsAsync.when(
          data: (stats) {
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: gridCount,
              crossAxisSpacing: AppConstants.md,
              mainAxisSpacing: AppConstants.md,
              childAspectRatio: isDesktop ? 1.4 : 1.6,
              children: [
                AnalyticsCard(
                  title: 'Total Users',
                  value: '${stats.totalUsers}',
                  icon: Icons.people_rounded,
                  color: AppColors.primary,
                  subtitle: '+12% from last month',
                ),
                AnalyticsCard(
                  title: 'Active Students',
                  value: '${stats.totalStudents}',
                  icon: Icons.school_rounded,
                  color: AppColors.secondary,
                  subtitle: '92% completion rate',
                ),
                AnalyticsCard(
                  title: 'AI Conversations',
                  value: '${stats.aiInteractions}',
                  icon: Icons.smart_toy_rounded,
                  color: AppColors.accent,
                  subtitle: 'Average 12 messages/session',
                ),
                AnalyticsCard(
                  title: 'Completed Lessons',
                  value: '${stats.lessonsCompleted}',
                  icon: Icons.assignment_turned_in_rounded,
                  color: Colors.green,
                  subtitle: '+45 completed today',
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error loading stats: $err')),
        ),
        const SizedBox(height: AppConstants.lg),

        const SectionTitle(title: 'Platform Management Options'),
        const SizedBox(height: AppConstants.sm),

        DashboardCard(
          title: 'Users & Diagnostics Directory',
          subtitle: 'Approve counselors, modify child profiles, and view linked parents',
          icon: Icons.manage_accounts_rounded,
          color: AppColors.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const AdminUsersListPage(),
              ),
            );
          },
        ),
        DashboardCard(
          title: 'Course & Content Configuration',
          subtitle: 'Verify curriculum paths, outline lesson modules, and review completion rates',
          icon: Icons.collections_bookmark_rounded,
          color: AppColors.secondary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const AdminCourseListPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab(ThemeData theme, bool isDesktop, bool isTablet) {
    final gridCount = isDesktop ? 2 : 1;

    return ListView(
      padding: const EdgeInsets.all(AppConstants.lg),
      children: [
        const SectionTitle(title: 'Diagnostic Analytics Board'),
        const SizedBox(height: AppConstants.md),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: gridCount,
          crossAxisSpacing: AppConstants.md,
          mainAxisSpacing: AppConstants.md,
          childAspectRatio: isDesktop ? 1.55 : 1.35,
          children: const [
            ChartCard(
              title: 'Registered User Growth Trend',
              subtitle: 'Accumulated registered platform users (March - July)',
              color: AppColors.primary,
              labels: ['Mar', 'Apr', 'May', 'Jun', 'Jul'],
              values: [35, 58, 82, 110, 142],
            ),
            ChartCard(
              title: 'Completed Lessons By Month',
              subtitle: 'Solved diagnostic modules and Attentiveness tasks',
              color: AppColors.secondary,
              labels: ['Mar', 'Apr', 'May', 'Jun', 'Jul'],
              values: [95, 180, 260, 340, 412],
            ),
            ChartCard(
              title: 'Accessibility Toggles Usage',
              subtitle: 'Total active toggles configured in settings profiles',
              color: AppColors.accent,
              labels: ['Visual', 'Audio', 'Cognit.', 'Physic.', 'Autism'],
              values: [42, 28, 55, 15, 34],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfigTab(ThemeData theme, bool isDesktop, bool isTablet) {
    final gridCount = isDesktop ? 2 : 1;

    return ListView(
      padding: const EdgeInsets.all(AppConstants.lg),
      children: [
        const SectionTitle(title: 'Access System Toggles'),
        const SizedBox(height: AppConstants.md),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: gridCount,
          crossAxisSpacing: AppConstants.md,
          mainAxisSpacing: AppConstants.md,
          childAspectRatio: isDesktop ? 2.5 : 3.0,
          children: [
            _buildConfigToggleCard('Maintenance Mode', 'Redirects all users to offline placeholder', false),
            _buildConfigToggleCard('Allow Self Signup', 'Permits student and parent signup flows', true),
            _buildConfigToggleCard('Enable AI Copilot Assistance', 'Permits Counselor chatbot diagnostics', true),
          ],
        ),
      ],
    );
  }

  Widget _buildConfigToggleCard(String title, String subtitle, bool initialVal) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.md, vertical: AppConstants.sm),
        child: Center(
          child: SwitchListTile(
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
            value: initialVal,
            onChanged: (val) {},
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
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
            backgroundColor: Colors.red,
            child: Icon(Icons.admin_panel_settings_rounded, size: 48, color: Colors.white),
          ),
          const SizedBox(height: AppConstants.md),
          Text(
            'Platform Administrator',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'admin@ableone.org',
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppConstants.xl),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.security_rounded, color: Colors.red),
            title: const Text('Security Audit Log'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.cloud_sync_rounded, color: Colors.red),
            title: const Text('Manual Backup Trigger'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
