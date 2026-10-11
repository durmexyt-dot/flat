import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: live alerts for support answers and new requests.
class SupportAlerts extends ConsumerWidget {
  const SupportAlerts({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) => child;
}
