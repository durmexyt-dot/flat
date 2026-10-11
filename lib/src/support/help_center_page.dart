import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../admin/admin_repository.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../settings/settings_widgets.dart';
import '../ui/async_view.dart';
import '../ui/skeleton.dart';
import '../ui/site_scaffold.dart';
import 'support_repository.dart';
import 'support_widgets.dart';

class HelpCenterPage extends ConsumerWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final signedIn = ref.watch(currentUidProvider) != null;
    final fees = ref.watch(feeConfigProvider).value ?? const FeeConfig();
    final buyer = '${fees.buyerPercent}';
    final seller = '${fees.sellerPercent}';

    final sections = [
      (
        l10n.buying,
        [
          (l10n.faqBuySafeQ, l10n.faqBuySafeA),
          (l10n.faqWhenTicketsQ, l10n.faqWhenTicketsA),
          (l10n.faqCancelQ, l10n.faqCancelA),
        ],
      ),
      (
        l10n.selling,
        [
          (l10n.faqFeesQ, l10n.faqFeesA(buyer, seller)),
          (l10n.faqSendTicketsQ, l10n.faqSendTicketsA),
          (l10n.faqPayoutWhenQ, l10n.faqPayoutWhenA),
        ],
      ),
    ];

    return SiteScaffold(
      title: l10n.helpCenter,
      maxWidth: SiteWidth.form,
      accountNav: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          if (signedIn) const _MyRequests(),
          for (final (title, faqs) in sections) ...[
            SettingsSectionTitle(title),
            FCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FAccordion(
                  children: [
                    for (final (q, a) in faqs)
                      FAccordionItem(
                        title: Text(q),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            a,
                            style: theme.typography.body.sm.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
          if (!signedIn) ...[
            const SizedBox(height: 24),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.muted,
                borderRadius: theme.style.borderRadius.lg,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      FLucideIcons.headset,
                      size: 40,
                      color: theme.colors.mutedForeground,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.stillNeedHelp,
                      textAlign: TextAlign.center,
                      style: theme.typography.body.md.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FButton(
                      mainAxisSize: MainAxisSize.min,
                      onPress: () => context.go('/login'),
                      child: Text(
                        l10n.signInOrUp,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The signed-in user's requests and the way to open a new one.
class _MyRequests extends ConsumerWidget {
  const _MyRequests();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final tickets = ref.watch(myTicketsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionTitle(l10n.supportMyRequests),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: AsyncView<List<SupportTicket>>(
            value: tickets,
            onRetry: () => ref.invalidate(myTicketsProvider),
            loading: const Shimmer(
              child: Column(
                spacing: 12,
                children: [
                  SkeletonBox(height: 88, radius: 12),
                  SkeletonBox(height: 88, radius: 12),
                ],
              ),
            ),
            data: (list) => list.isEmpty
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colors.muted,
                      borderRadius: theme.style.borderRadius.lg,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            FLucideIcons.messagesSquare,
                            color: theme.colors.mutedForeground,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.supportNoRequests,
                              style: theme.typography.body.sm.copyWith(
                                color: theme.colors.mutedForeground,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 8,
                    children: [
                      for (final t in list)
                        SupportTicketTile(
                          key: ValueKey(t.id),
                          ticket: t,
                          unread: t.unreadForUser,
                          onTap: () => context.push('/support/ticket/${t.id}'),
                        ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 16),
        FButton(
          prefix: const Icon(FLucideIcons.messageSquarePlus),
          onPress: () => context.push('/support/new'),
          child: Text(l10n.contactSupport, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
