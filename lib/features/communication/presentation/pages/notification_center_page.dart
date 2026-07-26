import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/core/services/firebase_service.dart';
import 'package:ableone_app/features/communication/data/repositories/communication_repository_impl.dart';
import 'package:ableone_app/features/communication/presentation/widgets/communication_widgets.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';

class NotificationCenterPage extends ConsumerStatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  ConsumerState<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends ConsumerState<NotificationCenterPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(firebaseAuthProvider).currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view notifications.')),
      );
    }

    final notificationsAsync = ref.watch(notificationsStreamProvider(currentUser.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Reminders'),
            Tab(text: 'Progress'),
          ],
        ),
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildNotificationList(notifications, null),
              _buildNotificationList(notifications, 'reminder'),
              _buildNotificationList(notifications, 'progress'),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading alerts: $err')),
      ),
    );
  }

  Widget _buildNotificationList(List<dynamic> list, String? filterType) {
    final filtered = filterType == null
        ? list
        : list.where((n) => n.type.toString().toLowerCase() == filterType).toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          'No notifications in this category.',
          style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.md),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return NotificationCard(
          notification: item,
          onTap: () {
            ref.read(communicationRepositoryProvider).markNotificationAsRead(item.id);
          },
        );
      },
    );
  }
}
