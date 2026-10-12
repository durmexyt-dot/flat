import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// A file the user picked.
typedef PickedFile = ({String name, Uint8List bytes, String contentType});

/// Opens the browser's file dialog for [accept] (e.g.
/// "application/pdf,image/png"). Null when nothing was picked.
Future<PickedFile?> pickFile({String accept = ''}) async {
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = accept;
  final picked = Completer<web.File?>();
  input
    ..addEventListener(
      'change',
      ((web.Event _) {
        final files = input.files;
        if (!picked.isCompleted) {
          picked.complete(
            files == null || files.length == 0 ? null : files.item(0),
          );
        }
      }).toJS,
    )
    ..addEventListener(
      'cancel',
      ((web.Event _) {
        if (!picked.isCompleted) picked.complete(null);
      }).toJS,
    );
  input.click();
  final file = await picked.future;
  if (file == null) return null;
  final buffer = await file.arrayBuffer().toDart;
  return (
    name: file.name,
    bytes: buffer.toDart.asUint8List(),
    contentType: file.type,
  );
}
