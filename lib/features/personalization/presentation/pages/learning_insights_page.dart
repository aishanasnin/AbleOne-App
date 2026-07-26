import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/core/services/firebase_service.dart';
import 'package:ableone_app/features/personalization/data/repositories/personalization_repository_impl.dart';
import 'package:ableone_app/features/personalization/presentation/widgets/recommendation_widget.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/shared/widgets/section_title.dart';

class LearningInsightsPage extends ConsumerWidget {
  const LearningInsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(firebaseAuthProvider).currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view learning insights.')),
      );
    }

    final profileAsync = ref.watch(learningProfileProvider(currentUser.uid));
    final recsAsync = ref.watch(aiRecommendationsProvider(currentUser.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Insights'),
      ),
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Strengths Section
                  const SectionTitle(title: 'Cognitive Strengths'),
                  const SizedBox(height: AppConstants.xs),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: profile.strengths.map((str) {
                      return Chip(
                        label: Text(str, style: const TextStyle(fontSize: 12)),
                        avatar: const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.secondary),
                        backgroundColor: AppColors.secondary.withValues(alpha: 0.05),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppConstants.lg),

                  // Weaknesses Section
                  const SectionTitle(title: 'Focus Improvement Areas'),
                  const SizedBox(height: AppConstants.xs),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: profile.weaknesses.map((weak) {
                      return Chip(
                        label: Text(weak, style: const TextStyle(fontSize: 12)),
                        avatar: const Icon(Icons.warning_rounded, size: 14, color: AppColors.error),
                        backgroundColor: AppColors.error.withValues(alpha: 0.05),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppConstants.lg),

                  // General Settings Info Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Learning Style', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(profile.learningStyle, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Preferred Difficulty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(profile.preferredDifficulty, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.xl),

                  // Recommendations Section
                  const SectionTitle(title: 'AI Recommendations'),
                  const SizedBox(height: AppConstants.sm),
                  recsAsync.when(
                    data: (recs) {
                      if (recs.isEmpty) {
                        return const Center(child: Text('No recommendations available yet.'));
                      }
                      return Column(
                        children: recs.map((rec) => RecommendationWidget(recommendation: rec)).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Error loading recommendations: $err')),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error loading insights: $err')),
        ),
      ),
    );
  }
}
