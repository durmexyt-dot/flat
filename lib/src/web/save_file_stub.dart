import 'dart:typed_data';

/// Saves [bytes] as a download named [name]. The apps will use a share
/// sheet; for now nothing happens there.
Future<bool> saveFile(Uint8List bytes, String name, String mimeType) async =>
    false;
