// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCceb6O9ObHROFB4nBeLHXkPH4TLmSvwdQ',
    appId: '1:819534973944:web:9f2855cc967e6ab3c7240d',
    messagingSenderId: '819534973944',
    projectId: 'direction-irrigation',
    authDomain: 'direction-irrigation.firebaseapp.com',
    storageBucket: 'direction-irrigation.appspot.com',
    measurementId: 'G-7GMEY3D9RX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCFbs4YdyHENoqNykBzTEiiXOh503i6X8A',
    appId: '1:819534973944:android:8133fb883e12030ec7240d',
    messagingSenderId: '819534973944',
    projectId: 'direction-irrigation',
    storageBucket: 'direction-irrigation.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCyBd5KE_6hnKNuPUMEGN92XSbrWN7j83E',
    appId: '1:819534973944:ios:b827cc808d42bdd9c7240d',
    messagingSenderId: '819534973944',
    projectId: 'direction-irrigation',
    storageBucket: 'direction-irrigation.appspot.com',
    iosClientId: '819534973944-a5pajpk17f6rktgdpbucbrkgtnmp8gec.apps.googleusercontent.com',
    iosBundleId: 'com.example.direction',
  );
}
