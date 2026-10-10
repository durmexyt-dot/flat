import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import 'test_payment_gateway.dart';

enum PaymentFailure {
  cardDeclined,
  insufficientFunds,
  expiredCard,
  processingError,

  /// The tickets were bought by someone else while paying.
  soldOut,
}

sealed class PaymentOutcome {
  const PaymentOutcome();
}

class PaymentSucceeded extends PaymentOutcome {
  const PaymentSucceeded({required this.paymentId, required this.methodLabel});

  /// The provider's reference, e.g. a Stripe PaymentIntent id.
  final String paymentId;

  /// Shown on the invoice, e.g. "Visa •••• 4242".
  final String methodLabel;
}

class PaymentFailed extends PaymentOutcome {
  const PaymentFailed(this.reason);
  final PaymentFailure reason;
}

/// The buyer closed the payment form.
class PaymentCancelled extends PaymentOutcome {
  const PaymentCancelled();
}

/// Collects the money for an order.
///
/// [TestPaymentGateway] simulates it. A Stripe gateway replaces it later:
/// the server creates a PaymentIntent for the order, the app confirms it
/// with Stripe (PaymentSheet on mobile, Elements on web), and a Stripe
/// webhook on the server marks the order as paid.
abstract class PaymentGateway {
  /// Payments don't move real money; the UI marks them as test payments.
  bool get isTest;

  Future<PaymentOutcome> collect(BuildContext context, Order order);
}

final paymentGatewayProvider = Provider<PaymentGateway>(
  (ref) => const TestPaymentGateway(),
);
