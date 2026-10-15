import 'package:flutter/widgets.dart';
import 'package:url_launcher/link.dart';

import '../web/link_modifiers.dart';

/// Makes a tappable widget a real link to [path] in the browser: middle
/// click, Ctrl/Cmd/Shift-click and "open in new tab" work, and the address
/// shows on hover. A normal click runs [onTap], so in-app navigation (with
/// its animations and back button) stays as it is.
///
/// Middle click is the browser's own, on the link element underneath.
class AppLink extends StatelessWidget {
  const AppLink({
    super.key,
    required this.path,
    required this.onTap,
    required this.builder,
  });

  /// An address inside the app, e.g. `/event/abc`.
  final String path;
  final VoidCallback onTap;

  /// Builds the widget; it calls the given callback when tapped.
  final Widget Function(VoidCallback onTap) builder;

  @override
  Widget build(BuildContext context) {
    // Starts listening, so the first click already knows its modifiers.
    lastPointerWantsNewTab();
    return Link(
      uri: Uri.parse(path),
      // The link's own navigation is never asked for: a normal click is
      // the app's, and with Ctrl/Cmd/Shift a new tab opens, the app stays.
      builder: (context, _) => builder(() {
        if (lastPointerWantsNewTab()) {
          openInNewTab(path);
        } else {
          onTap();
        }
      }),
    );
  }
}
