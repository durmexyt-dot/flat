import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../admin/admin_repository.dart';
import '../auth/auth_repository.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../ui/app_dialog.dart';
import '../ui/async_view.dart';
import '../ui/format.dart';
import '../ui/site_scaffold.dart';
import '../ui/skeleton.dart';
import '../ui/snack.dart';
import 'contact_support_page.dart';
import 'support_repository.dart';
import 'support_widgets.dart';

/// One support request: its details, the conversation and a composer.
/// Users see their own requests; the team sees all of them.
class SupportTicketPage extends ConsumerStatefulWidget {
  const SupportTicketPage({super.key, required this.id});

  final String id;

  @override
  ConsumerState<SupportTicketPage> createState() => _SupportTicketPageState();
}

class _SupportTicketPageState extends ConsumerState<SupportTicketPage> {
  final _scroll = ScrollController();
  int _messageCount = 0;

  /// The ticket state last marked as read, so each change is marked once.
  String? _markedKey;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _markReadIfNeeded(SupportTicket t, {required bool asStaff}) {
    final unread = asStaff ? t.unreadForStaff : t.unreadForUser;
    if (!unread) return;
    final key = '${t.status.name}-${t.lastMessageAt}-$asStaff';
    if (key == _markedKey) return;
    _markedKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(supportRepositoryProvider)
          .markRead(t.id, byStaff: asStaff)
          .catchError((_) {});
    });
  }

  void _followNewMessages(int count) {
    if (count > _messageCount && _messageCount > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
    _messageCount = count;
  }

  Future<void> _send(
    SupportTicket t,
    String text,
    List<String> images, {
    required bool asStaff,
  }) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    final profileName = ref.read(profileProvider).value?.displayName;
    final name = [
      profileName,
      user.displayName,
      user.email,
    ].firstWhere((s) => s != null && s.trim().isNotEmpty, orElse: () => '')!;
    await ref
        .read(supportRepositoryProvider)
        .sendMessage(
          ticket: t,
          authorId: user.uid,
          authorName: name.trim(),
          fromStaff: asStaff,
          text: text,
          images: images,
        );
  }

  Future<void> _close(SupportTicket t, {required bool asStaff}) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showAppDialog<bool>(
      context: context,
      title: l10n.supportCloseConfirm,
      body: Text(
        asStaff ? l10n.supportCloseConfirmStaff : l10n.supportCloseConfirmInfo,
      ),
      actions: (ctx) => [
        FButton(
          variant: FButtonVariant.outline,
          onPress: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        FButton(
          onPress: () => Navigator.pop(ctx, true),
          child: Text(l10n.supportCloseTicket),
        ),
      ],
    );
    if (ok != true) return;
    try {
      await ref
          .read(supportRepositoryProvider)
          .closeTicket(t.id, byStaff: asStaff);
    } catch (_) {
      showSnack(l10n.saveError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ticket = ref.watch(supportTicketProvider(widget.id));
    final messages = ref.watch(supportMessagesProvider(widget.id));
    final uid = ref.watch(currentUidProvider);
    final isStaff = ref.watch(isStaffProvider);

    final t = ticket.value;
    final asStaff = t != null && isStaff && t.uid != uid;
    if (t != null) _markReadIfNeeded(t, asStaff: asStaff);
    final list = messages.value;
    if (list != null) _followNewMessages(list.length);

    return SiteScaffold(
      title: t?.number ?? l10n.supportTicket,
      maxWidth: SiteWidth.form,
      accountNav: true,
      body: AsyncView<SupportTicket?>(
        value: ticket,
        onRetry: () => ref.invalidate(supportTicketProvider(widget.id)),
        loading: const _TicketSkeleton(),
        data: (t) => t == null
            ? Center(
                child: EmptyState(
                  icon: FLucideIcons.searchX,
                  title: l10n.supportNotFound,
                  action: FButton(
                    mainAxisSize: MainAxisSize.min,
                    variant: FButtonVariant.outline,
                    onPress: () => context.go('/support'),
                    child: Text(l10n.helpCenter),
                  ),
                ),
              )
            : _conversation(context, t, messages, asStaff: asStaff),
      ),
    );
  }

  Widget _conversation(
    BuildContext context,
    SupportTicket t,
    AsyncValue<List<SupportMessage>> messages, {
    required bool asStaff,
  }) {
    final l10n = AppLocalizations.of(context);
    final list = messages.value ?? const <SupportMessage>[];
    // Reversed: the newest message sits at the bottom and stays in view.
    final items = <Widget>[
      if (!t.isClosed)
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Center(
            child: FButton(
              variant: FButtonVariant.ghost,
              size: FButtonSizeVariant.sm,
              mainAxisSize: MainAxisSize.min,
              prefix: const Icon(FLucideIcons.circleCheck),
              onPress: () => _close(t, asStaff: asStaff),
              child: Text(
                asStaff ? l10n.supportCloseTicket : l10n.supportResolveTicket,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      for (final m in list.reversed)
        _Bubble(
          key: ValueKey(m.id),
          message: m,
          mine: m.fromStaff == asStaff,
          author: m.fromStaff
              ? (asStaff && m.authorName.isNotEmpty
                    ? m.authorName
                    : l10n.supportTeamName)
              : (asStaff
                    ? (m.authorName.isNotEmpty ? m.authorName : t.name)
                    : l10n.supportYou),
        ),
      if (messages.isLoading && !messages.hasValue)
        const Shimmer(
          child: Column(
            spacing: 12,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: SkeletonBox(width: 220, height: 64, radius: 12),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: SkeletonBox(width: 260, height: 80, radius: 12),
              ),
            ],
          ),
        ),
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _TicketHeader(ticket: t, staffView: asStaff),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            reverse: true,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            itemCount: items.length,
            itemBuilder: (_, i) => items[i],
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: t.isClosed
              ? _ClosedBanner(
                  key: const ValueKey('closed'),
                  ticket: t,
                  staffView: asStaff,
                )
              : SupportComposer(
                  key: const ValueKey('composer'),
                  onSend: (text, images) =>
                      _send(t, text, images, asStaff: asStaff),
                ),
        ),
      ],
    );
  }
}

class _TicketHeader extends StatelessWidget {
  const _TicketHeader({required this.ticket, required this.staffView});

  final SupportTicket ticket;
  final bool staffView;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final t = ticket;
    final muted = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );
    final value = theme.typography.body.sm.copyWith(
      color: theme.colors.foreground,
    );
    final details = [
      if (staffView && t.name.isNotEmpty) (l10n.supportUser, t.name),
      if (staffView && t.email.isNotEmpty) (l10n.supportEmail, t.email),
      if (t.reference.isNotEmpty) (l10n.reference, t.reference),
      if (staffView && t.appVersion.isNotEmpty)
        (l10n.supportAppVersion, t.appVersion),
    ];
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.number,
                    style: theme.typography.body.lg.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colors.foreground,
                    ),
                  ),
                ),
                SupportStatusBadge(status: t.status),
              ],
            ),
            Text(
              [
                supportTopicName(l10n, t.topic),
                if (t.createdAt != null) formatDateTime(context, t.createdAt!),
              ].join(' · '),
              style: muted,
            ),
            if (details.isNotEmpty) ...[
              const FDivider(
                style: .delta(
                  padding: .value(EdgeInsets.symmetric(vertical: 4)),
                ),
              ),
              for (final (label, text) in details)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 140, child: Text(label, style: muted)),
                    Expanded(child: SelectableText(text, style: value)),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    super.key,
    required this.message,
    required this.mine,
    required this.author,
  });

  final SupportMessage message;
  final bool mine;
  final String author;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final m = message;
    final radius = theme.style.borderRadius.lg;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: LayoutBuilder(
          builder: (context, constraints) => ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: (constraints.maxWidth * 0.82).clamp(0, 560),
            ),
            child: Column(
              crossAxisAlignment: mine
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Text(
                    [
                      author,
                      if (m.createdAt != null)
                        supportShortTime(context, m.createdAt),
                    ].join(' · '),
                    style: theme.typography.body.xs.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: mine ? theme.colors.muted : theme.colors.card,
                    borderRadius: radius,
                    border: mine
                        ? null
                        : Border.all(color: theme.colors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        if (m.text.isNotEmpty)
                          SelectableText(
                            m.text,
                            style: theme.typography.body.md.copyWith(
                              color: theme.colors.foreground,
                            ),
                          ),
                        if (m.images.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final img in m.images)
                                SupportImageThumb(data: img, size: 96),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClosedBanner extends StatelessWidget {
  const _ClosedBanner({
    super.key,
    required this.ticket,
    required this.staffView,
  });

  final SupportTicket ticket;
  final bool staffView;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final by = switch (ticket.closedBy) {
      'staff' => l10n.supportClosedByStaff,
      'user' => staffView ? l10n.supportClosedByUser : l10n.supportClosedByYou,
      _ => null,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.muted,
        border: Border(top: BorderSide(color: theme.colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Icon(FLucideIcons.lock, color: theme.colors.mutedForeground),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.supportClosed,
                      style: theme.typography.body.md.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colors.foreground,
                      ),
                    ),
                    if (by != null)
                      Text(
                        by,
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                  ],
                ),
              ),
              if (!staffView) ...[
                const SizedBox(width: 12),
                FButton(
                  variant: FButtonVariant.outline,
                  size: FButtonSizeVariant.sm,
                  mainAxisSize: MainAxisSize.min,
                  prefix: const Icon(FLucideIcons.messageSquarePlus),
                  onPress: () => context.push('/support/new'),
                  child: Text(l10n.supportNewRequest),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketSkeleton extends StatelessWidget {
  const _TicketSkeleton();

  @override
  Widget build(BuildContext context) => const Shimmer(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          SkeletonBox(height: 96, radius: 12),
          Align(
            alignment: Alignment.centerRight,
            child: SkeletonBox(width: 220, height: 64, radius: 12),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: SkeletonBox(width: 260, height: 80, radius: 12),
          ),
        ],
      ),
    ),
  );
}
