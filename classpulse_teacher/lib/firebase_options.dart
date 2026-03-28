// Firebase configuration for ClassPulse
// Generated from Firebase console: classpulse-46640
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDr9vFgJZ2Wik5mN2JMdvyJUEwGiwpxBJI',
    authDomain: 'classpulse-46640.firebaseapp.com',
    projectId: 'classpulse-46640',
    storageBucket: 'classpulse-46640.firebasestorage.app',
    messagingSenderId: '1084413847480',
    appId: '1:1084413847480:web:f2fb8502c0a7038e6e914d',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDr9vFgJZ2Wik5mN2JMdvyJUEwGiwpxBJI',
    authDomain: 'classpulse-46640.firebaseapp.com',
    projectId: 'classpulse-46640',
    storageBucket: 'classpulse-46640.firebasestorage.app',
    messagingSenderId: '1084413847480',
    appId: '1:1084413847480:web:f2fb8502c0a7038e6e914d',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDr9vFgJZ2Wik5mN2JMdvyJUEwGiwpxBJI',
    authDomain: 'classpulse-46640.firebaseapp.com',
    projectId: 'classpulse-46640',
    storageBucket: 'classpulse-46640.firebasestorage.app',
    messagingSenderId: '1084413847480',
    appId: '1:1084413847480:web:f2fb8502c0a7038e6e914d',
    iosClientId: '',
    iosBundleId: 'com.classpulse.teacher',
  );
}
