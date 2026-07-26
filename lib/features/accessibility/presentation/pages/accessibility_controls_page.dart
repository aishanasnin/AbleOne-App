import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/features/accessibility/data/repositories/accessibility_repository_impl.dart';
import 'package:ableone_app/features/accessibility/presentation/widgets/accessibility_toggle.dart';
import 'package:ableone_app/features/accessibility/presentation/widgets/accessibility_slider.dart';
import 'package:ableone_app/features/accessibility/presentation/widgets/accessibility_option_card.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/shared/widgets/section_title.dart';

/// Accessibility Settings Dashboard screen featuring Visual Settings, Audio Settings, and Learning Support.
class AccessibilityControlsPage extends ConsumerWidget {
  /// Creates an [AccessibilityControlsPage] instance.
  const AccessibilityControlsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(accessibilitySettingsProvider);
    final notifier = ref.read(accessibilitySettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility Dashboard'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Visual Settings Section
              const SectionTitle(title: 'Visual Settings'),
              const SizedBox(height: AppConstants.sm),
              AccessibilitySlider(
                title: 'Text Scale Sizing',
                label: '${(settings.textScale * 100).toInt()}%',
                value: settings.textScale,
                min: 0.8,
                max: 1.8,
                divisions: 5,
                onChanged: (val) => notifier.setTextScale(val),
              ),
              const SizedBox(height: AppConstants.sm),
              const Text('Contrast Theme Select', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: AppConstants.xs),
              AccessibilityOptionCard(
                title: 'Standard Normal',
                description: 'Default app color styling matching regular layout colors.',
                icon: Icons.brightness_medium_rounded,
                isSelected: settings.contrastMode == 'Normal',
                onTap: () => notifier.setContrastMode('Normal'),
              ),
              const SizedBox(height: 8),
              AccessibilityOptionCard(
                title: 'High Contrast Mode',
                description: 'Enforces pure black-and-white borders and high contrast color keys.',
                icon: Icons.brightness_high_rounded,
                isSelected: settings.contrastMode == 'High Contrast',
                onTap: () => notifier.setContrastMode('High Contrast'),
              ),
              const SizedBox(height: AppConstants.lg),

              // Audio Settings Section
              const SectionTitle(title: 'Audio Settings'),
              const SizedBox(height: AppConstants.sm),
              AccessibilityToggle(
                title: 'Voice Narration Assist',
                description: 'Enables audio description narration guides on content widgets.',
                value: settings.voiceEnabled,
                onChanged: (_) => notifier.toggleVoice(),
              ),
              if (settings.voiceEnabled) ...[
                const SizedBox(height: AppConstants.sm),
                AccessibilitySlider(
                  title: 'Narration Speed Pace',
                  label: '${settings.readingSpeed}x',
                  value: settings.readingSpeed,
                  min: 0.8,
                  max: 2.0,
                  divisions: 6,
                  onChanged: (val) => notifier.setReadingSpeed(val),
                ),
              ],
              const SizedBox(height: AppConstants.lg),

              // Learning Support Section
              const SectionTitle(title: 'Learning Support'),
              const SizedBox(height: AppConstants.sm),
              AccessibilityToggle(
                title: 'Simple Explanation Mode',
                description: 'Simplifies complex definitions and paragraphs into direct visual terms.',
                value: settings.simplifiedMode,
                onChanged: (_) => notifier.toggleSimplified(),
              ),
              AccessibilityToggle(
                title: 'Step-by-Step Task Layout',
                description: 'Splits guides and lists into numbered step pages instead of large text areas.',
                value: settings.stepByStepMode,
                onChanged: (_) => notifier.toggleStepByStep(),
              ),
              AccessibilityToggle(
                title: 'Animation Transitions Enabled',
                description: 'Enables animations, page transitions, and progress animations.',
                value: settings.animationEnabled,
                onChanged: (_) => notifier.toggleAnimation(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
