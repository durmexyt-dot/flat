import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../config/app_info.dart';
import '../ui/snack.dart';
import '../web/version_check.dart';

/// Tells web users when a newer version is online, so nobody keeps working
/// with an old one from the browser cache. Checks every 10 minutes and
/// whenever the tab comes back to the foreground.
class UpdateNotifier extends StatefulWidget {
  const UpdateNotifier({super.key, required this.child});

  final Widget child;

  @override
  State<UpdateNotifier> createState() => _UpdateNotifierState();
}

class _UpdateNotifierState extends State<UpdateNotifier> {
  Timer? _timer;
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    // Builds without a build number (local runs, tests) skip the check.
    if (AppInfo.build == 0) return;
    _timer = Timer.periodic(const Duration(minutes: 10), (_) => _check());
    onPageVisible(_check);
    Future.delayed(const Duration(seconds: 30), _check);
  }

  Future<void> _check() async {
    if (_shown || !mounted) return;
    final online = await deployedBuild();
    if (online == null || online <= AppInfo.build || !mounted) return;
    _shown = true;
    final l10n = AppLocalizations.of(context);
    showSnack(
      l10n.newVersionTitle,
      description: l10n.newVersionBody,
      actionLabel: l10n.reload,
      onAction: reloadPage,
      // Stays until the user reloads.
      duration: null,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
