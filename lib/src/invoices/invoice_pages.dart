import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../admin/admin_page.dart';
import '../data/models.dart';
import '../data/platform_repository.dart';
import '../settings/settings_widgets.dart';
import '../ui/async_view.dart';
import '../ui/format.dart';
import '../ui/site_scaffold.dart';
import '../ui/skeleton.dart';
import '../ui/snack.dart';
import '../web/save_file.dart';
import 'invoice_pdf.dart';
import 'invoice_texts.dart';

/// Downloads [inv] as a PDF.
Future<void> downloadInvoice(BuildContext context, PlatformInvoice inv) async {
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toLanguageTag();
  try {
    final bytes = await invoicePdf(inv, l10n, locale);
    final saved = await saveFile(bytes, '${inv.number}.pdf', 'application/pdf');
    if (!saved) showSnack(l10n.invoiceDownloadUnavailable);
  } catch (_) {
    showSnack(l10n.loadError);
  }
}

/// One invoice in a list: number, what for, date and amount.
class InvoiceTile extends StatelessWidget with FTileMixin {
  const InvoiceTile({
    super.key,
    required this.invoice,
    this.showRecipient = false,
  });

  final PlatformInvoice invoice;
  final bool showRecipient;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final inv = invoice;
    return FTile(
      prefix: Icon(
        inv.isCreditNote ? FLucideIcons.receiptText : FLucideIcons.receipt,
      ),
      title: Text('${invoiceTitle(l10n, inv)} ${inv.number}'),
      subtitle: Text(
        [
          if (showRecipient)
            inv.recipientName.isEmpty ? inv.recipientEmail : inv.recipientName,
          invoiceLine(l10n, inv),
          if (inv.issuedAt != null) formatDate(context, inv.issuedAt!),
        ].join(' · '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      details: Text(formatMoney(context, inv.grossMinor, inv.currency)),
      suffix: const Icon(FLucideIcons.chevronRight),
      onPress: () => context.push('/invoice/${inv.id}'),
    );
  }
}

/// The signed-in user's invoices for the platform's fees.
class MyInvoicesPage extends ConsumerWidget {
  const MyInvoicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SiteScaffold(
      title: l10n.invoicesTitle,
      accountNav: true,
      body: AsyncView<List<PlatformInvoice>>(
        value: ref.watch(myInvoicesProvider),
        onRetry: () => ref.invalidate(myInvoicesProvider),
        loading: const SkeletonTicketList(count: 3),
        data: (invoices) => invoices.isEmpty
            ? Center(
                child: EmptyState(
                  icon: FLucideIcons.receipt,
                  title: l10n.invoicesEmpty,
                  message: l10n.invoicesInfo,
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                children: [
                  Text(
                    l10n.invoicesInfo,
                    style: context.theme.typography.body.sm.copyWith(
                      color: context.theme.colors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SettingsGroup(
                    children: [
                      for (final i in invoices) InvoiceTile(invoice: i),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

/// The invoices of one order, on the order page (only the reader's own).
class OrderInvoices extends ConsumerWidget {
  const OrderInvoices({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final invoices =
        ref.watch(orderInvoicesProvider(orderId)).value ?? const [];
    if (invoices.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionTitle(l10n.invoicesPlatform),
        SettingsGroup(
          children: [for (final i in invoices) InvoiceTile(invoice: i)],
        ),
      ],
    );
  }
}

/// One invoice, as it is printed, with a PDF download.
class InvoicePage extends ConsumerWidget {
  const InvoicePage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SiteScaffold(
      title: l10n.invoiceTitle,
      accountNav: true,
      body: AsyncView<PlatformInvoice?>(
        value: ref.watch(invoiceProvider(id)),
        onRetry: () => ref.invalidate(invoiceProvider(id)),
        loading: const SkeletonTicketList(count: 2),
        data: (inv) => inv == null
            ? Center(
                child: EmptyState(
                  icon: FLucideIcons.fileX,
                  title: l10n.invoiceNotFound,
                ),
              )
            : _InvoiceView(invoice: inv),
      ),
    );
  }
}

class _InvoiceView extends StatelessWidget {
  const _InvoiceView({required this.invoice});
  final PlatformInvoice invoice;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final inv = invoice;
    final c = inv.company;
    final muted = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );
    final strong = theme.typography.body.md.copyWith(
      fontWeight: FontWeight.w700,
      color: theme.colors.foreground,
    );
    String m(int minor) => formatMoney(context, minor, inv.currency);
    Widget line(String label, String value, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: bold ? strong : null)),
          Text(value, style: bold ? strong : null),
        ],
      ),
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        FCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name, style: strong),
                          if (c.address.isNotEmpty)
                            Text(c.address, style: muted),
                          if (c.taxId.isNotEmpty)
                            Text(
                              '${l10n.invoiceTaxId}: ${c.taxId}',
                              style: muted,
                            ),
                          if (c.vatNumber.isNotEmpty)
                            Text(
                              '${l10n.invoiceVatNumber}: ${c.vatNumber}',
                              style: muted,
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(invoiceTitle(l10n, inv), style: strong),
                        Text(inv.number, style: muted),
                        if (inv.issuedAt != null)
                          Text(
                            formatDate(context, inv.issuedAt!),
                            style: muted,
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(l10n.invoiceRecipient, style: muted),
                Text(
                  inv.recipientName.isEmpty
                      ? inv.recipientEmail
                      : inv.recipientName,
                  style: strong,
                ),
                if (inv.recipientName.isNotEmpty &&
                    inv.recipientEmail.isNotEmpty)
                  Text(inv.recipientEmail, style: muted),
                if (inv.isCreditNote) ...[
                  const SizedBox(height: 12),
                  Text(l10n.invoiceCreditFor(inv.creditFor)),
                ],
                const SizedBox(height: 20),
                Text(invoiceLine(l10n, inv), style: strong),
                Text(
                  '${l10n.invoiceOrder} ${inv.orderNumber}'
                  '${inv.eventName.isEmpty ? '' : ' · ${inv.eventName}'}',
                  style: muted,
                ),
                Text(
                  l10n.invoiceBase(inv.feePercent, m(inv.baseMinor)),
                  style: muted,
                ),
                const FDivider(),
                line(l10n.invoiceNet, m(inv.netMinor)),
                line(
                  inv.vatPercent == 0
                      ? l10n.invoiceNoVat
                      : l10n.invoiceVat(inv.vatPercent),
                  m(inv.vatMinor),
                ),
                const FDivider(),
                line(l10n.invoiceGross, m(inv.grossMinor), bold: true),
                const SizedBox(height: 12),
                Text(
                  inv.forBuyer ? l10n.invoicePaidBuyer : l10n.invoicePaidSeller,
                  style: muted,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FButton(
          onPress: () => downloadInvoice(context, inv),
          prefix: const Icon(FLucideIcons.download),
          child: Text(l10n.invoiceDownload),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Admins: all invoices of a month, totals, CSV export
// ---------------------------------------------------------------------------

/// The invoices as CSV for the accountant (semicolon separated, UTF-8 BOM so
/// spreadsheet programs show č, ć, š, ž).
String invoicesCsv(List<PlatformInvoice> invoices) {
  String cell(Object? v) {
    final s = '$v';
    return s.contains(RegExp('[;"\n]')) ? '"${s.replaceAll('"', '""')}"' : s;
  }

  String amount(int minor) =>
      (minor / 100).toStringAsFixed(2).replaceAll('.', ',');
  final rows = [
    [
      'number',
      'type',
      'date',
      'order',
      'recipient',
      'email',
      'role',
      'net',
      'vat',
      'gross',
      'vatPercent',
      'currency',
      'creditFor',
    ],
    for (final i in [...invoices]..sort((a, b) => a.number.compareTo(b.number)))
      [
        i.number,
        i.type.name,
        i.issuedAt?.toIso8601String().substring(0, 10) ?? '',
        i.orderNumber,
        i.recipientName,
        i.recipientEmail,
        i.recipientRole,
        amount(i.netMinor),
        amount(i.vatMinor),
        amount(i.grossMinor),
        i.vatPercent,
        i.currency,
        i.creditFor,
      ],
  ];
  return '﻿${rows.map((r) => r.map(cell).join(';')).join('\r\n')}\r\n';
}

class AdminInvoicesPage extends ConsumerStatefulWidget {
  const AdminInvoicesPage({super.key});

  @override
  ConsumerState<AdminInvoicesPage> createState() => _AdminInvoicesPageState();
}

class _AdminInvoicesPageState extends ConsumerState<AdminInvoicesPage> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  void _move(int months) =>
      setState(() => _month = DateTime(_month.year, _month.month + months));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final label = MaterialLocalizations.of(context).formatMonthYear(_month);
    final current = DateTime(DateTime.now().year, DateTime.now().month);
    return SiteScaffold(
      title: l10n.adminInvoicesTitle,
      accountNav: true,
      body: AdminGate(
        builder: (context) => AsyncView<List<PlatformInvoice>>(
          value: ref.watch(monthInvoicesProvider(_month)),
          onRetry: () => ref.invalidate(monthInvoicesProvider(_month)),
          loading: const AdminSkeleton(count: 4),
          data: (invoices) {
            int sum(int Function(PlatformInvoice) f) =>
                invoices.fold(0, (s, i) => s + f(i));
            // All in the listing currency; amounts in other currencies are
            // shown in the list.
            final currency = invoices.firstOrNull?.currency ?? 'BAM';
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              children: [
                Row(
                  children: [
                    FButton.icon(
                      variant: FButtonVariant.outline,
                      semanticsLabel: l10n.invoicesPrevMonth,
                      onPress: () => _move(-1),
                      child: const Icon(FLucideIcons.chevronLeft),
                    ),
                    Expanded(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: theme.typography.body.lg.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colors.foreground,
                        ),
                      ),
                    ),
                    FButton.icon(
                      variant: FButtonVariant.outline,
                      semanticsLabel: l10n.invoicesNextMonth,
                      onPress: _month.isBefore(current) ? () => _move(1) : null,
                      child: const Icon(FLucideIcons.chevronRight),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.invoicesCount(invoices.length),
                          style: theme.typography.body.sm.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _Total(
                          l10n.invoiceNet,
                          formatMoney(
                            context,
                            sum((i) => i.netMinor),
                            currency,
                          ),
                        ),
                        _Total(
                          l10n.invoiceVatTotal,
                          formatMoney(
                            context,
                            sum((i) => i.vatMinor),
                            currency,
                          ),
                        ),
                        _Total(
                          l10n.invoiceGross,
                          formatMoney(
                            context,
                            sum((i) => i.grossMinor),
                            currency,
                          ),
                          strong: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FButton(
                  variant: FButtonVariant.outline,
                  onPress: invoices.isEmpty
                      ? null
                      : () async {
                          final ok = await saveFile(
                            utf8.encode(invoicesCsv(invoices)),
                            'stubswap-racuni-${_month.year}-'
                                '${_month.month.toString().padLeft(2, '0')}.csv',
                            'text/csv',
                          );
                          if (!ok) showSnack(l10n.invoiceDownloadUnavailable);
                        },
                  prefix: const Icon(FLucideIcons.sheet),
                  child: Text(l10n.invoicesExport),
                ),
                SettingsSectionTitle(l10n.invoicesTitle),
                if (invoices.isEmpty)
                  Text(
                    l10n.invoicesNoneInMonth,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  )
                else
                  SettingsGroup(
                    children: [
                      for (final i in invoices)
                        InvoiceTile(invoice: i, showRecipient: true),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total(this.label, this.value, {this.strong = false});
  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final style = strong
        ? theme.typography.body.lg.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colors.foreground,
          )
        : theme.typography.body.sm.copyWith(color: theme.colors.foreground);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
