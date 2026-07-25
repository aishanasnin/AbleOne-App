import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA-placeholder-web-api-key',
    appId: '1:1234567890:web:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'ableone-app-placeholder',
    authDomain: 'ableone-app-placeholder.firebaseapp.com',
    storageBucket: 'ableone-app-placeholder.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA-placeholder-android-api-key',
    appId: '1:1234567890:android:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'ableone-app-placeholder',
    storageBucket: 'ableone-app-placeholder.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA-placeholder-ios-api-key',
    appId: '1:1234567890:ios:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'ableone-app-placeholder',
    storageBucket: 'ableone-app-placeholder.appspot.com',
    iosBundleId: 'com.example.ableoneApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA-placeholder-macos-api-key',
    appId: '1:1234567890:ios:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'ableone-app-placeholder',
    storageBucket: 'ableone-app-placeholder.appspot.com',
    iosBundleId: 'com.example.ableoneApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA-placeholder-windows-api-key',
    appId: '1:1234567890:windows:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'ableone-app-placeholder',
    storageBucket: 'ableone-app-placeholder.appspot.com',
  );
}
