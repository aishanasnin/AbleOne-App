import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/router/route_names.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/shared/widgets/section_title.dart';
import 'package:ableone_app/shared/widgets/primary_button.dart';
import 'package:ableone_app/features/profile/presentation/widgets/support_option_card.dart';

/// Selection wizard page configuring custom accessibility support needs.
class AccessibilitySetupPage extends StatefulWidget {
  /// The initial support needs list, if editing.
  final List<String> initialNeeds;

  /// Creates an [AccessibilitySetupPage] instance.
  const AccessibilitySetupPage({super.key, this.initialNeeds = const []});

  @override
  State<AccessibilitySetupPage> createState() => _AccessibilitySetupPageState();
}

class _AccessibilitySetupPageState extends State<AccessibilitySetupPage> {
  final List<String> _selectedNeeds = [];

  final List<Map<String, dynamic>> _options = const [
    {
      'label': 'Visual Support',
      'icon': Icons.visibility_rounded,
    },
    {
      'label': 'Hearing Support',
      'icon': Icons.hearing_rounded,
    },
    {
      'label': 'Speech Support',
      'icon': Icons.record_voice_over_rounded,
    },
    {
      'label': 'Physical Support',
      'icon': Icons.accessible_rounded,
    },
    {
      'label': 'Learning Support',
      'icon': Icons.menu_book_rounded,
    },
    {
      'label': 'Autism / Neurodivergent Support',
      'icon': Icons.psychology_rounded,
    },
    {
      'label': 'Multiple Support Needs',
      'icon': Icons.dynamic_feed_rounded,
    },
    {
      'label': 'No specific support',
      'icon': Icons.block_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedNeeds.addAll(widget.initialNeeds);
  }

  void _toggleOption(String label) {
    setState(() {
      if (label == 'No specific support') {
        _selectedNeeds.clear();
        _selectedNeeds.add(label);
      } else {
        _selectedNeeds.remove('No specific support');
        if (_selectedNeeds.contains(label)) {
          _selectedNeeds.remove(label);
        } else {
          _selectedNeeds.add(label);
        }
      }
    });
  }

  void _proceed() {
    // If no option is selected, default to "No specific support"
    if (_selectedNeeds.isEmpty) {
      _selectedNeeds.add('No specific support');
    }
    context.push(RouteNames.learningPreferencePath, extra: _selectedNeeds);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalization'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.lg),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(
                          title: 'How can AbleOne support you better?',
                          semanticsLabel: 'Accessibility Support Needs Questionnaire',
                        ),
                        const SizedBox(height: AppConstants.xs),
                        Text(
                          'Select all options that apply to customize your learning profile preferences:',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppConstants.lg),

                        // Render options list
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _options.length,
                          itemBuilder: (context, index) {
                            final opt = _options[index];
                            final label = opt['label'] as String;
                            final isSelected = _selectedNeeds.contains(label);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppConstants.md),
                              child: SupportOptionCard(
                                label: label,
                                icon: opt['icon'] as IconData,
                                isSelected: isSelected,
                                onTap: () => _toggleOption(label),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Continue control panel
            Container(
              padding: const EdgeInsets.all(AppConstants.md),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          text: 'Continue',
                          onPressed: _proceed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
