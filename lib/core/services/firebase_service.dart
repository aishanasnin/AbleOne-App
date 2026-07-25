import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/firebase_options.dart';

class FirebaseService {
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseStorage get storage => FirebaseStorage.instance;
  FirebaseMessaging get messaging => FirebaseMessaging.instance;
}

// Riverpod Providers
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  throw UnimplementedError('Initialize and override firebaseServiceProvider in main.dart');
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return ref.watch(firebaseServiceProvider).auth;
});

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return ref.watch(firebaseServiceProvider).firestore;
});

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return ref.watch(firebaseServiceProvider).storage;
});

final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  return ref.watch(firebaseServiceProvider).messaging;
});
