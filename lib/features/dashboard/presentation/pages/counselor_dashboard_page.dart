import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/router/route_names.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/shared/widgets/dashboard_card.dart';
import 'package:ableone_app/shared/widgets/section_title.dart';
import 'package:ableone_app/features/authentication/data/repositories/authentication_repository_impl.dart';

class CounselorDashboardPage extends ConsumerStatefulWidget {
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
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width <= 900 && size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
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
            _buildStudentsTab(theme, isDesktop, isTablet),
            _buildSessionsTab(theme, isDesktop, isTablet),
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

  Widget _buildStudentsTab(ThemeData theme, bool isDesktop, bool isTablet) {
    final gridCount = isDesktop ? 3 : (isTablet ? 2 : 1);

    return ListView(
      padding: const EdgeInsets.all(AppConstants.lg),
      children: [
        // Welcome Header card
        Card(
          color: AppColors.accent.withValues(alpha: 0.08),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
            side: const BorderSide(color: AppColors.accent, width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    'Hello, Counselor! 🧠',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentDark,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.xs),
                Text(
                  'Evaluate diagnostic assessments, manage counseling cases, and update therapy plans.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppConstants.lg),

        const SectionTitle(title: 'Active Patient Register'),
        const SizedBox(height: AppConstants.sm),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: gridCount,
          crossAxisSpacing: AppConstants.md,
          mainAxisSpacing: AppConstants.md,
          childAspectRatio: isDesktop ? 1.5 : 1.7,
          children: [
            _buildStudentCard(
              name: 'Alex Smith',
              condition: 'Autism Spectrum (Level 1)',
              status: 'Needs Assessment Review',
              statusColor: Colors.orange,
            ),
            _buildStudentCard(
              name: 'Emily Davis',
              condition: 'Speech Sound Disorder',
              status: 'Plan Active & Up-to-date',
              statusColor: Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStudentCard({
    required String name,
    required String condition,
    required String status,
    required Color statusColor,
  }) {
    return DashboardCard(
      title: name,
      subtitle: condition,
      icon: Icons.person_rounded,
      color: AppColors.primary,
      onTap: () {},
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: statusColor,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSessionsTab(ThemeData theme, bool isDesktop, bool isTablet) {
    final gridCount = isDesktop ? 2 : 1;

    return ListView(
      padding: const EdgeInsets.all(AppConstants.lg),
      children: [
        const SectionTitle(title: 'Upcoming Consultations Today'),
        const SizedBox(height: AppConstants.md),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: gridCount,
          crossAxisSpacing: AppConstants.md,
          mainAxisSpacing: AppConstants.md,
          childAspectRatio: isDesktop ? 1.7 : 2.0,
          children: [
            _buildSessionCard(
              time: '2:30 PM - 3:15 PM',
              student: 'Alex Smith',
              type: 'Cognitive Review',
              room: 'Virtual Room A',
            ),
            _buildSessionCard(
              time: '4:00 PM - 4:45 PM',
              student: 'Emily Davis (Parent Consult)',
              type: 'Monthly Progress Evaluation',
              room: 'Virtual Room B',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSessionCard({
    required String time,
    required String student,
    required String type,
    required String room,
  }) {
    return DashboardCard(
      title: student,
      subtitle: '$type • $time',
      icon: Icons.calendar_month_rounded,
      color: AppColors.primary,
      content: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          room,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }
}
