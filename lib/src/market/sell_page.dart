import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

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
import '../ui/segmented.dart';
import '../ui/snack.dart';
import '../ui/site_scaffold.dart';

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
      showSnack(l10n.listingPublished);
      router.pushReplacement('/listing/$id');
    } catch (_) {
      showSnack(l10n.saveError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authStateProvider).value;
    final currency = ref.watch(settingsProvider).currency;
    final payoutMethod = ref.watch(payoutMethodProvider);
    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? l10n.required : null;

    return SiteScaffold(
      title: l10n.sellTitle,
      maxWidth: SiteWidth.full,
      // No selling without a payout method: the money needs somewhere to go.
      body: AsyncView<PayoutMethod?>(
        value: payoutMethod,
        onRetry: () => ref.invalidate(payoutMethodProvider),
        loading: const SkeletonTicketList(count: 3),
        data: (method) => method == null
            ? const _PayoutRequired()
            : _WithGuide(
                form: Form(
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
                            child: FAlert(
                              icon: const Icon(FLucideIcons.mailWarning),
                              title: Text(l10n.verifyBeforeSelling),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: FButton(
                                    variant: FButtonVariant.outline,
                                    size: FButtonSizeVariant.sm,
                                    mainAxisSize: MainAxisSize.min,
                                    onPress: () =>
                                        context.push('/settings/privacy'),
                                    child: Text(l10n.verifyNow),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        SettingsSectionTitle(l10n.event),
                        FTextFormField(
                          control: FTextFieldControl.managed(controller: _name),
                          label: Text(l10n.eventName),
                          prefixBuilder: (context, style, variants) =>
                              fieldIcon(FLucideIcons.ticket),
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          validator: required,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: FTextFormField(
                                control: FTextFieldControl.managed(
                                  controller: _venue,
                                ),
                                label: Text(l10n.venue),
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                validator: required,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FTextFormField(
                                control: FTextFieldControl.managed(
                                  controller: _city,
                                ),
                                label: Text(l10n.city),
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                validator: required,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _DateField(
                          date: _date,
                          error: _dateError
                              ? (_date == null
                                    ? l10n.required
                                    : l10n.dateInPast)
                              : null,
                          onTap: _pickDate,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final c in EventCategory.values)
                              FButton(
                                size: FButtonSizeVariant.sm,
                                mainAxisSize: MainAxisSize.min,
                                variant: _category == c
                                    ? FButtonVariant.primary
                                    : FButtonVariant.outline,
                                prefix: Icon(categoryIcon(c)),
                                onPress: () => setState(() => _category = c),
                                child: Text(categoryName(l10n, c)),
                              ),
                          ],
                        ),
                        SettingsSectionTitle(l10n.tickets),
                        Segmented<TicketType>(
                          values: TicketType.values,
                          selected: _type,
                          label: (t) => ticketTypeName(l10n, t),
                          onChanged: (t) => setState(() => _type = t),
                        ),
                        const SizedBox(height: 12),
                        _QuantityStepper(
                          value: _quantity,
                          onChanged: (v) => setState(() => _quantity = v),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: FTextFormField(
                                control: FTextFieldControl.managed(
                                  controller: _section,
                                ),
                                label: Text(l10n.section),
                                description: Text(l10n.optional),
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FTextFormField(
                                control: FTextFieldControl.managed(
                                  controller: _row,
                                ),
                                label: Text(l10n.row),
                                description: Text(l10n.optional),
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FTextFormField(
                          control: FTextFieldControl.managed(
                            controller: _seats,
                          ),
                          label: Text(l10n.seats),
                          description: Text(l10n.optional),
                          textInputAction: TextInputAction.next,
                        ),
                        SettingsSectionTitle(l10n.price),
                        FTextFormField(
                          control: FTextFieldControl.managed(
                            controller: _price,
                            onChange: (_) => setState(() {}),
                          ),
                          label: Text(l10n.pricePerTicket),
                          prefixBuilder: (context, style, variants) =>
                              fieldIcon(FLucideIcons.tag),
                          suffixBuilder: (context, style, variants) => Padding(
                            padding: const EdgeInsetsDirectional.only(end: 12),
                            child: Text(
                              currency.symbol,
                              style: context.theme.typography.body.sm.copyWith(
                                color: context.theme.colors.mutedForeground,
                              ),
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
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
                        FTextFormField(
                          control: FTextFieldControl.managed(controller: _note),
                          label: Text(l10n.noteLabel),
                          description: Text(l10n.optional),
                          keyboardType: TextInputType.multiline,
                          maxLines: 3,
                          minLines: 1,
                          maxLength: 300,
                        ),
                        const SizedBox(height: 16),
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
      ),
    );
  }
}

/// The form, and on wide screens a guide to selling next to it.
class _WithGuide extends StatelessWidget {
  const _WithGuide({required this.form});

  final Widget form;

  @override
  Widget build(BuildContext context) {
    if (!isWideLayout(context)) return form;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: SiteWidth.form),
              child: form,
            ),
          ),
        ),
        // The form's scroll padding already adds 16 on its right.
        const SizedBox(width: 16),
        const SizedBox(
          width: 340,
          child: Padding(
            padding: EdgeInsets.only(top: 8, right: 16),
            child: _SellingGuide(),
          ),
        ),
      ],
    );
  }
}

class _SellingGuide extends StatelessWidget {
  const _SellingGuide();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final steps = [
      l10n.sellStep1,
      l10n.sellStep2,
      l10n.sellStep3,
      l10n.sellStep4,
    ];
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.howSellingWorks,
              style: theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colors.foreground,
              ),
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FAvatar.raw(
                      size: 26,
                      child: Text(
                        '${i + 1}',
                        style: theme.typography.body.xs.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colors.foreground,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        steps[i],
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.foreground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const FDivider(
              style: .delta(padding: .value(EdgeInsets.only(bottom: 12))),
            ),
            Text(
              l10n.faqFeesA('${Fees.buyerPercent}', '${Fees.sellerPercent}'),
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
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
          icon: FLucideIcons.landmark,
          title: l10n.payoutRequiredTitle,
          message: l10n.payoutRequiredInfo,
          action: FButton(
            mainAxisSize: MainAxisSize.min,
            onPress: () => context.push('/account/payout-method'),
            prefix: const Icon(FLucideIcons.plus),
            child: Text(l10n.setUpPayout),
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
    // Read-only: tapping opens the date and time pickers.
    return FTextFormField(
      control: FTextFieldControl.lifted(
        value: TextEditingValue(
          text: date == null ? '' : formatDateTime(context, date!),
        ),
        onChange: (_) {},
      ),
      label: Text(l10n.dateTime),
      prefixBuilder: (context, style, variants) =>
          fieldIcon(FLucideIcons.calendar),
      suffixBuilder: (context, style, variants) => Padding(
        padding: const EdgeInsetsDirectional.only(end: 12),
        child: Icon(
          FLucideIcons.chevronDown,
          size: 16,
          color: context.theme.colors.mutedForeground,
        ),
      ),
      readOnly: true,
      enableInteractiveSelection: false,
      onTap: onTap,
      forceErrorText: error,
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
    final theme = context.theme;
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.quantity,
            style: theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colors.foreground,
            ),
          ),
        ),
        FButton.icon(
          variant: FButtonVariant.outline,
          onPress: value > 1 ? () => onChanged(value - 1) : null,
          child: const Icon(FLucideIcons.minus),
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
              style: theme.typography.body.lg.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colors.foreground,
              ),
            ),
          ),
        ),
        FButton.icon(
          variant: FButtonVariant.outline,
          onPress: value < 20 ? () => onChanged(value + 1) : null,
          child: const Icon(FLucideIcons.plus),
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
    final theme = context.theme;
    final perTicket = priceMinor - Fees.sellerFee(priceMinor);

    Widget row(String label, int minor, {bool strong = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.typography.body.sm.copyWith(
                color: strong
                    ? theme.colors.foreground
                    : theme.colors.mutedForeground,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              formatMoney(context, minor, currency),
              key: ValueKey(minor),
              style: strong
                  ? theme.typography.body.lg.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colors.foreground,
                    )
                  : theme.typography.body.sm.copyWith(
                      color: theme.colors.foreground,
                    ),
            ),
          ),
        ],
      ),
    );

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            row(
              l10n.buyerPays('${Fees.buyerPercent}'),
              priceMinor + Fees.buyerFee(priceMinor),
            ),
            row(l10n.youReceive('${Fees.sellerPercent}'), perTicket),
            const FDivider(
              style: .delta(padding: .value(EdgeInsets.symmetric(vertical: 8))),
            ),
            row(l10n.totalPayout, perTicket * quantity, strong: true),
          ],
        ),
      ),
    );
  }
}
