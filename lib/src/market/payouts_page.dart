import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../settings/settings_widgets.dart';
import '../support/contact_support_page.dart';
import '../ui/app_style.dart';
import '../ui/async_view.dart';
import '../ui/format.dart';
import '../ui/hero_tags.dart';
import '../ui/skeleton.dart';
import '../ui/status_timeline.dart';
import 'labels.dart';
import 'order_detail_page.dart';
import 'order_labels.dart';
import '../ui/site_scaffold.dart';

class PayoutsPage extends ConsumerWidget {
  const PayoutsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final payouts = ref.watch(payoutsProvider);

    return SiteScaffold(
      title: l10n.payouts,
      maxWidth: SiteWidth.form,
      body: Column(
        children: [
          Expanded(
            child: AsyncView<List<Payout>>(
              value: payouts,
              onRetry: () => ref.invalidate(payoutsProvider),
              loading: const _PayoutsSkeleton(),
              data: (all) => ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  _Summary(payouts: all),
                  const SizedBox(height: 12),
                  const _MethodCard(),
                  SettingsSectionTitle(l10n.payouts),
                  if (all.isEmpty)
                    EmptyState(
                      icon: Icons.account_balance_outlined,
                      title: l10n.noPayouts,
                      message: l10n.noPayoutsInfo,
                    )
                  else
                    for (final p in all) ...[
                      PayoutCard(
                        payout: p,
                        onTap: () => context.push('/payout/${p.id}', extra: p),
                      ),
                      const SizedBox(height: 12),
                    ],
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
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SkeletonBox(height: 96, radius: 20),
          SizedBox(height: 12),
          SkeletonBox(height: 64, radius: 20),
          SizedBox(height: 24),
          SkeletonBox(height: 80, radius: 20),
          SizedBox(height: 12),
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
    final theme = Theme.of(context);
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

    Widget figure(String label, int minor, Color color) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: minor.toDouble()),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => Text(
              formatMoney(context, v.round(), currency),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );

    return Card.filled(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            figure(
              l10n.payoutsUpcoming,
              upcoming,
              theme.colorScheme.onPrimaryContainer,
            ),
            figure(l10n.payoutsPaidTotal, paid, theme.colorScheme.primary),
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
    final theme = Theme.of(context);
    final method = ref.watch(payoutMethodProvider).value;
    return SettingsGroup(
      children: [
        ListTile(
          shape: const RoundedRectangleBorder(),
          leading: Icon(
            method == null
                ? Icons.error_outline
                : Icons.account_balance_outlined,
            color: method == null ? theme.colorScheme.error : null,
          ),
          title: Text(l10n.payoutMethod),
          subtitle: Text(method?.masked ?? l10n.payoutMethodMissing),
          trailing: TextButton(
            onPressed: () => context.push('/account/payout-method'),
            child: Text(method == null ? l10n.setUpPayout : l10n.change),
          ),
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
    final theme = Theme.of(context);
    final when = payout.status == PayoutStatus.paid
        ? payout.reachedAt(PayoutStatus.paid)
        : payout.expectedAt;

    return Hero(
      tag: HeroTags.payout(payout.id),
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyle.of(context).cardRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: Icon(
                    Icons.account_balance_outlined,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatMoney(
                          context,
                          payout.amountMinor,
                          payout.currency,
                        ),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (when != null)
                        Text(
                          payout.status == PayoutStatus.paid
                              ? formatDate(context, when)
                              : l10n.expectedOn(formatDate(context, when)),
                          style: theme.textTheme.bodySmall,
                        ),
                      Text(
                        payout.orderNumbers.join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
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
        ),
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
      body: payout == null
          ? AsyncView<Payout?>(
              value: live,
              onRetry: () => ref.invalidate(payoutProvider(id)),
              loading: const _PayoutsSkeleton(),
              data: (_) =>
                  EmptyState(icon: Icons.search_off, title: l10n.loadError),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                PayoutCard(payout: payout),
                const SizedBox(height: 16),
                NextStepCard(
                  text: payoutNextStep(l10n, payout.status),
                  tone: payoutTone(payout.status),
                ),
                if (payout.failureReason.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(l10n.failureReason),
                    subtitle: Text(payout.failureReason),
                  ),
                ],
                SettingsSectionTitle(l10n.statusHistory),
                StatusTimeline(steps: payoutTimeline(context, payout)),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.push(
                    '/support/new',
                    extra: SupportContext(
                      topic: SupportTopic.payout,
                      reference: payout.orderNumbers.join(', '),
                    ),
                  ),
                  icon: const Icon(Icons.support_agent),
                  label: Text(l10n.getHelpPayout),
                ),
                SettingsSectionTitle(l10n.payoutOrders),
                SettingsGroup(
                  children: [
                    for (final n in payout.orderNumbers)
                      ListTile(
                        shape: const RoundedRectangleBorder(),
                        leading: const Icon(Icons.receipt_long_outlined),
                        title: Text(n),
                      ),
                    if (payout.method.isNotEmpty)
                      ListTile(
                        shape: const RoundedRectangleBorder(),
                        leading: const Icon(Icons.account_balance_outlined),
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
