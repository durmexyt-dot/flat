import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'locale_controller.dart';

/// App bar action for switching the UI language.
class LanguageMenu extends ConsumerWidget {
  const LanguageMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider);

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      tooltip: AppLocalizations.of(context).language,
      initialValue: current.languageCode,
      onSelected: (code) =>
          ref.read(localeProvider.notifier).setLocale(Locale(code)),
      itemBuilder: (context) => [
        for (final entry in languageNames.entries)
          PopupMenuItem(value: entry.key, child: Text(entry.value)),
      ],
    );
  }
}
