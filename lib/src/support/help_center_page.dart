import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../settings/settings_widgets.dart';
import '../ui/site_scaffold.dart';

class HelpCenterPage extends ConsumerWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final signedIn = ref.watch(currentUidProvider) != null;
    final buyer = '${Fees.buyerPercent}';
    final seller = '${Fees.sellerPercent}';

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
                    onPress: () => signedIn
                        ? context.push('/support/new')
                        : context.go('/login'),
                    child: Text(
                      signedIn ? l10n.contactSupport : l10n.signInOrUp,
                    ),
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
