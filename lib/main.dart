import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ableone_app/app.dart';
import 'package:ableone_app/core/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive storage
  await Hive.initFlutter();
  
  // Initialize Firebase Service
  final firebaseService = FirebaseService();
  await firebaseService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        firebaseServiceProvider.overrideWithValue(firebaseService),
      ],
      child: const AbleOneApp(),
    ),
  );
}
