import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'tokens.dart';

/// A small count in the brand color on the top right of [child], e.g. unread
/// support answers on the profile picture. Hidden at zero; pops in and out.
class CountBadge extends StatelessWidget {
  const CountBadge({super.key, required this.count, required this.child});

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -4,
          right: -4,
          child: AnimatedScale(
            scale: count > 0 ? 1 : 0,
            duration: Motion.normal,
            curve: Motion.enter,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18),
              height: 18,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: colors.background, width: 1.5),
              ),
              child: Text(
                count > 9 ? '9+' : '$count',
                style: TextStyle(
                  color: colors.primaryForeground,
                  fontSize: 10,
                  height: 1,
                  fontWeight: FontWeights.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
