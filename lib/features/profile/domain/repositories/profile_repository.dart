import 'package:ableone_app/features/profile/domain/entities/user_profile_entity.dart';

/// Repository interface defining core data access operations for user accessibility personalization profiles.
abstract class ProfileRepository {
  /// Fetches the user accessibility profile for the given [uid] from local database storage.
  Future<UserProfileEntity?> getUserProfile(String uid);

  /// Saves or updates the user accessibility profile inside local database storage.
  Future<void> saveUserProfile(UserProfileEntity profile);
}
