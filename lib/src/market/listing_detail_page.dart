import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../admin/admin_repository.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_repository.dart';
import '../auth/auth_widgets.dart';
import '../data/events_repository.dart';
import '../data/models.dart';
import '../data/platform_repository.dart';
import '../events/event_image.dart';
import '../events/event_status_badge.dart';
import '../ui/app_style.dart';
import '../data/repositories.dart';
import '../data/tickets_repository.dart';
import '../settings/settings_widgets.dart';
import '../ui/async_view.dart';
import '../ui/format.dart';
import '../ui/responsive_grid.dart';
import '../ui/skeleton.dart';
import 'labels.dart';
import 'listing_ticket.dart';
import '../ui/app_dialog.dart';
import '../ui/snack.dart';
import '../ui/site_scaffold.dart';
import '../admin/moderation_pages.dart' show reportReasonName;

/// A listing as its seller (manage) or a buyer (buy) sees it.
class ListingDetailPage extends ConsumerWidget {
  const ListingDetailPage({super.key, required this.id, this.initial});

  final String id;

  /// The listing as shown in the list, so the ticket can fly in at once.
  final Listing? initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final live = ref.watch(listingProvider(id));
    final listing = live.value ?? initial;
    final uid = ref.watch(currentUidProvider);

    return SiteScaffold(
      title: l10n.listingDetails,
      maxWidth: SiteWidth.full,
      body: listing == null
          ? AsyncView<Listing?>(
              value: live,
              onRetry: () => ref.invalidate(listingProvider(id)),
              loading: const SkeletonTicketList(count: 1),
              data: (_) => EmptyState(
                icon: FLucideIcons.searchX,
                title: l10n.listingNotFound,
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                // Details left, buying or managing right on wide screens.
                SplitView(
                  wide: isWideLayout(context),
                  main: [
                    if (listing.eventId.isNotEmpty) ...[
                      _EventBanner(eventId: listing.eventId),
                      const SizedBox(height: 16),
                    ],
                    ListingTicket(listing: listing, showStatus: true),
                    const SizedBox(height: 16),
                    _Facts(listing: listing),
                  ],
                  side: [
                    if (listing.sellerId == uid)
                      _SellerPanel(listing: listing)
                    else ...[
                      _BuyerPanel(listing: listing),
                      // Signed-in buyers can report a listing to the team.
                      if (uid != null && !ref.watch(isStaffProvider))
                        _ReportButton(listing: listing),
                    ],
                  ],
                ),
              ],
            ),
    );
  }
}

/// The event's picture and a way to all of its offers.
class _EventBanner extends ConsumerWidget {
  const _EventBanner({required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final event = ref.watch(eventProvider(eventId)).value;
    final visible = event != null && !event.hidden;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          alignment: Alignment.topCenter,
          child: visible
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      EventImage(
                        event: event,
                        borderRadius: BorderRadius.circular(
                          AppStyle.of(context).cardRadius,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          EventCategoryBadge(event),
                          EventStatusBadge(event),
                        ],
                      ),
                      if (event.pending) ...[
                        const SizedBox(height: 6),
                        Text(
                          l10n.eventStatusPendingInfo,
                          style: context.theme.typography.body.xs.copyWith(
                            color: context.theme.colors.mutedForeground,
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FButton(
            variant: FButtonVariant.ghost,
            size: FButtonSizeVariant.sm,
            mainAxisSize: MainAxisSize.min,
            onPress: () => context.push('/event/$eventId', extra: event),
            suffix: const Icon(FLucideIcons.arrowRight),
            child: Text(l10n.eventsAllOffers, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
  }
}

class _Facts extends StatelessWidget {
  const _Facts({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final seats = seatText(l10n, listing.section, listing.row, listing.seats);
    return SettingsGroup(
      children: [
        _fact(
          FLucideIcons.calendar,
          l10n.dateTime,
          formatDateTime(context, listing.event.date),
        ),
        _fact(
          FLucideIcons.mapPin,
          l10n.venue,
          '${listing.event.venue}, ${listing.event.city}',
        ),
        _fact(
          FLucideIcons.ticket,
          l10n.ticketType,
          ticketTypeName(l10n, listing.ticketType),
        ),
        if (seats.isNotEmpty) _fact(FLucideIcons.armchair, l10n.seats, seats),
        _fact(
          FLucideIcons.packageOpen,
          l10n.quantity,
          l10n.ticketsLeft('${listing.available}', '${listing.quantity}'),
        ),
        // Transparency for buyers: what the ticket originally cost.
        if (listing.faceValueMinor case final face?)
          _fact(
            FLucideIcons.receiptText,
            l10n.priceFaceValueShort,
            formatMoney(context, face, listing.currency),
          ),
        if (listing.note.isNotEmpty)
          _fact(FLucideIcons.notebookText, l10n.noteLabel, listing.note),
      ],
    );
  }
}

FTile _fact(IconData icon, String label, String value) =>
    FTile(prefix: Icon(icon), title: Text(label), subtitle: Text(value));

class _SellerPanel extends ConsumerWidget {
  const _SellerPanel({required this.listing});

  final Listing listing;

  Future<void> _editPrice(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final form = GlobalKey<_PriceFormState>();
    // The resale rule for this event: the highest price over the face value.
    final resale = ref.read(resaleConfigProvider).value ?? const ResaleConfig();
    final event = listing.eventId.isEmpty
        ? null
        : ref.read(eventProvider(listing.eventId)).value;
    final markup = resale.limitFor(event);
    final face = listing.faceValueMinor;
    final minor = await showAppDialog<int>(
      context: context,
      title: l10n.editPrice,
      body: _PriceForm(
        key: form,
        listing: listing,
        needsFaceValue: resale.needsFaceValue(event) && face == null,
        maxPriceMinor: markup == null || face == null
            ? null
            : maxResalePrice(face, markup),
      ),
      actions: (ctx) => [
        FButton(
          variant: FButtonVariant.outline,
          onPress: () => Navigator.pop(ctx),
          child: Flexible(
            child: Text(l10n.cancel, overflow: TextOverflow.ellipsis),
          ),
        ),
        FButton(
          onPress: () => form.currentState?.submit(),
          child: Flexible(
            child: Text(l10n.save, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
    if (minor == null) return;
    try {
      await ref
          .read(marketRepositoryProvider)
          .updateListingPrice(listing.id, minor);
      showSnack(l10n.saved);
    } catch (_) {
      showSnack(l10n.saveError);
    }
  }

  Future<void> _withdraw(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showAppDialog<bool>(
      context: context,
      title: l10n.withdrawListing,
      body: Text(l10n.withdrawConfirm),
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
            child: Text(l10n.withdrawListing, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
    if (ok != true) return;
    try {
      await ref.read(marketRepositoryProvider).withdrawListing(listing.id);
      ref.invalidate(statsProvider);
      showSnack(l10n.listingWithdrawn);
    } catch (_) {
      showSnack(l10n.saveError);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Loaded now, so the price dialog knows the resale rule.
    ref.watch(resaleConfigProvider);
    if (listing.eventId.isNotEmpty) ref.watch(eventProvider(listing.eventId));
    final l10n = AppLocalizations.of(context);
    final active = listing.status == ListingStatus.active;
    // E-tickets not yet uploaded: a warning until every ticket is there.
    final uploaded = listing.ticketType == TicketType.eTicket
        ? (ref.watch(listingFilesProvider(listing.id)).value ?? const [])
              .fold<int>(0, (n, f) => n + f.tickets)
        : listing.quantity;
    final live = const {
      ListingStatus.active,
      ListingStatus.reserved,
      ListingStatus.soldOut,
    }.contains(listing.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          child: live && uploaded < listing.quantity
              ? Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: FAlert(
                    variant: FAlertVariant.destructive,
                    icon: const Icon(FLucideIcons.fileWarning),
                    title: Text(l10n.sellerTicketsMissing),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.sellerTicketsMissingInfo(
                            uploaded,
                            listing.quantity,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FButton(
                          variant: FButtonVariant.outline,
                          size: FButtonSizeVariant.sm,
                          mainAxisSize: MainAxisSize.min,
                          onPress: () =>
                              context.push('/listing/${listing.id}/tickets'),
                          prefix: const Icon(FLucideIcons.fileUp),
                          child: Text(
                            l10n.sellerUploadNow,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
        SettingsSectionTitle(l10n.yourListing),
        FCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _MoneyRow(
                  l10n.pricePerTicket,
                  formatMoney(context, listing.priceMinor, listing.currency),
                ),
                _MoneyRow(
                  l10n.youReceive('${listing.fees.sellerPercent}'),
                  formatMoney(
                    context,
                    listing.payoutPerTicketMinor,
                    listing.currency,
                  ),
                ),
                const FDivider(
                  style: .delta(
                    padding: .value(EdgeInsets.symmetric(vertical: 8)),
                  ),
                ),
                _MoneyRow(
                  l10n.totalPayout,
                  formatMoney(
                    context,
                    listing.payoutPerTicketMinor * listing.available,
                    listing.currency,
                  ),
                  strong: true,
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          child: active
              ? Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      // E-tickets are uploaded and sent automatically.
                      if (listing.ticketType == TicketType.eTicket)
                        FButton(
                          mainAxisSize: MainAxisSize.min,
                          onPress: () =>
                              context.push('/listing/${listing.id}/tickets'),
                          prefix: const Icon(FLucideIcons.fileUp),
                          child: Text(
                            l10n.sellerTicketsButton,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      FButton(
                        variant: FButtonVariant.secondary,
                        mainAxisSize: MainAxisSize.min,
                        onPress: () => _editPrice(context, ref),
                        prefix: const Icon(FLucideIcons.pencil),
                        child: Text(
                          l10n.editPrice,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      FButton(
                        variant: FButtonVariant.outline,
                        mainAxisSize: MainAxisSize.min,
                        onPress: () => _withdraw(context, ref),
                        prefix: const Icon(FLucideIcons.eyeOff),
                        child: Text(
                          l10n.withdrawListing,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

/// Asks for a new price inside the dialog body. Owns its text controller,
/// which must outlive the dialog's closing animation.
class _PriceForm extends StatefulWidget {
  const _PriceForm({
    super.key,
    required this.listing,
    this.maxPriceMinor,
    this.needsFaceValue = false,
  });

  final Listing listing;

  /// The highest price the resale rules allow, if limited.
  final int? maxPriceMinor;

  /// The rules need a face value the listing doesn't have.
  final bool needsFaceValue;

  @override
  State<_PriceForm> createState() => _PriceFormState();
}

class _PriceFormState extends State<_PriceForm> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(
    text: (widget.listing.priceMinor / 100).toStringAsFixed(2),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, parseMoney(_controller.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final symbol = currencySymbols[widget.listing.currency];
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Form(
        key: _formKey,
        child: FTextFormField(
          control: FTextFieldControl.managed(controller: _controller),
          autofocus: true,
          label: Text(l10n.pricePerTicket),
          prefixBuilder: (context, style, variants) =>
              fieldIcon(FLucideIcons.banknote),
          suffixBuilder: symbol == null
              ? null
              : (context, style, variants) => Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12),
                  child: Text(symbol),
                ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          onSubmit: (_) => submit(),
          description: widget.maxPriceMinor == null
              ? null
              : Text(
                  l10n.resaleTooHigh(
                    formatMoney(
                      context,
                      widget.maxPriceMinor!,
                      widget.listing.currency,
                    ),
                  ),
                ),
          validator: (v) {
            final m = parseMoney(v ?? '');
            if (m == null || m <= 0) return l10n.priceInvalid;
            if (widget.needsFaceValue) return l10n.resaleNeedsFaceValue;
            final max = widget.maxPriceMinor;
            if (max != null && m > max) {
              return l10n.resaleTooHigh(
                formatMoney(context, max, widget.listing.currency),
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow(this.label, this.value, {this.strong = false});

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.typography.body.sm.copyWith(
                color: strong
                    ? theme.colors.foreground
                    : theme.colors.mutedForeground,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              value,
              key: ValueKey(value),
              style: strong
                  ? theme.typography.body.lg.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colors.foreground,
                    )
                  : theme.typography.body.sm.copyWith(
                      color: theme.colors.foreground,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuyerPanel extends ConsumerStatefulWidget {
  const _BuyerPanel({required this.listing});

  final Listing listing;

  @override
  ConsumerState<_BuyerPanel> createState() => _BuyerPanelState();
}

class _BuyerPanelState extends ConsumerState<_BuyerPanel> {
  int _quantity = 1;

  void _buy() {
    final l10n = AppLocalizations.of(context);
    if (ref.read(currentUidProvider) == null) {
      showSnack(
        l10n.guestSignInPrompt,
        actionLabel: l10n.loginButton,
        onAction: () {
          ref.read(guestModeProvider.notifier).exit();
          context.go('/login');
        },
      );
      return;
    }
    context.push(
      '/checkout/${widget.listing.id}',
      extra: (widget.listing, _quantity),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final listing = widget.listing;
    final quantity = _quantity.clamp(1, listing.available.clamp(1, 99));
    final subtotal = listing.priceMinor * quantity;
    final fee = listing.fees.buyerFee(subtotal);
    final available =
        listing.status == ListingStatus.active && listing.available > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionTitle(l10n.buyTickets),
        FCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.quantity,
                        style: theme.typography.body.sm.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colors.foreground,
                        ),
                      ),
                    ),
                    FButton.icon(
                      variant: FButtonVariant.outline,
                      onPress: quantity > 1
                          ? () => setState(() => _quantity = quantity - 1)
                          : null,
                      child: const Icon(FLucideIcons.minus),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '$quantity',
                        textAlign: TextAlign.center,
                        style: theme.typography.body.lg.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colors.foreground,
                        ),
                      ),
                    ),
                    FButton.icon(
                      variant: FButtonVariant.outline,
                      onPress: quantity < listing.available
                          ? () => setState(() => _quantity = quantity + 1)
                          : null,
                      child: const Icon(FLucideIcons.plus),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _MoneyRow(
                  '$quantity × ${formatMoney(context, listing.priceMinor, listing.currency)}',
                  formatMoney(context, subtotal, listing.currency),
                ),
                _MoneyRow(
                  '${l10n.serviceFee} (${listing.fees.buyerPercent} %)',
                  formatMoney(context, fee, listing.currency),
                ),
                const FDivider(
                  style: .delta(
                    padding: .value(EdgeInsets.symmetric(vertical: 8)),
                  ),
                ),
                _MoneyRow(
                  l10n.total,
                  formatMoney(context, subtotal + fee, listing.currency),
                  strong: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (ref.watch(isStaffProvider))
          // Team accounts don't buy.
          FAlert(
            icon: const Icon(FLucideIcons.shieldUser),
            title: Text(l10n.staffNoMarketTitle),
            subtitle: Text(l10n.staffNoMarketInfo),
          )
        else
          FButton(
            size: FButtonSizeVariant.lg,
            onPress: available ? _buy : null,
            prefix: const Icon(FLucideIcons.shoppingBag),
            child: Flexible(
              child: Text(l10n.buyTickets, overflow: TextOverflow.ellipsis),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              FLucideIcons.shieldCheck,
              size: 18,
              color: theme.colors.mutedForeground,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.buyerProtection,
                style: theme.typography.body.xs.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Lets a buyer report a listing (fake tickets, price, …) to the team.
class _ReportButton extends ConsumerWidget {
  const _ReportButton({required this.listing});

  final Listing listing;

  Future<void> _report(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    final repo = ref.read(platformRepositoryProvider);
    if (await repo.hasReported(listing.id, uid)) {
      showSnack(l10n.reportAlready);
      return;
    }
    if (!context.mounted) return;
    var reason = ReportReason.fake;
    final text = TextEditingController();
    final send = await showAppDialog<bool>(
      context: context,
      title: l10n.reportListing,
      body: StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.reportListingInfo),
            const SizedBox(height: 12),
            for (final r in ReportReason.values)
              FTile(
                prefix: Icon(
                  r == reason ? FLucideIcons.circleDot : FLucideIcons.circle,
                ),
                title: Text(reportReasonName(l10n, r)),
                onPress: () => setState(() => reason = r),
              ),
            const SizedBox(height: 12),
            FTextField(
              control: FTextFieldControl.managed(controller: text),
              label: Text(l10n.reportDetails),
              maxLines: 3,
              minLines: 1,
              maxLength: 500,
            ),
          ],
        ),
      ),
      actions: (ctx) => [
        FButton(
          variant: FButtonVariant.outline,
          onPress: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        FButton(
          onPress: () => Navigator.pop(ctx, true),
          child: Text(l10n.reportSend),
        ),
      ],
    );
    final details = text.text.trim();
    text.dispose();
    if (send != true) return;
    try {
      await repo.reportListing(
        listingId: listing.id,
        uid: uid,
        reason: reason,
        text: details,
      );
      showSnack(l10n.reportSent);
    } catch (_) {
      showSnack(l10n.saveError);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: FButton(
        variant: FButtonVariant.ghost,
        onPress: () => _report(context, ref),
        prefix: const Icon(FLucideIcons.flag),
        child: Text(l10n.reportListing),
      ),
    );
  }
}
