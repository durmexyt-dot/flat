import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';

// TODO: implemented by the feature work.
class EventPage extends ConsumerWidget {
  const EventPage({super.key, required this.id, this.initial});

  final String id;
  final Event? initial;
  @override
  Widget build(BuildContext context, WidgetRef ref) => const SizedBox();
}
