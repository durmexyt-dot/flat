import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Goes back, or to [fallback] when the page was opened directly (sidebar,
/// link, reload) and there is nothing to go back to.
void popOrGo(BuildContext context, String fallback) {
  final router = GoRouter.of(context);
  router.canPop() ? router.pop() : router.go(fallback);
}
