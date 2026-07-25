import 'package:flutter/material.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';

/// Reusable level selector component allowing users to specify a cognitive/learning level setting.
class LevelSelector extends StatelessWidget {
  /// The currently selected learning level (e.g. 'Beginner', 'Intermediate', 'Advanced').
  final String selectedLevel;

  /// Callback action triggered when a new level is selected.
  final ValueChanged<String> onLevelChanged;

  /// Creates a [LevelSelector] instance.
  const LevelSelector({
    super.key,
    required this.selectedLevel,
    required this.onLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final levels = [
      {
        'level': 'Beginner',
        'desc': 'Simple definitions, high-visual aids, and paced audio helpers.',
        'icon': Icons.child_care_rounded,
      },
      {
        'level': 'Intermediate',
        'desc': 'Standard vocabulary layouts, moderate quizzes, and focus guides.',
        'icon': Icons.school_rounded,
      },
      {
        'level': 'Advanced',
        'desc': 'Detailed text content, analytical quizzes, and multi-media modules.',
        'icon': Icons.auto_stories_rounded,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: levels.map((item) {
        final levelName = item['level'] as String;
        final isSelected = selectedLevel == levelName;

        return Semantics(
          button: true,
          selected: isSelected,
          label: '$levelName learning level. Description: ${item['desc']}',
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.md),
            child: InkWell(
              onTap: () => onLevelChanged(levelName),
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              child: Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2.0 : 1.0,
                  ),
                ),
                color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.md),
                  child: Row(
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        color: isSelected ? AppColors.primary : AppColors.textLight,
                        size: 28,
                      ),
                      const SizedBox(width: AppConstants.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              levelName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['desc'] as String,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                      else
                        const Icon(Icons.radio_button_unchecked_rounded, color: AppColors.textLight),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
