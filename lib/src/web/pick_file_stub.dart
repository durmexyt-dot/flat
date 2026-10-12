import 'dart:typed_data';

/// A file the user picked.
typedef PickedFile = ({String name, Uint8List bytes, String contentType});

/// Lets the user pick a ticket file (PDF or picture). Only on the web for
/// now; elsewhere nothing is picked.
Future<PickedFile?> pickFile({String accept = ''}) async => null;
