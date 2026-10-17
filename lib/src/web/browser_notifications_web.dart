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
  if (result.toDart == 'granted') _registration();
  return _fromPermission(result.toDart);
}

/// What a tap on a shown notification does, by its tag.
final _onClick = <String, void Function()>{};
var _listening = false;
Future<web.ServiceWorkerRegistration?>? _registering;

/// The service worker that shows notifications (`web/notify_sw.js`).
/// Phone browsers refuse `new Notification()` and allow them only through
/// one; desktop browsers accept both.
Future<web.ServiceWorkerRegistration?> _registration() =>
    _registering ??= () async {
      if (!web.window.navigator.has('serviceWorker')) return null;
      final workers = web.window.navigator.serviceWorker;
      if (!_listening) {
        _listening = true;
        workers.addEventListener(
          'message',
          ((web.MessageEvent event) {
            final data = event.data;
            if (data == null || !data.isA<JSObject>()) return;
            data as JSObject;
            if ((data['type'] as JSString?)?.toDart != 'notificationclick') {
              return;
            }
            final tag = (data['tag'] as JSString?)?.toDart ?? '';
            _onClick.remove(tag)?.call();
          }).toJS,
        );
      }
      try {
        await workers.register('notify_sw.js'.toJS).toDart;
        return await workers.ready.toDart;
      } catch (_) {
        _registering = null;
        return null;
      }
    }();

/// Shows a notification; false if the browser didn't let it.
Future<bool> _show(
  String title,
  String body, {
  String tag = '',
  void Function()? onClick,
}) async {
  if (pushSupport() != PushSupport.granted) return false;
  final options = web.NotificationOptions(
    body: body,
    icon: 'icons/Icon-192.png',
    tag: tag,
  );
  final registration = await _registration();
  if (registration != null) {
    try {
      await registration.showNotification(title, options).toDart;
      if (onClick != null) _onClick[tag] = onClick;
      return true;
    } catch (_) {
      // Falls back to a page notification below.
    }
  }
  try {
    final n = web.Notification(title, options);
    n.onclick = ((web.Event _) {
      web.window.focus();
      n.close();
      onClick?.call();
    }).toJS;
    return true;
  } catch (_) {
    return false;
  }
}

Future<bool> showTestNotification(String title, String body) =>
    _show(title, body, tag: 'test');

/// True while the tab is in the background or the window minimized.
bool pageHidden() => web.document.visibilityState == 'hidden';

/// A system notification; a click brings the tab to the front and runs
/// [onClick]. Notifications with the same [tag] replace each other.
void showSystemNotification(
  String title,
  String body, {
  String? tag,
  void Function()? onClick,
}) {
  _show(title, body, tag: tag ?? '', onClick: onClick);
}
