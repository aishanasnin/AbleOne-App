import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/shared/widgets/section_title.dart';
import 'package:ableone_app/shared/widgets/primary_button.dart';
import 'package:ableone_app/features/profile/domain/entities/user_profile_entity.dart';
import 'package:ableone_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:ableone_app/features/profile/presentation/widgets/preference_card.dart';
import 'package:ableone_app/features/profile/presentation/widgets/level_selector.dart';
import 'package:ableone_app/core/services/firebase_service.dart';

/// Selection wizard page configuring learning levels and content delivery format preferences.
class LearningPreferencePage extends ConsumerStatefulWidget {
  /// Custom support needs forwarded from the accessibility setup questionnaire.
  final List<String> supportNeeds;

  /// Creates a [LearningPreferencePage] instance.
  const LearningPreferencePage({super.key, required this.supportNeeds});

  @override
  ConsumerState<LearningPreferencePage> createState() => _LearningPreferencePageState();
}

class _LearningPreferencePageState extends ConsumerState<LearningPreferencePage> {
  String _selectedPreference = 'Simple explanations';
  String _selectedLevel = 'Beginner';
  bool _needsCounselor = false;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _preferences = const [
    {
      'label': 'Simple explanations',
      'icon': Icons.cleaning_services_rounded,
    },
    {
      'label': 'Detailed explanations',
      'icon': Icons.analytics_outlined,
    },
    {
      'label': 'Visual examples',
      'icon': Icons.image_search_rounded,
    },
    {
      'label': 'Audio explanation',
      'icon': Icons.volume_up_rounded,
    },
    {
      'label': 'Step-by-step guidance',
      'icon': Icons.format_list_numbered_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Load pre-existing choices if they already exist in the notifier
    final profileState = ref.read(userProfileNotifierProvider);
    profileState.whenData((profile) {
      if (profile != null) {
        setState(() {
          _selectedPreference = profile.learningPreference;
          _selectedLevel = profile.learningLevel;
          _needsCounselor = profile.needsCounselor;
        });
      }
    });
  }

  Future<void> _saveProfile() async {
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user == null) return;

    setState(() {
      _isSaving = true;
    });

    final updatedProfile = UserProfileEntity(
      id: user.uid,
      name: user.displayName ?? 'AbleOne Student',
      role: 'Student',
      supportNeeds: widget.supportNeeds,
      learningLevel: _selectedLevel,
      learningPreference: _selectedPreference,
      preferredLanguage: 'English',
      needsCounselor: _needsCounselor,
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(userProfileNotifierProvider.notifier).updateProfile(updatedProfile);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Accessibility Profile Saved Successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        // Pop twice to return to the Profile page
        context.pop();
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Settings'),
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
                          title: 'Choose Explanation Preference',
                          semanticsLabel: 'Explanation Style preference group',
                        ),
                        const SizedBox(height: AppConstants.sm),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _preferences.length,
                          itemBuilder: (context, index) {
                            final item = _preferences[index];
                            final label = item['label'] as String;
                            final isSelected = _selectedPreference == label;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppConstants.md),
                              child: PreferenceCard(
                                label: label,
                                icon: item['icon'] as IconData,
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() {
                                    _selectedPreference = label;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppConstants.lg),

                        const SectionTitle(
                          title: 'Choose Learning Level',
                          semanticsLabel: 'Cognitive learning level group',
                        ),
                        const SizedBox(height: AppConstants.sm),
                        LevelSelector(
                          selectedLevel: _selectedLevel,
                          onLevelChanged: (val) {
                            setState(() {
                              _selectedLevel = val;
                            });
                          },
                        ),
                        const SizedBox(height: AppConstants.lg),

                        // Option checklist
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          elevation: 0,
                          child: SwitchListTile(
                            title: const Text(
                              'Request Active Counselor Reviews',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text('Allow assigned counselors to track and inspect your learning activities.'),
                            value: _needsCounselor,
                            onChanged: (val) {
                              setState(() {
                                _needsCounselor = val;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Save actions panel
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
                          text: 'Complete & Save Settings',
                          isLoading: _isSaving,
                          onPressed: _isSaving ? null : _saveProfile,
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
