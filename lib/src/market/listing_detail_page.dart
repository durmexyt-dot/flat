import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_repository.dart';
import '../auth/auth_widgets.dart';
import '../data/models.dart';
import '../data/repositories.dart';
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
                    ListingTicket(listing: listing, showStatus: true),
                    const SizedBox(height: 16),
                    _Facts(listing: listing),
                  ],
                  side: [
                    if (listing.sellerId == uid)
                      _SellerPanel(listing: listing)
                    else
                      _BuyerPanel(listing: listing),
                  ],
                ),
              ],
            ),
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
    final minor = await showAppDialog<int>(
      context: context,
      title: l10n.editPrice,
      body: _PriceForm(key: form, listing: listing),
      actions: (ctx) => [
        FButton(
          variant: FButtonVariant.outline,
          onPress: () => Navigator.pop(ctx),
          child: Text(l10n.cancel),
        ),
        FButton(
          onPress: () => form.currentState?.submit(),
          child: Text(l10n.save),
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
          child: Text(l10n.cancel),
        ),
        FButton(
          variant: FButtonVariant.destructive,
          onPress: () => Navigator.pop(ctx, true),
          child: Text(l10n.withdrawListing),
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
    final l10n = AppLocalizations.of(context);
    final active = listing.status == ListingStatus.active;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                  l10n.youReceive('${Fees.sellerPercent}'),
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
                      FButton(
                        variant: FButtonVariant.secondary,
                        mainAxisSize: MainAxisSize.min,
                        onPress: () => _editPrice(context, ref),
                        prefix: const Icon(FLucideIcons.pencil),
                        child: Text(l10n.editPrice),
                      ),
                      FButton(
                        variant: FButtonVariant.outline,
                        mainAxisSize: MainAxisSize.min,
                        onPress: () => _withdraw(context, ref),
                        prefix: const Icon(FLucideIcons.eyeOff),
                        child: Text(l10n.withdrawListing),
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
  const _PriceForm({super.key, required this.listing});

  final Listing listing;

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
          validator: (v) {
            final m = parseMoney(v ?? '');
            return (m == null || m <= 0) ? l10n.priceInvalid : null;
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
    final fee = Fees.buyerFee(subtotal);
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
                  '${l10n.serviceFee} (${Fees.buyerPercent} %)',
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
        FButton(
          size: FButtonSizeVariant.lg,
          onPress: available ? _buy : null,
          prefix: const Icon(FLucideIcons.shoppingBag),
          child: Text(l10n.buyTickets),
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
