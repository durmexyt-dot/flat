import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads Forui's Inter font, so text in tests has its real width instead
/// of the test font's wide square glyphs (which made labels overflow).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final inter = FontLoader('packages/forui/Inter')
    ..addFont(rootBundle.load('packages/forui/assets/fonts/inter/Inter.ttf'));
  final icons = FontLoader('packages/forui_lucide/ForuiLucideIcons')
    ..addFont(rootBundle.load('packages/forui_lucide/assets/lucide.ttf'));
  await Future.wait([inter.load(), icons.load()]);
  await testMain();
}
