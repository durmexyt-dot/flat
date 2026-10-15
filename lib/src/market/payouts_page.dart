import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../settings/settings_widgets.dart';
import '../support/contact_support_page.dart';
import '../ui/async_view.dart';
import '../ui/format.dart';
import '../ui/hero_tags.dart';
import '../ui/responsive_grid.dart';
import '../ui/skeleton.dart';
import '../ui/status_timeline.dart';
import 'labels.dart';
import 'order_detail_page.dart';
import 'order_labels.dart';
import '../ui/site_scaffold.dart';
import '../ui/tokens.dart';

class PayoutsPage extends ConsumerWidget {
  const PayoutsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final payouts = ref.watch(payoutsProvider);

    return SiteScaffold(
      title: l10n.payouts,
      maxWidth: SiteWidth.full,
      accountNav: true,
      body: Column(
        children: [
          Expanded(
            child: AsyncView<List<Payout>>(
              value: payouts,
              onRetry: () => ref.invalidate(payoutsProvider),
              loading: const _PayoutsSkeleton(),
              data: (all) => ListView(
                padding: Insets.pageList,
                children: [
                  ResponsiveGrid(
                    maxColumns: 2,
                    gap: 12,
                    children: [
                      _Summary(payouts: all),
                      const _MethodCard(),
                    ],
                  ),
                  SettingsSectionTitle(l10n.payouts),
                  if (all.isEmpty)
                    EmptyState(
                      icon: FLucideIcons.landmark,
                      title: l10n.noPayouts,
                      message: l10n.noPayoutsInfo,
                    )
                  else
                    ResponsiveGrid(
                      maxColumns: 2,
                      gap: 12,
                      children: [
                        for (final p in all)
                          PayoutCard(
                            payout: p,
                            onTap: () =>
                                context.push('/payout/${p.id}', extra: p),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayoutsSkeleton extends StatelessWidget {
  const _PayoutsSkeleton();

  @override
  Widget build(BuildContext context) => const Shimmer(
    child: Padding(
      padding: EdgeInsets.all(Space.xl),
      child: Column(
        children: [
          SkeletonBox(height: 96, radius: 20),
          SizedBox(height: Space.lg),
          SkeletonBox(height: 64, radius: 20),
          SizedBox(height: Space.x3l),
          SkeletonBox(height: 80, radius: 20),
          SizedBox(height: Space.lg),
          SkeletonBox(height: 80, radius: 20),
        ],
      ),
    ),
  );
}

class _Summary extends StatelessWidget {
  const _Summary({required this.payouts});

  final List<Payout> payouts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final colors = theme.colors;
    final currency = payouts.firstOrNull?.currency ?? 'BAM';
    int sum(bool Function(Payout) f) =>
        payouts.where(f).fold(0, (total, p) => total + p.amountMinor);
    final upcoming = sum(
      (p) => const {
        PayoutStatus.pending,
        PayoutStatus.scheduled,
        PayoutStatus.processing,
      }.contains(p.status),
    );
    final paid = sum((p) => p.status == PayoutStatus.paid);

    Widget figure(String label, int minor) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.typography.body.xs.copyWith(
              color: colors.mutedForeground,
              fontWeight: FontWeights.medium,
            ),
          ),
          const SizedBox(height: Space.xs),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: minor.toDouble()),
            duration: Motion.long,
            curve: Motion.enter,
            builder: (context, v, _) => Text(
              formatMoney(context, v.round(), currency),
              style: theme.typography.display.sm.copyWith(
                fontWeight: FontWeights.heavy,
                color: colors.foreground,
              ),
            ),
          ),
        ],
      ),
    );

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Space.xxl),
        child: Row(
          children: [
            figure(l10n.payoutsUpcoming, upcoming),
            figure(l10n.payoutsPaidTotal, paid),
          ],
        ),
      ),
    );
  }
}

class _MethodCard extends ConsumerWidget {
  const _MethodCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.theme.colors;
    final method = ref.watch(payoutMethodProvider).value;
    return SettingsGroup(
      children: [
        FTile(
          prefix: Icon(
            method == null ? FLucideIcons.circleAlert : FLucideIcons.landmark,
            color: method == null ? colors.destructive : null,
          ),
          title: Text(l10n.payoutMethod),
          subtitle: Text(method?.masked ?? l10n.payoutMethodMissing),
          details: Text(method == null ? l10n.setUpPayout : l10n.change),
          suffix: const Icon(FLucideIcons.chevronRight),
          onPress: () => context.push('/account/payout-method'),
        ),
      ],
    );
  }
}

/// A payout with amount, status and expected date. Flies into its details.
class PayoutCard extends StatelessWidget {
  const PayoutCard({super.key, required this.payout, this.onTap});

  final Payout payout;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final colors = theme.colors;
    final body = theme.typography.body;
    final when = payout.status == PayoutStatus.paid
        ? payout.reachedAt(PayoutStatus.paid)
        : payout.expectedAt;

    final card = FCard(
      child: Padding(
        padding: const EdgeInsets.all(Space.xl),
        child: Row(
          children: [
            FAvatar.raw(
              size: 40,
              child: Icon(
                FLucideIcons.landmark,
                size: IconSizes.lg,
                color: colors.mutedForeground,
              ),
            ),
            const SizedBox(width: Space.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatMoney(context, payout.amountMinor, payout.currency),
                    style: body.lg.copyWith(
                      fontWeight: FontWeights.heavy,
                      color: colors.foreground,
                    ),
                  ),
                  if (when != null)
                    Text(
                      payout.status == PayoutStatus.paid
                          ? formatDate(context, when)
                          : l10n.expectedOn(formatDate(context, when)),
                      style: body.sm.copyWith(color: colors.foreground),
                    ),
                  Text(
                    payout.orderNumbers.join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: body.xs.copyWith(color: colors.mutedForeground),
                  ),
                ],
              ),
            ),
            StatusChip(
              label: payoutStatusName(l10n, payout.status),
              tone: payoutTone(payout.status),
            ),
          ],
        ),
      ),
    );

    return Hero(
      tag: HeroTags.payout(payout.id),
      child: Material(
        type: MaterialType.transparency,
        child: onTap == null ? card : FTappable(onPress: onTap, child: card),
      ),
    );
  }
}

class PayoutDetailPage extends ConsumerWidget {
  const PayoutDetailPage({super.key, required this.id, this.initial});

  final String id;
  final Payout? initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final live = ref.watch(payoutProvider(id));
    final payout = live.value ?? initial;

    return SiteScaffold(
      title: l10n.payoutDetails,
      maxWidth: SiteWidth.form,
      accountNav: true,
      body: payout == null
          ? AsyncView<Payout?>(
              value: live,
              onRetry: () => ref.invalidate(payoutProvider(id)),
              loading: const _PayoutsSkeleton(),
              data: (_) =>
                  EmptyState(icon: FLucideIcons.searchX, title: l10n.loadError),
            )
          : ListView(
              padding: Insets.pageList,
              children: [
                PayoutCard(payout: payout),
                const SizedBox(height: Space.xl),
                NextStepCard(
                  text: payoutNextStep(l10n, payout.status),
                  tone: payoutTone(payout.status),
                ),
                if (payout.failureReason.isNotEmpty) ...[
                  const SizedBox(height: Space.lg),
                  FAlert(
                    variant: FAlertVariant.destructive,
                    icon: const Icon(FLucideIcons.info),
                    title: Text(l10n.failureReason),
                    subtitle: Text(payout.failureReason),
                  ),
                ],
                SettingsSectionTitle(l10n.statusHistory),
                StatusTimeline(steps: payoutTimeline(context, payout)),
                const SizedBox(height: Space.lg),
                FButton(
                  variant: FButtonVariant.outline,
                  onPress: () => context.push(
                    '/support/new',
                    extra: SupportContext(
                      topic: SupportTopic.payout,
                      reference: payout.orderNumbers.join(', '),
                    ),
                  ),
                  prefix: const Icon(FLucideIcons.headset),
                  child: Flexible(
                    child: Text(
                      l10n.getHelpPayout,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SettingsSectionTitle(l10n.payoutOrders),
                SettingsGroup(
                  children: [
                    for (final n in payout.orderNumbers)
                      FTile(
                        prefix: const Icon(FLucideIcons.receipt),
                        title: Text(n),
                      ),
                    if (payout.method.isNotEmpty)
                      FTile(
                        prefix: const Icon(FLucideIcons.landmark),
                        title: Text(l10n.payoutMethod),
                        subtitle: Text(payout.method),
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}
