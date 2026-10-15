import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../admin/admin_repository.dart';
import '../../l10n/app_localizations.dart';
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
import '../ui/tokens.dart';

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

    final wide = isWideLayout(context);
    final staff = ref.watch(isStaffProvider);
    final buyer = listing != null && listing.sellerId != uid && !staff;
    // Phones: buying sits in a bar that stays at the bottom of the screen.
    final buyBar = buyer && !wide;

    final Widget body;
    if (listing == null) {
      body = AsyncView<Listing?>(
        value: live,
        onRetry: () => ref.invalidate(listingProvider(id)),
        loading: const SkeletonTicketList(count: 1),
        data: (_) =>
            EmptyState(icon: FLucideIcons.searchX, title: l10n.listingNotFound),
      );
    } else {
      final list = ListView(
        padding: Insets.pageList,
        children: [
          // Details left, buying or managing right on wide screens.
          SplitView(
            wide: wide,
            main: [
              if (listing.eventId.isNotEmpty) ...[
                _EventBanner(eventId: listing.eventId),
                const SizedBox(height: Space.xl),
              ],
              ListingTicket(listing: listing, showStatus: true),
              const SizedBox(height: Space.xl),
              _Facts(listing: listing),
              if (buyBar) ...[
                const SizedBox(height: Space.xl),
                const _BuyerProtection(),
              ],
              // Signed-in buyers can report a listing to the team; kept
              // away from the buy button.
              if (buyer && uid != null) ...[
                const SizedBox(height: Space.x3l),
                _ReportButton(listing: listing),
              ],
            ],
            side: [
              if (listing.sellerId == uid)
                _SellerPanel(listing: listing)
              else if (staff)
                // Team accounts don't buy.
                FAlert(
                  icon: const Icon(FLucideIcons.shieldUser),
                  title: Text(l10n.staffNoMarketTitle),
                  subtitle: Text(l10n.staffNoMarketInfo),
                )
              else if (!buyBar)
                _BuyerPanel(listing: listing),
            ],
          ),
        ],
      );
      body = buyBar
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: list),
                _BuyBar(listing: listing),
              ],
            )
          : list;
    }

    return SiteScaffold(
      selectable: true,
      title: l10n.listingDetails,
      maxWidth: SiteWidth.full,
      body: body,
    );
  }
}

/// Opens checkout; the number of tickets is chosen there. Guests are sent
/// to sign-in first and come straight back.
void _buy(BuildContext context, Listing listing) =>
    context.push('/checkout/${listing.id}', extra: (listing, 1));

bool _canBuy(Listing l) => l.status == ListingStatus.active && l.available > 0;

/// Phones: price and the buy button, always in reach.
class _BuyBar extends StatelessWidget {
  const _BuyBar({required this.listing});

  final Listing listing;

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
          padding: const EdgeInsets.fromLTRB(
            Space.xl,
            Space.lg,
            Space.xl,
            Space.lg,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatMoney(
                        context,
                        listing.buyerPriceMinor,
                        listing.currency,
                      ),
                      style: theme.typography.body.xl.copyWith(
                        fontWeight: FontWeights.bold,
                        color: theme.colors.foreground,
                      ),
                    ),
                    Text(
                      '${l10n.offerPerTicket} · '
                      '${l10n.priceInclFee('${listing.fees.buyerPercent}')}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.mutedSmallText,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Space.lg),
              FButton(
                mainAxisSize: MainAxisSize.min,
                onPress: _canBuy(listing) ? () => _buy(context, listing) : null,
                prefix: const Icon(FLucideIcons.shoppingBag),
                child: Text(l10n.buyTickets),
              ),
            ],
          ),
        ),
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
          duration: Motion.slow,
          alignment: Alignment.topCenter,
          child: visible
              ? Padding(
                  padding: const EdgeInsets.only(bottom: Space.md),
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
                      const SizedBox(height: Space.md),
                      Wrap(
                        spacing: Space.sm,
                        runSpacing: Space.sm,
                        children: [
                          EventCategoryBadge(event),
                          EventStatusBadge(event),
                        ],
                      ),
                      if (event.pending) ...[
                        const SizedBox(height: Space.sm),
                        Text(
                          l10n.eventStatusPendingInfo,
                          style: context.theme.mutedSmallText,
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
          duration: Motion.normal,
          child: live && uploaded < listing.quantity
              ? Padding(
                  padding: const EdgeInsets.only(top: Space.xl),
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
                        const SizedBox(height: Space.md),
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
            padding: const EdgeInsets.all(Space.xl),
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
                    padding: .value(EdgeInsets.symmetric(vertical: Space.md)),
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
          duration: Motion.normal,
          child: active
              ? Padding(
                  padding: const EdgeInsets.only(top: Space.xl),
                  child: Wrap(
                    spacing: Space.lg,
                    runSpacing: Space.md,
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
      padding: const EdgeInsets.only(top: Space.md),
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
            duration: Motion.quick,
            child: Text(
              value,
              key: ValueKey(value),
              style: strong
                  ? theme.typography.body.lg.copyWith(
                      fontWeight: FontWeights.bold,
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

/// Wide screens: the price and the buy button beside the details.
class _BuyerPanel extends StatelessWidget {
  const _BuyerPanel({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionTitle(l10n.buyTickets),
        FCard(
          child: Padding(
            padding: const EdgeInsets.all(Space.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatMoney(
                    context,
                    listing.buyerPriceMinor,
                    listing.currency,
                  ),
                  style: theme.typography.display.sm.copyWith(
                    fontWeight: FontWeights.bold,
                    color: theme.colors.foreground,
                  ),
                ),
                Text(
                  '${l10n.offerPerTicket} · '
                  '${l10n.priceInclFee('${listing.fees.buyerPercent}')}',
                  style: theme.mutedText,
                ),
                const SizedBox(height: Space.md),
                Text(l10n.offerAmountAtCheckout, style: theme.mutedSmallText),
              ],
            ),
          ),
        ),
        const SizedBox(height: Space.xl),
        FButton(
          size: FButtonSizeVariant.lg,
          onPress: _canBuy(listing) ? () => _buy(context, listing) : null,
          prefix: const Icon(FLucideIcons.shoppingBag),
          child: Flexible(
            child: Text(l10n.buyTickets, overflow: TextOverflow.ellipsis),
          ),
        ),
        const SizedBox(height: Space.lg),
        const _BuyerProtection(),
      ],
    );
  }
}

/// What buyers are promised.
class _BuyerProtection extends StatelessWidget {
  const _BuyerProtection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Row(
      children: [
        Icon(
          FLucideIcons.shieldCheck,
          size: IconSizes.md,
          color: theme.colors.mutedForeground,
        ),
        const SizedBox(width: Space.md),
        Expanded(
          child: Text(l10n.buyerProtection, style: theme.mutedSmallText),
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
            const SizedBox(height: Space.lg),
            for (final r in ReportReason.values)
              FTile(
                prefix: Icon(
                  r == reason ? FLucideIcons.circleDot : FLucideIcons.circle,
                ),
                title: Text(reportReasonName(l10n, r)),
                onPress: () => setState(() => reason = r),
              ),
            const SizedBox(height: Space.lg),
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
      padding: const EdgeInsets.only(top: Space.lg),
      child: FButton(
        variant: FButtonVariant.ghost,
        onPress: () => _report(context, ref),
        prefix: const Icon(FLucideIcons.flag),
        child: Text(l10n.reportListing),
      ),
    );
  }
}
