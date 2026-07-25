import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/router/route_names.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/shared/widgets/loading_widget.dart';
import 'package:ableone_app/shared/widgets/empty_state.dart';
import 'package:ableone_app/shared/widgets/section_title.dart';
import 'package:ableone_app/shared/widgets/primary_button.dart';
import 'package:ableone_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:ableone_app/core/services/firebase_service.dart';

/// Screen listing a student's active personalization preferences, support needs, and learning options.
class ProfilePage extends ConsumerWidget {
  /// Creates a [ProfilePage] instance.
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(userProfileNotifierProvider);
    final user = ref.watch(firebaseAuthProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Accessibility Profile'),
      ),
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) {
            if (profile == null) {
              return const EmptyState(
                title: 'No Profile Found',
                message: 'No personalization profile exists for this account.',
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.lg),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User information card
                      Card(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                          side: const BorderSide(color: AppColors.border, width: 1),
                        ),
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.md),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  (user?.displayName ?? 'S')[0].toUpperCase(),
                                  style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: AppConstants.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile.name,
                                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      user?.email ?? 'student@ableone.org',
                                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        profile.role.toUpperCase(),
                                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.lg),

                      // Support Needs list
                      const SectionTitle(title: 'Active Support Preferences'),
                      const SizedBox(height: AppConstants.sm),
                      if (profile.supportNeeds.isEmpty)
                        const Text('No custom support constraints selected.')
                      else
                        Wrap(
                          spacing: AppConstants.sm,
                          runSpacing: AppConstants.xs,
                          children: profile.supportNeeds.map((need) {
                            return Chip(
                              label: Text(need),
                              avatar: Icon(_getSupportIcon(need), size: 16),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: AppConstants.lg),

                      // Learning Level
                      const SectionTitle(title: 'Learning Level'),
                      const SizedBox(height: AppConstants.sm),
                      _buildInfoTile(Icons.bar_chart_rounded, profile.learningLevel, 'Explanations detail standard', theme),
                      const SizedBox(height: AppConstants.lg),

                      // Learning Preference
                      const SectionTitle(title: 'Learning Preference Style'),
                      const SizedBox(height: AppConstants.sm),
                      _buildInfoTile(Icons.star_outline_rounded, profile.learningPreference, 'Preferred explanation presentation', theme),
                      const SizedBox(height: AppConstants.lg),

                      // Accessibility properties
                      const SectionTitle(title: 'Accessibility Configurations'),
                      const SizedBox(height: AppConstants.sm),
                      _buildInfoTile(Icons.language_rounded, 'Interface language: ${profile.preferredLanguage}', 'Preferred language selection', theme),
                      _buildInfoTile(
                        profile.needsCounselor ? Icons.check_circle_outline_rounded : Icons.radio_button_unchecked_rounded,
                        profile.needsCounselor ? 'Active counselor reviews enabled' : 'Counselor reviews disabled',
                        'Counselor review tracking preference',
                        theme,
                      ),
                      const SizedBox(height: AppConstants.xl),

                      PrimaryButton(
                        text: 'Update Personalization Profile',
                        onPressed: () {
                          context.push(RouteNames.accessibilitySetupPath, extra: profile.supportNeeds);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const LoadingWidget(message: 'Loading personalization metrics...'),
          error: (e, _) => EmptyState(
            title: 'Load Failed',
            message: e.toString().replaceAll('Exception: ', ''),
            actionText: 'Retry',
            onActionPressed: () => ref.read(userProfileNotifierProvider.notifier).loadProfile(),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String semanticDesc, ThemeData theme) {
    return Semantics(
      label: '$semanticDesc: $title',
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          side: const BorderSide(color: AppColors.border),
        ),
        elevation: 0,
        margin: const EdgeInsets.only(bottom: AppConstants.sm),
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ),
    );
  }

  IconData _getSupportIcon(String need) {
    switch (need.toLowerCase()) {
      case 'visual support':
        return Icons.visibility_rounded;
      case 'hearing support':
        return Icons.hearing_rounded;
      case 'speech support':
        return Icons.record_voice_over_rounded;
      case 'physical support':
        return Icons.accessible_rounded;
      case 'learning support':
        return Icons.menu_book_rounded;
      case 'autism / neurodivergent support':
        return Icons.psychology_rounded;
      case 'multiple support needs':
        return Icons.dynamic_feed_rounded;
      default:
        return Icons.accessibility_new_rounded;
    }
  }
}
