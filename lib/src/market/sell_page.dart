import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_repository.dart';
import '../auth/auth_widgets.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_widgets.dart';
import '../ui/async_view.dart';
import '../ui/format.dart';
import '../ui/skeleton.dart';
import 'labels.dart';
import '../ui/snack.dart';

class SellPage extends ConsumerStatefulWidget {
  const SellPage({super.key});

  @override
  ConsumerState<SellPage> createState() => _SellPageState();
}

class _SellPageState extends ConsumerState<SellPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _venue = TextEditingController();
  final _city = TextEditingController();
  final _section = TextEditingController();
  final _row = TextEditingController();
  final _seats = TextEditingController();
  final _price = TextEditingController();
  final _note = TextEditingController();
  DateTime? _date;
  EventCategory _category = EventCategory.concerts;
  TicketType _type = TicketType.eTicket;
  int _quantity = 1;
  bool _saving = false;
  bool _dateError = false;

  @override
  void dispose() {
    for (final c in [
      _name,
      _venue,
      _city,
      _section,
      _row,
      _seats,
      _price,
      _note,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final day = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: _date != null
          ? TimeOfDay.fromDateTime(_date!)
          : const TimeOfDay(hour: 20, minute: 0),
    );
    if (time == null) return;
    setState(() {
      _date = DateTime(day.year, day.month, day.day, time.hour, time.minute);
      _dateError = false;
    });
  }

  Future<void> _publish() async {
    final validDate = _date != null && _date!.isAfter(DateTime.now());
    setState(() => _dateError = !validDate);
    if (!_formKey.currentState!.validate() || !validDate || _saving) return;
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() => _saving = true);
    try {
      final id = await ref
          .read(marketRepositoryProvider)
          .createListing(
            Listing(
              id: '',
              sellerId: uid,
              event: EventInfo(
                name: _name.text.trim(),
                venue: _venue.text.trim(),
                city: _city.text.trim(),
                date: _date!,
                category: _category,
              ),
              ticketType: _type,
              quantity: _quantity,
              quantitySold: 0,
              priceMinor: parseMoney(_price.text)!,
              currency: ref.read(settingsProvider).currency.code,
              status: ListingStatus.active,
              section: _section.text.trim(),
              row: _row.text.trim(),
              seats: _seats.text.trim(),
              note: _note.text.trim(),
            ),
          );
      ref.invalidate(statsProvider);
      showSnack(messenger, l10n.listingPublished);
      router.pushReplacement('/listing/$id');
    } catch (_) {
      showSnack(messenger, l10n.saveError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;
    final currency = ref.watch(settingsProvider).currency;
    final payoutMethod = ref.watch(payoutMethodProvider);
    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? l10n.required : null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sellTitle)),
      // No selling without a payout method: the money needs somewhere to go.
      body: AsyncView<PayoutMethod?>(
        value: payoutMethod,
        onRetry: () => ref.invalidate(payoutMethodProvider),
        loading: const SkeletonTicketList(count: 3),
        data: (method) => method == null
            ? const _PayoutRequired()
            : Form(
                key: _formKey,
                // Not a ListView: it would drop off-screen fields, and the form
                // would skip validating them.
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (user != null && !user.emailVerified)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Card.filled(
                            margin: EdgeInsets.zero,
                            color: theme.colorScheme.secondaryContainer,
                            child: ListTile(
                              leading: const Icon(
                                Icons.mark_email_unread_outlined,
                              ),
                              title: Text(l10n.verifyBeforeSelling),
                              trailing: TextButton(
                                onPressed: () =>
                                    context.push('/settings/privacy'),
                                child: Text(l10n.verifyNow),
                              ),
                            ),
                          ),
                        ),
                      SettingsSectionTitle(l10n.event),
                      TextFormField(
                        controller: _name,
                        decoration: InputDecoration(
                          labelText: l10n.eventName,
                          prefixIcon: const Icon(Icons.local_activity_outlined),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: required,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _venue,
                              decoration: InputDecoration(
                                labelText: l10n.venue,
                              ),
                              textCapitalization: TextCapitalization.words,
                              validator: required,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _city,
                              decoration: InputDecoration(labelText: l10n.city),
                              textCapitalization: TextCapitalization.words,
                              validator: required,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _DateField(
                        date: _date,
                        error: _dateError
                            ? (_date == null ? l10n.required : l10n.dateInPast)
                            : null,
                        onTap: _pickDate,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final c in EventCategory.values)
                            ChoiceChip(
                              avatar: Icon(categoryIcon(c), size: 18),
                              label: Text(categoryName(l10n, c)),
                              selected: _category == c,
                              onSelected: (_) => setState(() => _category = c),
                            ),
                        ],
                      ),
                      SettingsSectionTitle(l10n.tickets),
                      SegmentedButton<TicketType>(
                        segments: [
                          for (final t in TicketType.values)
                            ButtonSegment(
                              value: t,
                              label: Text(ticketTypeName(l10n, t)),
                            ),
                        ],
                        selected: {_type},
                        onSelectionChanged: (s) =>
                            setState(() => _type = s.first),
                      ),
                      const SizedBox(height: 12),
                      _QuantityStepper(
                        value: _quantity,
                        onChanged: (v) => setState(() => _quantity = v),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _section,
                              decoration: InputDecoration(
                                labelText: l10n.section,
                                helperText: l10n.optional,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _row,
                              decoration: InputDecoration(
                                labelText: l10n.row,
                                helperText: l10n.optional,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _seats,
                        decoration: InputDecoration(
                          labelText: l10n.seats,
                          helperText: l10n.optional,
                        ),
                      ),
                      SettingsSectionTitle(l10n.price),
                      TextFormField(
                        controller: _price,
                        decoration: InputDecoration(
                          labelText: l10n.pricePerTicket,
                          prefixIcon: const Icon(Icons.sell_outlined),
                          suffixText: currency.symbol,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (v) {
                          final minor = parseMoney(v ?? '');
                          return (minor == null || minor <= 0)
                              ? l10n.priceInvalid
                              : null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _PriceBreakdown(
                        priceMinor: parseMoney(_price.text) ?? 0,
                        quantity: _quantity,
                        currency: currency.code,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _note,
                        decoration: InputDecoration(
                          labelText: l10n.noteLabel,
                          helperText: l10n.optional,
                        ),
                        maxLines: 3,
                        minLines: 1,
                        maxLength: 300,
                      ),
                      const SizedBox(height: 12),
                      SubmitButton(
                        label: l10n.publishListing,
                        loading: _saving,
                        onPressed: _publish,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

/// Explains why a payout method is needed and leads to the form.
class _PayoutRequired extends StatelessWidget {
  const _PayoutRequired();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        child: EmptyState(
          icon: Icons.account_balance_outlined,
          title: l10n.payoutRequiredTitle,
          message: l10n.payoutRequiredInfo,
          action: FilledButton.icon(
            onPressed: () => context.push('/account/payout-method'),
            icon: const Icon(Icons.add),
            label: Text(l10n.setUpPayout),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.date,
    required this.error,
    required this.onTap,
  });

  final DateTime? date;
  final String? error;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.dateTime,
          prefixIcon: const Icon(Icons.event_outlined),
          errorText: error,
        ),
        isEmpty: date == null,
        child: Text(date == null ? '' : formatDateTime(context, date!)),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Text(l10n.quantity, style: theme.textTheme.titleSmall)),
        IconButton.filledTonal(
          onPressed: value > 1 ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 48,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Text(
              '$value',
              key: ValueKey(value),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
          ),
        ),
        IconButton.filledTonal(
          onPressed: value < 20 ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class _PriceBreakdown extends StatelessWidget {
  const _PriceBreakdown({
    required this.priceMinor,
    required this.quantity,
    required this.currency,
  });

  final int priceMinor;
  final int quantity;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final perTicket = priceMinor - Fees.sellerFee(priceMinor);

    Widget row(String label, int minor, {bool strong = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              formatMoney(context, minor, currency),
              key: ValueKey(minor),
              style: strong
                  ? theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );

    return Card.filled(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            row(
              l10n.buyerPays('${Fees.buyerPercent}'),
              priceMinor + Fees.buyerFee(priceMinor),
            ),
            row(l10n.youReceive('${Fees.sellerPercent}'), perTicket),
            const Divider(),
            row(l10n.totalPayout, perTicket * quantity, strong: true),
          ],
        ),
      ),
    );
  }
}
