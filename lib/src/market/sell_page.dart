import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_repository.dart';
import '../auth/auth_widgets.dart';
import '../data/events_repository.dart';
import '../data/models.dart';
import '../events/event_picker.dart';
import '../admin/admin_repository.dart';
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
  const SellPage({super.key, this.eventId});

  /// Preselected event, e.g. when coming from its page.
  final String? eventId;

  @override
  ConsumerState<SellPage> createState() => _SellPageState();
}

class _SellPageState extends ConsumerState<SellPage> {
  final _formKey = GlobalKey<FormState>();
  final _section = TextEditingController();
  final _row = TextEditingController();
  final _seats = TextEditingController();
  final _price = TextEditingController();
  final _note = TextEditingController();
  Event? _event;
  bool _preselected = false;
  TicketType _type = TicketType.eTicket;
  int _quantity = 1;
  bool _saving = false;
  bool _eventError = false;

  @override
  void dispose() {
    for (final c in [_section, _row, _seats, _price, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  /// The event chosen before, if still on sale, else the preselected one
  /// from the event page.
  Event? _selected(List<Event> events) {
    if (!_preselected) {
      final match = events.where((e) => e.id == widget.eventId).firstOrNull;
      // A just added event may reach the list a moment later: keep
      // looking for it until it's there.
      if (match != null || widget.eventId == null) {
        _preselected = true;
        _event ??= match;
      }
    }
    final id = _event?.id;
    return events.where((e) => e.id == id).firstOrNull;
  }

  Future<void> _chooseEvent(List<Event> events) async {
    final event = await showEventPicker(
      context,
      events: events,
      selectedId: _event?.id,
      onAddEvent: () => _addEvent(context),
    );
    if (event == null || !mounted) return;
    setState(() {
      _event = event;
      _eventError = false;
    });
  }

  Future<void> _publish() async {
    final event = _selected(ref.read(upcomingEventsProvider).value ?? []);
    setState(() => _eventError = event == null);
    if (!_formKey.currentState!.validate() || event == null || _saving) {
      return;
    }
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    final l10n = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    setState(() => _saving = true);
    // Only confirmed email addresses sell (the rules check it too). The
    // link may have been opened meanwhile: check again first.
    if (ref.read(authStateProvider).value?.emailVerified != true) {
      await ref.read(authRepositoryProvider).reloadUser();
      final verified = ref
          .read(authRepositoryProvider)
          .currentUser
          ?.emailVerified;
      if (verified != true) {
        showSnack(l10n.verifyBeforeSelling);
        if (mounted) setState(() => _saving = false);
        return;
      }
    }
    try {
      final id = await ref
          .read(marketRepositoryProvider)
          .createListing(
            Listing(
              id: '',
              sellerId: uid,
              eventId: event.id,
              event: event.info,
              fees: ref.read(feeConfigProvider).value ?? const FeeConfig(),
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
    final payoutMethod = ref.watch(payoutMethodProvider);
    final upcoming = ref.watch(upcomingEventsProvider);

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
            : AsyncView<List<Event>>(
                value: upcoming,
                onRetry: () => ref.invalidate(eventsProvider),
                loading: const SkeletonTicketList(count: 3),
                data: (events) => events.isEmpty
                    ? const _NoEvents()
                    : _form(context, events, user),
              ),
      ),
    );
  }

  Widget _form(BuildContext context, List<Event> events, AppUser? user) {
    final l10n = AppLocalizations.of(context);
    final currency = ref.watch(settingsProvider).currency;
    final selected = _selected(events);
    return _WithGuide(
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
                          onPress: () => context.push('/settings/privacy'),
                          child: Text(
                            l10n.verifyNow,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              SettingsSectionTitle(l10n.event),
              EventField(
                event: selected,
                error: _eventError && selected == null
                    ? l10n.eventsPickRequired
                    : null,
                onTap: () => _chooseEvent(events),
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
                      control: FTextFieldControl.managed(controller: _section),
                      inputFormatters: [LengthLimitingTextInputFormatter(40)],
                      label: Text(l10n.section),
                      description: Text(l10n.optional),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FTextFormField(
                      control: FTextFieldControl.managed(controller: _row),
                      inputFormatters: [LengthLimitingTextInputFormatter(40)],
                      label: Text(l10n.row),
                      description: Text(l10n.optional),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FTextFormField(
                control: FTextFieldControl.managed(controller: _seats),
                inputFormatters: [LengthLimitingTextInputFormatter(60)],
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

class _SellingGuide extends ConsumerWidget {
  const _SellingGuide();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fees = ref.watch(feeConfigProvider).value ?? const FeeConfig();
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
              l10n.faqFeesA('${fees.buyerPercent}', '${fees.sellerPercent}'),
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
            child: Text(l10n.setUpPayout, overflow: TextOverflow.ellipsis),
          ),
        ),
      ),
    );
  }
}

/// Adds a missing event: the editor comes back here with it preselected.
/// It replaces this page, so going back afterwards doesn't land on an
/// outdated sell form.
void _addEvent(BuildContext context) =>
    GoRouter.of(context).pushReplacement('/events/new?sell=1');

/// No upcoming events yet: users can add theirs.
class _NoEvents extends StatelessWidget {
  const _NoEvents();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        child: EmptyState(
          icon: FLucideIcons.calendarX,
          title: l10n.eventsNoneToSell,
          message: l10n.eventsUserNoneToSellInfo,
          action: AddEventPrompt(onPress: () => _addEvent(context)),
        ),
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

class _PriceBreakdown extends ConsumerWidget {
  const _PriceBreakdown({
    required this.priceMinor,
    required this.quantity,
    required this.currency,
  });

  final int priceMinor;
  final int quantity;
  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fees = ref.watch(feeConfigProvider).value ?? const FeeConfig();
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final perTicket = priceMinor - fees.sellerFee(priceMinor);

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
              l10n.buyerPays('${fees.buyerPercent}'),
              priceMinor + fees.buyerFee(priceMinor),
            ),
            row(l10n.youReceive('${fees.sellerPercent}'), perTicket),
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
