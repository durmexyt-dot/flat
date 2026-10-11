import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_widgets.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_widgets.dart';
import '../ui/app_dialog.dart';
import '../ui/async_view.dart';
import '../ui/format.dart';
import '../ui/site_scaffold.dart';
import '../ui/snack.dart';
import 'admin_page.dart';
import 'admin_repository.dart';

/// Ticket price of the example on the fees page (50,00).
const _examplePriceMinor = 5000;

/// The service fees new listings get: buyer and seller percent.
class FeesPage extends ConsumerWidget {
  const FeesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SiteScaffold(
      title: l10n.adminFeesTitle,
      accountNav: true,
      body: AdminGate(
        builder: (context) => AsyncView<FeeConfig>(
          value: ref.watch(feeConfigProvider),
          loading: const AdminSkeleton(count: 3),
          onRetry: () => ref.invalidate(feeConfigProvider),
          data: (fees) => _FeesForm(current: fees),
        ),
      ),
    );
  }
}

class _FeesForm extends ConsumerStatefulWidget {
  const _FeesForm({required this.current});

  final FeeConfig current;

  @override
  ConsumerState<_FeesForm> createState() => _FeesFormState();
}

class _FeesFormState extends ConsumerState<_FeesForm> {
  late final _buyer = TextEditingController(
    text: '${widget.current.buyerPercent}',
  );
  late final _seller = TextEditingController(
    text: '${widget.current.sellerPercent}',
  );
  bool _saving = false;

  @override
  void didUpdateWidget(_FeesForm old) {
    super.didUpdateWidget(old);
    // Saved elsewhere: follow the new values unless they were being edited.
    if (old.current != widget.current) {
      if (_buyer.text == '${old.current.buyerPercent}') {
        _buyer.text = '${widget.current.buyerPercent}';
      }
      if (_seller.text == '${old.current.sellerPercent}') {
        _seller.text = '${widget.current.sellerPercent}';
      }
    }
  }

  @override
  void dispose() {
    _buyer.dispose();
    _seller.dispose();
    super.dispose();
  }

  static int? _parse(String text) {
    final v = int.tryParse(text.trim());
    return v == null || v < 0 || v > FeeConfig.maxPercent ? null : v;
  }

  /// The entered fees, or null while one is invalid.
  FeeConfig? get _edited {
    final buyer = _parse(_buyer.text);
    final seller = _parse(_seller.text);
    if (buyer == null || seller == null) return null;
    return FeeConfig(buyerPercent: buyer, sellerPercent: seller);
  }

  Future<void> _save() async {
    final fees = _edited;
    final uid = ref.read(currentUidProvider);
    if (_saving || fees == null || uid == null) return;
    final l10n = AppLocalizations.of(context);
    final ok = await showAppDialog<bool>(
      context: context,
      title: l10n.adminFeesConfirmTitle,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.adminFeesSummary(fees.buyerPercent, fees.sellerPercent),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(l10n.adminFeesNotice),
        ],
      ),
      actions: (ctx) => [
        FButton(
          variant: .outline,
          onPress: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        FButton(
          onPress: () => Navigator.pop(ctx, true),
          child: Text(l10n.save),
        ),
      ],
    );
    if (ok != true || !mounted) return;
    setState(() => _saving = true);
    try {
      await ref.read(adminRepositoryProvider).setFees(fees, byUid: uid);
      showSnack(l10n.adminFeesSaved);
    } catch (_) {
      showSnack(l10n.saveError);
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final current = widget.current;
    final edited = _edited;
    final changed = edited != null && edited != current;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Text(
          l10n.adminFeesCurrent(
            l10n.adminFeesSummary(current.buyerPercent, current.sellerPercent),
          ),
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        const SizedBox(height: 16),
        FCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PercentField(
                  key: const ValueKey('buyer-fee'),
                  controller: _buyer,
                  label: l10n.adminBuyerFee,
                  description: l10n.adminBuyerFeeInfo,
                  icon: FLucideIcons.shoppingCart,
                  onChanged: () => setState(() {}),
                ),
                const SizedBox(height: 20),
                _PercentField(
                  key: const ValueKey('seller-fee'),
                  controller: _seller,
                  label: l10n.adminSellerFee,
                  description: l10n.adminSellerFeeInfo,
                  icon: FLucideIcons.store,
                  onChanged: () => setState(() {}),
                ),
              ],
            ),
          ),
        ),
        _Example(fees: edited ?? current),
        const SizedBox(height: 16),
        _Notice(text: l10n.adminFeesNotice),
        const SizedBox(height: 24),
        SubmitButton(
          label: l10n.adminFeesSave,
          loading: _saving,
          onPressed: changed ? _save : null,
        ),
      ],
    );
  }
}

/// A whole percent from 0 to [FeeConfig.maxPercent], typed or stepped with
/// minus and plus (easier than a slider on phones).
class _PercentField extends StatelessWidget {
  const _PercentField({
    super.key,
    required this.controller,
    required this.label,
    required this.description,
    required this.icon,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String description;
  final IconData icon;
  final VoidCallback onChanged;

  void _step(int delta) {
    final v = int.tryParse(controller.text.trim()) ?? 0;
    controller.text = '${(v + delta).clamp(0, FeeConfig.maxPercent)}';
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final value = int.tryParse(controller.text.trim());
    final invalid = value == null || value > FeeConfig.maxPercent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: theme.colors.mutedForeground),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: theme.typography.body.md.copyWith(
                  color: theme.colors.foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          description,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FButton.icon(
              semanticsLabel: '${l10n.adminFeeDecrease} $label',
              onPress: value != null && value > 0 ? () => _step(-1) : null,
              child: const Icon(FLucideIcons.minus),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FTextFormField(
                control: FTextFieldControl.managed(
                  controller: controller,
                  onChange: (_) => onChanged(),
                ),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                suffixBuilder: (context, style, variants) => Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12),
                  child: Text(
                    '%',
                    style: theme.typography.body.md.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ),
                forceErrorText: invalid
                    ? l10n.adminFeeRange(FeeConfig.maxPercent)
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            FButton.icon(
              semanticsLabel: '${l10n.adminFeeIncrease} $label',
              onPress: value == null || value < FeeConfig.maxPercent
                  ? () => _step(1)
                  : null,
              child: const Icon(FLucideIcons.plus),
            ),
          ],
        ),
      ],
    );
  }
}

/// What buyer and seller see for a 50,00 ticket with [fees].
class _Example extends ConsumerWidget {
  const _Example({required this.fees});

  final FeeConfig fees;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final currency = ref.watch(settingsProvider).currency.code;
    String money(int m) => formatMoney(context, m, currency);
    const price = _examplePriceMinor;
    final buyerFee = fees.buyerFee(price);
    final sellerFee = fees.sellerFee(price);

    Widget row(String label, String value, {bool strong = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.typography.body.sm.copyWith(
                color: strong
                    ? theme.colors.foreground
                    : theme.colors.mutedForeground,
                fontWeight: strong ? FontWeight.w600 : null,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Text(
              value,
              key: ValueKey(value),
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.foreground,
                fontWeight: strong ? FontWeight.w600 : FontWeight.w500,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionTitle(l10n.adminFeesExample(money(price))),
        FCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                row(l10n.adminTicketPrice, money(price)),
                row(
                  '${l10n.adminBuyerFee} (${fees.buyerPercent} %)',
                  '+ ${money(buyerFee)}',
                ),
                row(l10n.adminBuyerPays, money(price + buyerFee), strong: true),
                const FDivider(
                  style: .delta(
                    padding: .value(EdgeInsets.symmetric(vertical: 8)),
                  ),
                ),
                row(
                  '${l10n.adminSellerFee} (${fees.sellerPercent} %)',
                  '− ${money(sellerFee)}',
                ),
                row(
                  l10n.adminSellerReceives,
                  money(price - sellerFee),
                  strong: true,
                ),
                const FDivider(
                  style: .delta(
                    padding: .value(EdgeInsets.symmetric(vertical: 8)),
                  ),
                ),
                row(l10n.adminPlatformEarns, money(buyerFee + sellerFee)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A muted info box.
class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.muted,
        borderRadius: theme.style.borderRadius.lg,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(FLucideIcons.info, size: 18, color: theme.colors.foreground),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
