import 'package:web/web.dart' as web;

/// Removes the splash in web/index.html, shown while Flutter loads.
void removeHtmlSplash() => web.document.getElementById('splash')?.remove();
