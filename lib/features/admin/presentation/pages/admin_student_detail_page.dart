import 'package:flutter/material.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/shared/widgets/premium_widgets.dart';

class AdminStudentDetailPage extends StatelessWidget {
  final Map<String, dynamic> student;

  const AdminStudentDetailPage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = student['name'] as String? ?? 'Student';
    final email = student['email'] as String? ?? '';
    final progress = student['progress'] as double? ?? 0.0;
    final streak = student['streak'] as int? ?? 0;
    final level = student['learningLevel'] as String? ?? 'Beginner';
    final supportNeeds = student['supportNeeds'] as List<dynamic>? ?? [];

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
              description: 'Student Case • $email',
              streakDays: streak,
            ),
            const SizedBox(height: AppConstants.lg),

            // Performance Card
            Semantics(
              label: 'Student learning progress rate: ${progress.toInt()}%',
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.lg),
                  child: Row(
                    children: [
                      ProgressRing(
                        value: progress / 100.0,
                        size: 64,
                        strokeWidth: 5,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppConstants.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Overall Program Completion',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Currently enrolled in 4 foundational literacy courses.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.lg),

            // Profile info details
            Text(
              'Case Learning Preferences',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.sm),
            ListTile(
              leading: const Icon(Icons.psychology_outlined, color: AppColors.primary),
              title: const Text('Cognitive Learning Level'),
              subtitle: Text(level),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.schedule_rounded, color: AppColors.primary),
              title: const Text('Last Active Session'),
              subtitle: Text(student['lastSession'] as String? ?? 'N/A'),
            ),
            const SizedBox(height: AppConstants.lg),

            // Support Needs Chips
            Text(
              'Configured Accessibility Supports',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.sm),
            Wrap(
              spacing: AppConstants.sm,
              runSpacing: AppConstants.sm,
              children: supportNeeds.map((need) {
                return Chip(
                  label: Text(need as String),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                  side: const BorderSide(color: AppColors.primary, width: 0.5),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
