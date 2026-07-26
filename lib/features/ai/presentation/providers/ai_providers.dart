import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/features/ai/domain/entities/ai_user_context.dart';
import 'package:ableone_app/features/profile/data/repositories/profile_repository_impl.dart';

/// Provider that constructs and exposes [AIUserContext] reactively
/// by watching the active user's personalization profile state.
final aiUserContextProvider = Provider<AIUserContext>((ref) {
  final profileAsync = ref.watch(userProfileNotifierProvider);

  return profileAsync.maybeWhen(
    data: (profile) {
      if (profile != null) {
        return AIUserContext(
          learningLevel: profile.learningLevel,
          supportNeeds: profile.supportNeeds,
          preferredLanguage: profile.preferredLanguage,
          learningPreference: profile.learningPreference,
        );
      }
      return const AIUserContext(
        learningLevel: 'Beginner',
        supportNeeds: [],
        preferredLanguage: 'English',
        learningPreference: 'Simple explanations',
      );
    },
    orElse: () => const AIUserContext(
      learningLevel: 'Beginner',
      supportNeeds: [],
      preferredLanguage: 'English',
      learningPreference: 'Simple explanations',
    ),
  );
});
