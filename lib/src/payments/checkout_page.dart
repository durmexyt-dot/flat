import 'dart:async';

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
import '../ui/tokens.dart';

/// The clock of the reservation countdown; tests move it forward.
DateTime Function() checkoutNow = DateTime.now;

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

  /// Created on the first pay tap; reused while its payment is open. Its
  /// tickets are held for the buyer for [reservationDuration].
  Order? _order;

  /// The time to pay ran out: the tickets went back on sale.
  bool _expired = false;
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  /// Time left to pay for the held tickets, or null without a hold.
  Duration? get _left {
    final until = _order?.reservedUntil;
    if (until == null) return null;
    final left = until.difference(checkoutNow());
    return left.isNegative ? Duration.zero : left;
  }

  /// Starts the countdown for a new order.
  void _hold(Order order) {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_left == Duration.zero) _expire();
      setState(() {});
    });
  }

  void _expire() {
    _ticker?.cancel();
    _ticker = null;
    if (mounted) setState(() => _expired = true);
  }

  /// Starts over after the hold ran out.
  void _restart() {
    _ticker?.cancel();
    _ticker = null;
    setState(() {
      _order = null;
      _expired = false;
      _failure = null;
    });
  }

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
      var order = _order;
      if (order == null) {
        order = _order = await ref
            .read(checkoutRepositoryProvider)
            .createOrder(listing: listing, quantity: _quantity, buyerId: uid);
        _hold(order);
      }
      if (!mounted) return;
      final outcome = await payOrder(context, ref, order);
      switch (outcome) {
        case PaymentSucceeded():
          showSnack(l10n.paymentSucceeded);
          router.pushReplacement('/order/${order.id}');
        case PaymentFailed(:final reason):
          // A failed payment cancels its order; a retry starts a new one.
          _order = null;
          _ticker?.cancel();
          if (mounted) setState(() => _failure = reason);
        case PaymentCancelled():
          break;
      }
    } on ReservationExpiredException {
      _expire();
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
          // Nobody buys their own tickets (the rules refuse it too).
          : listing.sellerId == ref.watch(currentUidProvider)
          ? EmptyState(
              icon: FLucideIcons.tag,
              title: l10n.yourListing,
              message: l10n.cannotBuyOwnListing,
              action: FButton(
                mainAxisSize: MainAxisSize.min,
                onPress: () =>
                    context.go('/listing/${listing.id}', extra: listing),
                child: Text(l10n.openListing),
              ),
            )
          : _expired
          ? _expiredView(context, listing)
          : _body(context, listing),
    );
  }

  Widget _expiredView(BuildContext context, Listing listing) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Space.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FAlert(
                variant: FAlertVariant.destructive,
                icon: const Icon(FLucideIcons.timerOff),
                title: Text(l10n.reservationExpiredTitle),
                subtitle: Text(l10n.reservationExpiredInfo),
              ),
              const SizedBox(height: Space.xl),
              FButton(
                onPress: () =>
                    context.go('/listing/${listing.id}', extra: listing),
                child: Text(l10n.reservationBackToListing),
              ),
              const SizedBox(height: Space.md),
              FButton(
                variant: FButtonVariant.outline,
                onPress: _restart,
                child: Text(l10n.tryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, Listing listing) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final colors = theme.colors;
    final gateway = ref.watch(paymentGatewayProvider);
    final email = ref.watch(authStateProvider).value?.email ?? '';
    // The listing counts the tickets held for this buyer's own order as
    // taken; they are still theirs to pay for.
    final held = _order?.reserved == true ? _order!.quantity : 0;
    final left = listing.available + held;
    final available =
        (listing.status == ListingStatus.active ||
            (held > 0 && listing.status == ListingStatus.reserved)) &&
        left > 0;
    final locked = _busy || _order != null;
    final quantity = _quantity.clamp(1, left.clamp(1, 99));
    final timeLeft = _left;
    final subtotal = listing.priceMinor * quantity;
    final total = subtotal + listing.fees.buyerFee(subtotal);
    String money(int m) => formatMoney(context, m, listing.currency);
    const divider = FDivider(
      style: .delta(padding: .value(EdgeInsets.symmetric(vertical: Space.lg))),
    );

    return ListView(
      padding: Insets.pageList,
      children: [
        // The event left, the payment right on wide screens.
        SplitView(
          wide: isWideLayout(context),
          main: [
            ListingTicket(listing: listing),
            if (gateway.isTest) ...[
              const SizedBox(height: Space.lg),
              Align(
                alignment: Alignment.centerLeft,
                child: FBadge(
                  variant: FBadgeVariant.secondary,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FLucideIcons.flaskConical, size: IconSizes.xs),
                      const SizedBox(width: Space.xs),
                      Text(l10n.testModeBadge),
                    ],
                  ),
                ),
              ),
            ],
          ],
          side: [
            SettingsSectionTitle(l10n.tickets),
            FCard(
              child: Padding(
                padding: const EdgeInsets.all(Space.xl),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.quantity,
                            style: theme.typography.body.sm.copyWith(
                              color: colors.foreground,
                            ),
                          ),
                        ),
                        FButton.icon(
                          onPress: !locked && quantity > 1
                              ? () => setState(() {
                                  _quantity = quantity - 1;
                                  _order = null;
                                })
                              : null,
                          child: const Icon(FLucideIcons.minus),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            '$quantity',
                            textAlign: TextAlign.center,
                            style: theme.typography.body.lg.copyWith(
                              fontWeight: FontWeights.semibold,
                              color: colors.foreground,
                            ),
                          ),
                        ),
                        FButton.icon(
                          onPress: !locked && quantity < left
                              ? () => setState(() {
                                  _quantity = quantity + 1;
                                  _order = null;
                                })
                              : null,
                          child: const Icon(FLucideIcons.plus),
                        ),
                      ],
                    ),
                    divider,
                    _Line(
                      '$quantity × ${money(listing.priceMinor)}',
                      money(subtotal),
                    ),
                    _Line(
                      '${l10n.serviceFee} (${listing.fees.buyerPercent} %)',
                      money(listing.fees.buyerFee(subtotal)),
                    ),
                    divider,
                    _Line(l10n.total, money(total), strong: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Space.lg),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Space.md),
              child: Row(
                children: [
                  Icon(
                    FLucideIcons.mail,
                    size: IconSizes.md,
                    color: colors.mutedForeground,
                  ),
                  const SizedBox(width: Space.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.buyerEmail,
                          style: theme.typography.body.xs.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                        Text(
                          email,
                          style: theme.typography.body.sm.copyWith(
                            color: colors.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.xs),
            AnimatedSize(
              duration: Motion.normal,
              curve: Motion.enter,
              child: _failure == null
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(bottom: Space.lg),
                      child: _FailureCard(failure: _failure!),
                    ),
            ),
            AnimatedSwitcher(
              duration: Motion.normal,
              child: timeLeft == null
                  ? Padding(
                      key: const ValueKey('hint'),
                      padding: const EdgeInsets.only(bottom: Space.lg),
                      child: Row(
                        children: [
                          Icon(
                            FLucideIcons.timer,
                            size: IconSizes.md,
                            color: colors.mutedForeground,
                          ),
                          const SizedBox(width: Space.md),
                          Expanded(
                            child: Text(
                              l10n.reservationHint,
                              style: theme.typography.body.xs.copyWith(
                                color: colors.mutedForeground,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      key: const ValueKey('held'),
                      padding: const EdgeInsets.only(bottom: Space.lg),
                      child: FAlert(
                        icon: const Icon(FLucideIcons.timer),
                        title: Text(
                          l10n.reservationHeld(_mmss(timeLeft)),
                          style: const TextStyle(
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
            ),
            if (!available)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.lg),
                child: Text(
                  l10n.notAvailableAnymore,
                  textAlign: TextAlign.center,
                  style: theme.typography.body.sm.copyWith(
                    color: colors.destructive,
                  ),
                ),
              ),
            SubmitButton(
              label: _failure == null
                  ? l10n.payAmount(money(total))
                  : l10n.tryAgain,
              loading: _busy,
              onPressed: available ? () => _pay(listing) : () {},
            ),
            const SizedBox(height: Space.lg),
            Row(
              children: [
                Icon(
                  FLucideIcons.shieldCheck,
                  size: IconSizes.md,
                  color: colors.mutedForeground,
                ),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Text(
                    l10n.buyerProtection,
                    style: theme.typography.body.xs.copyWith(
                      color: colors.mutedForeground,
                    ),
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

String _mmss(Duration d) {
  final s = d.inSeconds;
  return '${(s ~/ 60).toString().padLeft(2, '0')}:'
      '${(s % 60).toString().padLeft(2, '0')}';
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value, {this.strong = false});

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final body = theme.typography.body;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: strong
                  ? body.sm.copyWith(
                      fontWeight: FontWeights.semibold,
                      color: colors.foreground,
                    )
                  : body.sm.copyWith(color: colors.mutedForeground),
            ),
          ),
          Text(
            value,
            style: strong
                ? body.lg.copyWith(
                    fontWeight: FontWeights.heavy,
                    color: colors.foreground,
                  )
                : body.sm.copyWith(color: colors.foreground),
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
    return FAlert(
      variant: FAlertVariant.destructive,
      icon: const Icon(FLucideIcons.creditCard),
      title: Text(l10n.paymentFailedTitle),
      subtitle: Text(l10n.paymentFailedInfo(paymentFailureText(l10n, failure))),
    );
  }
}
