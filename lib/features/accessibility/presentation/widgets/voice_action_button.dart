import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/features/accessibility/data/repositories/accessibility_repository_impl.dart';

/// narration button that simulates reading screen components aloud based on speed preferences.
class VoiceActionButton extends ConsumerWidget {
  /// The literal text content to narrate.
  final String textToSpeak;

  /// Accessibility reader tag.
  final String semanticLabel;

  /// Creates a [VoiceActionButton] instance.
  const VoiceActionButton({
    super.key,
    required this.textToSpeak,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(accessibilitySettingsProvider);

    // Narrator remains hidden if voice features are not enabled
    if (!settings.voiceEnabled) {
      return const SizedBox.shrink();
    }

    Color buttonColor = AppColors.primary;
    if (settings.highContrastMode) {
      buttonColor = Colors.black;
    }

    return Semantics(
      label: semanticLabel,
      button: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: FloatingActionButton.small(
          heroTag: null,
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '[Voice Narration: Speed ${settings.readingSpeed}x] "$textToSpeak"',
                ),
                duration: const Duration(seconds: 4),
              ),
            );
          },
          child: const Icon(Icons.volume_up_rounded, size: 20),
        ),
      ),
    );
  }
}
