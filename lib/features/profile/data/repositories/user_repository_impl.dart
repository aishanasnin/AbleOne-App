import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/core/services/firebase_service.dart';
import 'package:ableone_app/features/authentication/data/repositories/authentication_repository_impl.dart';
import 'package:ableone_app/features/profile/domain/entities/user_entity.dart';
import 'package:ableone_app/features/profile/domain/repositories/user_repository.dart';
import 'package:ableone_app/features/profile/data/datasources/firestore_datasource.dart';
import 'package:ableone_app/features/profile/data/models/user_model.dart';

/// Implementation of [UserRepository] executing data queries via [FirestoreDatasource].
class UserRepositoryImpl implements UserRepository {
  final FirestoreDatasource _datasource;

  /// Creates a [UserRepositoryImpl] instance.
  UserRepositoryImpl(this._datasource);

  @override
  Future<UserEntity?> getUser(String uid) async {
    try {
      return await _datasource.getUser(uid);
    } catch (e) {
      throw Exception('Failed to load user profile: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  @override
  Future<void> createUser(UserEntity user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await _datasource.createUser(userModel);
    } catch (e) {
      throw Exception('Failed to save user profile: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await _datasource.updateUser(userModel);
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  @override
  Future<void> deleteUser(String uid) async {
    try {
      await _datasource.deleteUser(uid);
    } catch (e) {
      throw Exception('Failed to delete user profile: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }
}

// Riverpod Providers

/// Provider exposing the [FirestoreDatasource] instance.
final firestoreDatasourceProvider = Provider<FirestoreDatasource>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return FirestoreDatasource(firestore);
});

/// Provider exposing the [UserRepository] instance.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final datasource = ref.watch(firestoreDatasourceProvider);
  return UserRepositoryImpl(datasource);
});

/// Provider exposing a reactive stream of the currently logged-in user profile,
/// automatically updating whenever the authentication state changes.
final currentUserProvider = StreamProvider<UserEntity?>((ref) async* {
  final authRepository = ref.watch(authenticationRepositoryProvider);

  await for (final firebaseUser in authRepository.authStateChanges) {
    if (firebaseUser == null) {
      yield null;
    } else {
      final userRepository = ref.watch(userRepositoryProvider);
      final profile = await userRepository.getUser(firebaseUser.uid);
      yield profile;
    }
  }
});
