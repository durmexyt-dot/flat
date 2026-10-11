import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// The device position as (latitude, longitude), or null when unavailable
/// or not allowed. The browser asks the user the first time.
Future<(double, double)?> currentPosition() {
  final done = Completer<(double, double)?>();
  try {
    web.window.navigator.geolocation.getCurrentPosition(
      ((web.GeolocationPosition p) {
        if (!done.isCompleted) {
          done.complete((p.coords.latitude, p.coords.longitude));
        }
      }).toJS,
      ((web.GeolocationPositionError _) {
        if (!done.isCompleted) done.complete(null);
      }).toJS,
      // A city is enough: no GPS fix needed, a recent position is fine.
      web.PositionOptions(
        enableHighAccuracy: false,
        timeout: 10000,
        maximumAge: 600000,
      ),
    );
  } catch (_) {
    if (!done.isCompleted) done.complete(null);
  }
  return done.future.timeout(
    const Duration(seconds: 12),
    onTimeout: () => null,
  );
}
