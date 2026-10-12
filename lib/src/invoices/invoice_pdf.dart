import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import 'invoice_texts.dart';

/// The platform's invoice as an A4 PDF, in the reader's language.
Future<Uint8List> invoicePdf(
  PlatformInvoice inv,
  AppLocalizations l10n,
  String locale,
) async {
  final regular = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
  );
  final bold = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
  );
  final money = NumberFormat.currency(
    locale: locale,
    symbol: currencySymbol(inv.currency),
  );
  String m(int minor) => money.format(minor / 100);
  final date = inv.issuedAt == null
      ? ''
      : DateFormat.yMMMMd(locale).format(inv.issuedAt!);
  const brand = PdfColor.fromInt(0xFF5B2EFF);
  const muted = PdfColor.fromInt(0xFF71717A);
  final small = pw.TextStyle(fontSize: 9, color: muted);
  final company = inv.company;

  pw.Widget row(String label, String value, {bool strong = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(
                label,
                style: strong ? pw.TextStyle(font: bold) : null,
              ),
            ),
            pw.Text(value, style: strong ? pw.TextStyle(font: bold) : null),
          ],
        ),
      );

  final doc = pw.Document(
    title: '${invoiceTitle(l10n, inv)} ${inv.number}',
    author: company.name,
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(48),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.RichText(
                      text: pw.TextSpan(
                        style: pw.TextStyle(font: bold, fontSize: 22),
                        children: [
                          const pw.TextSpan(text: 'Stub'),
                          const pw.TextSpan(
                            text: 'swap',
                            style: pw.TextStyle(color: brand),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(company.name, style: pw.TextStyle(font: bold)),
                    if (company.address.isNotEmpty) pw.Text(company.address),
                    if (company.taxId.isNotEmpty)
                      pw.Text('${l10n.invoiceTaxId}: ${company.taxId}'),
                    if (company.vatNumber.isNotEmpty)
                      pw.Text('${l10n.invoiceVatNumber}: ${company.vatNumber}'),
                    if (company.email.isNotEmpty) pw.Text(company.email),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    invoiceTitle(l10n, inv),
                    style: pw.TextStyle(font: bold, fontSize: 18),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(inv.number),
                  pw.Text(date),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 32),
          pw.Text(l10n.invoiceRecipient, style: small),
          pw.Text(
            inv.recipientName.isEmpty ? inv.recipientEmail : inv.recipientName,
            style: pw.TextStyle(font: bold),
          ),
          if (inv.recipientName.isNotEmpty && inv.recipientEmail.isNotEmpty)
            pw.Text(inv.recipientEmail),
          pw.SizedBox(height: 24),
          if (inv.isCreditNote) ...[
            pw.Text(l10n.invoiceCreditFor(inv.creditFor)),
            pw.SizedBox(height: 12),
          ],
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Text(
                  invoiceLine(l10n, inv),
                  style: pw.TextStyle(font: bold),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  '${l10n.invoiceOrder} ${inv.orderNumber}'
                  '${inv.eventName.isEmpty ? '' : ' · ${inv.eventName}'}',
                  style: small,
                ),
                pw.Text(
                  l10n.invoiceBase(inv.feePercent, m(inv.baseMinor)),
                  style: small,
                ),
                pw.Divider(color: PdfColors.grey300),
                row(l10n.invoiceNet, m(inv.netMinor)),
                row(
                  inv.vatPercent == 0
                      ? l10n.invoiceNoVat
                      : l10n.invoiceVat(inv.vatPercent),
                  m(inv.vatMinor),
                ),
                pw.Divider(color: PdfColors.grey300),
                row(l10n.invoiceGross, m(inv.grossMinor), strong: true),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            inv.forBuyer ? l10n.invoicePaidBuyer : l10n.invoicePaidSeller,
            style: small,
          ),
          pw.Spacer(),
          pw.Text(l10n.invoiceFooter, style: small),
        ],
      ),
    ),
  );
  return doc.save();
}
