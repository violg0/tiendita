import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Pega aqui las credenciales de tu proyecto de Firebase
/// (Consola de Firebase > Configuracion del proyecto > Tus apps).
/// Si ejecutas `flutterfire configure`, este archivo se reemplaza solo.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'Firebase no esta configurado para $defaultTargetPlatform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'TU_API_KEY',
    appId: 'TU_APP_ID_WEB',
    messagingSenderId: 'TU_MESSAGING_SENDER_ID',
    projectId: 'TU_PROJECT_ID',
    authDomain: 'TU_PROJECT_ID.firebaseapp.com',
    storageBucket: 'TU_PROJECT_ID.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'TU_API_KEY',
    appId: 'TU_APP_ID_ANDROID',
    messagingSenderId: 'TU_MESSAGING_SENDER_ID',
    projectId: 'TU_PROJECT_ID',
    storageBucket: 'TU_PROJECT_ID.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'TU_API_KEY',
    appId: 'TU_APP_ID_WEB',
    messagingSenderId: 'TU_MESSAGING_SENDER_ID',
    projectId: 'TU_PROJECT_ID',
    authDomain: 'TU_PROJECT_ID.firebaseapp.com',
    storageBucket: 'TU_PROJECT_ID.firebasestorage.app',
  );
}
