import 'package:flutter/material.dart';
import 'package:ableone_app/features/admin/domain/entities/course_management_entity.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/shared/widgets/premium_widgets.dart';

class AdminCourseDetailPage extends StatelessWidget {
  final CourseManagementEntity course;

  const AdminCourseDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.lg),
        children: [
          // Header Summary Card
          ProfileHeader(
            name: course.title,
            description: 'Course ID: ${course.courseId} • ${course.category}',
            streakDays: 0,
          ),
          const SizedBox(height: AppConstants.lg),

          // Statistics Overview
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Enrolled',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${course.enrolledUsers}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.md),
              Expanded(
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Difficulty Level',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course.difficulty,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.lg),

          // Completion Rate Card
          Card(
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
                    value: course.completionRate / 100.0,
                    size: 54,
                    strokeWidth: 4,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppConstants.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overall Completion Rate',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Percentage of active students who completed all diagnostic models.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.lg),

          // Course Outline / Config
          Text(
            'Course Outline & Status',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppConstants.sm),
          _buildOutlineItem('Module 1: Introduction Diagnostics', '3 Lessons • Active'),
          const Divider(),
          _buildOutlineItem('Module 2: Fundamental Focus Exercises', '4 Lessons • Active'),
          const Divider(),
          _buildOutlineItem('Module 3: Advanced Verbal Scaffolds', '2 Lessons • Draft'),
        ],
      ),
    );
  }

  Widget _buildOutlineItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
        ],
      ),
    );
  }
}
