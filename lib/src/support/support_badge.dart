import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ui/count_badge.dart';
import 'support_repository.dart';

/// The profile picture's badge: unread support answers, and for the team
/// new requests.
class AccountBadge extends ConsumerWidget {
  const AccountBadge({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      CountBadge(count: ref.watch(accountBadgeProvider), child: child);
}
