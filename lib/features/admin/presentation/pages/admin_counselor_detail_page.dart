import 'package:flutter/material.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/shared/widgets/premium_widgets.dart';

class AdminCounselorDetailPage extends StatelessWidget {
  final Map<String, dynamic> counselor;

  const AdminCounselorDetailPage({super.key, required this.counselor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = counselor['name'] as String? ?? 'Counselor';
    final email = counselor['email'] as String? ?? '';
    final rating = counselor['rating'] as double? ?? 5.0;
    final assignedStudents = counselor['assignedStudents'] as int? ?? 0;
    final bio = counselor['bio'] as String? ?? '';
    final specialties = counselor['specialties'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            ProfileHeader(
              name: name,
              description: 'Counselor Profile • $email',
              streakDays: 0,
            ),
            const SizedBox(height: AppConstants.lg),

            // Bio description
            Text(
              'Professional Bio',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.xs),
            Text(
              bio,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: AppConstants.lg),

            // Clinic details
            Text(
              'Clinic Details',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.sm),
            ListTile(
              leading: const Icon(Icons.people_alt_outlined, color: AppColors.accent),
              title: const Text('Assigned Patient Count'),
              subtitle: Text('$assignedStudents Active Students'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.star_rounded, color: Colors.amber),
              title: const Text('Counselor Rating Score'),
              subtitle: Text('$rating out of 5.0 stars'),
            ),
            const SizedBox(height: AppConstants.lg),

            // Specialties
            Text(
              'Clinical Specialties',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.sm),
            Wrap(
              spacing: AppConstants.sm,
              runSpacing: AppConstants.sm,
              children: specialties.map((specialty) {
                return Chip(
                  label: Text(specialty as String),
                  backgroundColor: AppColors.accent.withValues(alpha: 0.05),
                  side: const BorderSide(color: AppColors.accent, width: 0.5),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
