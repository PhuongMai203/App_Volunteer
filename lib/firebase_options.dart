// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAvc7EbK7uIDCfIyO0YCCzLFEbGsZgONmQ',
    appId: '1:328324807771:web:f39aa88f41f25fa9eb537e',
    messagingSenderId: '328324807771',
    projectId: 'help-connect-e9c17',
    authDomain: 'help-connect-e9c17.firebaseapp.com',
    storageBucket: 'help-connect-e9c17.firebasestorage.app',
    databaseURL: 'https://help-connect-e9c17.firebaseio.com', // Thêm
    measurementId: 'G-XXXXXXX', // Nếu dùng Analytics
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBf_WT9doz_lh75NoxQTP-6fRK0ESRyuLI',
    appId: '1:328324807771:android:b8104077581846a4eb537e',
    messagingSenderId: '328324807771',
    projectId: 'help-connect-e9c17',
    storageBucket: 'help-connect-e9c17.firebasestorage.app',
    authDomain: 'help-connect-e9c17.firebaseapp.com', // Thêm
    databaseURL: 'https://help-connect-e9c17.firebaseio.com', // Thêm
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCj9rMUeAE8XQc50LaLnBXRX656RdHlNpg',
    appId: '1:328324807771:ios:f2775b654fc48084eb537e',
    messagingSenderId: '328324807771',
    projectId: 'help-connect-e9c17',
    storageBucket: 'help-connect-e9c17.firebasestorage.app',
    iosBundleId: 'com.example.helpConnect',
    databaseURL: 'https://help-connect-e9c17.firebaseio.com', // Thêm
    androidClientId: '328324807771-xxxxxx.apps.googleusercontent.com', // Nếu dùng Google Sign-In
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCj9rMUeAE8XQc50LaLnBXRX656RdHlNpg',
    appId: '1:328324807771:ios:f2775b654fc48084eb537e',
    messagingSenderId: '328324807771',
    projectId: 'help-connect-e9c17',
    storageBucket: 'help-connect-e9c17.firebasestorage.app',
    iosBundleId: 'com.example.helpConnect',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAvc7EbK7uIDCfIyO0YCCzLFEbGsZgONmQ',
    appId: '1:328324807771:web:08934463c04412c2eb537e',
    messagingSenderId: '328324807771',
    projectId: 'help-connect-e9c17',
    authDomain: 'help-connect-e9c17.firebaseapp.com',
    storageBucket: 'help-connect-e9c17.firebasestorage.app',
  );
}
