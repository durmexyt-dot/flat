import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_repository.dart';
import '../auth/auth_widgets.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../market/listing_ticket.dart';
import '../settings/settings_widgets.dart';
import '../ui/async_view.dart';
import '../ui/format.dart';
import '../ui/responsive_grid.dart';
import '../ui/skeleton.dart';
import '../ui/snack.dart';
import 'checkout_repository.dart';
import 'pay_flow.dart';
import 'payment_gateway.dart';
import 'test_payment_gateway.dart';
import '../ui/site_scaffold.dart';

/// Buying tickets from a listing: summary, then payment.
class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({
    super.key,
    required this.listingId,
    this.initial,
    this.quantity = 1,
  });

  final String listingId;
  final Listing? initial;
  final int quantity;

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  late int _quantity = widget.quantity;
  bool _busy = false;
  PaymentFailure? _failure;

  /// Created on the first pay tap; reused while its payment is open.
  Order? _order;

  Future<void> _pay(Listing listing) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null || _busy) return;
    final l10n = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      final order = _order ??= await ref
          .read(checkoutRepositoryProvider)
          .createOrder(listing: listing, quantity: _quantity, buyerId: uid);
      if (!mounted) return;
      final outcome = await payOrder(context, ref, order);
      switch (outcome) {
        case PaymentSucceeded():
          showSnack(l10n.paymentSucceeded);
          router.pushReplacement('/order/${order.id}');
        case PaymentFailed(:final reason):
          // A failed payment cancels its order; a retry starts a new one.
          _order = null;
          if (mounted) setState(() => _failure = reason);
        case PaymentCancelled():
          break;
      }
    } catch (_) {
      showSnack(l10n.errorUnknown);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final live = ref.watch(listingProvider(widget.listingId));
    final listing = live.value ?? widget.initial;

    return SiteScaffold(
      title: l10n.checkout,
      maxWidth: SiteWidth.full,
      body: listing == null
          ? AsyncView<Listing?>(
              value: live,
              onRetry: () => ref.invalidate(listingProvider(widget.listingId)),
              loading: const SkeletonTicketList(count: 1),
              data: (_) => EmptyState(
                icon: FLucideIcons.searchX,
                title: l10n.listingNotFound,
              ),
            )
          : _body(context, listing),
    );
  }

  Widget _body(BuildContext context, Listing listing) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final gateway = ref.watch(paymentGatewayProvider);
    final email = ref.watch(authStateProvider).value?.email ?? '';
    final available =
        listing.status == ListingStatus.active && listing.available > 0;
    final quantity = _quantity.clamp(1, listing.available.clamp(1, 99));
    final subtotal = listing.priceMinor * quantity;
    final total = subtotal + Fees.buyerFee(subtotal);
    String money(int m) => formatMoney(context, m, listing.currency);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        // The event left, the payment right on wide screens.
        SplitView(
          wide: isWideLayout(context),
          main: [
            ListingTicket(listing: listing),
            if (gateway.isTest) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  avatar: const Icon(FLucideIcons.flaskConical, size: 18),
                  label: Text(l10n.testModeBadge),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ],
          side: [
            SettingsSectionTitle(l10n.tickets),
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
                          onPressed: !_busy && quantity > 1
                              ? () => setState(() {
                                  _quantity = quantity - 1;
                                  _order = null;
                                })
                              : null,
                          icon: const Icon(FLucideIcons.minus),
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
                          onPressed: !_busy && quantity < listing.available
                              ? () => setState(() {
                                  _quantity = quantity + 1;
                                  _order = null;
                                })
                              : null,
                          icon: const Icon(FLucideIcons.plus),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _Line(
                      '$quantity × ${money(listing.priceMinor)}',
                      money(subtotal),
                    ),
                    _Line(
                      '${l10n.serviceFee} (${Fees.buyerPercent} %)',
                      money(Fees.buyerFee(subtotal)),
                    ),
                    const Divider(height: 24),
                    _Line(l10n.total, money(total), strong: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(FLucideIcons.mail),
              title: Text(l10n.buyerEmail),
              subtitle: Text(email),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: _failure == null
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FailureCard(failure: _failure!),
                    ),
            ),
            if (!available)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  l10n.notAvailableAnymore,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            SubmitButton(
              label: _failure == null
                  ? l10n.payAmount(money(total))
                  : l10n.tryAgain,
              loading: _busy,
              onPressed: available ? () => _pay(listing) : () {},
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  FLucideIcons.shieldCheck,
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
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value, {this.strong = false});

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
          Text(
            value,
            style: strong
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

class _FailureCard extends StatelessWidget {
  const _FailureCard({required this.failure});

  final PaymentFailure failure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(FLucideIcons.creditCard, color: colors.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.paymentFailedTitle,
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(color: colors.onErrorContainer),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.paymentFailedInfo(paymentFailureText(l10n, failure)),
                  style: TextStyle(color: colors.onErrorContainer),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
