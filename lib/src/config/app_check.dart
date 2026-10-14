import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

import 'app_info.dart';

/// reCAPTCHA Enterprise (Fraud Defense) website keys for Firebase App Check,
/// one per Firebase project, created in that project's Google Cloud
/// console (a key from the other project is not accepted). They are public. Empty means App Check is not
/// set up for that environment yet, and the app runs without it.
const _siteKeyStaging = '6LeJbe8tAAAAAM_RV_io88dlX6R1aX57RK6Oi_Sg';
const _siteKeyProd = '6LfVOu8tAAAAAO11enPHNnxrDfAhin2tfL_z8np-';

/// Proves to Firestore, Storage and the functions that requests come from
/// this app. For browser tests on localhost, `?appCheckDebug=<token>` uses a
/// debug token registered in the Firebase console instead (`?appCheckDebug=`
/// alone makes a new one that the browser console prints).
Future<void> activateAppCheck() async {
  if (!kIsWeb) return;
  final siteKey = AppInfo.isProd ? _siteKeyProd : _siteKeyStaging;
  if (siteKey.isEmpty) return;
  final local = Uri.base.host == 'localhost' || Uri.base.host == '127.0.0.1';
  final debugToken = Uri.base.queryParameters['appCheckDebug'];
  try {
    await FirebaseAppCheck.instance.activate(
      providerWeb: local && debugToken != null
          ? WebDebugProvider(debugToken: debugToken.isEmpty ? null : debugToken)
          : ReCaptchaEnterpriseProvider(siteKey),
    );
    await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
  } catch (e) {
    // Without a token requests still go out; once enforced they are refused,
    // which the app shows as errors. Never block the start for it.
    debugPrint('App Check: $e');
  }
}
