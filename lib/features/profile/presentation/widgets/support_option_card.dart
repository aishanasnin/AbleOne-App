import 'package:flutter/material.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';

/// Reusable selectable option card representing a custom support need (e.g. Visual Support).
class SupportOptionCard extends StatelessWidget {
  /// Name or title of the support need.
  final String label;

  /// Icon representing the support need.
  final IconData icon;

  /// Flag indicating if the option is currently selected.
  final bool isSelected;

  /// Callback action triggered upon tapping the card.
  final VoidCallback onTap;

  /// Creates a [SupportOptionCard] instance.
  const SupportOptionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label support choice. Tap to toggle preference selection.',
      child: InkWell(
        onTap: onTap,
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
            // Large touch target padding
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isSelected ? AppColors.primary : AppColors.border.withValues(alpha: 0.5),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppConstants.md),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                    ),
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
    );
  }
}
