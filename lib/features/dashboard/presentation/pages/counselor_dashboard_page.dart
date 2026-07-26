import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/router/route_names.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/features/authentication/data/repositories/authentication_repository_impl.dart';
import 'package:ableone_app/features/counselor/presentation/pages/student_list_page.dart';
import 'package:ableone_app/features/counselor/presentation/pages/session_overview_page.dart';
import 'package:ableone_app/features/accessibility/presentation/pages/accessibility_controls_page.dart';

import 'package:ableone_app/features/communication/presentation/pages/notification_center_page.dart';
import 'package:ableone_app/features/communication/presentation/pages/conversation_list_page.dart';

/// Counselor portal dashboard managing active child cases and video consultations.
class CounselorDashboardPage extends ConsumerStatefulWidget {
  /// Creates a [CounselorDashboardPage] instance.
  const CounselorDashboardPage({super.key});

  @override
  ConsumerState<CounselorDashboardPage> createState() => _CounselorDashboardPageState();
}

class _CounselorDashboardPageState extends ConsumerState<CounselorDashboardPage> {
  int _currentIndex = 0;

  final List<String> _titles = ['My Students', 'Consultation Sessions', 'Settings'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            label: 'Logout from counselor account',
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
            const StudentListPage(),
            const SessionOverviewPage(),
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
            label: 'Students',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event_rounded),
            label: 'Sessions',
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

  Widget _buildProfileTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.lg),
      child: Column(
        children: [
          const SizedBox(height: AppConstants.xl),
          const CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.accent,
            child: Icon(Icons.psychology_rounded, size: 48, color: Colors.white),
          ),
          const SizedBox(height: AppConstants.md),
          Text(
            'Dr. Jane Doe',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'jane.doe@ableone.org',
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppConstants.xl),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.analytics_rounded, color: AppColors.accent),
            title: const Text('Clinical Case Reports'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month_rounded, color: AppColors.accent),
            title: const Text('My Work Hours & Shifts'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings_accessibility_rounded, color: AppColors.accent),
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
