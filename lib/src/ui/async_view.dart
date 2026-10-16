import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import 'tokens.dart';

/// Shows [loading] (usually a skeleton), an error with retry, or the data,
/// cross-fading between them.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.loading,
    required this.data,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget loading;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    // Riverpod keeps a failed provider "loading" while it retries, with the
    // error attached; show the error then instead of an endless skeleton.
    final Widget child = value.hasError
        ? ErrorState(
            key: const ValueKey('error'),
            onRetry: onRetry,
            error: value.error,
          )
        : value.hasValue
        ? KeyedSubtree(
            key: const ValueKey('data'),
            child: data(value.requireValue),
          )
        : KeyedSubtree(key: const ValueKey('loading'), child: loading);
    return AnimatedSwitcher(
      duration: Motion.slow,
      switchInCurve: Motion.ease,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topCenter,
        children: [...previous, ?current],
      ),
      child: child,
    );
  }
}

/// A short code for an error, shown small so a report says what failed,
/// e.g. "permission-denied".
String? errorCode(Object? error) => switch (error) {
  null => null,
  FirebaseException(:final code) => code,
  _ => error.runtimeType.toString(),
};

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, this.onRetry, this.error});

  final VoidCallback? onRetry;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final code = errorCode(error);
    if (error != null) debugPrint('Load error: $error');
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(Space.x3l),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FLucideIcons.cloudOff,
            size: IconSizes.illustration,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: Space.lg),
          Text(l10n.loadError, style: theme.textTheme.titleMedium),
          const SizedBox(height: Space.xs),
          Text(
            l10n.loadErrorInfo,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (code != null) ...[
            const SizedBox(height: Space.xs),
            Text(
              code,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: Space.lg),
            FButton(
              variant: FButtonVariant.outline,
              mainAxisSize: MainAxisSize.min,
              onPress: onRetry,
              prefix: const Icon(FLucideIcons.refreshCw),
              child: Text(l10n.retry, overflow: TextOverflow.ellipsis),
            ),
          ],
        ],
      ),
    );
  }
}

/// Icon, title and text for an empty list.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.x3l, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.9, end: 1),
            duration: Motion.slow,
            curve: Motion.enter,
            builder: (context, v, child) =>
                Transform.scale(scale: v, child: child),
            // Icon in a muted circle, like Forui's empty states.
            child: Container(
              padding: const EdgeInsets.all(Space.xl),
              decoration: BoxDecoration(
                color: context.theme.colors.muted,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ),
          const SizedBox(height: Space.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.theme.typography.body.lg.copyWith(
              fontWeight: FontWeights.semibold,
              color: context.theme.colors.foreground,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: Space.xs),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (action != null) ...[const SizedBox(height: Space.xl), action!],
        ],
      ),
    );
  }
}
