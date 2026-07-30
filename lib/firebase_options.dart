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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCvWd6N_mijyRrZ4e_jxew9eMP9cRZ5kEo',
    appId: '1:818547129677:web:f330e876a0944ee93e4b04',
    messagingSenderId: '818547129677',
    projectId: 'zana-app-88c38',
    authDomain: 'zana-app-88c38.firebaseapp.com',
    storageBucket: 'zana-app-88c38.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCvWd6N_mijyRrZ4e_jxew9eMP9cRZ5kEo',
    appId: '1:818547129677:android:f330e876a0944ee93e4b04',
    messagingSenderId: '818547129677',
    projectId: 'zana-app-88c38',
    storageBucket: 'zana-app-88c38.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCvWd6N_mijyRrZ4e_jxew9eMP9cRZ5kEo',
    appId: '1:818547129677:ios:f330e876a0944ee93e4b04',
    messagingSenderId: '818547129677',
    projectId: 'zana-app-88c38',
    storageBucket: 'zana-app-88c38.firebasestorage.app',
    iosBundleId: 'com.zana.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCvWd6N_mijyRrZ4e_jxew9eMP9cRZ5kEo',
    appId: '1:818547129677:ios:f330e876a0944ee93e4b04',
    messagingSenderId: '818547129677',
    projectId: 'zana-app-88c38',
    storageBucket: 'zana-app-88c38.firebasestorage.app',
    iosBundleId: 'com.zana.app',
  );
}