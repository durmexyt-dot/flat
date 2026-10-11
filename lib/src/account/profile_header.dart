import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

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
/// [horizontal] lays it out as a wide card row (website layout).
class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key, this.horizontal = false});

  final bool horizontal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final colors = theme.colors;
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
        final align = horizontal ? WrapAlignment.start : WrapAlignment.center;

        final avatar = FTappable(
          semanticsLabel: l10n.editProfile,
          onPress: () => showPhotoActions(context, ref),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              UserAvatar(size: 96, photoBase64: p?.photoBase64, name: name),
              Positioned(
                right: -2,
                bottom: -2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.foreground,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.background, width: 3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      FLucideIcons.camera,
                      size: 16,
                      color: colors.background,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        final details = <Widget>[
          Text(
            name,
            textAlign: horizontal ? TextAlign.start : TextAlign.center,
            style: theme.typography.body.xl.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.foreground,
            ),
          ),
          if (handle != null)
            Text(
              handle,
              style: theme.typography.body.sm.copyWith(
                color: colors.mutedForeground,
              ),
            ),
          const SizedBox(height: 8),
          Wrap(
            alignment: align,
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _InfoBadge(
                icon: private ? FLucideIcons.lock : FLucideIcons.globe,
                label: private ? l10n.profilePrivate : l10n.profilePublic,
              ),
              if (p?.createdAt case final since?)
                _InfoBadge(
                  icon: FLucideIcons.calendarCheck,
                  label: l10n.memberSince(formatDate(context, since)),
                ),
              if (horizontal) _editButton(context, l10n),
            ],
          ),
        ];

        if (horizontal) {
          return Row(
            children: [
              avatar,
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: details,
                ),
              ),
              const SizedBox(width: 24),
              const SizedBox(width: 340, child: StatsRow()),
            ],
          );
        }
        return Column(
          children: [
            avatar,
            const SizedBox(height: 12),
            ...details,
            const SizedBox(height: 12),
            _editButton(context, l10n),
            const SizedBox(height: 16),
            const StatsRow(),
          ],
        );
      },
    );
  }

  Widget _editButton(BuildContext context, AppLocalizations l10n) => FButton(
    variant: .outline,
    size: .sm,
    mainAxisSize: MainAxisSize.min,
    onPress: () => context.push('/settings/profile'),
    prefix: const Icon(FLucideIcons.pencil),
    child: Text(l10n.editProfile),
  );
}

/// A small neutral badge with a leading icon.
class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => FBadge(
    variant: .secondary,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14),
        const SizedBox(width: 4),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    ),
  );
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

    Widget card(ProfileStats? s, {bool failed = false}) => FCard(
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
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FTooltip(
                  tipBuilder: (context, _) => Text(l10n.retry),
                  child: FButton.icon(
                    variant: .ghost,
                    semanticsLabel: l10n.retry,
                    onPress: () => ref.invalidate(statsProvider),
                    child: const Icon(FLucideIcons.refreshCw),
                  ),
                ),
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
    final theme = context.theme;
    final colors = theme.colors;
    final number = theme.typography.body.xl.copyWith(
      fontWeight: FontWeight.w800,
    );
    return Expanded(
      child: Column(
        children: [
          if (value == null)
            Text('–', style: number.copyWith(color: colors.mutedForeground))
          else
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value!.toDouble()),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => Text(
                '${v.round()}',
                style: number.copyWith(color: colors.foreground),
              ),
            ),
          Text(
            label,
            style: theme.typography.body.xs.copyWith(
              color: colors.mutedForeground,
              fontWeight: FontWeight.w500,
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
  Widget build(BuildContext context) =>
      const SizedBox(height: 36, child: FDivider(axis: Axis.vertical));
}
