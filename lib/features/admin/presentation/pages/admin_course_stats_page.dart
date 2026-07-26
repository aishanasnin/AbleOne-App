import 'package:flutter/material.dart';
import 'package:ableone_app/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';

class AdminCourseStatsPage extends StatelessWidget {
  const AdminCourseStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Completion Analytics'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.lg),
        children: [
          Text(
            'Enrollment Overview',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppConstants.sm),
          const ChartCard(
            title: 'Active Registrations By Course',
            subtitle: 'Real-time enrollment allocations for academic tracks',
            color: AppColors.primary,
            labels: ['Words', 'Maths', 'Emotions', 'Attention'],
            values: [45, 38, 25, 34],
          ),
          const SizedBox(height: AppConstants.lg),

          Text(
            'Comparative Analysis',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppConstants.sm),
          const ChartCard(
            title: 'Completion Success Rates (%)',
            subtitle: 'Average percentage of users finishing course pathways',
            color: AppColors.secondary,
            labels: ['Words', 'Maths', 'Emotions', 'Attention'],
            values: [78, 64, 40, 85],
          ),
          const SizedBox(height: AppConstants.lg),
        ],
      ),
    );
  }
}
