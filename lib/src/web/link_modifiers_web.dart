import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:web/web.dart' as web;

bool _newTab = false;
bool _listening = false;

/// Whether the last pointer press held Ctrl, Cmd or Shift, i.e. the user
/// wants the link in a new tab or window. Read straight from the browser's
/// event: the app handles the tap only after the browser's click.
bool lastPointerWantsNewTab() {
  if (!_listening) {
    _listening = true;
    web.window.addEventListener(
      'pointerdown',
      ((web.PointerEvent e) {
        _newTab = e.ctrlKey || e.metaKey || e.shiftKey;
      }).toJS,
      true.toJS,
    );
  }
  return _newTab;
}

/// Opens the app's page [path] in a new tab. Still part of the click's user
/// gesture, so browsers allow it.
void openInNewTab(String path) {
  final url = ui_web.urlStrategy?.prepareExternalUrl(path) ?? path;
  web.window.open(url, '_blank', 'noopener');
}
