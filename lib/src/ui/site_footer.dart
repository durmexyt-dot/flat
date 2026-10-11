import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../brand/brand.dart';
import '../config/app_info.dart';
import '../data/repositories.dart';
import 'app_style.dart';
import 'site_scaffold.dart';

/// The website footer: brand, company pages, help and the version. Columns
/// side by side on wide screens, stacked on phones.
class SiteFooter extends ConsumerWidget {
  const SiteFooter({super.key, this.bottomInset = 0});

  /// Extra space at the bottom, e.g. so a floating button covers nothing.
  final double bottomInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final colors = theme.colors;
    final wide = isWideLayout(context);
    final signedIn = ref.watch(currentUidProvider) != null;

    final brand = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // The header's logo is the one that flies between screens.
        const HeroMode(
          enabled: false,
          child: BrandHeader(markSize: 28, wordmarkHeight: 20),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.footerClaim,
          style: theme.typography.body.sm.copyWith(
            color: colors.mutedForeground,
          ),
        ),
      ],
    );
    final company = _FooterColumn(
      title: l10n.footerCompany,
      links: [
        (l10n.infoAboutTitle, '/info/about'),
        (l10n.infoPressTitle, '/info/press'),
        (l10n.infoHowTitle, '/info/how'),
        (l10n.infoSafetyTitle, '/info/safety'),
      ],
    );
    final help = _FooterColumn(
      title: l10n.footerQuestions,
      links: [
        (l10n.helpCenter, '/support'),
        (l10n.contactSupport, signedIn ? '/support/new' : '/support'),
      ],
    );

    return Container(
      padding: wide
          ? EdgeInsets.fromLTRB(32, 32, 32, 24 + bottomInset)
          : EdgeInsets.fromLTRB(16, 28, 16, 24 + bottomInset),
      decoration: BoxDecoration(
        color: colors.muted,
        borderRadius: wide
            ? BorderRadius.circular(AppStyle.of(context).cardRadius)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: brand),
                const SizedBox(width: 32),
                Expanded(child: company),
                const SizedBox(width: 32),
                Expanded(child: help),
              ],
            )
          else ...[
            brand,
            const SizedBox(height: 24),
            company,
            const SizedBox(height: 20),
            help,
          ],
          const SizedBox(height: 24),
          const FDivider(),
          const SizedBox(height: 4),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              for (final text in [
                l10n.footerCopyright(DateTime.now().year),
                l10n.footerVersion(AppInfo.label),
              ])
                Text(
                  text,
                  style: theme.typography.body.xs.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({required this.title, required this.links});

  final String title;
  final List<(String, String)> links;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colors.foreground,
          ),
        ),
        const SizedBox(height: 6),
        for (final (label, path) in links)
          FTappable(
            onPress: () => context.push(path),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                label,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
