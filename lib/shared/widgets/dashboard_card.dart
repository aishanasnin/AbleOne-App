import 'package:flutter/material.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? content;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;
  final String? semanticsLabel;
  final String? semanticsHint;

  const DashboardCard({
    super.key,
    required this.title,
    this.subtitle,
    this.content,
    this.icon,
    this.color,
    this.onTap,
    this.semanticsLabel,
    this.semanticsHint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? AppColors.primary;

    Widget cardBody = Padding(
      padding: const EdgeInsets.all(AppConstants.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(AppConstants.sm),
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: Icon(
                    icon,
                    color: cardColor,
                    size: 26,
                  ),
                ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.textMuted,
                  size: 18,
                ),
            ],
          ),
          const SizedBox(height: AppConstants.md),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppConstants.xs),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
          if (content != null) ...[
            const SizedBox(height: AppConstants.md),
            content!,
          ],
        ],
      ),
    );

    return Semantics(
      container: true,
      label: semanticsLabel ?? '$title. ${subtitle ?? ""}',
      hint: semanticsHint ?? (onTap != null ? 'Double tap to open' : null),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                splashColor: cardColor.withValues(alpha: 0.08),
                highlightColor: cardColor.withValues(alpha: 0.04),
                child: cardBody,
              )
            : cardBody,
      ),
    );
  }
}
