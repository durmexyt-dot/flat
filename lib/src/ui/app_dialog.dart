import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'tokens.dart';

/// A Forui dialog: title, body and actions. On phones the actions stack,
/// primary first; on wider screens they sit in a row on the right.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required String title,
  Widget? body,
  required List<Widget> Function(BuildContext context) actions,
  bool barrierDismissible = true,
}) {
  return showFDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context, style, animation) => FDialog(
      animation: animation,
      builder: (context, style) {
        final narrow = MediaQuery.sizeOf(context).width < 600;
        final buttons = actions(context);
        return Padding(
          padding: const EdgeInsets.all(Space.x3l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: style.titleTextStyle),
              if (body != null) ...[
                const SizedBox(height: Space.md),
                DefaultTextStyle.merge(
                  style: style.bodyTextStyle.copyWith(
                    fontSize: context.theme.typography.body.sm.fontSize,
                  ),
                  child: body,
                ),
              ],
              const SizedBox(height: Space.xxl),
              if (narrow)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Space.md,
                  children: buttons.reversed.toList(),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: Space.md,
                  children: [for (final b in buttons) IntrinsicWidth(child: b)],
                ),
            ],
          ),
        );
      },
    ),
  );
}
