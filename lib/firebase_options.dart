// Firebase configuration of the STAGING project (stubswap-eda59): test
// accounts and test data. Prod is in firebase_options_prod.dart.
//
// Web is configured by hand from the Firebase console. For Android, iOS and
// macOS run `flutterfire configure` on a Mac; it regenerates this file with
// all platforms included.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'Firebase is not configured for $defaultTargetPlatform yet. '
      'Run `flutterfire configure` to add it (see README).',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA82cbUD2VX44KOdMO5RD_w2wkooTCC340',
    appId: '1:333980955906:web:f6100fb1a83c0ba7b97e1b',
    messagingSenderId: '333980955906',
    projectId: 'stubswap-eda59',
    authDomain: 'stubswap-eda59.firebaseapp.com',
    storageBucket: 'stubswap-eda59.appspot.com',
  );
}
