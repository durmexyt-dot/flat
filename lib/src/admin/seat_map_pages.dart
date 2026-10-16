import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../data/events_repository.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../data/seat_map_repository.dart';
import '../events/seat_map_view.dart';
import '../settings/settings_widgets.dart';
import '../ui/app_dialog.dart';
import '../ui/async_view.dart';
import '../ui/images.dart';
import '../ui/segmented.dart';
import '../ui/site_scaffold.dart';
import '../ui/skeleton.dart';
import '../ui/snack.dart';
import '../ui/tokens.dart';
import 'admin_page.dart';

/// For the team: the venues of all events, and whether each has a seat map.
class SeatMapsPage extends ConsumerWidget {
  const SeatMapsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SiteScaffold(
      title: l10n.adminSeatMaps,
      accountNav: true,
      body: AdminGate(
        staff: true,
        builder: (context) {
          final maps = ref.watch(seatMapsProvider);
          final events = ref.watch(eventsProvider).value ?? const <Event>[];
          return AsyncView<List<SeatMap>>(
            value: maps,
            onRetry: () => ref.invalidate(seatMapsProvider),
            loading: const SkeletonTicketList(count: 3),
            data: (maps) {
              final byId = {for (final m in maps) m.id: m};
              // Every venue once: those with events, then maps without.
              final venues = <String, (String, String)>{};
              for (final e in events) {
                venues.putIfAbsent(
                  seatMapId(e.info.venue, e.info.city),
                  () => (e.info.venue, e.info.city),
                );
              }
              for (final m in maps) {
                venues.putIfAbsent(m.id, () => (m.venue, m.city));
              }
              final ids = venues.keys.toList()
                ..sort((a, b) => venues[a]!.$1.compareTo(venues[b]!.$1));
              return ListView(
                padding: Insets.page,
                children: [
                  SettingsSectionTitle(l10n.seatMapVenues),
                  Text(l10n.adminSeatMapsInfo, style: context.theme.mutedText),
                  const SizedBox(height: Space.lg),
                  SettingsGroup(
                    children: [
                      for (final id in ids)
                        SettingsLinkTile(
                          icon: byId[id] == null
                              ? FLucideIcons.mapPinOff
                              : FLucideIcons.map,
                          title: '${venues[id]!.$1} · ${venues[id]!.$2}',
                          subtitle: byId[id] == null
                              ? l10n.seatMapNone
                              : l10n.seatMapSectionsCount(
                                  byId[id]!.sections.length,
                                ),
                          onTap: () => context.push(
                            Uri(
                              path: '/admin/seatmaps/$id',
                              queryParameters: {
                                'venue': venues[id]!.$1,
                                'city': venues[id]!.$2,
                              },
                            ).toString(),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// For the team: draws a venue's seat map. Drag to add a section (or the
/// stage), drag a selected section to move it, tap one to rename or
/// delete it.
class SeatMapEditorPage extends ConsumerWidget {
  const SeatMapEditorPage({
    super.key,
    required this.id,
    required this.venue,
    required this.city,
  });

  final String id;
  final String venue;
  final String city;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SiteScaffold(
      title: l10n.seatMapTitle,
      accountNav: true,
      maxWidth: SiteWidth.detail,
      body: AdminGate(
        staff: true,
        builder: (context) => AsyncView<SeatMap?>(
          value: ref.watch(seatMapProvider(id)),
          onRetry: () => ref.invalidate(seatMapProvider(id)),
          loading: const SkeletonTicketList(count: 2),
          data: (map) => _Editor(
            initial:
                map ?? SeatMap(id: id, venue: venue.trim(), city: city.trim()),
            exists: map != null,
          ),
        ),
      ),
    );
  }
}

enum _Tool { section, stage }

class _Editor extends ConsumerStatefulWidget {
  const _Editor({required this.initial, required this.exists});

  final SeatMap initial;
  final bool exists;

  @override
  ConsumerState<_Editor> createState() => _EditorState();
}

class _EditorState extends ConsumerState<_Editor> {
  late SeatMap _map = widget.initial;
  _Tool _tool = _Tool.section;

  /// The section being edited, by index.
  int? _selected;
  final _name = TextEditingController();

  /// While dragging: the rectangle being drawn, or the move's last point.
  MapRect? _draft;
  Offset? _start;
  Offset? _moveFrom;

  String? _newImage;
  Uint8List? _newBytes;
  bool _removeImage = false;
  bool _encoding = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _select(int? i) => setState(() {
    _selected = i;
    _name.text = i == null ? '' : _map.sections[i].name;
  });

  void _replaceSection(int i, SeatSection s) {
    final list = [..._map.sections]..[i] = s;
    _map = _map.copyWith(sections: list);
  }

  Offset _fraction(Offset local, Size size) => Offset(
    (local.dx / size.width).clamp(0.0, 1.0),
    (local.dy / size.height).clamp(0.0, 1.0),
  );

  int? _hit(Offset f) {
    for (var i = _map.sections.length - 1; i >= 0; i--) {
      if (_map.sections[i].rect.contains(f.dx, f.dy)) return i;
    }
    return null;
  }

  void _onStart(Offset f) {
    final i = _selected;
    if (_tool == _Tool.section &&
        i != null &&
        _map.sections[i].rect.contains(f.dx, f.dy)) {
      _moveFrom = f;
    } else {
      _start = f;
    }
  }

  void _onUpdate(Offset f) => setState(() {
    if (_moveFrom case final from?) {
      final i = _selected!;
      final r = _map.sections[i].rect;
      final d = f - from;
      _replaceSection(
        i,
        _map.sections[i].copyWith(
          rect: MapRect(
            (r.x + d.dx).clamp(0.0, 1 - r.w),
            (r.y + d.dy).clamp(0.0, 1 - r.h),
            r.w,
            r.h,
          ),
        ),
      );
      _moveFrom = f;
    } else if (_start case final s?) {
      _draft = MapRect.normalized(s.dx, s.dy, f.dx - s.dx, f.dy - s.dy);
    }
  });

  void _onEnd({required bool tap, Offset? at}) {
    final l10n = AppLocalizations.of(context);
    final draft = _draft;
    setState(() {
      _draft = null;
      _start = null;
      _moveFrom = null;
    });
    if (tap && at != null) {
      _select(_hit(at));
      return;
    }
    if (draft == null) return;
    setState(() {
      if (_tool == _Tool.stage) {
        _map = _map.copyWith(stage: () => draft);
        return;
      }
      if (_map.sections.length >= SeatMap.maxSections) return;
      final name = l10n.seatMapSectionDefault(_map.sections.length + 1);
      _map = _map.copyWith(
        sections: [
          ..._map.sections,
          SeatSection(name: name, rect: draft),
        ],
      );
    });
    _select(_map.sections.length - 1);
  }

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context);
    final bytes = await pickImageBytes();
    if (bytes == null || !mounted) return;
    setState(() => _encoding = true);
    try {
      final (data, ratio) = await compute(encodeSeatMapImage, bytes);
      if (!mounted) return;
      setState(() {
        _newImage = data;
        _newBytes = base64Decode(data);
        _removeImage = false;
        _map = _map.copyWith(aspectRatio: ratio);
      });
    } catch (_) {
      showSnack(l10n.eventsPictureError);
    } finally {
      if (mounted) setState(() => _encoding = false);
    }
  }

  void _dropImage() => setState(() {
    _newImage = null;
    _newBytes = null;
    _removeImage = true;
    _map = _map.copyWith(aspectRatio: SeatMap.defaultAspectRatio);
  });

  bool get _hasPicture => _newBytes != null || (!_removeImage && _map.hasImage);

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final names = [for (final s in _map.sections) searchKey(s.name)];
    if (names.any((n) => n.isEmpty)) {
      showSnack(l10n.required);
      return;
    }
    if (names.toSet().length != names.length) {
      showSnack(l10n.seatMapDuplicate);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(seatMapRepositoryProvider)
          .saveSeatMap(_map, imageBase64: _newImage, removeImage: _removeImage);
      showSnack(l10n.saved);
      if (mounted) {
        final router = GoRouter.of(context);
        router.canPop() ? router.pop() : router.go('/admin/seatmaps');
      }
    } catch (_) {
      showSnack(l10n.saveError);
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showAppDialog<bool>(
      context: context,
      title: l10n.seatMapDelete,
      body: Text(l10n.seatMapDeleteInfo),
      actions: (ctx) => [
        FButton(
          variant: FButtonVariant.outline,
          onPress: () => Navigator.pop(ctx, false),
          child: Flexible(
            child: Text(l10n.cancel, overflow: TextOverflow.ellipsis),
          ),
        ),
        FButton(
          variant: FButtonVariant.destructive,
          onPress: () => Navigator.pop(ctx, true),
          child: Flexible(
            child: Text(l10n.seatMapDelete, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
    if (ok != true || !mounted) return;
    final router = GoRouter.of(context);
    try {
      await ref.read(seatMapRepositoryProvider).deleteSeatMap(_map.id);
      router.canPop() ? router.pop() : router.go('/admin/seatmaps');
    } catch (_) {
      showSnack(l10n.saveError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final selected = _selected;

    // Sections sellers typed that the map doesn't have yet.
    final listings = ref.watch(activeListingsProvider).value ?? const [];
    final missing = <String, String>{};
    for (final l in listings) {
      if (seatMapId(l.event.venue, l.event.city) != _map.id) continue;
      if (l.section.trim().isEmpty || _map.sectionOf(l.section) != null) {
        continue;
      }
      missing.putIfAbsent(searchKey(l.section), () => l.section.trim());
    }

    final shown = _draft == null
        ? _map
        : _tool == _Tool.stage
        ? _map.copyWith(stage: () => _draft)
        : _map.copyWith(
            sections: [
              ..._map.sections,
              SeatSection(name: '', rect: _draft!),
            ],
          );

    return ListView(
      padding: Insets.page,
      children: [
        SettingsSectionTitle('${_map.venue} · ${_map.city}'),
        Text(l10n.seatMapDrawHint, style: theme.mutedText),
        const SizedBox(height: Space.lg),
        Segmented<_Tool>(
          values: _Tool.values,
          selected: _tool,
          label: (t) => switch (t) {
            _Tool.section => l10n.seatMapDrawSection,
            _Tool.stage => l10n.seatMapStage,
          },
          icon: (t) => switch (t) {
            _Tool.section => FLucideIcons.squareDashed,
            _Tool.stage => FLucideIcons.theater,
          },
          onChanged: (t) => setState(() => _tool = t),
        ),
        const SizedBox(height: Space.lg),
        SeatMapView(
          map: shown,
          allActive: true,
          picture: _removeImage ? null : _newBytes,
          selected: selected == null ? null : _map.sections[selected].name,
          overlay: (size) => RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            gestures: {
              _EagerPan: GestureRecognizerFactoryWithHandlers<_EagerPan>(
                _EagerPan.new,
                (r) {
                  Offset? down;
                  var moved = false;
                  r
                    ..onStart = (d) {
                      down = _fraction(d.localPosition, size);
                      moved = false;
                      _onStart(down!);
                    }
                    ..onUpdate = (d) {
                      moved = true;
                      _onUpdate(_fraction(d.localPosition, size));
                    }
                    ..onEnd = (_) => _onEnd(tap: !moved, at: down);
                },
              ),
            },
          ),
        ),
        if (missing.isNotEmpty) ...[
          const SizedBox(height: Space.lg),
          FAlert(
            icon: const Icon(FLucideIcons.info),
            title: Text(l10n.seatMapUnmatched(missing.values.join(', '))),
          ),
        ],
        AnimatedSize(
          duration: Motion.normal,
          alignment: Alignment.topCenter,
          child: selected == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: Space.lg),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: FTextField(
                          control: FTextFieldControl.managed(
                            controller: _name,
                            onChange: (v) => setState(
                              () => _replaceSection(
                                selected,
                                _map.sections[selected].copyWith(name: v.text),
                              ),
                            ),
                          ),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(40),
                          ],
                          label: Text(l10n.seatMapSectionName),
                        ),
                      ),
                      const SizedBox(width: Space.md),
                      FButton.icon(
                        variant: FButtonVariant.outline,
                        semanticsLabel: l10n.seatMapDeleteSection,
                        onPress: () {
                          setState(() {
                            _map = _map.copyWith(
                              sections: [..._map.sections]..removeAt(selected),
                            );
                          });
                          _select(null);
                        },
                        child: const Icon(FLucideIcons.trash2),
                      ),
                    ],
                  ),
                ),
        ),
        if (_map.stage != null) ...[
          const SizedBox(height: Space.lg),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FButton(
              variant: FButtonVariant.ghost,
              size: FButtonSizeVariant.sm,
              mainAxisSize: MainAxisSize.min,
              prefix: const Icon(FLucideIcons.x),
              onPress: () =>
                  setState(() => _map = _map.copyWith(stage: () => null)),
              child: Text(l10n.seatMapRemoveStage),
            ),
          ),
        ],
        SettingsSectionTitle(l10n.seatMapPicture),
        Text(l10n.seatMapPictureHint, style: theme.mutedText),
        const SizedBox(height: Space.md),
        Wrap(
          spacing: Space.md,
          runSpacing: Space.md,
          children: [
            FButton(
              variant: FButtonVariant.outline,
              mainAxisSize: MainAxisSize.min,
              prefix: const Icon(FLucideIcons.imagePlus),
              onPress: _encoding || _saving ? null : _pickImage,
              child: Text(
                _hasPicture
                    ? l10n.eventsPictureReplace
                    : l10n.eventsPicturePick,
              ),
            ),
            if (_hasPicture)
              FButton(
                variant: FButtonVariant.ghost,
                mainAxisSize: MainAxisSize.min,
                onPress: _saving ? null : _dropImage,
                child: Text(l10n.eventsPictureRemove),
              ),
          ],
        ),
        const SizedBox(height: Space.x3l),
        FButton(
          onPress: _saving || _encoding ? null : _save,
          child: Text(l10n.save),
        ),
        if (widget.exists) ...[
          const SizedBox(height: Space.md),
          FButton(
            variant: FButtonVariant.ghost,
            onPress: _saving ? null : _delete,
            child: Text(l10n.seatMapDelete),
          ),
        ],
      ],
    );
  }
}

/// A pan that wins at once, so drawing on the map doesn't scroll the page.
class _EagerPan extends PanGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}
