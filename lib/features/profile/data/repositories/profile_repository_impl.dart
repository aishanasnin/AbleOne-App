import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:ableone_app/features/profile/domain/entities/user_profile_entity.dart';
import 'package:ableone_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:ableone_app/features/profile/data/models/user_profile_model.dart';
import 'package:ableone_app/core/services/firebase_service.dart';

/// Implementation of [ProfileRepository] using Hive local storage.
class ProfileRepositoryImpl implements ProfileRepository {
  final String _boxName = 'user_profile';

  /// Creates a [ProfileRepositoryImpl] instance.
  ProfileRepositoryImpl();

  Future<Box<dynamic>> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box(_boxName);
    }
    return await Hive.openBox(_boxName);
  }

  @override
  Future<UserProfileEntity?> getUserProfile(String uid) async {
    try {
      final box = await _openBox();
      final data = box.get(uid);
      if (data != null) {
        return UserProfileModel.fromMap(Map<String, dynamic>.from(data as Map));
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load user profile: ${e.toString()}');
    }
  }

  @override
  Future<void> saveUserProfile(UserProfileEntity profile) async {
    try {
      final box = await _openBox();
      final model = UserProfileModel.fromEntity(profile);
      await box.put(profile.id, model.toMap());
    } catch (e) {
      throw Exception('Failed to save user profile: ${e.toString()}');
    }
  }
}

// Riverpod Providers

/// Provider exposing the [ProfileRepository] instance.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl();
});

/// StateNotifier that manages loading and updating the active user personalization profile.
class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfileEntity?>> {
  final ProfileRepository _repository;
  final Ref _ref;

  /// Creates a [UserProfileNotifier] instance.
  UserProfileNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  /// Loads the personalization profile for the currently authenticated user.
  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    final user = _ref.read(firebaseAuthProvider).currentUser;
    if (user == null) {
      state = const AsyncValue.data(null);
      return;
    }

    try {
      final profile = await _repository.getUserProfile(user.uid);
      if (profile != null) {
        state = AsyncValue.data(profile);
      } else {
        // Fallback or default profile if none exists
        final defaultProfile = UserProfileEntity(
          id: user.uid,
          name: user.displayName ?? 'AbleOne Student',
          role: 'Student',
          supportNeeds: const [],
          learningLevel: 'Beginner',
          learningPreference: 'Simple explanations',
          preferredLanguage: 'English',
          needsCounselor: false,
          createdAt: DateTime.now(),
        );
        state = AsyncValue.data(defaultProfile);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Updates and saves the personalization profile settings.
  Future<void> updateProfile(UserProfileEntity profile) async {
    state = const AsyncValue.loading();
    try {
      await _repository.saveUserProfile(profile);
      state = AsyncValue.data(profile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// Provider managing active user profile states.
final userProfileNotifierProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfileEntity?>>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return UserProfileNotifier(repo, ref);
});
