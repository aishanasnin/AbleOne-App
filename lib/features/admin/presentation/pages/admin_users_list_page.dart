import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:ableone_app/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:ableone_app/features/admin/presentation/pages/admin_student_detail_page.dart';
import 'package:ableone_app/features/admin/presentation/pages/admin_counselor_detail_page.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';

class AdminUsersListPage extends ConsumerStatefulWidget {
  const AdminUsersListPage({super.key});

  @override
  ConsumerState<AdminUsersListPage> createState() => _AdminUsersListPageState();
}

class _AdminUsersListPageState extends ConsumerState<AdminUsersListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Administration'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Students'),
            Tab(text: 'Parents'),
            Tab(text: 'Counselors'),
          ],
        ),
      ),
      body: usersAsync.when(
        data: (users) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildUserFilteredList(users, null),
              _buildUserFilteredList(users, 'student'),
              _buildUserFilteredList(users, 'parent'),
              _buildUserFilteredList(users, 'counselor'),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildUserFilteredList(List<Map<String, dynamic>> users, String? roleFilter) {
    final filtered = roleFilter == null
        ? users
        : users.where((u) => (u['role'] as String).toLowerCase() == roleFilter).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No users in this registry category.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.md),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final user = filtered[index];
        return UserCard(
          user: user,
          onTap: () => _navigateToDetail(user),
        );
      },
    );
  }

  void _navigateToDetail(Map<String, dynamic> user) {
    final role = (user['role'] as String).toLowerCase();
    if (role == 'student') {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => AdminStudentDetailPage(student: user),
        ),
      );
    } else if (role == 'counselor') {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => AdminCounselorDetailPage(counselor: user),
        ),
      );
    } else {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(user['name'] as String? ?? 'Parent Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: ${user['email']}'),
              const SizedBox(height: 8),
              Text('Associated Child: ${user['associatedChild'] ?? 'None'}'),
              Text('Linked Counselor: ${user['linkedCounselor'] ?? 'None'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }
}
