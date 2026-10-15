import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../data/platform_repository.dart';
import '../data/repositories.dart';
import '../data/server_actions.dart';
import '../market/labels.dart';
import '../market/order_labels.dart';
import '../market/ticket_files_widgets.dart' show serverErrorText;
import '../settings/settings_widgets.dart';
import '../ui/app_dialog.dart';
import '../ui/async_view.dart';
import '../ui/format.dart';
import '../ui/segmented.dart';
import '../ui/site_scaffold.dart';
import '../ui/snack.dart';
import 'admin_page.dart';
import 'admin_repository.dart';
import '../ui/tokens.dart';

/// Any user's profile, for the team.
final userProfileProvider = StreamProvider.autoDispose
    .family<UserProfile?, String>(
      (ref, uid) => ref.watch(profileRepositoryProvider).watchProfile(uid),
    );

/// Asks for a short reason (optional) before a team action; null: cancelled.
Future<String?> askReason(
  BuildContext context, {
  required String title,
  required String message,
  required String confirm,
  bool destructive = false,
}) {
  final l10n = AppLocalizations.of(context);
  final reason = TextEditingController();
  return showAppDialog<String>(
    context: context,
    title: title,
    body: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(message),
        const SizedBox(height: Space.lg),
        FTextField(
          control: FTextFieldControl.managed(controller: reason),
          label: Text(l10n.moderationReason),
          description: Text(l10n.moderationReasonInfo),
          maxLines: 3,
          minLines: 1,
          inputFormatters: [LengthLimitingTextInputFormatter(300)],
        ),
      ],
    ),
    actions: (ctx) => [
      FButton(
        variant: FButtonVariant.outline,
        onPress: () => Navigator.pop(ctx),
        child: Text(l10n.cancel),
      ),
      FButton(
        variant: destructive
            ? FButtonVariant.destructive
            : FButtonVariant.primary,
        onPress: () => Navigator.pop(ctx, reason.text.trim()),
        child: Text(confirm),
      ),
    ],
  ).whenComplete(reason.dispose);
}

/// Runs a team action on the server and reports the outcome.
Future<bool> runAction(
  BuildContext context,
  Future<void> Function() action,
  String done,
) async {
  final l10n = AppLocalizations.of(context);
  try {
    await action();
    showSnack(done);
    return true;
  } catch (e) {
    showSnack(serverErrorText(l10n, e));
    return false;
  }
}

// ---------------------------------------------------------------------------
// Hub: reports and finding users
// ---------------------------------------------------------------------------

enum _Tab { open, handled, users }

/// The team's moderation: reported listings, copied ticket files, users.
class ModerationPage extends ConsumerStatefulWidget {
  const ModerationPage({super.key});

  @override
  ConsumerState<ModerationPage> createState() => _ModerationPageState();
}

class _ModerationPageState extends ConsumerState<ModerationPage> {
  _Tab _tab = _Tab.open;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final open = ref.watch(openReportsProvider).value?.length ?? 0;
    return SiteScaffold(
      title: l10n.moderationTitle,
      accountNav: true,
      body: AdminGate(
        staff: true,
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.xl,
                0,
                Space.xl,
                Space.md,
              ),
              child: Segmented<_Tab>(
                values: _Tab.values,
                selected: _tab,
                label: (t) => switch (t) {
                  _Tab.open => '${l10n.moderationOpen} ($open)',
                  _Tab.handled => l10n.moderationHandled,
                  _Tab.users => l10n.moderationUsers,
                },
                onChanged: (t) => setState(() => _tab = t),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: Motion.normal,
                child: switch (_tab) {
                  _Tab.open => const _Reports(
                    key: ValueKey('open'),
                    open: true,
                  ),
                  _Tab.handled => const _Reports(
                    key: ValueKey('handled'),
                    open: false,
                  ),
                  _Tab.users => const _UserSearch(key: ValueKey('users')),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String reportReasonName(AppLocalizations l10n, ReportReason r) => switch (r) {
  ReportReason.fake => l10n.reportReasonFake,
  ReportReason.price => l10n.reportReasonPrice,
  ReportReason.wrongEvent => l10n.reportReasonWrongEvent,
  ReportReason.spam => l10n.reportReasonSpam,
  ReportReason.other => l10n.reportReasonOther,
};

class _Reports extends ConsumerWidget {
  const _Reports({super.key, required this.open});
  final bool open;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = open ? openReportsProvider : handledReportsProvider;
    return AsyncView<List<Report>>(
      value: ref.watch(provider),
      onRetry: () => ref.invalidate(provider),
      loading: const AdminSkeleton(count: 3),
      data: (reports) => reports.isEmpty
          ? Center(
              child: EmptyState(
                icon: FLucideIcons.shieldCheck,
                title: open ? l10n.moderationNoOpen : l10n.moderationNoHandled,
              ),
            )
          : ListView(
              padding: Insets.pageList,
              children: [
                SettingsGroup(
                  children: [
                    for (final r in reports)
                      FTile(
                        prefix: Icon(
                          r.type == ReportType.duplicateTicket
                              ? FLucideIcons.copy
                              : FLucideIcons.flag,
                        ),
                        title: Text(
                          r.type == ReportType.duplicateTicket
                              ? l10n.moderationDuplicate
                              : reportReasonName(l10n, r.reason),
                        ),
                        subtitle: Text(
                          [
                            if (r.eventName.isNotEmpty) r.eventName,
                            if (r.text.isNotEmpty) r.text,
                            if (r.createdAt != null)
                              formatDateTime(context, r.createdAt!),
                          ].join(' · '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        suffix: const Icon(FLucideIcons.chevronRight),
                        onPress: () => showReport(context, ref, r),
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}

/// One report: the listing, and what the team can do about it.
Future<void> showReport(BuildContext context, WidgetRef ref, Report r) async {
  final l10n = AppLocalizations.of(context);
  final router = GoRouter.of(context);
  // The listing as it is now; the report opens also when it can't be read.
  Listing? listing;
  try {
    listing = await ref
        .read(marketRepositoryProvider)
        .watchListing(r.listingId)
        .first
        .timeout(const Duration(seconds: 8));
  } catch (_) {
    listing = null;
  }
  if (!context.mounted) return;
  final sellerId = r.sellerId.isNotEmpty ? r.sellerId : listing?.sellerId ?? '';
  final note = TextEditingController(text: r.note);
  final action = await showAppDialog<String>(
    context: context,
    title: r.type == ReportType.duplicateTicket
        ? l10n.moderationDuplicate
        : l10n.moderationReport,
    body: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          r.type == ReportType.duplicateTicket
              ? l10n.moderationDuplicateInfo
              : '${reportReasonName(l10n, r.reason)}${r.text.isEmpty ? '' : ': ${r.text}'}',
        ),
        const SizedBox(height: Space.lg),
        if (listing != null)
          FTile(
            prefix: const Icon(FLucideIcons.ticket),
            title: Text(listing.event.name),
            subtitle: Text(
              '${listing.quantity - listing.quantitySold} × '
              '${formatMoney(context, listing.priceMinor, listing.currency)}'
              '${listing.faceValueMinor == null ? '' : ' (${l10n.priceFaceValue}: ${formatMoney(context, listing.faceValueMinor!, listing.currency)})'}',
            ),
            suffix: StatusChip(
              label: listingStatusName(l10n, listing.status),
              tone: listingTone(listing.status),
            ),
          ),
        if (r.status == ReportStatus.open) ...[
          const SizedBox(height: Space.lg),
          FTextField(
            control: FTextFieldControl.managed(controller: note),
            label: Text(l10n.moderationNote),
            maxLines: 2,
            minLines: 1,
            inputFormatters: [LengthLimitingTextInputFormatter(500)],
          ),
        ] else if (r.note.isNotEmpty) ...[
          const SizedBox(height: Space.lg),
          Text('${l10n.moderationNote}: ${r.note}'),
        ],
      ],
    ),
    actions: (ctx) => [
      if (sellerId.isNotEmpty)
        FButton(
          variant: FButtonVariant.outline,
          onPress: () => Navigator.pop(ctx, 'seller'),
          prefix: const Icon(FLucideIcons.user),
          child: Text(l10n.moderationOpenSeller),
        ),
      if (listing != null &&
          (listing.status == ListingStatus.active ||
              listing.status == ListingStatus.soldOut))
        FButton(
          variant: FButtonVariant.destructive,
          onPress: () => Navigator.pop(ctx, 'remove'),
          prefix: const Icon(FLucideIcons.trash2),
          child: Text(l10n.moderationRemoveListing),
        ),
      if (r.status == ReportStatus.open) ...[
        FButton(
          onPress: () => Navigator.pop(ctx, 'resolved'),
          prefix: const Icon(FLucideIcons.check),
          child: Text(l10n.moderationResolve),
        ),
        FButton(
          variant: FButtonVariant.ghost,
          onPress: () => Navigator.pop(ctx, 'dismissed'),
          child: Text(l10n.moderationDismiss),
        ),
      ],
    ],
  );
  final noteText = note.text.trim();
  note.dispose();
  if (action == null || !context.mounted) return;
  final uid = ref.read(currentUidProvider);
  switch (action) {
    case 'seller':
      router.push('/admin/users/$sellerId');
    case 'remove':
      final reason = await askReason(
        context,
        title: l10n.moderationRemoveListing,
        message: l10n.moderationRemoveListingInfo,
        confirm: l10n.moderationRemoveListing,
        destructive: true,
      );
      if (reason == null || !context.mounted) return;
      final ok = await runAction(
        context,
        () => ref
            .read(serverActionsProvider)
            .removeListing(listingId: r.listingId, reason: reason),
        l10n.moderationListingRemoved,
      );
      if (ok && uid != null && r.status == ReportStatus.open) {
        await ref
            .read(platformRepositoryProvider)
            .handleReport(
              r.id,
              status: ReportStatus.resolved,
              note: reason.isEmpty ? noteText : reason,
              byUid: uid,
            );
      }
    case 'resolved' || 'dismissed':
      if (uid == null) return;
      await runAction(
        context,
        () => ref
            .read(platformRepositoryProvider)
            .handleReport(
              r.id,
              status: action == 'resolved'
                  ? ReportStatus.resolved
                  : ReportStatus.dismissed,
              note: noteText,
              byUid: uid,
            ),
        l10n.saved,
      );
  }
}

class _UserSearch extends ConsumerStatefulWidget {
  const _UserSearch({super.key});

  @override
  ConsumerState<_UserSearch> createState() => _UserSearchState();
}

class _UserSearchState extends ConsumerState<_UserSearch> {
  final _query = TextEditingController();
  bool _searching = false;
  bool _notFound = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _query.text.trim();
    if (q.isEmpty || _searching) return;
    setState(() {
      _searching = true;
      _notFound = false;
    });
    try {
      final user = await ref.read(adminRepositoryProvider).findUser(q);
      if (!mounted) return;
      if (user == null) {
        setState(() => _notFound = true);
      } else {
        context.push('/admin/users/${user.uid}');
      }
    } catch (_) {
      showSnack(AppLocalizations.of(context).loadError);
    }
    if (mounted) setState(() => _searching = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: Insets.pageList,
      children: [
        FTextField(
          control: FTextFieldControl.managed(controller: _query),
          label: Text(l10n.moderationFindUser),
          description: Text(l10n.moderationFindUserInfo),
          hint: 'ime@primjer.ba / @korisnik',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.search,
          onSubmit: (_) => _search(),
        ),
        const SizedBox(height: Space.lg),
        FButton(
          onPress: _searching ? null : _search,
          prefix: _searching
              ? FCircularProgress.loader()
              : const Icon(FLucideIcons.search),
          child: Text(l10n.moderationSearch),
        ),
        if (_notFound) ...[
          const SizedBox(height: Space.xl),
          Text(l10n.moderationUserNotFound, textAlign: TextAlign.center),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// One user: block, limits, listings, orders, log
// ---------------------------------------------------------------------------

class UserModerationPage extends ConsumerWidget {
  const UserModerationPage({super.key, required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SiteScaffold(
      title: l10n.moderationUser,
      accountNav: true,
      body: AdminGate(staff: true, builder: (context) => _UserDetail(uid: uid)),
    );
  }
}

class _UserDetail extends ConsumerWidget {
  const _UserDetail({required this.uid});
  final String uid;

  Future<void> _toggleBan(
    BuildContext context,
    WidgetRef ref,
    UserBan? ban,
  ) async {
    final l10n = AppLocalizations.of(context);
    final block = ban == null;
    final reason = await askReason(
      context,
      title: block ? l10n.moderationBlock : l10n.moderationUnblock,
      message: block ? l10n.moderationBlockInfo : l10n.moderationUnblockInfo,
      confirm: block ? l10n.moderationBlock : l10n.moderationUnblock,
      destructive: block,
    );
    if (reason == null || !context.mounted) return;
    await runAction(
      context,
      () => ref
          .read(serverActionsProvider)
          .setUserBan(uid: uid, banned: block, reason: reason),
      block ? l10n.moderationBlocked : l10n.moderationUnblocked,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final profile = ref.watch(userProfileProvider(uid)).value;
    final ban = ref.watch(banProvider(uid)).value;
    final stats =
        ref.watch(sellerStatsProvider(uid)).value ?? const SellerStats();
    final limits =
        ref.watch(sellerLimitsProvider).value ?? const SellerLimits();
    final listings = ref.watch(listingsOfProvider(uid));
    final orders = ref.watch(ordersOfProvider(uid));
    final log = ref.watch(moderationLogProvider(uid));
    final muted = theme.mutedText;
    return ListView(
      padding: Insets.page,
      children: [
        FCard(
          child: Padding(
            padding: const EdgeInsets.all(Space.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (profile?.displayName ?? '').isEmpty
                      ? l10n.adminNoName
                      : profile!.displayName!,
                  style: theme.typography.display.lg.copyWith(
                    fontWeight: FontWeights.bold,
                    color: theme.colors.foreground,
                  ),
                ),
                const SizedBox(height: Space.xs),
                SelectableText(
                  [
                    if ((profile?.email ?? '').isNotEmpty) profile!.email!,
                    if ((profile?.username ?? '').isNotEmpty)
                      '@${profile!.username}',
                  ].join(' · '),
                  style: muted,
                ),
                const SizedBox(height: Space.lg),
                Wrap(
                  spacing: Space.md,
                  runSpacing: Space.md,
                  children: [
                    if (ban != null)
                      StatusChip(
                        label: l10n.moderationIsBlocked,
                        tone: StatusTone.negative,
                      ),
                    StatusChip(
                      label: stats.isNew(limits)
                          ? l10n.moderationNewSeller
                          : l10n.moderationTrustedSeller,
                      tone: stats.isNew(limits)
                          ? StatusTone.waiting
                          : StatusTone.positive,
                    ),
                    StatusChip(
                      label: l10n.moderationStats(
                        stats.activeListings,
                        stats.completedSales,
                      ),
                      tone: StatusTone.neutral,
                    ),
                  ],
                ),
                if (ban != null && ban.reason.isNotEmpty) ...[
                  const SizedBox(height: Space.md),
                  Text('${l10n.moderationReason}: ${ban.reason}', style: muted),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: Space.lg),
        Wrap(
          spacing: Space.md,
          runSpacing: Space.md,
          children: [
            FButton(
              variant: ban == null
                  ? FButtonVariant.destructive
                  : FButtonVariant.outline,
              mainAxisSize: MainAxisSize.min,
              onPress: () => _toggleBan(context, ref, ban),
              prefix: Icon(
                ban == null ? FLucideIcons.ban : FLucideIcons.circleCheck,
              ),
              child: Text(
                ban == null ? l10n.moderationBlock : l10n.moderationUnblock,
              ),
            ),
            FButton(
              variant: FButtonVariant.outline,
              mainAxisSize: MainAxisSize.min,
              onPress: () => runAction(
                context,
                () => ref
                    .read(serverActionsProvider)
                    .setSellerTrusted(uid: uid, trusted: !stats.trusted),
                l10n.saved,
              ),
              prefix: Icon(
                stats.trusted
                    ? FLucideIcons.shieldAlert
                    : FLucideIcons.shieldCheck,
              ),
              child: Text(
                stats.trusted ? l10n.moderationUntrust : l10n.moderationTrust,
              ),
            ),
          ],
        ),
        SettingsSectionTitle(l10n.moderationListings),
        AsyncView<List<Listing>>(
          value: listings,
          onRetry: () => ref.invalidate(listingsOfProvider(uid)),
          loading: const AdminSkeleton(count: 2),
          data: (items) => items.isEmpty
              ? Text(l10n.moderationNone, style: muted)
              : SettingsGroup(
                  children: [
                    for (final l in items)
                      FTile(
                        title: Text(l.event.name),
                        subtitle: Text(
                          '${l.quantity} × ${formatMoney(context, l.priceMinor, l.currency)} · '
                          '${formatDate(context, l.event.date)}',
                        ),
                        suffix: StatusChip(
                          label: listingStatusName(l10n, l.status),
                          tone: listingTone(l.status),
                        ),
                        onPress: () => _listingActions(context, ref, l),
                      ),
                  ],
                ),
        ),
        SettingsSectionTitle(l10n.moderationOrders),
        AsyncView<List<Order>>(
          value: orders,
          onRetry: () => ref.invalidate(ordersOfProvider(uid)),
          loading: const AdminSkeleton(count: 2),
          data: (items) => items.isEmpty
              ? Text(l10n.moderationNone, style: muted)
              : SettingsGroup(
                  children: [
                    for (final o in items)
                      FTile(
                        prefix: Icon(
                          o.buyerId == uid
                              ? FLucideIcons.shoppingBag
                              : FLucideIcons.store,
                        ),
                        title: Text('${o.number} · ${o.event.name}'),
                        subtitle: Text(
                          '${o.buyerId == uid ? l10n.moderationAsBuyer : l10n.moderationAsSeller} · '
                          '${formatMoney(context, o.totalMinor, o.currency)}',
                        ),
                        suffix: StatusChip(
                          label: orderStatusName(l10n, o.status),
                          tone: orderTone(o.status),
                        ),
                        onPress: () => _orderActions(context, ref, o),
                      ),
                  ],
                ),
        ),
        SettingsSectionTitle(l10n.moderationLog),
        AsyncView<List<ModerationEntry>>(
          value: log,
          onRetry: () => ref.invalidate(moderationLogProvider(uid)),
          loading: const AdminSkeleton(count: 1),
          data: (entries) => entries.isEmpty
              ? Text(l10n.moderationNone, style: muted)
              : SettingsGroup(
                  children: [
                    for (final e in entries)
                      FTile(
                        prefix: const Icon(FLucideIcons.history),
                        title: Text(moderationActionName(l10n, e.action)),
                        subtitle: Text(
                          [
                            if (e.at != null) formatDateTime(context, e.at!),
                            if (e.reason.isNotEmpty) e.reason,
                          ].join(' · '),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _listingActions(
    BuildContext context,
    WidgetRef ref,
    Listing l,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (l.status != ListingStatus.active && l.status != ListingStatus.soldOut) {
      context.push('/listing/${l.id}');
      return;
    }
    final reason = await askReason(
      context,
      title: l10n.moderationRemoveListing,
      message: l10n.moderationRemoveListingInfo,
      confirm: l10n.moderationRemoveListing,
      destructive: true,
    );
    if (reason == null || !context.mounted) return;
    await runAction(
      context,
      () => ref
          .read(serverActionsProvider)
          .removeListing(listingId: l.id, reason: reason),
      l10n.moderationListingRemoved,
    );
  }

  Future<void> _orderActions(
    BuildContext context,
    WidgetRef ref,
    Order o,
  ) async {
    final l10n = AppLocalizations.of(context);
    const refundable = [
      OrderStatus.paid,
      OrderStatus.ticketsSent,
      OrderStatus.disputed,
    ];
    if (!refundable.contains(o.status)) {
      context.push('/order/${o.id}');
      return;
    }
    final reason = await askReason(
      context,
      title: l10n.moderationRefund,
      message: l10n.moderationRefundInfo(o.number),
      confirm: l10n.moderationRefund,
      destructive: true,
    );
    if (reason == null || !context.mounted) return;
    await runAction(
      context,
      () => ref
          .read(serverActionsProvider)
          .refundOrder(orderId: o.id, reason: reason),
      l10n.moderationRefunded,
    );
  }
}

String moderationActionName(AppLocalizations l10n, String action) =>
    switch (action) {
      'ban' => l10n.moderationBlocked,
      'unban' => l10n.moderationUnblocked,
      'removeListing' => l10n.moderationListingRemoved,
      'refund' => l10n.moderationRefunded,
      'trust' => l10n.moderationTrust,
      'untrust' => l10n.moderationUntrust,
      _ => action,
    };
