import 'package:flutter/material.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';

/// Card showing counselor-student consultation details and session control options.
class SessionCard extends StatelessWidget {
  /// Session time range.
  final String time;

  /// Student full name.
  final String student;

  /// Focus of diagnostic consultation.
  final String type;

  /// Room designation details.
  final String room;

  /// Creates a [SessionCard] instance.
  const SessionCard({
    super.key,
    required this.time,
    required this.student,
    required this.type,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Session with $student. Time: $time. Type: $type. Location: $room.',
      container: true,
      child: Card(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: const EdgeInsets.only(bottom: AppConstants.md),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      student,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    child: Text(
                      time,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.sm),
              Text(
                'Session Type: $type',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: AppConstants.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.video_camera_back_rounded, color: AppColors.accent, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        room,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Launching consult room: $room')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(100, 40), // Touch targets >= 48px is best, let's keep it large
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      ),
                    ),
                    child: const Text('Join Room'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
