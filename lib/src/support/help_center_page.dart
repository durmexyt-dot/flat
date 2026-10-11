import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final theme = Theme.of(context);
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          for (final (title, faqs) in sections) ...[
            SettingsSectionTitle(title),
            SettingsGroup(
              children: [
                for (final (q, a) in faqs)
                  ExpansionTile(
                    shape: const RoundedRectangleBorder(),
                    collapsedShape: const RoundedRectangleBorder(),
                    title: Text(q),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    expandedAlignment: Alignment.centerLeft,
                    children: [
                      Text(
                        a,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          Card.filled(
            margin: EdgeInsets.zero,
            color: theme.colorScheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 40,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.stillNeedHelp, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => signedIn
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
