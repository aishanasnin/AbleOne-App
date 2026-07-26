import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/features/accessibility/data/repositories/accessibility_repository_impl.dart';

/// Reusable icon button enforcing a minimum touch target size of 48x48 and dynamic high contrast overriding.
class AccessibleIconButton extends ConsumerWidget {
  /// Header icon design.
  final IconData icon;

  /// Semantic reader description label.
  final String semanticLabel;

  /// On tap callback.
  final VoidCallback onPressed;

  /// Custom icon color theme.
  final Color? color;

  /// Base icon size.
  final double size;

  /// Creates an [AccessibleIconButton] instance.
  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.color,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(accessibilitySettingsProvider);

    Color iconColor = color ?? AppColors.primary;
    if (settings.highContrastMode) {
      iconColor = Colors.black;
    }

    return Semantics(
      label: semanticLabel,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Container(
          width: 48.0, // Minimum target target constraints
          height: 48.0,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: iconColor,
            size: size * settings.textScale,
          ),
        ),
      ),
    );
  }
}
