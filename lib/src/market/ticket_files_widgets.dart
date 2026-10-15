import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../data/server_actions.dart';
import '../data/tickets_repository.dart';
import '../ui/format.dart';
import '../ui/snack.dart';
import '../web/open_url.dart';
import '../web/pick_file.dart';
import '../ui/tokens.dart';

export '../web/pick_file.dart' show PickedFile;

/// Lets the seller pick a ticket file. Tests replace it, since they can't
/// drive the browser's file dialog.
Future<PickedFile?> Function() pickTicketFile = () =>
    pickFile(accept: {...ticketFileTypes.values}.join(','));

/// Opens a ticket file's download link. Tests replace it.
Future<bool> Function(String url) openTicketUrl = openUrl;

/// The content type for an uploaded ticket file, from its name (or the
/// browser's type); null when it isn't a type sellers may upload.
String? ticketContentType(String name, String browserType) {
  final dot = name.lastIndexOf('.');
  final ext = dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
  return ticketFileTypes[ext] ??
      (ticketFileTypes.containsValue(browserType) ? browserType : null);
}

/// How many tickets the files hold together.
int ticketsIn(Iterable<TicketFile> files) =>
    files.fold(0, (sum, f) => sum + f.tickets);

/// "350 KB", "1,2 MB".
String formatFileSize(BuildContext context, int bytes) {
  final locale = Localizations.localeOf(context).languageCode;
  final sep = locale == 'en' ? '.' : ',';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).ceil()} KB';
  final mb = (bytes / (1024 * 1024)).toStringAsFixed(1);
  return '${mb.replaceAll('.', sep)} MB';
}

IconData ticketFileIcon(TicketFile f) =>
    f.isPdf ? FLucideIcons.fileText : FLucideIcons.fileImage;

/// A readable message for an error from a server action.
String serverErrorText(AppLocalizations l10n, Object error) => switch (error) {
  ServerActionException(code: 'permission-denied' || 'unauthenticated') =>
    l10n.disputeErrorPermission,
  ServerActionException(code: 'failed-precondition') =>
    l10n.disputeErrorTooLate,
  ServerActionException(code: 'invalid-argument') => l10n.disputeErrorInvalid,
  ServerActionException(code: 'not-found') => l10n.disputeErrorNotFound,
  _ => l10n.errorUnknown,
};

/// The sales still waiting for e-tickets: how many tickets, by when, and a
/// way to the first listing that needs them. Nothing when all is uploaded.
class SalesAwaitingTicketsAlert extends ConsumerWidget {
  const SalesAwaitingTicketsAlert({
    super.key,
    this.padding = const EdgeInsets.fromLTRB(Space.xl, Space.md, Space.xl, 0),
  });

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final waiting = [...ref.watch(salesAwaitingTicketsProvider)]
      ..sort((a, b) => a.deliveryDeadline.compareTo(b.deliveryDeadline));
    final missing = waiting.fold(0, (sum, o) => sum + o.ticketsMissing);
    return AnimatedSize(
      duration: Motion.normal,
      alignment: Alignment.topCenter,
      child: waiting.isEmpty
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: padding,
              child: FAlert(
                variant: FAlertVariant.destructive,
                icon: const Icon(FLucideIcons.fileWarning),
                title: Text(l10n.deliverySalesWarning(missing)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.deliveryDeadline(
                        formatDateTime(context, waiting.first.deliveryDeadline),
                      ),
                    ),
                    const SizedBox(height: Space.md),
                    FButton(
                      variant: FButtonVariant.outline,
                      size: FButtonSizeVariant.sm,
                      mainAxisSize: MainAxisSize.min,
                      prefix: const Icon(FLucideIcons.upload),
                      onPress: () => context.push(
                        '/listing/${waiting.first.listingId}/tickets',
                      ),
                      child: Text(
                        l10n.deliveryUploadAction,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// Under a seller's e-ticket listing: a note while not all of its tickets
/// are uploaded, leading to the upload page.
class ListingMissingTickets extends ConsumerWidget {
  const ListingMissingTickets({super.key, required this.listing});

  final Listing listing;

  /// Whether the listing still needs (or can take) ticket files.
  static bool applies(Listing l) =>
      l.ticketType == TicketType.eTicket &&
      l.status != ListingStatus.withdrawn &&
      l.status != ListingStatus.expired;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final files = applies(listing)
        ? ref.watch(listingFilesProvider(listing.id)).value
        : null;
    final show = files != null && ticketsIn(files) < listing.quantity;
    return AnimatedSize(
      duration: Motion.normal,
      alignment: Alignment.topCenter,
      child: !show
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(top: Space.sm),
              child: FTappable(
                semanticsLabel: l10n.deliveryUploadAction,
                onPress: () => context.push('/listing/${listing.id}/tickets'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Space.xs,
                    vertical: Space.sm,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        FLucideIcons.fileWarning,
                        size: IconSizes.sm,
                        color: theme.colors.destructive,
                      ),
                      const SizedBox(width: Space.sm),
                      Expanded(
                        child: Text(
                          l10n.deliveryMissingBadge,
                          style: theme.typography.body.sm.copyWith(
                            color: theme.colors.destructive,
                            fontWeight: FontWeights.semibold,
                          ),
                        ),
                      ),
                      Text(
                        l10n.deliveryUploadAction,
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.foreground,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      Icon(
                        FLucideIcons.chevronRight,
                        size: IconSizes.sm,
                        color: theme.colors.mutedForeground,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

/// The buyer's tickets of an e-ticket order: files to download, or when
/// they are due.
class OrderFilesSection extends ConsumerStatefulWidget {
  const OrderFilesSection({super.key, required this.order});

  final Order order;

  /// Whether the order has (or waits for) ticket files.
  static bool applies(Order o) =>
      o.ticketType == TicketType.eTicket &&
      const {
        OrderStatus.paid,
        OrderStatus.ticketsSent,
        OrderStatus.completed,
        OrderStatus.disputed,
      }.contains(o.status);

  @override
  ConsumerState<OrderFilesSection> createState() => _OrderFilesSectionState();
}

class _OrderFilesSectionState extends ConsumerState<OrderFilesSection> {
  String? _opening;

  Future<void> _download(TicketFile file) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _opening = file.id);
    try {
      final url = await ref
          .read(ticketFileRepositoryProvider)
          .downloadUrl(file);
      if (!await openTicketUrl(url)) showSnack(l10n.deliveryDownloadError);
    } catch (_) {
      showSnack(l10n.deliveryDownloadError);
    } finally {
      if (mounted) setState(() => _opening = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final order = widget.order;
    final files = ref.watch(orderFilesProvider(order.id)).value ?? const [];
    final waiting = order.ticketsMissing > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (files.isNotEmpty)
          FTileGroup(
            children: [
              for (final f in files)
                FTile(
                  prefix: Icon(ticketFileIcon(f)),
                  title: Text(f.name, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    '${l10n.deliveryFileTickets(f.tickets)} · '
                    '${formatFileSize(context, f.size)}',
                  ),
                  suffix: _opening == f.id
                      ? const FCircularProgress(size: .sm)
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l10n.deliveryDownload),
                            const SizedBox(width: Space.sm),
                            const Icon(
                              FLucideIcons.download,
                              size: IconSizes.sm,
                            ),
                          ],
                        ),
                  onPress: _opening == null ? () => _download(f) : null,
                ),
            ],
          ),
        if (waiting) ...[
          if (files.isNotEmpty) const SizedBox(height: Space.lg),
          FAlert(
            icon: const Icon(FLucideIcons.clock),
            title: Text(l10n.deliveryBuyerSection),
            subtitle: Text(
              l10n.deliveryBuyerWaiting(
                formatDateTime(context, order.deliveryDeadline),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
