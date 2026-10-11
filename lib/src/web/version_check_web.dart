import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// The build number of the version that is online now, from the
/// `version.json` Flutter writes next to the app. Null if unknown.
Future<int?> deployedBuild() async {
  try {
    // Past every cache: the point is to see a new deploy.
    final url = 'version.json?t=${DateTime.now().millisecondsSinceEpoch}';
    final response = await web.window
        .fetch(url.toJS, web.RequestInit(cache: 'no-store'))
        .toDart;
    if (!response.ok) return null;
    final text = (await response.text().toDart).toDart;
    final json = jsonDecode(text) as Map<String, dynamic>;
    return int.tryParse('${json['build_number']}');
  } catch (_) {
    return null;
  }
}

void reloadPage() => web.window.location.reload();

/// Calls [onVisible] when the tab comes back to the foreground.
void onPageVisible(void Function() onVisible) {
  web.document.addEventListener(
    'visibilitychange',
    ((web.Event _) {
      if (web.document.visibilityState == 'visible') onVisible();
    }).toJS,
  );
}
