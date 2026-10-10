import 'package:flutter/material.dart';

/// Shows [text] right away, replacing a visible snack bar instead of
/// queueing behind it.
void showSnack(
  ScaffoldMessengerState messenger,
  String text, {
  SnackBarAction? action,
}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text), action: action));
}
