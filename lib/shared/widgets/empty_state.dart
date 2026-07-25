import 'package:flutter/material.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/shared/widgets/primary_button.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final String? semanticsLabel;

  const EmptyState({
    super.key,
    this.title = 'No Data Available',
    this.message = 'There is nothing to display here right now.',
    this.icon = Icons.inbox_rounded,
    this.actionText,
    this.onActionPressed,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label: semanticsLabel ?? '$title. $message',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.textMuted,
                  size: 64,
                ),
              ),
              const SizedBox(height: AppConstants.lg),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.sm),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              if (actionText != null && onActionPressed != null) ...[
                const SizedBox(height: AppConstants.lg),
                PrimaryButton(
                  text: actionText!,
                  onPressed: onActionPressed,
                  width: 200,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
