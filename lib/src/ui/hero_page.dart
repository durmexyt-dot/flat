import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Duration of page transitions, and with it of every Hero flight.
const heroTransitionDuration = Duration(milliseconds: 700);

/// A page whose transition puts shared elements in focus: the new screen
/// fades in and rises slightly while the Heroes fly to their new places.
CustomTransitionPage<void> heroPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: heroTransitionDuration,
    reverseTransitionDuration: heroTransitionDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.35, 1, curve: Curves.easeOutCubic),
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
