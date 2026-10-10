import 'dart:math';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../ui/format.dart';
import 'payment_gateway.dart';

String paymentFailureText(AppLocalizations l10n, PaymentFailure f) =>
    switch (f) {
      PaymentFailure.cardDeclined => l10n.failCardDeclined,
      PaymentFailure.insufficientFunds => l10n.failInsufficientFunds,
      PaymentFailure.expiredCard => l10n.failExpiredCard,
      PaymentFailure.processingError => l10n.failProcessingError,
      PaymentFailure.soldOut => l10n.failSoldOut,
    };

/// Simulates a card payment: the tester decides whether it succeeds.
class TestPaymentGateway implements PaymentGateway {
  const TestPaymentGateway();

  @override
  bool get isTest => true;

  @override
  Future<PaymentOutcome> collect(BuildContext context, Order order) async {
    final outcome = await showModalBottomSheet<PaymentOutcome>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      isDismissible: false,
      builder: (_) => PaymentSimulatorSheet(order: order),
    );
    return outcome ?? const PaymentCancelled();
  }
}

/// A card form in the style of Stripe Checkout, with a switch for the
/// result.
class PaymentSimulatorSheet extends StatefulWidget {
  const PaymentSimulatorSheet({super.key, required this.order});

  final Order order;

  @override
  State<PaymentSimulatorSheet> createState() => _PaymentSimulatorSheetState();
}

class _PaymentSimulatorSheetState extends State<PaymentSimulatorSheet> {
  bool _succeed = true;
  PaymentFailure _failure = PaymentFailure.cardDeclined;
  bool _processing = false;

  static const _declines = [
    PaymentFailure.cardDeclined,
    PaymentFailure.insufficientFunds,
    PaymentFailure.expiredCard,
    PaymentFailure.processingError,
  ];

  Future<void> _pay() async {
    setState(() => _processing = true);
    // Like a real provider round trip.
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    final id = 'pi_test_${Random().nextInt(1 << 32).toRadixString(16)}';
    Navigator.pop(
      context,
      _succeed
          ? PaymentSucceeded(paymentId: id, methodLabel: 'Visa •••• 4242')
          : PaymentFailed(_failure),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final amount = formatMoney(
      context,
      widget.order.totalMinor,
      widget.order.currency,
    );

    Widget field(String label, String value, {double? width}) => SizedBox(
      width: width,
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        enabled: !_processing,
        decoration: InputDecoration(labelText: label),
      ),
    );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'stripe',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF635BFF),
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDE92),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'TEST',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF983705),
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: l10n.cancel,
                  onPressed: _processing
                      ? null
                      : () => Navigator.pop(context, const PaymentCancelled()),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Text(
              l10n.simulatorInfo,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            field(l10n.cardNumber, '4242 4242 4242 4242'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: field(l10n.cardExpiry, '12 / 34')),
                const SizedBox(width: 12),
                Expanded(child: field(l10n.cardCvc, '123')),
              ],
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _succeed,
              onChanged: _processing
                  ? null
                  : (v) => setState(() => _succeed = v ?? true),
              title: Text(l10n.simulateSuccess),
              subtitle: Text(l10n.simulateSuccessInfo),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _succeed
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final f in _declines)
                            ChoiceChip(
                              label: Text(paymentFailureText(l10n, f)),
                              selected: _failure == f,
                              onSelected: _processing
                                  ? null
                                  : (_) => setState(() => _failure = f),
                            ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _processing ? null : _pay,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: const Color(0xFF635BFF),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF635BFF)
                    .withValues(alpha: 0.7),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _processing
                    ? Row(
                        key: const ValueKey('processing'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.processingPayment,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      )
                    : Text(l10n.payAmount(amount), key: const ValueKey('pay')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
