import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/features/profile/domain/entities/user_profile_entity.dart';
import 'package:ableone_app/features/profile/data/repositories/profile_repository_impl.dart';

/// Provider exposing the current [UserProfileEntity] directly.
final userProfileProvider = Provider<UserProfileEntity?>((ref) {
  return ref.watch(userProfileNotifierProvider).value;
});

/// Provider exposing the current list of support needs.
final supportNeedsProvider = Provider<List<String>>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile?.supportNeeds ?? const [];
});

/// Provider exposing the current learning level.
final learningLevelProvider = Provider<String>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile?.learningLevel ?? 'Beginner';
});

/// Provider exposing the current learning preference.
final learningPreferenceProvider = Provider<String>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile?.learningPreference ?? 'Simple explanations';
});
