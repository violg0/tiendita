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
    apiKey: 'AIzaSyABKthzrWFcXVfSddIIAh_Un03XpDs6e_M',
    appId: '1:59051603205:web:0268072729a7743004736c',
    messagingSenderId: '59051603205',
    projectId: 'tienda-de-hobbies',
    authDomain: 'tienda-de-hobbies.firebaseapp.com',
    storageBucket: 'tienda-de-hobbies.firebasestorage.app',
    measurementId: 'G-868W7CLBE8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCf0Ddc8Qf_hqtCpUQiuAggz_gCNPO_kUM',
    appId: '1:59051603205:android:d653da4d359dcc7d04736c',
    messagingSenderId: '59051603205',
    projectId: 'tienda-de-hobbies',
    storageBucket: 'tienda-de-hobbies.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyABKthzrWFcXVfSddIIAh_Un03XpDs6e_M',
    appId: '1:59051603205:web:4416480bd954234504736c',
    messagingSenderId: '59051603205',
    projectId: 'tienda-de-hobbies',
    authDomain: 'tienda-de-hobbies.firebaseapp.com',
    storageBucket: 'tienda-de-hobbies.firebasestorage.app',
    measurementId: 'G-7SY8SFQ3JQ',
  );
}
