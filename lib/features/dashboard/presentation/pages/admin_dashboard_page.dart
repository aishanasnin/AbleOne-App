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

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  int _currentIndex = 0;

  final List<String> _titles = ['System Registry', 'System Diagnostics', 'Feature Configuration', 'Admin Profile'];

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
    final gridCount = isDesktop ? 3 : (isTablet ? 3 : 1);

    return ListView(
      padding: const EdgeInsets.all(AppConstants.lg),
      children: [
        // Welcome Header card
        Card(
          color: Colors.red.withValues(alpha: 0.08),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
            side: const BorderSide(color: Colors.red, width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    'Hello, Admin! 🛡️',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.xs),
                Text(
                  'Manage system workspaces, approve counselor registration, and review access logs.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppConstants.lg),

        const SectionTitle(title: 'Total System Registry'),
        const SizedBox(height: AppConstants.sm),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: gridCount,
          crossAxisSpacing: AppConstants.md,
          mainAxisSpacing: AppConstants.md,
          childAspectRatio: isDesktop ? 1.5 : 1.3,
          children: const [
            StatCard(
              label: 'Students',
              value: '240',
              icon: Icons.school_rounded,
              color: Colors.indigo,
            ),
            StatCard(
              label: 'Counselors',
              value: '42',
              icon: Icons.psychology_rounded,
              color: Colors.orange,
            ),
            StatCard(
              label: 'Parents',
              value: '180',
              icon: Icons.family_restroom_rounded,
              color: Colors.green,
            ),
          ],
        ),
        const SizedBox(height: AppConstants.lg),
      ],
    );
  }

  Widget _buildAnalyticsTab(ThemeData theme, bool isDesktop, bool isTablet) {
    final gridCount = isDesktop ? 3 : (isTablet ? 2 : 1);

    return ListView(
      padding: const EdgeInsets.all(AppConstants.lg),
      children: [
        const SectionTitle(title: 'Diagnostic System Metrics'),
        const SizedBox(height: AppConstants.lg),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: gridCount,
          crossAxisSpacing: AppConstants.md,
          mainAxisSpacing: AppConstants.md,
          childAspectRatio: isDesktop ? 1.4 : 1.6,
          children: [
            _buildMetricCard('Active Sessions today', '48 sessions', 0.8, Colors.green),
            _buildMetricCard('Database Storage', '14.2 GB of 100 GB', 0.14, Colors.blue),
            _buildMetricCard('API Endpoint Health', '99.98% Uptime', 0.99, Colors.teal),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, double progress, Color color) {
    return DashboardCard(
      title: label,
      subtitle: value,
      icon: Icons.bar_chart_rounded,
      color: color,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ],
      ),
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
