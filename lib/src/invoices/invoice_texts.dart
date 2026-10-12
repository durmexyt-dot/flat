import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../ui/format.dart';

String invoiceTitle(AppLocalizations l10n, PlatformInvoice inv) =>
    inv.isCreditNote ? l10n.invoiceCreditNote : l10n.invoiceTitle;

/// What the invoice is for: the buyer's service fee or the seller's fee.
String invoiceLine(AppLocalizations l10n, PlatformInvoice inv) =>
    inv.forBuyer ? l10n.invoiceFeeBuyer : l10n.invoiceFeeSeller;

String currencySymbol(String code) => currencySymbols[code] ?? code;
