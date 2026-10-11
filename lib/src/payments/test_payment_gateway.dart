import 'dart:math';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

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
    final outcome = await showFSheet<PaymentOutcome>(
      context: context,
      side: FLayout.btt,
      // The form scrolls itself on short screens.
      mainAxisMaxRatio: null,
      barrierDismissible: false,
      draggable: false,
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
    // Not `1 << 32`: on the web that is 0 (JavaScript shifts in 32 bits).
    final id = 'pi_test_${Random().nextInt(0x7fffffff).toRadixString(16)}';
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
    final theme = context.theme;
    final colors = theme.colors;
    final amount = formatMoney(
      context,
      widget.order.totalMinor,
      widget.order.currency,
    );

    Widget field(String label, String value) => FTextFormField(
      control: FTextFieldControl.managed(
        initial: TextEditingValue(text: value),
      ),
      readOnly: true,
      enabled: !_processing,
      label: Text(label),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.border)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Drag handle look of a bottom sheet.
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: colors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'stripe',
                          style: theme.typography.display.md.copyWith(
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
                        FTooltip(
                          tipBuilder: (context, _) => Text(l10n.cancel),
                          child: FButton.icon(
                            variant: FButtonVariant.ghost,
                            semanticsLabel: l10n.cancel,
                            onPress: _processing
                                ? null
                                : () => Navigator.pop(
                                    context,
                                    const PaymentCancelled(),
                                  ),
                            child: const Icon(FLucideIcons.x),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.simulatorInfo,
                      style: theme.typography.body.sm.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    field(l10n.cardNumber, '4242 4242 4242 4242'),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: field(l10n.cardExpiry, '12 / 34')),
                        const SizedBox(width: 12),
                        Expanded(child: field(l10n.cardCvc, '123')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FCheckbox(
                      value: _succeed,
                      enabled: !_processing,
                      onChange: (v) => setState(() => _succeed = v),
                      label: Text(l10n.simulateSuccess),
                      description: Text(l10n.simulateSuccessInfo),
                    ),
                    const SizedBox(height: 12),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: _succeed
                          ? const SizedBox(width: double.infinity)
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final f in _declines)
                                    FButton(
                                      size: FButtonSizeVariant.sm,
                                      mainAxisSize: MainAxisSize.min,
                                      variant: _failure == f
                                          ? FButtonVariant.primary
                                          : FButtonVariant.outline,
                                      onPress: _processing
                                          ? null
                                          : () => setState(() => _failure = f),
                                      child: Text(paymentFailureText(l10n, f)),
                                    ),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 8),
                    IgnorePointer(
                      ignoring: _processing,
                      child: FButton(
                        size: FButtonSizeVariant.lg,
                        onPress: _pay,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _processing
                              ? Row(
                                  key: const ValueKey('processing'),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FCircularProgress.loader(
                                      style: .delta(
                                        iconStyle: .delta(
                                          color: colors.primaryForeground,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(l10n.processingPayment),
                                  ],
                                )
                              : Text(
                                  l10n.payAmount(amount),
                                  key: const ValueKey('pay'),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
