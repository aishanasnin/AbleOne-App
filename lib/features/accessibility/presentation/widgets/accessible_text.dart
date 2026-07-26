import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/features/accessibility/data/repositories/accessibility_repository_impl.dart';

/// Accessibility-aware Text widget dynamically adjusting sizing, styling, and contrast based on user settings.
class AccessibleText extends ConsumerWidget {
  /// Raw text content.
  final String text;

  /// Font styling template.
  final TextStyle? style;

  /// Optional accessibility reader description.
  final String? semanticLabel;

  /// Sizing alignment descriptor.
  final TextAlign? textAlign;

  /// Creates an [AccessibleText] instance.
  const AccessibleText({
    super.key,
    required this.text,
    this.style,
    this.semanticLabel,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(accessibilitySettingsProvider);

    final baseStyle = style ?? Theme.of(context).textTheme.bodyMedium;

    Color textColor = baseStyle?.color ?? AppColors.textPrimary;
    if (settings.highContrastMode) {
      // In high contrast mode, map light colors to absolute pitch black
      if (textColor == AppColors.textSecondary || textColor == Colors.grey) {
        textColor = Colors.black87;
      } else {
        textColor = Colors.black;
      }
    }

    final finalStyle = baseStyle?.copyWith(
      fontSize: (baseStyle.fontSize ?? 14.0) * settings.textScale,
      color: textColor,
      height: settings.largeTextMode ? 1.4 : baseStyle.height,
    );

    return Semantics(
      label: semanticLabel ?? text,
      child: Text(
        text,
        style: finalStyle,
        textAlign: textAlign,
      ),
    );
  }
}
