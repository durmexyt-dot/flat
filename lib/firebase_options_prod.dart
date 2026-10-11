// Firebase configuration of the PROD project (real users).
//
// Fill in the web config from the Firebase console of the prod project:
// Project settings → Your apps → Web app → SDK setup and configuration.
// Until then, prod builds refuse to start (tool/build_web.sh checks it).
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

abstract final class ProdFirebaseOptions {
  static const FirebaseOptions? web = null;
}
