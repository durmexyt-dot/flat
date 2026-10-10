import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../data/repositories.dart';
import 'checkout_repository.dart';
import 'payment_gateway.dart';

/// Collects payment for [order] and records the result.
Future<PaymentOutcome> payOrder(
  BuildContext context,
  WidgetRef ref,
  Order order,
) async {
  final outcome = await ref
      .read(paymentGatewayProvider)
      .collect(context, order);
  final checkout = ref.read(checkoutRepositoryProvider);
  try {
    await checkout.completePayment(order, outcome);
  } on SoldOutException {
    const failed = PaymentFailed(PaymentFailure.soldOut);
    await checkout.completePayment(order, failed);
    return failed;
  }
  if (outcome is PaymentSucceeded) ref.invalidate(statsProvider);
  return outcome;
}
