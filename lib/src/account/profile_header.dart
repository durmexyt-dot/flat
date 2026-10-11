import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_repository.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../ui/async_view.dart';
import '../ui/format.dart';
import '../ui/skeleton.dart';
import 'avatar.dart';
import 'photo_actions.dart';

/// Photo, name, username and ticket counts at the top of the account page.
class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;
    final profile = ref.watch(profileProvider);

    return AsyncView<UserProfile?>(
      // Without a profile document (e.g. Firestore not set up yet) the
      // header still shows what the sign-in knows.
      value: profile.hasError ? const AsyncData(null) : profile,
      onRetry: () => ref.invalidate(profileProvider),
      loading: const _HeaderSkeleton(),
      data: (p) {
        final name = p?.displayName ?? user?.displayName ?? user?.email ?? '';
        final handle = p?.username != null ? '@${p!.username}' : user?.email;
        final private = p?.visibility == ProfileVisibility.private;
        return Column(
          children: [
            GestureDetector(
              onTap: () => showPhotoActions(context, ref),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  UserAvatar(size: 96, photoBase64: p?.photoBase64, name: name),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Material(
                      color: theme.colorScheme.primary,
                      shape: CircleBorder(
                        side: BorderSide(
                          color: theme.colorScheme.surface,
                          width: 3,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.photo_camera_outlined,
                          size: 18,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (handle != null)
              Text(
                handle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: Icon(
                    private ? Icons.lock_outline : Icons.public,
                    size: 16,
                  ),
                  label: Text(
                    private ? l10n.profilePrivate : l10n.profilePublic,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                if (p?.createdAt case final since?)
                  Chip(
                    avatar: const Icon(
                      Icons.event_available_outlined,
                      size: 16,
                    ),
                    label: Text(l10n.memberSince(formatDate(context, since))),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/settings/profile'),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(l10n.editProfile),
            ),
            const SizedBox(height: 16),
            const StatsRow(),
          ],
        );
      },
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Shimmer(
      child: Column(
        children: [
          SkeletonBox(width: 96, height: 96, radius: 48),
          SizedBox(height: 12),
          SkeletonBox(width: 160, height: 24),
          SizedBox(height: 8),
          SkeletonBox(width: 110, height: 14),
          SizedBox(height: 16),
          SkeletonBox(width: 140, height: 36, radius: 18),
          SizedBox(height: 16),
          SkeletonBox(height: 76, radius: 16),
        ],
      ),
    );
  }
}

/// Listed, sold and bought ticket counts; numbers count up when they load.
class StatsRow extends ConsumerWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(statsProvider);

    Widget card(ProfileStats? s, {bool failed = false}) => Card.filled(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            _Stat(value: s?.listed, label: l10n.statListed),
            const _StatDivider(),
            _Stat(value: s?.sold, label: l10n.statSold),
            const _StatDivider(),
            _Stat(value: s?.bought, label: l10n.statBought),
            if (failed)
              IconButton(
                tooltip: l10n.retry,
                onPressed: () => ref.invalidate(statsProvider),
                icon: const Icon(Icons.refresh),
              ),
          ],
        ),
      ),
    );

    // A failed count is no reason for a big error box: dashes and a retry.
    if (stats.hasError) return card(null, failed: true);
    return AsyncView<ProfileStats?>(
      value: stats,
      loading: const Shimmer(child: SkeletonBox(height: 76, radius: 16)),
      data: (s) => card(s ?? const ProfileStats(listed: 0, sold: 0, bought: 0)),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  /// Null when unknown.
  final int? value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          if (value == null)
            Text(
              '–',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.outline,
              ),
            )
          else
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value!.toDouble()),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => Text(
                '${v.round()}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 36,
    child: VerticalDivider(color: Theme.of(context).colorScheme.outlineVariant),
  );
}
