import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ableone_app/features/profile/data/models/user_model.dart';

/// Datasource handling low-level Cloud Firestore read and write queries for user profiles.
class FirestoreDatasource {
  final FirebaseFirestore _firestore;

  /// Creates a [FirestoreDatasource] instance.
  FirestoreDatasource(this._firestore);

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Creates a new user profile document in the Firestore collection.
  Future<void> createUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(user.toMap());
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred while writing profile to database.');
    }
  }

  /// Fetches a user profile document from the Firestore collection.
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred while retrieving profile from database.');
    }
  }

  /// Updates an existing user profile document in the Firestore collection.
  Future<void> updateUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).update(user.toMap());
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred while updating profile in database.');
    }
  }

  /// Deletes a user profile document from the Firestore collection.
  Future<void> deleteUser(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred while deleting profile from database.');
    }
  }

  Exception _handleFirebaseException(FirebaseException e) {
    if (e.code == 'permission-denied') {
      return Exception('Access Denied: You do not have permission to access this resource.');
    } else if (e.code == 'unavailable') {
      return Exception('Network Unavailable: Please check your internet connection and try again.');
    } else if (e.code == 'not-found') {
      return Exception('Resource Missing: The requested document could not be located.');
    }
    return Exception(e.message ?? 'A database error occurred.');
  }
}
