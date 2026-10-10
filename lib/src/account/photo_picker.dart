import 'dart:convert';

import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

/// Lets the user pick a photo and returns it as a square 256 px JPEG in
/// base64, small enough to store in the profile document. Null if cancelled.
Future<String?> pickProfilePhoto() async {
  final file = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 1024,
    maxHeight: 1024,
  );
  if (file == null) return null;
  final bytes = await file.readAsBytes();
  return encodeProfilePhoto(bytes);
}

/// Crops to a centered square, scales to 256 px and encodes as JPEG.
String encodeProfilePhoto(List<int> bytes) {
  final decoded = img.decodeImage(
    bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
  );
  if (decoded == null) throw const FormatException('Unsupported image');
  final oriented = img.bakeOrientation(decoded);
  final side = oriented.width < oriented.height
      ? oriented.width
      : oriented.height;
  final square = img.copyCrop(
    oriented,
    x: (oriented.width - side) ~/ 2,
    y: (oriented.height - side) ~/ 2,
    width: side,
    height: side,
  );
  final small = img.copyResize(square, width: 256, height: 256);
  return base64Encode(img.encodeJpg(small, quality: 80));
}
