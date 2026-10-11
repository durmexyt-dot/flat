// Firebase configuration of the PROD project (stubswap-prod): real users.
// From the Firebase console: Project settings → Your apps → Web app.
// Staging (test data) is in firebase_options.dart.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

abstract final class ProdFirebaseOptions {
  // No measurementId: Analytics would need a consent banner first.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA_at4eS7IW2OZ4izDOBm7HD6O4J8k2Bjc',
    appId: '1:233354668314:web:17b4e4845b0db50ce424a3',
    messagingSenderId: '233354668314',
    projectId: 'stubswap-prod',
    authDomain: 'stubswap-prod.firebaseapp.com',
    storageBucket: 'stubswap-prod.firebasestorage.app',
  );
}
