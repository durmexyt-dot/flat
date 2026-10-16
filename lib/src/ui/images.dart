import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

/// Lets the user pick a picture from the gallery. Null if cancelled.
Future<Uint8List?> pickImageBytes({double maxSide = 2000}) async {
  final file = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: maxSide,
    maxHeight: maxSide,
  );
  return file?.readAsBytes();
}

img.Image _decode(List<int> bytes) {
  final decoded = img.decodeImage(
    bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
  );
  if (decoded == null) throw const FormatException('Unsupported image');
  return img.bakeOrientation(decoded);
}

/// Event pictures: cropped to 16:9 around the center, 1280 × 720 JPEG in
/// base64 (well under the 400 000 characters the rules allow).
String encodeEventImage(List<int> bytes) {
  final image = _decode(bytes);
  const ratio = 16 / 9;
  var w = image.width;
  var h = (w / ratio).round();
  if (h > image.height) {
    h = image.height;
    w = (h * ratio).round();
  }
  final cropped = img.copyCrop(
    image,
    x: (image.width - w) ~/ 2,
    y: (image.height - h) ~/ 2,
    width: w,
    height: h,
  );
  final small = w > 1280 ? img.copyResize(cropped, width: 1280) : cropped;
  return _fit(small, maxChars: 380000);
}

/// Seat map pictures (floor plans): not cropped, longest side at most
/// 1600 px, JPEG in base64 under 380 000 characters. Returns the data and
/// the picture's width / height.
(String, double) encodeSeatMapImage(List<int> bytes) {
  final image = _decode(bytes);
  final longest = image.width > image.height ? image.width : image.height;
  final small = longest > 1600
      ? (image.width >= image.height
            ? img.copyResize(image, width: 1600)
            : img.copyResize(image, height: 1600))
      : image;
  return (_fit(small, maxChars: 380000), small.width / small.height);
}

/// Support pictures (screenshots, tickets): longest side at most 1600 px,
/// JPEG in base64 under 300 000 characters as the rules require.
String encodeSupportImage(List<int> bytes) {
  final image = _decode(bytes);
  final longest = image.width > image.height ? image.width : image.height;
  final small = longest > 1600
      ? img.copyResize(
          image,
          width: image.width >= image.height ? 1600 : null,
          height: image.height > image.width ? 1600 : null,
        )
      : image;
  return _fit(small, maxChars: 290000);
}

/// Lowers the quality, then the size, until the JPEG fits.
String _fit(img.Image image, {required int maxChars}) {
  var current = image;
  for (var round = 0; round < 6; round++) {
    for (final quality in const [80, 68, 55]) {
      final data = base64Encode(img.encodeJpg(current, quality: quality));
      if (data.length <= maxChars) return data;
    }
    current = img.copyResize(current, width: (current.width * 0.75).round());
  }
  return base64Encode(img.encodeJpg(current, quality: 50));
}
