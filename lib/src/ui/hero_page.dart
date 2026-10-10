import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Duration of page transitions, and with it of every Hero flight.
const heroTransitionDuration = Duration(milliseconds: 600);

/// A page whose transition puts shared elements in focus: the screens only
/// cross-fade, so the Heroes are the only thing that moves.
CustomTransitionPage<void> heroPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: heroTransitionDuration,
    reverseTransitionDuration: heroTransitionDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: const Interval(0.3, 1, curve: Curves.easeOut),
        ),
        child: child,
      );
    },
  );
}
