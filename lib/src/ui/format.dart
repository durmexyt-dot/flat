import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const currencySymbols = {'BAM': 'KM', 'EUR': '€', 'USD': r'$'};

String _locale(BuildContext context) =>
    Localizations.localeOf(context).toLanguageTag();

String formatMoney(BuildContext context, int minor, String currency) =>
    NumberFormat.currency(
      locale: _locale(context),
      name: currency,
      symbol: currencySymbols[currency] ?? currency,
      decimalDigits: 2,
    ).format(minor / 100);

String formatDate(BuildContext context, DateTime date) =>
    DateFormat.yMMMd(_locale(context)).format(date);

String formatDateTime(BuildContext context, DateTime date) =>
    DateFormat.yMMMd(_locale(context)).add_Hm().format(date);

/// Short day + month for ticket stubs, e.g. ("14", "OKT").
(String, String) formatStubDate(BuildContext context, DateTime date) => (
  DateFormat.d(_locale(context)).format(date),
  DateFormat.MMM(_locale(context)).format(date).toUpperCase(),
);
