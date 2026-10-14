import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'firebase_options_prod.dart';
import 'src/config/app_check.dart';
import 'src/config/app_info.dart';
import 'src/app.dart';
import 'src/auth/auth_repository.dart';
import 'src/data/retry_policy.dart';
import 'src/settings/settings_controller.dart';

/// The Firebase project of this build's environment.
FirebaseOptions firebaseOptions() {
  if (!AppInfo.isProd) return DefaultFirebaseOptions.currentPlatform;
  return ProdFirebaseOptions.web;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions());
  await activateAppCheck();
  final prefs = await SharedPreferences.getInstance();
  await FirebaseAuthRepository.dropUnwantedSession(
    FirebaseAuth.instance,
    prefs,
  );

  runApp(
    ProviderScope(
      retry: retryPolicy,
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const FlatApp(),
    ),
  );
}
