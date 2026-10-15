import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_widgets.dart';
import '../location/cities.dart';
import '../location/location_controller.dart';
import '../ui/app_style.dart';
import '../ui/snack.dart';
import '../ui/tokens.dart';

/// A sheet to choose the home page's city: search, the device location or
/// none.
Future<void> showCityPicker(BuildContext context) => showFSheet<void>(
  context: context,
  side: FLayout.btt,
  mainAxisMaxRatio: 0.85,
  constraints: const BoxConstraints(maxWidth: 640),
  builder: (_) => const _CityPickerSheet(),
);

class _CityPickerSheet extends ConsumerStatefulWidget {
  const _CityPickerSheet();

  @override
  ConsumerState<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends ConsumerState<_CityPickerSheet> {
  final _search = TextEditingController();
  var _locating = false;

  @override
  void initState() {
    super.initState();
    _search.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _search
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _choose(String name) {
    if (name.trim().isEmpty) return;
    ref.read(chosenCityProvider.notifier).setCity(name);
    Navigator.pop(context);
  }

  Future<void> _useLocation() async {
    final unavailable = AppLocalizations.of(context)
        .homeCityLocationUnavailable;
    setState(() => _locating = true);
    final ok = await ref.read(chosenCityProvider.notifier).useMyLocation();
    if (!mounted) return;
    setState(() => _locating = false);
    if (ok) {
      Navigator.pop(context);
    } else {
      showSnack(unavailable);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final chosen = ref.watch(chosenCityProvider);
    final query = _search.text.trim();
    final key = cityKey(query);
    final suggestions = [
      for (final c in ref.watch(citySuggestionsProvider))
        if (key.isEmpty || cityKey(c).contains(key)) c,
    ];
    final exact = suggestions.any((c) => sameCity(c, query));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background,
        border: Border(top: BorderSide(color: theme.colors.border)),
        borderRadius: Radii.sheetTop,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Space.xl,
            Space.xl,
            Space.xl,
            Space.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.homeCityPick,
                style: theme.typography.body.lg.copyWith(
                  fontWeight: FontWeights.semibold,
                  color: theme.colors.foreground,
                ),
              ),
              const SizedBox(height: Space.lg),
              FTextField(
                control: FTextFieldControl.managed(controller: _search),
                hint: l10n.homeCitySearch,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.words,
                prefixBuilder: (context, style, variants) =>
                    fieldIcon(FLucideIcons.search),
                clearable: (value) => value.text.isNotEmpty,
                onSubmit: (value) {
                  final match = suggestions.where((c) => sameCity(c, value));
                  _choose(match.isEmpty ? value : match.first);
                },
              ),
              const SizedBox(height: Space.lg),
              Row(
                spacing: Space.md,
                children: [
                  Expanded(
                    child: FButton(
                      variant: FButtonVariant.outline,
                      onPress: _locating ? null : _useLocation,
                      prefix: _locating
                          ? const FCircularProgress.loader()
                          : const Icon(FLucideIcons.locateFixed),
                      child: Text(
                        l10n.homeCityUseLocation,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (chosen != null)
                    FButton(
                      variant: FButtonVariant.ghost,
                      mainAxisSize: MainAxisSize.min,
                      onPress: () {
                        ref.read(chosenCityProvider.notifier).clear();
                        Navigator.pop(context);
                      },
                      child: Text(
                        l10n.homeCityClear,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Space.md),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: Space.xs),
                  children: [
                    if (query.isNotEmpty && !exact)
                      _CityTile(
                        icon: FLucideIcons.mapPinPlus,
                        name: l10n.homeCityUseTyped(query),
                        onTap: () => _choose(query),
                      ),
                    for (final c in suggestions)
                      _CityTile(
                        name: c,
                        selected: chosen != null && sameCity(c, chosen.name),
                        onTap: () => _choose(c),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CityTile extends StatelessWidget {
  const _CityTile({
    required this.name,
    required this.onTap,
    this.icon = FLucideIcons.mapPin,
    this.selected = false,
  });

  final String name;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    return FTappable(
      onPress: onTap,
      child: AnimatedContainer(
        duration: Motion.quick,
        padding: const EdgeInsets.symmetric(
          horizontal: Space.md,
          vertical: Space.lg,
        ),
        decoration: BoxDecoration(
          color: selected ? colors.muted : null,
          borderRadius: BorderRadius.circular(
            AppStyle.of(context).controlRadius,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: IconSizes.md, color: colors.mutedForeground),
            const SizedBox(width: Space.lg),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.body.md.copyWith(
                  color: colors.foreground,
                  fontWeight: selected
                      ? FontWeights.semibold
                      : FontWeights.regular,
                ),
              ),
            ),
            if (selected)
              Icon(
                FLucideIcons.check,
                size: IconSizes.md,
                color: colors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
