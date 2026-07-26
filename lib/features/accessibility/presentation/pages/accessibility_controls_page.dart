import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/features/accessibility/data/repositories/accessibility_repository_impl.dart';

/// Settings screen for configuring text scale size, contrast themes, narration support, and speech pace.
class AccessibilityControlsPage extends ConsumerWidget {
  /// Creates an [AccessibilityControlsPage] instance.
  const AccessibilityControlsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(accessibilitySettingsProvider);
    final notifier = ref.read(accessibilitySettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility Settings'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.lg),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Accessibility Controls',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.xs),
                  const Text(
                    'Customize display, voice description narration, and layout details to make learning inclusive.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppConstants.lg),

                  // High Contrast Mode Toggle
                  SwitchListTile(
                    title: const Text('High Contrast Mode'),
                    subtitle: const Text('Enhance color readability for text and icons.'),
                    value: settings.highContrastMode,
                    onChanged: (value) => notifier.toggleHighContrast(),
                  ),
                  const Divider(),

                  // Simplified Interface Mode
                  SwitchListTile(
                    title: const Text('Simplified Mode'),
                    subtitle: const Text('Display basic spacing options with fewer complex widgets.'),
                    value: settings.simplifiedMode,
                    onChanged: (value) => notifier.toggleSimplified(),
                  ),
                  const Divider(),

                  // Voice Narration Toggle
                  SwitchListTile(
                    title: const Text('Voice Narration Support'),
                    subtitle: const Text('Show narration narrator voice actions on text elements.'),
                    value: settings.voiceEnabled,
                    onChanged: (value) => notifier.toggleVoice(),
                  ),
                  const Divider(),

                  // Text Scaling Slider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Text Scale Sizing', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('${(settings.textScale * 100).toInt()}%'),
                          ],
                        ),
                        Slider(
                          min: 0.8,
                          max: 1.8,
                          divisions: 5,
                          value: settings.textScale,
                          onChanged: (val) => notifier.setTextScale(val),
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // Speech Narration Speed Slider
                  if (settings.voiceEnabled)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Narration Speech Pace', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('${settings.readingSpeed}x'),
                            ],
                          ),
                          Slider(
                            min: 0.8,
                            max: 2.0,
                            divisions: 6,
                            value: settings.readingSpeed,
                            onChanged: (val) => notifier.setReadingSpeed(val),
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
