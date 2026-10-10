import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

/// Browser notification permission. On iPhone, Safari offers notifications
/// only when the page was added to the home screen.
enum PushSupport { unsupported, notAsked, granted, denied }

PushSupport _fromPermission(String permission) => switch (permission) {
  'granted' => PushSupport.granted,
  'denied' => PushSupport.denied,
  _ => PushSupport.notAsked,
};

PushSupport pushSupport() {
  if (!globalContext.has('Notification')) return PushSupport.unsupported;
  return _fromPermission(web.Notification.permission);
}

Future<PushSupport> requestPushPermission() async {
  if (!globalContext.has('Notification')) return PushSupport.unsupported;
  final result = await web.Notification.requestPermission().toDart;
  return _fromPermission(result.toDart);
}

void showTestNotification(String title, String body) {
  if (pushSupport() != PushSupport.granted) return;
  web.Notification(
    title,
    web.NotificationOptions(body: body, icon: 'icons/Icon-192.png'),
  );
}
