import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_repository.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../settings/settings_widgets.dart';
import '../ui/async_view.dart';
import '../ui/format.dart';
import '../ui/skeleton.dart';
import 'labels.dart';
import 'listing_ticket.dart';
import '../ui/snack.dart';

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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.listingDetails)),
      body: listing == null
          ? AsyncView<Listing?>(
              value: live,
              onRetry: () => ref.invalidate(listingProvider(id)),
              loading: const SkeletonTicketList(count: 1),
              data: (_) => EmptyState(
                icon: Icons.search_off,
                title: l10n.listingNotFound,
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                ListingTicket(listing: listing, showStatus: true),
                const SizedBox(height: 16),
                _Facts(listing: listing),
                if (listing.sellerId == uid)
                  _SellerPanel(listing: listing)
                else
                  _BuyerPanel(listing: listing),
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
        _Fact(
          Icons.event_outlined,
          l10n.dateTime,
          formatDateTime(context, listing.event.date),
        ),
        _Fact(
          Icons.place_outlined,
          l10n.venue,
          '${listing.event.venue}, ${listing.event.city}',
        ),
        _Fact(
          Icons.confirmation_number_outlined,
          l10n.ticketType,
          ticketTypeName(l10n, listing.ticketType),
        ),
        if (seats.isNotEmpty)
          _Fact(Icons.event_seat_outlined, l10n.seats, seats),
        _Fact(
          Icons.inventory_2_outlined,
          l10n.quantity,
          l10n.ticketsLeft('${listing.available}', '${listing.quantity}'),
        ),
        if (listing.note.isNotEmpty)
          _Fact(Icons.notes_outlined, l10n.noteLabel, listing.note),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    shape: const RoundedRectangleBorder(),
    leading: Icon(icon),
    title: Text(label, style: Theme.of(context).textTheme.labelMedium),
    subtitle: Text(value, style: Theme.of(context).textTheme.bodyLarge),
  );
}

class _SellerPanel extends ConsumerWidget {
  const _SellerPanel({required this.listing});

  final Listing listing;

  Future<void> _editPrice(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final minor = await showDialog<int>(
      context: context,
      builder: (_) => _PriceDialog(listing: listing),
    );
    if (minor == null) return;
    try {
      await ref
          .read(marketRepositoryProvider)
          .updateListingPrice(listing.id, minor);
      showSnack(messenger, l10n.saved);
    } catch (_) {
      showSnack(messenger, l10n.saveError);
    }
  }

  Future<void> _withdraw(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.withdrawListing),
        content: Text(l10n.withdrawConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.withdrawListing),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(marketRepositoryProvider).withdrawListing(listing.id);
      ref.invalidate(statsProvider);
      showSnack(messenger, l10n.listingWithdrawn);
    } catch (_) {
      showSnack(messenger, l10n.saveError);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final active = listing.status == ListingStatus.active;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionTitle(l10n.yourListing),
        Card.filled(
          margin: EdgeInsets.zero,
          color: theme.colorScheme.surfaceContainerLow,
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
                const Divider(),
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
                      FilledButton.tonalIcon(
                        onPressed: () => _editPrice(context, ref),
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(l10n.editPrice),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _withdraw(context, ref),
                        icon: const Icon(Icons.visibility_off_outlined),
                        label: Text(l10n.withdrawListing),
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

/// Asks for a new price. Owns its text controller, which must outlive the
/// dialog's closing animation.
class _PriceDialog extends StatefulWidget {
  const _PriceDialog({required this.listing});

  final Listing listing;

  @override
  State<_PriceDialog> createState() => _PriceDialogState();
}

class _PriceDialogState extends State<_PriceDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(
    text: (widget.listing.priceMinor / 100).toStringAsFixed(2),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, parseMoney(_controller.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.editPrice),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.pricePerTicket,
            suffixText: currencySymbols[widget.listing.currency],
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onFieldSubmitted: (_) => _submit(),
          validator: (v) {
            final m = parseMoney(v ?? '');
            return (m == null || m <= 0) ? l10n.priceInvalid : null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.save)),
      ],
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              value,
              key: ValueKey(value),
              style: strong
                  ? theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    )
                  : null,
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
        ScaffoldMessenger.of(context),
        l10n.guestSignInPrompt,
        action: SnackBarAction(
          label: l10n.loginButton,
          onPressed: () {
            ref.read(guestModeProvider.notifier).exit();
            context.go('/login');
          },
        ),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: EmptyState(
          icon: Icons.lock_clock_outlined,
          title: l10n.checkoutSoonTitle,
          message: l10n.checkoutSoonInfo,
          action: FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
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
        Card.filled(
          margin: EdgeInsets.zero,
          color: theme.colorScheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Text(l10n.quantity)),
                    IconButton.filledTonal(
                      onPressed: quantity > 1
                          ? () => setState(() => _quantity = quantity - 1)
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '$quantity',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: quantity < listing.available
                          ? () => setState(() => _quantity = quantity + 1)
                          : null,
                      icon: const Icon(Icons.add),
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
                const Divider(),
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
        FilledButton.icon(
          onPressed: available ? _buy : null,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          icon: const Icon(Icons.shopping_bag_outlined),
          label: Text(l10n.buyTickets),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.verified_user_outlined,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.buyerProtection,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
