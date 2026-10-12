import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: the seller's ticket files of a listing (upload, status, delete).
class ListingTicketsPage extends ConsumerWidget {
  const ListingTicketsPage({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => const SizedBox();
}
