import 'package:web/web.dart' as web;

/// Opens [url] (e.g. a ticket file) in a new tab.
Future<bool> openUrl(String url) async {
  web.window.open(url, '_blank', 'noopener');
  return true;
}
