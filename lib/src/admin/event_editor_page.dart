import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_repository.dart';
import '../auth/auth_widgets.dart';
import '../data/events_repository.dart';
import '../data/repositories.dart';
import '../data/models.dart';
import '../events/event_image.dart';
import '../events/event_status_badge.dart';
import '../events/genres.dart';
import '../market/labels.dart';
import '../settings/settings_widgets.dart';
import '../ui/app_dialog.dart';
import '../ui/app_style.dart';
import '../ui/async_view.dart';
import '../ui/date_field.dart';
import '../ui/images.dart';
import '../ui/site_scaffold.dart';
import '../ui/skeleton.dart';
import '../ui/snack.dart';
import 'admin_repository.dart';
import 'events_admin_page.dart';

/// Creates ([id] null) or edits an event.
///
/// The team (admins and support accounts) creates confirmed events and
/// checks, corrects, confirms or hides any event. Signed-in users add
/// events on `/events/new`: they stay unconfirmed until the team checks
/// them.
class EventEditorPage extends ConsumerWidget {
  const EventEditorPage({super.key, this.id, this.forSale = false});

  /// Opened from the sell form: after saving, go on to sell tickets for
  /// the new event.
  final bool forSale;

  /// Null for a new event.
  final String? id;

  /// Opened as part of the team's pages (`/admin/...`).
  bool _teamRoute(BuildContext context) {
    try {
      return GoRouterState.of(context).uri.path.startsWith('/admin');
    } catch (_) {
      return id != null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final role = ref.watch(staffRoleProvider);
    final isStaff = ref.watch(isStaffProvider);
    final teamRoute = id != null || _teamRoute(context);
    final title = id != null
        ? l10n.eventsEdit
        : isStaff
        ? l10n.eventsNew
        : l10n.eventsUserNewTitle;

    final Widget body;
    if (!role.hasValue && !role.hasError) {
      body = const SkeletonTicketList(count: 3);
    } else if (!isStaff && teamRoute) {
      body = const EventsNoAccess();
    } else if (id == null) {
      body = _EventForm(
        event: null,
        team: isStaff,
        forSale: forSale,
        teamRoute: teamRoute,
      );
    } else {
      body = AsyncView<Event?>(
        value: ref.watch(eventProvider(id!)),
        onRetry: () => ref.invalidate(eventProvider(id!)),
        loading: const SkeletonTicketList(count: 3),
        data: (event) => event == null
            ? Center(
                child: SingleChildScrollView(
                  child: EmptyState(
                    icon: FLucideIcons.calendarX,
                    title: l10n.eventsNotFound,
                  ),
                ),
              )
            : _EventForm(
                key: ValueKey(event.id),
                event: event,
                team: true,
                forSale: false,
                teamRoute: true,
              ),
      );
    }
    return SiteScaffold(title: title, maxWidth: SiteWidth.form, body: body);
  }
}

class _EventForm extends ConsumerStatefulWidget {
  const _EventForm({
    super.key,
    required this.event,
    required this.team,
    required this.forSale,
    required this.teamRoute,
  });

  /// The event as it was when the form opened; null for a new one.
  final Event? event;

  /// Filled in by an admin or support account.
  final bool team;

  /// After adding, go on to sell tickets for the event.
  final bool forSale;

  /// Opened from the team's event list: go back there after saving.
  final bool teamRoute;

  @override
  ConsumerState<_EventForm> createState() => _EventFormState();
}

class _EventFormState extends ConsumerState<_EventForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.event?.info.name);
  late final _venue = TextEditingController(text: widget.event?.info.venue);
  late final _city = TextEditingController(text: widget.event?.info.city);
  late DateTime? _date = widget.event?.info.date;
  late EventCategory _category =
      widget.event?.info.category ?? EventCategory.concerts;
  late String _genre = widget.event?.genre ?? '';
  String? _dateError;

  /// A newly chosen picture (base64 JPEG) and its bytes for the preview.
  String? _newImage;
  Uint8List? _newBytes;
  bool _removeImage = false;
  bool _encoding = false;
  bool _saving = false;

  bool get _isNew => widget.event == null;

  @override
  void dispose() {
    for (final c in [_name, _venue, _city]) {
      c.dispose();
    }
    super.dispose();
  }

  /// The live event (e.g. its status), falling back to the opened one.
  Event? get _live {
    final e = widget.event;
    if (e == null) return null;
    return ref.watch(eventProvider(e.id)).value ?? e;
  }

  bool get _hasPicture =>
      _newBytes != null || (!_removeImage && widget.event?.hasImage == true);

  Future<void> _pickDate() async {
    final date = await pickDateTime(context, initial: _date);
    if (date == null || !mounted) return;
    setState(() {
      _date = date;
      _dateError = null;
    });
  }

  void _setCategory(EventCategory c) => setState(() {
    _category = c;
    // A subcategory of another type no longer fits.
    if (_genre.isNotEmpty && categoryOfGenre(_genre) != c) _genre = '';
  });

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context);
    final bytes = await pickImageBytes();
    if (bytes == null || !mounted) return;
    setState(() => _encoding = true);
    try {
      final encoded = await compute(encodeEventImage, bytes);
      if (!mounted) return;
      setState(() {
        _newImage = encoded;
        _newBytes = base64Decode(encoded);
        _removeImage = false;
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
  });

  String? _checkDate(AppLocalizations l10n) {
    if (_date == null) return l10n.required;
    final changed = _isNew || _date != widget.event!.info.date;
    if (changed && !_date!.isAfter(DateTime.now())) return l10n.dateInPast;
    // The rules take users' events up to two years ahead.
    if (!widget.team &&
        _date!.isAfter(DateTime.now().add(const Duration(days: 729)))) {
      return l10n.eventsUserDateTooFar;
    }
    return null;
  }

  /// Users need a confirmed email address to add events (the rules check
  /// it too). The link may have been opened meanwhile: check again first.
  Future<bool> _emailVerified() async {
    if (ref.read(authStateProvider).value?.emailVerified == true) return true;
    final auth = ref.read(authRepositoryProvider);
    await auth.reloadUser();
    return auth.currentUser?.emailVerified == true;
  }

  /// Saves the form; the team may [confirm] the event in the same step.
  Future<void> _save({bool confirm = false}) async {
    final l10n = AppLocalizations.of(context);
    final dateError = _checkDate(l10n);
    setState(() => _dateError = dateError);
    if (!_formKey.currentState!.validate() || dateError != null || _saving) {
      return;
    }
    final router = GoRouter.of(context);
    final info = EventInfo(
      name: _name.text.trim(),
      venue: _venue.text.trim(),
      city: _city.text.trim(),
      date: _date!,
      category: _category,
    );
    final repo = ref.read(eventRepositoryProvider);
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    setState(() => _saving = true);
    if (!widget.team && !await _emailVerified()) {
      showSnack(l10n.eventsUserVerifyFirst);
      if (mounted) setState(() => _saving = false);
      return;
    }
    try {
      if (_isNew) {
        final id = await repo.createEvent(
          info,
          createdBy: uid,
          byStaff: widget.team,
          genre: _genre,
          imageBase64: _newImage,
        );
        showSnack(widget.team ? l10n.eventsCreated : l10n.eventsUserAdded);
        if (widget.forSale) {
          router.pushReplacement('/sell?event=$id');
          return;
        }
        if (!widget.teamRoute) {
          router.pushReplacement('/event/$id');
          return;
        }
      } else {
        final event = widget.event!;
        await repo.updateEvent(
          event.id,
          info,
          genre: _genre,
          imageBase64: _newImage,
          removeImage: _removeImage && event.hasImage,
        );
        if (confirm) {
          await repo.setStatus(event.id, EventStatus.confirmed);
        }
        showSnack(confirm ? l10n.eventsReviewConfirmedToast : l10n.saved);
      }
      if (router.canPop()) {
        router.pop();
      } else {
        router.go('/admin/events');
      }
    } catch (_) {
      showSnack(l10n.saveError);
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _toggleHidden(Event event) async {
    final l10n = AppLocalizations.of(context);
    final hide = !event.hidden;
    final label = hide ? l10n.eventsHide : l10n.eventsShow;
    final ok = await showAppDialog<bool>(
      context: context,
      title: label,
      body: Text(hide ? l10n.eventsHideConfirm : l10n.eventsShowConfirm),
      actions: (ctx) => [
        FButton(
          variant: FButtonVariant.outline,
          onPress: () => Navigator.pop(ctx, false),
          child: Flexible(
            child: Text(l10n.cancel, overflow: TextOverflow.ellipsis),
          ),
        ),
        FButton(
          variant: hide ? FButtonVariant.destructive : FButtonVariant.primary,
          onPress: () => Navigator.pop(ctx, true),
          child: Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ),
      ],
    );
    if (ok != true) return;
    try {
      // Shown again means checked: confirmed.
      await ref
          .read(eventRepositoryProvider)
          .setStatus(
            event.id,
            hide ? EventStatus.hidden : EventStatus.confirmed,
          );
      showSnack(hide ? l10n.eventsHiddenToast : l10n.eventsShownToast);
    } catch (_) {
      showSnack(l10n.saveError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final live = _live;
    final user = ref.watch(authStateProvider).value;
    final uid = user?.uid;
    final team = widget.team;
    String? text(String? v, int min) => (v == null || v.trim().isEmpty)
        ? l10n.required
        : v.trim().length < min
        ? l10n.eventsNameTooShort
        : null;
    final muted = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
    );

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!team && user != null && !user.emailVerified) ...[
              const SizedBox(height: 8),
              FAlert(
                icon: const Icon(FLucideIcons.mailWarning),
                title: Text(l10n.eventsUserVerifyFirst),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FButton(
                      variant: FButtonVariant.outline,
                      size: FButtonSizeVariant.sm,
                      mainAxisSize: MainAxisSize.min,
                      onPress: () => context.push('/settings/privacy'),
                      child: Text(
                        l10n.verifyNow,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (!team) ...[
              const SizedBox(height: 8),
              FAlert(
                icon: const Icon(FLucideIcons.info),
                title: Text(l10n.eventsUserInfoTitle),
                subtitle: Text(l10n.eventsUserInfo),
              ),
            ],
            if (live != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  EventStatusBadge(live),
                  if (live.createdBy.isNotEmpty)
                    Text(
                      l10n.eventsReviewAddedBy(
                        live.createdBy == uid
                            ? l10n.eventsReviewAddedByYou
                            : l10n.eventsReviewAddedByUser,
                      ),
                      style: muted,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              FAlert(
                icon: const Icon(FLucideIcons.info),
                title: Text(l10n.eventsListingsKeepData),
              ),
            ],
            SettingsSectionTitle(l10n.eventsPicture),
            _picture(context),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FButton(
                  variant: FButtonVariant.outline,
                  size: FButtonSizeVariant.sm,
                  mainAxisSize: MainAxisSize.min,
                  onPress: _encoding || _saving ? null : _pickImage,
                  prefix: const Icon(FLucideIcons.imageUp),
                  child: Text(
                    _hasPicture
                        ? l10n.eventsPictureReplace
                        : l10n.eventsPicturePick,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_hasPicture)
                  FButton(
                    variant: FButtonVariant.ghost,
                    size: FButtonSizeVariant.sm,
                    mainAxisSize: MainAxisSize.min,
                    onPress: _encoding || _saving ? null : _dropImage,
                    prefix: const Icon(FLucideIcons.trash2),
                    child: Text(
                      l10n.eventsPictureRemove,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              team
                  ? l10n.eventsPictureHint
                  : '${l10n.eventsPictureHint} (${l10n.optional})',
              style: muted,
            ),
            SettingsSectionTitle(l10n.event),
            FTextFormField(
              control: FTextFieldControl.managed(controller: _name),
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
              label: Text(l10n.eventName),
              prefixBuilder: (context, style, variants) =>
                  fieldIcon(FLucideIcons.ticket),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (v) => text(v, 2),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FTextFormField(
                    control: FTextFieldControl.managed(controller: _venue),
                    inputFormatters: [LengthLimitingTextInputFormatter(100)],
                    label: Text(l10n.venue),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    validator: (v) => text(v, 1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FTextFormField(
                    control: FTextFieldControl.managed(controller: _city),
                    inputFormatters: [LengthLimitingTextInputFormatter(60)],
                    label: Text(l10n.city),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    validator: (v) => text(v, 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DateTimeField(date: _date, error: _dateError, onTap: _pickDate),
            SettingsSectionTitle(l10n.category),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in EventCategory.values)
                  FButton(
                    size: FButtonSizeVariant.sm,
                    mainAxisSize: MainAxisSize.min,
                    variant: _category == c
                        ? FButtonVariant.primary
                        : FButtonVariant.outline,
                    prefix: Icon(categoryIcon(c)),
                    onPress: () => _setCategory(c),
                    child: Text(
                      categoryName(l10n, c),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            SettingsSectionTitle(l10n.genreLabel),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              alignment: Alignment.topCenter,
              child: Wrap(
                key: ValueKey(_category),
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final g in ['', ...?eventGenres[_category]])
                    FButton(
                      size: FButtonSizeVariant.sm,
                      mainAxisSize: MainAxisSize.min,
                      variant: _genre == g
                          ? FButtonVariant.secondary
                          : FButtonVariant.outline,
                      prefix: _genre == g
                          ? const Icon(FLucideIcons.check)
                          : null,
                      onPress: () => setState(() => _genre = g),
                      child: Text(
                        g.isEmpty ? l10n.genreNone : genreName(l10n, g),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SubmitButton(
              label: team ? l10n.save : l10n.eventsUserNewTitle,
              loading: _saving,
              onPressed: () {
                if (!_encoding) _save();
              },
            ),
            if (live != null && live.pending) ...[
              const SizedBox(height: 12),
              FButton(
                variant: FButtonVariant.secondary,
                onPress: _saving || _encoding
                    ? null
                    : () => _save(confirm: true),
                prefix: const Icon(FLucideIcons.badgeCheck),
                child: Text(
                  l10n.eventsReviewConfirm,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            if (live != null) ...[
              const SizedBox(height: 12),
              FButton(
                variant: live.hidden
                    ? FButtonVariant.outline
                    : FButtonVariant.ghost,
                onPress: _saving ? null : () => _toggleHidden(live),
                prefix: Icon(
                  live.hidden ? FLucideIcons.eye : FLucideIcons.eyeOff,
                ),
                child: Text(
                  live.hidden ? l10n.eventsShow : l10n.eventsHide,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 16:9 preview of the picture the event will have.
  Widget _picture(BuildContext context) {
    final radius = BorderRadius.circular(AppStyle.of(context).cardRadius);
    final event = widget.event;
    final Widget preview = _newBytes != null
        ? AspectRatio(
            key: ValueKey(_newBytes.hashCode),
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: radius,
              child: Image.memory(_newBytes!, fit: BoxFit.cover),
            ),
          )
        : event != null && event.hasImage && !_removeImage
        ? EventImage(
            key: const ValueKey('current'),
            event: event,
            borderRadius: radius,
          )
        : AspectRatio(
            key: ValueKey('none-$_category'),
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: radius,
              child: EventImagePlaceholder(category: _category, iconSize: 48),
            ),
          );
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: preview,
        ),
        if (_encoding)
          const Positioned.fill(child: Center(child: FCircularProgress())),
      ],
    );
  }
}
