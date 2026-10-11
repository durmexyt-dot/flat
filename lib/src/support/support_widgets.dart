import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../ui/images.dart';
import '../ui/snack.dart';
import 'contact_support_page.dart';

String supportStatusName(AppLocalizations l10n, SupportStatus s) =>
    switch (s) {
      SupportStatus.open => l10n.supportStatusOpen,
      SupportStatus.answered => l10n.supportStatusAnswered,
      SupportStatus.closed => l10n.supportStatusClosed,
    };

/// Time of day for today, otherwise day and month (and the year when it is
/// not this year).
String supportShortTime(BuildContext context, DateTime? date) {
  if (date == null) return '';
  final locale = Localizations.localeOf(context).toLanguageTag();
  final now = DateTime.now();
  if (date.year == now.year &&
      date.month == now.month &&
      date.day == now.day) {
    return DateFormat.Hm(locale).format(date);
  }
  if (date.year == now.year) return DateFormat.MMMd(locale).format(date);
  return DateFormat.yMMMd(locale).format(date);
}

/// Open, answered or closed. The brand color marks "answered" (something
/// for the user to read); the others stay neutral.
class SupportStatusBadge extends StatelessWidget {
  const SupportStatusBadge({super.key, required this.status});

  final SupportStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FBadge(
      variant: switch (status) {
        SupportStatus.open => FBadgeVariant.secondary,
        SupportStatus.answered => FBadgeVariant.primary,
        SupportStatus.closed => FBadgeVariant.outline,
      },
      child: Text(supportStatusName(l10n, status)),
    );
  }
}

/// A small brand dot for unread tickets; keeps its space when read so rows
/// don't shift.
class UnreadDot extends StatelessWidget {
  const UnreadDot({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) => AnimatedScale(
    scale: visible ? 1 : 0,
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeOutBack,
    child: Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: context.theme.colors.primary,
        shape: BoxShape.circle,
      ),
    ),
  );
}

/// A ticket in a list: for users in the help center, for the team in the
/// inbox ([staffView] adds who wrote it).
class SupportTicketTile extends StatelessWidget {
  const SupportTicketTile({
    super.key,
    required this.ticket,
    required this.unread,
    required this.onTap,
    this.staffView = false,
  });

  final SupportTicket ticket;
  final bool unread;
  final bool staffView;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final muted = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );
    final who = [
      ticket.name,
      ticket.email,
    ].where((s) => s.isNotEmpty).join(' · ');

    return FTappable(
      onPress: onTap,
      child: FCard(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: UnreadDot(visible: unread),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${ticket.number} · '
                            '${supportTopicName(l10n, ticket.topic)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: muted,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          supportShortTime(
                            context,
                            ticket.lastMessageAt ?? ticket.createdAt,
                          ),
                          style: muted,
                        ),
                      ],
                    ),
                    if (staffView && who.isNotEmpty)
                      Text(
                        who,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.foreground,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    Text(
                      ticket.subject,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.md.copyWith(
                        color: theme.colors.foreground,
                        fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        SupportStatusBadge(status: ticket.status),
                        if (unread && !staffView)
                          FBadge(
                            variant: FBadgeVariant.outline,
                            child: Text(l10n.supportNewAnswer),
                          ),
                      ],
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

/// A base64 JPEG, decoded once.
class SupportImage extends StatefulWidget {
  const SupportImage({
    super.key,
    required this.data,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String data;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  State<SupportImage> createState() => _SupportImageState();
}

class _SupportImageState extends State<SupportImage> {
  Uint8List? _bytes;

  void _decode() {
    try {
      _bytes = base64Decode(widget.data);
    } on FormatException {
      _bytes = null;
    }
  }

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(SupportImage old) {
    super.didUpdateWidget(old);
    if (old.data != widget.data) _decode();
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;
    final placeholder = ColoredBox(
      color: context.theme.colors.muted,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Icon(
          FLucideIcons.imageOff,
          color: context.theme.colors.mutedForeground,
        ),
      ),
    );
    if (bytes == null) return placeholder;
    return Image.memory(
      bytes,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}

/// A square picture; tap opens it full screen. With [onRemove], a small
/// "x" removes it (attachments before sending).
class SupportImageThumb extends StatelessWidget {
  const SupportImageThumb({
    super.key,
    required this.data,
    this.size = 88,
    this.onRemove,
  });

  final String data;
  final double size;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: FTappable(
              semanticsLabel: l10n.supportImage,
              onPress: () => showSupportImage(context, data),
              child: ClipRRect(
                borderRadius: theme.style.borderRadius.md,
                child: DecoratedBox(
                  position: DecorationPosition.foreground,
                  decoration: BoxDecoration(
                    borderRadius: theme.style.borderRadius.md,
                    border: Border.all(color: theme.colors.border),
                  ),
                  child: SupportImage(data: data, width: size, height: size),
                ),
              ),
            ),
          ),
          if (onRemove != null)
            Positioned(
              top: -6,
              right: -6,
              child: FTappable(
                semanticsLabel: l10n.supportRemoveImage,
                onPress: onRemove,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.colors.foreground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colors.background,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    FLucideIcons.x,
                    size: 14,
                    color: theme.colors.background,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Shows a picture full screen: pinch to zoom, close button on top.
Future<void> showSupportImage(BuildContext context, String data) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 200),
      reverseTransitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (context, _, _) => const SizedBox(),
      transitionsBuilder: (context, animation, _, _) => FadeTransition(
        opacity: animation,
        child: _ImageViewer(data: data),
      ),
    ),
  );
}

class _ImageViewer extends StatelessWidget {
  const _ImageViewer({required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    final close = MaterialLocalizations.of(context).closeButtonTooltip;
    return Stack(
      children: [
        Positioned.fill(
          child: InteractiveViewer(
            maxScale: 5,
            child: Center(
              child: SupportImage(data: data, fit: BoxFit.contain),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: FTappable(
                semanticsLabel: close,
                onPress: () => Navigator.of(context).pop(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0x99000000),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(FLucideIcons.x, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Lets the user pick a picture and encodes it for a support message.
/// Null when cancelled; shows a toast when the picture can't be read.
Future<String?> pickSupportImage(AppLocalizations l10n) async {
  try {
    final bytes = await pickImageBytes();
    if (bytes == null) return null;
    return await compute(encodeSupportImage, bytes);
  } catch (_) {
    showSnack(l10n.supportImageError);
    return null;
  }
}

/// Pictures attached to a message before sending: thumbnails with "x", a
/// spinner while one is being prepared, and an add button.
class SupportAttachments extends StatelessWidget {
  const SupportAttachments({
    super.key,
    required this.images,
    required this.busy,
    required this.onAdd,
    required this.onRemove,
    this.showAddButton = true,
    this.size = 72,
  });

  final List<String> images;
  final bool busy;
  final VoidCallback? onAdd;
  final ValueChanged<int> onRemove;
  final bool showAddButton;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final canAdd = images.length < maxSupportImages && !busy;
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.topLeft,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final (i, data) in images.indexed)
            SupportImageThumb(
              key: ValueKey(data.hashCode ^ i),
              data: data,
              size: size,
              onRemove: () => onRemove(i),
            ),
          if (busy)
            SizedBox(
              width: size,
              height: size,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colors.muted,
                  borderRadius: theme.style.borderRadius.md,
                ),
                child: const Center(child: FCircularProgress()),
              ),
            ),
          if (showAddButton && images.length < maxSupportImages)
            FButton(
              variant: FButtonVariant.outline,
              size: FButtonSizeVariant.sm,
              mainAxisSize: MainAxisSize.min,
              prefix: const Icon(FLucideIcons.imagePlus),
              onPress: canAdd ? onAdd : null,
              child: Text(l10n.supportAddImage),
            ),
        ],
      ),
    );
  }
}

/// The message field at the bottom of a conversation: text, pictures and
/// a send button with a spinner. [onSend] throws to keep the draft.
class SupportComposer extends StatefulWidget {
  const SupportComposer({super.key, required this.onSend});

  final Future<void> Function(String text, List<String> images) onSend;

  @override
  State<SupportComposer> createState() => _SupportComposerState();
}

class _SupportComposerState extends State<SupportComposer> {
  final _text = TextEditingController();
  final _images = <String>[];
  bool _busy = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  bool get _canSend =>
      !_sending &&
      !_busy &&
      (_text.text.trim().isNotEmpty || _images.isNotEmpty);

  Future<void> _add() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    final data = await pickSupportImage(l10n);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (data != null && _images.length < maxSupportImages) _images.add(data);
    });
  }

  Future<void> _send() async {
    if (!_canSend) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _sending = true);
    try {
      await widget.onSend(_text.text.trim(), [..._images]);
      if (!mounted) return;
      _text.clear();
      setState(() => _images.clear());
    } catch (_) {
      showSnack(l10n.saveError);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background,
        border: Border(top: BorderSide(color: theme.colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                alignment: Alignment.topLeft,
                child: _images.isEmpty && !_busy
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(4, 6, 4, 10),
                        child: SupportAttachments(
                          images: _images,
                          busy: _busy,
                          showAddButton: false,
                          size: 64,
                          onAdd: null,
                          onRemove: (i) => setState(() => _images.removeAt(i)),
                        ),
                      ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 8,
                children: [
                  FButton.icon(
                    variant: FButtonVariant.ghost,
                    semanticsLabel: l10n.supportAddImage,
                    onPress: _images.length < maxSupportImages && !_busy
                        ? _add
                        : null,
                    child: const Icon(FLucideIcons.imagePlus),
                  ),
                  Expanded(
                    child: FTextField.multiline(
                      control: FTextFieldControl.managed(controller: _text),
                      hint: l10n.supportWriteMessage,
                      minLines: 1,
                      maxLines: 5,
                      inputFormatters: [LengthLimitingTextInputFormatter(2000)],
                    ),
                  ),
                  FButton.icon(
                    variant: FButtonVariant.primary,
                    semanticsLabel: l10n.send,
                    onPress: _canSend ? _send : null,
                    child: _sending
                        ? const FCircularProgress()
                        : const Icon(FLucideIcons.sendHorizontal),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
