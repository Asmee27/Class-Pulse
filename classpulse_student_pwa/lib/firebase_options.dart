// Firebase configuration for ClassPulse Student PWA
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Student PWA is always web
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDr9vFgJZ2Wik5mN2JMdvyJUEwGiwpxBJI',
    authDomain: 'classpulse-46640.firebaseapp.com',
    projectId: 'classpulse-46640',
    storageBucket: 'classpulse-46640.firebasestorage.app',
    messagingSenderId: '1084413847480',
    appId: '1:1084413847480:web:f2fb8502c0a7038e6e914d',
  );
}
