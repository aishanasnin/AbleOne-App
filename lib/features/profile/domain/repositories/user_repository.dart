import 'package:ableone_app/features/profile/domain/entities/user_entity.dart';

/// Repository interface defining core data operations for user profiles.
abstract class UserRepository {
  /// Fetches the profile of the user identified by [uid].
  Future<UserEntity?> getUser(String uid);

  /// Creates a new profile record for the specified [user].
  Future<void> createUser(UserEntity user);

  /// Updates an existing profile record with fields from [user].
  Future<void> updateUser(UserEntity user);

  /// Deletes the profile record of the user identified by [uid].
  Future<void> deleteUser(String uid);
}
