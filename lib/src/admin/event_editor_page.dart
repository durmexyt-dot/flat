import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_widgets.dart';
import '../data/events_repository.dart';
import '../data/repositories.dart';
import '../data/models.dart';
import '../events/event_image.dart';
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

/// Creates ([id] null) or edits an event. Admins only.
class EventEditorPage extends ConsumerWidget {
  const EventEditorPage({super.key, this.id, this.forSale = false});

  /// Opened from the sell form: after saving, go on to sell tickets for
  /// the new event.
  final bool forSale;

  /// Null for a new event.
  final String? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final role = ref.watch(staffRoleProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final title = id == null ? l10n.eventsNew : l10n.eventsEdit;

    final Widget body;
    if (!role.hasValue && !role.hasError) {
      body = const SkeletonTicketList(count: 3);
    } else if (!isAdmin) {
      body = const EventsNoAccess();
    } else if (id == null) {
      body = const _EventForm(event: null);
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
            : _EventForm(key: ValueKey(event.id), event: event),
      );
    }
    return SiteScaffold(title: title, maxWidth: SiteWidth.form, body: body);
  }
}

class _EventForm extends ConsumerStatefulWidget {
  const _EventForm({super.key, required this.event});

  /// The event as it was when the form opened; null for a new one.
  final Event? event;

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

  /// The live event (e.g. hidden state), falling back to the opened one.
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
    return null;
  }

  Future<void> _save() async {
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
    setState(() => _saving = true);
    try {
      if (_isNew) {
        await repo.createEvent(
          info,
          createdBy: ref.read(currentUidProvider) ?? '',
          byStaff: true,
          imageBase64: _newImage,
        );
        showSnack(l10n.eventsCreated);
      } else {
        await repo.updateEvent(
          widget.event!.id,
          info,
          imageBase64: _newImage,
          removeImage: _removeImage && widget.event!.hasImage,
        );
        showSnack(l10n.saved);
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
    String? text(String? v, int min) => (v == null || v.trim().isEmpty)
        ? l10n.required
        : v.trim().length < min
        ? l10n.eventsNameTooShort
        : null;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isNew) ...[
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
              l10n.eventsPictureHint,
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
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
                    onPress: () => setState(() => _category = c),
                    child: Text(
                      categoryName(l10n, c),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            SubmitButton(
              label: l10n.save,
              loading: _saving,
              onPressed: () {
                if (!_encoding) _save();
              },
            ),
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
