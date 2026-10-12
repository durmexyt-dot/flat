import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../data/platform_repository.dart';
import '../data/repositories.dart';
import '../settings/settings_widgets.dart';
import '../ui/async_view.dart';
import '../ui/format.dart';
import '../ui/site_scaffold.dart';
import '../ui/snack.dart';
import 'admin_page.dart';

/// A whole number field in [min]..[max]; empty means null when [optional].
class NumberField extends StatelessWidget {
  const NumberField({
    super.key,
    required this.controller,
    required this.label,
    required this.min,
    required this.max,
    this.description,
    this.optional = false,
    this.suffix,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? description;
  final int min;
  final int max;
  final bool optional;
  final String? suffix;
  final VoidCallback? onChanged;

  /// The value of [text], or null if empty (when allowed) or invalid.
  static int? parse(String text, int min, int max) {
    final v = int.tryParse(text.trim());
    return v == null || v < min || v > max ? null : v;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FTextFormField(
      control: FTextFieldControl.managed(
        controller: controller,
        onChange: (_) => onChanged?.call(),
      ),
      label: Text(label),
      description: description == null ? null : Text(description!),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(5),
      ],
      suffixBuilder: suffix == null
          ? null
          : (context, style, variants) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: Text(suffix!),
            ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (v) {
        final text = (v ?? '').trim();
        if (text.isEmpty && optional) return null;
        return parse(text, min, max) == null
            ? l10n.numberBetween(min, max)
            : null;
      },
    );
  }
}

/// Saves a settings form: confirms nothing, shows "saved" or the error.
Future<void> _saving(
  Future<void> Function() save,
  AppLocalizations l10n,
) async {
  try {
    await save();
    showSnack(l10n.saved);
  } catch (_) {
    showSnack(l10n.saveError);
  }
}

// ---------------------------------------------------------------------------
// Resale rules (admins)
// ---------------------------------------------------------------------------

/// How far above the face value tickets may be resold, for all events
/// (events can have their own limit in the event editor).
class ResaleRulesPage extends ConsumerWidget {
  const ResaleRulesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SiteScaffold(
      title: l10n.resaleTitle,
      accountNav: true,
      body: AdminGate(
        builder: (context) => AsyncView<ResaleConfig>(
          value: ref.watch(resaleConfigProvider),
          loading: const AdminSkeleton(count: 3),
          onRetry: () => ref.invalidate(resaleConfigProvider),
          data: (config) => _ResaleForm(current: config),
        ),
      ),
    );
  }
}

class _ResaleForm extends ConsumerStatefulWidget {
  const _ResaleForm({required this.current});
  final ResaleConfig current;

  @override
  ConsumerState<_ResaleForm> createState() => _ResaleFormState();
}

class _ResaleFormState extends ConsumerState<_ResaleForm> {
  late bool _limited = widget.current.maxMarkupPercent != null;
  late bool _requireFace = widget.current.requireFaceValue;
  late final _markup = TextEditingController(
    text: '${widget.current.maxMarkupPercent ?? 20}',
  );
  bool _busy = false;

  @override
  void dispose() {
    _markup.dispose();
    super.dispose();
  }

  ResaleConfig? get _edited {
    if (!_limited) return ResaleConfig(requireFaceValue: _requireFace);
    final m = NumberField.parse(_markup.text, 0, ResaleConfig.maxMarkup);
    return m == null
        ? null
        : ResaleConfig(maxMarkupPercent: m, requireFaceValue: _requireFace);
  }

  Future<void> _save() async {
    final config = _edited;
    final uid = ref.read(currentUidProvider);
    if (config == null || uid == null) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    await _saving(
      () => ref.read(platformRepositoryProvider).setResale(config, byUid: uid),
      l10n,
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final edited = _edited;
    final changed = edited != null && edited != widget.current;
    final example = edited?.maxMarkupPercent;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.resaleIntro,
            style: context.theme.typography.body.sm.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
          SettingsSectionTitle(l10n.resaleRules),
          SettingsGroup(
            children: [
              FTile(
                prefix: const Icon(FLucideIcons.chartNoAxesColumnIncreasing),
                title: Text(l10n.resaleLimitPrice),
                subtitle: Text(
                  l10n.resaleLimitPriceInfo,
                  overflow: TextOverflow.visible,
                ),
                suffix: FSwitch(
                  value: _limited,
                  onChange: (v) => setState(() => _limited = v),
                ),
                onPress: () => setState(() => _limited = !_limited),
              ),
              FTile(
                prefix: const Icon(FLucideIcons.receiptText),
                title: Text(l10n.resaleRequireFace),
                subtitle: Text(
                  l10n.resaleRequireFaceInfo,
                  overflow: TextOverflow.visible,
                ),
                suffix: FSwitch(
                  value: _requireFace || _limited,
                  onChange: _limited
                      ? null
                      : (v) => setState(() => _requireFace = v),
                ),
                onPress: _limited
                    ? null
                    : () => setState(() => _requireFace = !_requireFace),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            alignment: Alignment.topCenter,
            child: !_limited
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: NumberField(
                      key: const ValueKey('markup'),
                      controller: _markup,
                      label: l10n.resaleMarkup,
                      description: l10n.resaleMarkupInfo,
                      min: 0,
                      max: ResaleConfig.maxMarkup,
                      suffix: '%',
                      onChanged: () => setState(() {}),
                    ),
                  ),
          ),
          if (example != null) ...[
            const SizedBox(height: 12),
            AdminNotice(
              text: l10n.resaleExample(
                formatMoney(context, 5000, 'BAM'),
                formatMoney(context, maxResalePrice(5000, example), 'BAM'),
              ),
            ),
          ],
          const SizedBox(height: 12),
          AdminNotice(text: l10n.resaleNotice),
          const SizedBox(height: 24),
          FButton(
            onPress: changed && !_busy ? _save : null,
            prefix: _busy ? FCircularProgress.loader() : null,
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Limits for new sellers (the team)
// ---------------------------------------------------------------------------

class SellerLimitsPage extends ConsumerWidget {
  const SellerLimitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SiteScaffold(
      title: l10n.limitsTitle,
      accountNav: true,
      body: AdminGate(
        staff: true,
        builder: (context) => AsyncView<SellerLimits>(
          value: ref.watch(sellerLimitsProvider),
          loading: const AdminSkeleton(count: 3),
          onRetry: () => ref.invalidate(sellerLimitsProvider),
          data: (limits) => _LimitsForm(current: limits),
        ),
      ),
    );
  }
}

class _LimitsForm extends ConsumerStatefulWidget {
  const _LimitsForm({required this.current});
  final SellerLimits current;

  @override
  ConsumerState<_LimitsForm> createState() => _LimitsFormState();
}

class _LimitsFormState extends ConsumerState<_LimitsForm> {
  late final _listings = TextEditingController(
    text: '${widget.current.newSellerMaxListings}',
  );
  late final _tickets = TextEditingController(
    text: '${widget.current.newSellerMaxTickets}',
  );
  late final _sales = TextEditingController(
    text: '${widget.current.trustedAfterSales}',
  );
  bool _busy = false;

  @override
  void dispose() {
    _listings.dispose();
    _tickets.dispose();
    _sales.dispose();
    super.dispose();
  }

  SellerLimits? get _edited {
    final l = NumberField.parse(_listings.text, 1, 100);
    final t = NumberField.parse(_tickets.text, 1, 50);
    final s = NumberField.parse(_sales.text, 0, 100);
    return l == null || t == null || s == null
        ? null
        : SellerLimits(
            newSellerMaxListings: l,
            newSellerMaxTickets: t,
            trustedAfterSales: s,
          );
  }

  Future<void> _save() async {
    final limits = _edited;
    final uid = ref.read(currentUidProvider);
    if (limits == null || uid == null) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    await _saving(
      () => ref.read(platformRepositoryProvider).setLimits(limits, byUid: uid),
      l10n,
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final edited = _edited;
    final changed = edited != null && edited != widget.current;
    void update() => setState(() {});
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.limitsIntro,
            style: context.theme.typography.body.sm.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          NumberField(
            controller: _listings,
            label: l10n.limitsListings,
            description: l10n.limitsListingsInfo,
            min: 1,
            max: 100,
            onChanged: update,
          ),
          const SizedBox(height: 16),
          NumberField(
            controller: _tickets,
            label: l10n.limitsTickets,
            description: l10n.limitsTicketsInfo,
            min: 1,
            max: 50,
            onChanged: update,
          ),
          const SizedBox(height: 16),
          NumberField(
            controller: _sales,
            label: l10n.limitsTrusted,
            description: l10n.limitsTrustedInfo,
            min: 0,
            max: 100,
            onChanged: update,
          ),
          const SizedBox(height: 16),
          AdminNotice(text: l10n.limitsNotice),
          const SizedBox(height: 24),
          FButton(
            onPress: changed && !_busy ? _save : null,
            prefix: _busy ? FCircularProgress.loader() : null,
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Company details for invoices (admins)
// ---------------------------------------------------------------------------

class CompanyPage extends ConsumerWidget {
  const CompanyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SiteScaffold(
      title: l10n.companyTitle,
      accountNav: true,
      body: AdminGate(
        builder: (context) => AsyncView<CompanyInfo>(
          value: ref.watch(companyInfoProvider),
          loading: const AdminSkeleton(count: 5),
          onRetry: () => ref.invalidate(companyInfoProvider),
          data: (company) => _CompanyForm(current: company),
        ),
      ),
    );
  }
}

class _CompanyForm extends ConsumerStatefulWidget {
  const _CompanyForm({required this.current});
  final CompanyInfo current;

  @override
  ConsumerState<_CompanyForm> createState() => _CompanyFormState();
}

class _CompanyFormState extends ConsumerState<_CompanyForm> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.current.name);
  late final _address = TextEditingController(text: widget.current.address);
  late final _taxId = TextEditingController(text: widget.current.taxId);
  late final _vatNumber = TextEditingController(text: widget.current.vatNumber);
  late final _vat = TextEditingController(text: '${widget.current.vatPercent}');
  late final _email = TextEditingController(text: widget.current.email);
  late final _prefix = TextEditingController(
    text: widget.current.invoicePrefix,
  );
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [
      _name,
      _address,
      _taxId,
      _vatNumber,
      _vat,
      _email,
      _prefix,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    final l10n = AppLocalizations.of(context);
    final company = CompanyInfo(
      name: _name.text.trim(),
      address: _address.text.trim(),
      taxId: _taxId.text.trim(),
      vatNumber: _vatNumber.text.trim(),
      vatPercent: NumberField.parse(_vat.text, 0, 30)!,
      email: _email.text.trim(),
      invoicePrefix: _prefix.text.trim().toUpperCase(),
    );
    setState(() => _busy = true);
    await _saving(
      () =>
          ref.read(platformRepositoryProvider).setCompany(company, byUid: uid),
      l10n,
    );
    if (mounted) setState(() => _busy = false);
  }

  Widget _text(
    TextEditingController c,
    String label, {
    int max = 120,
    int lines = 1,
    String? description,
    String? Function(String)? check,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: FTextFormField(
      control: FTextFieldControl.managed(controller: c),
      label: Text(label),
      description: description == null ? null : Text(description),
      maxLines: lines,
      minLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(max)],
      validator: check == null ? null : (v) => check((v ?? '').trim()),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Form(
      key: _form,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.companyIntro,
              style: context.theme.typography.body.sm.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 16),
            _text(
              _name,
              l10n.companyName,
              check: (v) => v.isEmpty ? l10n.required : null,
            ),
            _text(_address, l10n.companyAddress, max: 300, lines: 3),
            _text(_taxId, l10n.companyTaxId, max: 40),
            _text(
              _vatNumber,
              l10n.companyVatNumber,
              max: 40,
              description: l10n.optional,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: NumberField(
                controller: _vat,
                label: l10n.companyVat,
                description: l10n.companyVatInfo,
                min: 0,
                max: 30,
                suffix: '%',
              ),
            ),
            _text(_email, l10n.companyEmail),
            _text(
              _prefix,
              l10n.companyPrefix,
              max: 6,
              description: l10n.companyPrefixInfo,
              check: (v) => RegExp(r'^[A-Za-z]{2,6}$').hasMatch(v)
                  ? null
                  : l10n.companyPrefixInvalid,
            ),
            AdminNotice(text: l10n.companyNotice),
            const SizedBox(height: 24),
            FButton(
              onPress: _busy ? null : _save,
              prefix: _busy ? FCircularProgress.loader() : null,
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
