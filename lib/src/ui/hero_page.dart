import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'tokens.dart';

/// Whether the next page takes over the brand from the splash. Set by the
/// splash page; cleared once that page has arrived.
abstract final class BrandHandoff {
  static bool pending = false;
}

/// A page whose transition keeps shared elements in focus: the new screen
/// fades in and rises slightly while the Heroes fly to their new places.
/// The new page is visible from the first frame, so a tap feels answered at
/// once. With reduced motion it only cross-fades.
CustomTransitionPage<void> heroPage(GoRouterState state, Widget child) {
  final handoff = BrandHandoff.pending && !Motion.reduced;
  if (Motion.reduced) BrandHandoff.pending = false;
  final duration = handoff ? Motion.brandHandoff : Motion.page;
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (handoff) {
        animation.addStatusListener((status) {
          if (status == AnimationStatus.completed) BrandHandoff.pending = false;
        });
      }
      final curved = CurvedAnimation(parent: animation, curve: Motion.enter);
      if (MediaQuery.disableAnimationsOf(context)) {
        return FadeTransition(opacity: curved, child: child);
      }
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
