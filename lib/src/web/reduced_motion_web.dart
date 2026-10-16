import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// The browser's `prefers-reduced-motion` setting, kept up to date while
/// the app runs.
final ValueListenable<bool> prefersReducedMotion = () {
  final query = web.window.matchMedia('(prefers-reduced-motion: reduce)');
  final value = ValueNotifier(query.matches);
  query.addEventListener(
    'change',
    ((web.Event _) => value.value = query.matches).toJS,
  );
  return value;
}();
