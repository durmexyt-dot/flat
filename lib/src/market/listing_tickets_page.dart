import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_widgets.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../data/tickets_repository.dart';
import '../settings/settings_widgets.dart';
import '../ui/app_dialog.dart';
import '../ui/async_view.dart';
import '../ui/site_scaffold.dart';
import '../ui/skeleton.dart';
import '../ui/snack.dart';
import 'labels.dart';
import 'listing_ticket.dart';
import 'ticket_files_widgets.dart';

/// The seller's ticket files of a listing: upload, status and delete.
/// Uploaded files go to buyers automatically right after they pay.
class ListingTicketsPage extends ConsumerWidget {
  const ListingTicketsPage({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final live = ref.watch(listingProvider(listingId));
    final listing = live.value;
    final uid = ref.watch(currentUidProvider);

    return SiteScaffold(
      title: l10n.deliveryPageTitle,
      maxWidth: SiteWidth.form,
      accountNav: true,
      body: listing == null
          ? AsyncView<Listing?>(
              value: live,
              onRetry: () => ref.invalidate(listingProvider(listingId)),
              loading: const SkeletonTicketList(count: 1),
              data: (_) => EmptyState(
                icon: FLucideIcons.searchX,
                title: l10n.listingNotFound,
              ),
            )
          : listing.sellerId != uid
          ? EmptyState(
              icon: FLucideIcons.shieldOff,
              title: l10n.deliveryNoAccessTitle,
              message: l10n.deliveryNoAccess,
            )
          : _TicketFiles(listing: listing),
    );
  }
}

class _TicketFiles extends ConsumerStatefulWidget {
  const _TicketFiles({required this.listing});

  final Listing listing;

  @override
  ConsumerState<_TicketFiles> createState() => _TicketFilesState();
}

class _TicketFilesState extends ConsumerState<_TicketFiles> {
  bool _uploading = false;

  Listing get _listing => widget.listing;

  Future<void> _add(int remaining) async {
    final l10n = AppLocalizations.of(context);
    final picked = await pickTicketFile();
    if (!mounted) return;
    if (picked == null) {
      if (!kIsWeb) showSnack(l10n.deliveryPickUnsupported);
      return;
    }
    final type = ticketContentType(picked.name, picked.contentType);
    if (type == null) {
      showSnack(l10n.deliveryWrongType);
      return;
    }
    if (picked.bytes.length > maxTicketFileBytes) {
      showSnack(l10n.deliveryTooBig);
      return;
    }
    final tickets = remaining <= 1 ? 1 : await _askTickets(remaining);
    if (tickets == null || !mounted) return;
    setState(() => _uploading = true);
    try {
      await ref
          .read(ticketFileRepositoryProvider)
          .upload(
            listing: _listing,
            bytes: picked.bytes,
            name: picked.name,
            contentType: type,
            tickets: tickets,
          );
      showSnack(l10n.deliveryUploaded);
    } catch (_) {
      showSnack(l10n.deliveryUploadError);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<int?> _askTickets(int max) {
    final l10n = AppLocalizations.of(context);
    final count = ValueNotifier(1);
    return showAppDialog<int>(
      context: context,
      title: l10n.deliveryHowManyTitle,
      body: _TicketCountPicker(max: max, count: count),
      actions: (ctx) => [
        FButton(
          variant: FButtonVariant.outline,
          onPress: () => Navigator.pop(ctx),
          child: Text(l10n.cancel),
        ),
        FButton(
          onPress: () => Navigator.pop(ctx, count.value),
          child: Text(l10n.deliveryUpload),
        ),
      ],
    );
  }

  Future<void> _delete(TicketFile file) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showAppDialog<bool>(
      context: context,
      title: l10n.deliveryDeleteTitle,
      body: Text(l10n.deliveryDeleteInfo),
      actions: (ctx) => [
        FButton(
          variant: FButtonVariant.outline,
          onPress: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        FButton(
          variant: FButtonVariant.destructive,
          onPress: () => Navigator.pop(ctx, true),
          child: Text(l10n.deliveryDelete),
        ),
      ],
    );
    if (ok != true) return;
    try {
      await ref.read(ticketFileRepositoryProvider).delete(_listing.id, file);
      showSnack(l10n.deliveryDeleted);
    } catch (_) {
      showSnack(l10n.saveError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final listing = _listing;
    final eTicket = listing.ticketType == TicketType.eTicket;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        ListingTicket(listing: listing, showStatus: true),
        const SizedBox(height: 16),
        if (eTicket)
          ..._eTickets(context)
        else ...[
          FAlert(
            icon: Icon(
              listing.ticketType == TicketType.mobile
                  ? FLucideIcons.smartphone
                  : FLucideIcons.ticket,
            ),
            title: Text(l10n.deliveryManualTitle),
            subtitle: Text(l10n.deliveryManualInfo),
          ),
          const SizedBox(height: 12),
          FButton(
            variant: FButtonVariant.outline,
            prefix: const Icon(FLucideIcons.store),
            onPress: () => context.push('/account/sales'),
            child: Text(l10n.sales, overflow: TextOverflow.ellipsis),
          ),
        ],
      ],
    );
  }

  List<Widget> _eTickets(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final listing = _listing;
    final filesValue = ref.watch(listingFilesProvider(listing.id));
    final files = filesValue.value ?? const <TicketFile>[];
    final uploaded = ticketsIn(files);
    final remaining = (listing.quantity - uploaded).clamp(0, listing.quantity);
    final sales = {
      for (final o in ref.watch(salesProvider).value ?? const <Order>[])
        o.id: o,
    };
    final active =
        listing.status != ListingStatus.withdrawn &&
        listing.status != ListingStatus.expired;

    return [
      FAlert(
        icon: const Icon(FLucideIcons.info),
        title: Text(l10n.deliveryInfoTitle),
        subtitle: Text(l10n.deliveryInfo),
      ),
      SettingsSectionTitle(l10n.deliveryFilesSection),
      FCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.deliveryProgress(uploaded, listing.quantity),
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              FDeterminateProgress(
                value: listing.quantity == 0
                    ? 0
                    : (uploaded / listing.quantity).clamp(0, 1),
              ),
              if (remaining == 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      FLucideIcons.circleCheck,
                      size: 16,
                      color: theme.colors.mutedForeground,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.deliveryAllUploaded,
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      AnimatedSize(
        duration: const Duration(milliseconds: 250),
        alignment: Alignment.topCenter,
        child: filesValue.isLoading && !filesValue.hasValue
            ? const Shimmer(child: SkeletonBox(height: 64, radius: 12))
            : files.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  l10n.deliveryNoFiles,
                  textAlign: TextAlign.center,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              )
            : FTileGroup(
                children: [
                  for (final f in files)
                    FTile(
                      key: ValueKey(f.id),
                      prefix: Icon(ticketFileIcon(f)),
                      title: Text(f.name, overflow: TextOverflow.ellipsis),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n.deliveryFileTickets(f.tickets)} · '
                            '${formatFileSize(context, f.size)}',
                          ),
                          const SizedBox(height: 6),
                          StatusChip(
                            label: f.assigned
                                ? l10n
                                      .deliverySentTo(
                                        sales[f.orderId]?.number ?? '',
                                      )
                                      .trim()
                                : l10n.deliveryWaiting,
                            tone: f.assigned
                                ? StatusTone.positive
                                : StatusTone.waiting,
                          ),
                        ],
                      ),
                      suffix: f.assigned
                          ? null
                          : FButton.icon(
                              variant: FButtonVariant.ghost,
                              semanticsLabel: l10n.deliveryDelete,
                              onPress: _uploading ? null : () => _delete(f),
                              child: const Icon(FLucideIcons.trash2),
                            ),
                    ),
                ],
              ),
      ),
      if (active && remaining > 0) ...[
        const SizedBox(height: 16),
        SubmitButton(
          label: _uploading ? l10n.deliveryUploading : l10n.deliveryAddFile,
          loading: _uploading,
          onPressed: () => _add(remaining),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.deliveryFileTypes,
          textAlign: TextAlign.center,
          style: theme.typography.body.xs.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      ],
    ];
  }
}

/// How many tickets a file holds: 1 up to [max].
class _TicketCountPicker extends StatelessWidget {
  const _TicketCountPicker({required this.max, required this.count});

  final int max;
  final ValueNotifier<int> count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.deliveryHowManyInfo),
        const SizedBox(height: 16),
        ValueListenableBuilder<int>(
          valueListenable: count,
          builder: (context, n, _) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FButton.icon(
                semanticsLabel: '−',
                onPress: n > 1 ? () => count.value = n - 1 : null,
                child: const Icon(FLucideIcons.minus),
              ),
              SizedBox(
                width: 120,
                child: Text(
                  l10n.deliveryFileTickets(n),
                  textAlign: TextAlign.center,
                  style: theme.typography.body.lg.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colors.foreground,
                  ),
                ),
              ),
              FButton.icon(
                semanticsLabel: '+',
                onPress: n < max ? () => count.value = n + 1 : null,
                child: const Icon(FLucideIcons.plus),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
