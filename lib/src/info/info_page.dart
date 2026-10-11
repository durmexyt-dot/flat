import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: implemented by the home page work (footer pages).
class InfoPage extends ConsumerWidget {
  const InfoPage({super.key, required this.topic});

  /// E.g. "about", "press".
  final String topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) => const SizedBox();
}
