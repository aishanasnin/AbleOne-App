import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ableone_app/app.dart';
import 'package:ableone_app/core/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Global Synchronous/UI Error Handler
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // In production, log to analytics/crashlytics here
    debugPrint('Uncaught Flutter Error: ${details.exceptionAsString()}');
  };

  // 2. Global Asynchronous/Platform Error Handler
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Uncaught Asynchronous Error: $error');
    debugPrintStack(stackTrace: stack);
    // In production, return true to prevent platform crashes
    return true;
  };

  try {
    // Load environment configurations
    await dotenv.load(fileName: '.env');
    
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
  } catch (e, stack) {
    debugPrint('Critical Initialization Error: $e');
    debugPrintStack(stackTrace: stack);
    // Fallback UI or recovery state can be initialized here
  }
}
