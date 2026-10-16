import 'package:flutter/foundation.dart';

/// The browser's "reduce motion" preference. Elsewhere the platform reports
/// it through `MediaQuery.disableAnimations`.
final ValueListenable<bool> prefersReducedMotion = ValueNotifier(false);
