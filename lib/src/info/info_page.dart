import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../ui/async_view.dart';
import '../ui/site_scaffold.dart';
import 'legal_texts.dart';

/// The footer's pages: about, press, how it works and buying safely, and
/// the legal pages ([legalTopics]).
const infoTopics = ['about', 'press', 'how', 'safety', ...legalTopics];

/// A block of an info page: an optional heading with a paragraph or steps.
typedef _Block = ({String? title, String? text, List<String> steps});

_Block _text(String? title, String text) =>
    (title: title, text: text, steps: const []);

_Block _steps(String title, List<String> steps) =>
    (title: title, text: null, steps: steps);

/// A short company or help page, opened from the footer.
class InfoPage extends ConsumerWidget {
  const InfoPage({super.key, required this.topic});

  /// One of [infoTopics], e.g. "about".
  final String topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final legal = legalDoc(topic, Localizations.localeOf(context));
    final (String title, IconData icon, List<_Block> blocks)? page =
        switch (topic) {
          'about' => (
            l10n.infoAboutTitle,
            FLucideIcons.ticket,
            [
              _text(null, l10n.infoAboutIntro),
              _text(l10n.infoAboutFansTitle, l10n.infoAboutFansText),
              _text(l10n.infoAboutTrustTitle, l10n.infoAboutTrustText),
            ],
          ),
          'press' => (
            l10n.infoPressTitle,
            FLucideIcons.newspaper,
            [
              _text(null, l10n.infoPressIntro),
              _steps(l10n.infoPressFactsTitle, [
                l10n.infoPressFact1,
                l10n.infoPressFact2,
                l10n.infoPressFact3,
              ]),
              _text(l10n.infoPressContactTitle, l10n.infoPressContactText),
            ],
          ),
          'how' => (
            l10n.infoHowTitle,
            FLucideIcons.listChecks,
            [
              _steps(l10n.infoHowBuyTitle, [
                l10n.infoHowBuy1,
                l10n.infoHowBuy2,
                l10n.infoHowBuy3,
              ]),
              _steps(l10n.infoHowSellTitle, [
                l10n.sellStep1,
                l10n.sellStep2,
                l10n.sellStep3,
                l10n.sellStep4,
              ]),
            ],
          ),
          'safety' => (
            l10n.infoSafetyTitle,
            FLucideIcons.shieldCheck,
            [
              _text(null, l10n.infoSafetyIntro),
              _text(l10n.infoSafetyPaymentTitle, l10n.infoSafetyPaymentText),
              _text(l10n.infoSafetySellersTitle, l10n.infoSafetySellersText),
              _text(l10n.infoSafetySupportTitle, l10n.infoSafetySupportText),
            ],
          ),
          'imprint' || 'terms' || 'privacy' || 'cookies' when legal != null => (
            switch (topic) {
              'imprint' => l10n.legalImprintTitle,
              'terms' => l10n.legalTermsTitle,
              'privacy' => l10n.legalPrivacyTitle,
              _ => l10n.legalCookiesTitle,
            },
            switch (topic) {
              'imprint' => FLucideIcons.building2,
              'terms' => FLucideIcons.scrollText,
              'privacy' => FLucideIcons.lock,
              _ => FLucideIcons.cookie,
            },
            [
              _text(null, legal.intro),
              for (final s in legal.sections) _text(s.title, s.text),
            ],
          ),
          _ => null,
        };

    if (page == null) {
      return SiteScaffold(
        title: l10n.infoNotFound,
        body: Center(
          child: EmptyState(
            icon: FLucideIcons.fileQuestion,
            title: l10n.infoNotFound,
            message: l10n.infoNotFoundInfo,
          ),
        ),
      );
    }

    final (title, icon, blocks) = page;
    final theme = context.theme;
    final colors = theme.colors;
    final numbered = topic == 'how';
    return SiteScaffold(
      title: title,
      maxWidth: SiteWidth.form,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.muted,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: colors.foreground),
            ),
          ),
          if (legal != null) ...[
            const SizedBox(height: 12),
            Text(
              legalValidFrom(Localizations.localeOf(context)),
              style: theme.typography.body.xs.copyWith(
                color: colors.mutedForeground,
              ),
            ),
          ],
          for (final b in blocks) ...[
            const SizedBox(height: 20),
            if (b.title != null) ...[
              Text(
                b.title!,
                style: theme.typography.body.lg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.foreground,
                ),
              ),
              const SizedBox(height: 6),
            ],
            if (b.text != null)
              Text(
                b.text!,
                style: theme.typography.body.md.copyWith(
                  color: b.title == null
                      ? colors.foreground
                      : colors.mutedForeground,
                  height: 1.5,
                ),
              ),
            for (final (i, step) in b.steps.indexed)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.muted,
                        shape: BoxShape.circle,
                      ),
                      child: numbered
                          ? Text(
                              '${i + 1}',
                              style: theme.typography.body.xs.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colors.foreground,
                              ),
                            )
                          : Icon(
                              FLucideIcons.check,
                              size: 14,
                              color: colors.foreground,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step,
                        style: theme.typography.body.md.copyWith(
                          color: colors.mutedForeground,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: FButton(
              variant: FButtonVariant.outline,
              mainAxisSize: MainAxisSize.min,
              prefix: const Icon(FLucideIcons.lifeBuoy),
              onPress: () => context.push('/support'),
              child: Text(l10n.helpCenter, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }
}

/// "I accept the terms of use and the privacy policy" with both names as
/// links to their pages. [template] gets the two link texts.
class LegalLinksText extends StatelessWidget {
  const LegalLinksText({
    super.key,
    required this.template,
    this.textAlign = TextAlign.start,
  });

  final String Function(String terms, String privacy) template;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final style = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );
    const terms = '\u0001', privacy = '\u0002';
    final raw = template(terms, privacy);

    InlineSpan link(String text, String path) => WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: FTappable(
        onPress: () => context.push(path),
        child: Text(
          text,
          style: style.copyWith(
            color: theme.colors.foreground,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );

    final spans = <InlineSpan>[];
    var start = 0;
    for (final m in RegExp('[$terms$privacy]').allMatches(raw)) {
      if (m.start > start) {
        spans.add(TextSpan(text: raw.substring(start, m.start)));
      }
      spans.add(
        m[0] == terms
            ? link(l10n.legalTermsLink, '/info/terms')
            : link(l10n.legalPrivacyLink, '/info/privacy'),
      );
      start = m.end;
    }
    if (start < raw.length) spans.add(TextSpan(text: raw.substring(start)));
    return Text.rich(
      TextSpan(style: style, children: spans),
      textAlign: textAlign,
    );
  }
}
