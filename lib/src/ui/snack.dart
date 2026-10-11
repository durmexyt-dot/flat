import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// The app's toaster, above the navigator, so toasts survive page changes
/// and can be shown after async gaps without a mounted context.
final toasterKey = GlobalKey<FToasterState>();

FToasterEntry? _current;

/// Shows [text] as a Forui toast right away, replacing a visible one instead
/// of stacking behind it. With [actionLabel], the toast gets a button.
void showSnack(String text, {String? actionLabel, VoidCallback? onAction}) {
  final toaster = toasterKey.currentState;
  if (toaster == null) return;
  // An entry from an earlier toaster (e.g. after a hot restart) is gone.
  try {
    _current?.dismiss();
  } on FlutterError {
    // Already dismissed.
  }
  late final FToasterEntry entry;
  entry = _current = toaster.show(
    onDismiss: () {
      if (identical(_current, entry)) _current = null;
    },
    alignment: FToastAlignment.bottomCenter,
    duration: const Duration(seconds: 4),
    builder: (context, entry) => FToast(
      title: Text(text),
      suffix: actionLabel == null
          ? null
          : FButton(
              size: FButtonSizeVariant.sm,
              mainAxisSize: MainAxisSize.min,
              onPress: () {
                entry.dismiss();
                onAction?.call();
              },
              child: Text(actionLabel, overflow: TextOverflow.ellipsis),
            ),
    ),
  );
}
