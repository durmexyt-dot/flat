import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_repository.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../settings/settings_widgets.dart';
import '../web/browser_notifications.dart';
import '../ui/snack.dart';
import '../ui/site_scaffold.dart';

/// Which alerts to get and where. Saved in the profile, so the server sends
/// only what the user wants, on every device.
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  /// Shown immediately; Firestore confirms in the background.
  NotificationPrefs? _optimistic;
  PushSupport _push = pushSupport();

  NotificationPrefs get _prefs =>
      _optimistic ??
      ref.read(profileProvider).value?.notifications ??
      const NotificationPrefs();

  Future<void> _set(String key, bool value) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final previous = _prefs;
    final next = previous.copyWithKey(key, value);
    setState(() => _optimistic = next);
    try {
      await ref.read(profileRepositoryProvider).setNotifications(uid, next);
    } catch (_) {
      if (mounted) setState(() => _optimistic = previous);
      showSnack(messenger, l10n.saveError);
    }
  }

  Future<void> _setPush(bool value) async {
    if (!value) return _set('push', false);
    final result = await requestPushPermission();
    if (!mounted) return;
    setState(() => _push = result);
    if (result == PushSupport.granted) {
      await _set('push', true);
      _sendTest();
    }
  }

  void _sendTest() {
    final l10n = AppLocalizations.of(context);
    showTestNotification(l10n.testNotificationTitle, l10n.testNotificationBody);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ref.watch(profileProvider);
    final user = ref.watch(authStateProvider).value;
    final prefs = _prefs;

    Widget toggle(String key, bool value, String title, String info) =>
        SwitchListTile(
          shape: const RoundedRectangleBorder(),
          title: Text(title),
          subtitle: Text(info),
          value: value,
          onChanged: (v) => _set(key, v),
        );

    final pushHint = switch (_push) {
      PushSupport.unsupported => l10n.pushUnsupported,
      PushSupport.denied => l10n.pushDenied,
      _ => null,
    };
    final pushOn = prefs.push && _push == PushSupport.granted;

    return SiteScaffold(
      title: l10n.notifications,
      maxWidth: SiteWidth.form,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          SettingsSectionTitle(l10n.channels),
          SettingsGroup(
            children: [
              SwitchListTile(
                shape: const RoundedRectangleBorder(),
                secondary: const Icon(Icons.email_outlined),
                title: Text(l10n.channelEmail),
                subtitle: Text(l10n.channelEmailInfo(user?.email ?? '')),
                value: prefs.email,
                onChanged: (v) => _set('email', v),
              ),
              SwitchListTile(
                shape: const RoundedRectangleBorder(),
                secondary: const Icon(Icons.notifications_active_outlined),
                title: Text(l10n.channelPush),
                subtitle: pushHint == null ? null : Text(pushHint),
                value: pushOn,
                onChanged:
                    _push == PushSupport.unsupported ||
                        _push == PushSupport.denied
                    ? null
                    : _setPush,
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: pushOn
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _sendTest,
                        icon: const Icon(Icons.send_outlined),
                        label: Text(l10n.sendTestNotification),
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
          SettingsSectionTitle(l10n.buying),
          SettingsGroup(
            children: [
              toggle(
                'orderUpdates',
                prefs.orderUpdates,
                l10n.notifOrderUpdates,
                l10n.notifOrderUpdatesInfo,
              ),
              toggle(
                'eventReminders',
                prefs.eventReminders,
                l10n.notifEventReminders,
                l10n.notifEventRemindersInfo,
              ),
              toggle(
                'priceAlerts',
                prefs.priceAlerts,
                l10n.notifPriceAlerts,
                l10n.notifPriceAlertsInfo,
              ),
            ],
          ),
          SettingsSectionTitle(l10n.selling),
          SettingsGroup(
            children: [
              toggle(
                'saleUpdates',
                prefs.saleUpdates,
                l10n.notifSaleUpdates,
                l10n.notifSaleUpdatesInfo,
              ),
              toggle(
                'payoutUpdates',
                prefs.payoutUpdates,
                l10n.notifPayoutUpdates,
                l10n.notifPayoutUpdatesInfo,
              ),
            ],
          ),
          SettingsSectionTitle(l10n.other),
          SettingsGroup(
            children: [
              toggle(
                'newsletter',
                prefs.newsletter,
                l10n.notifNewsletter,
                l10n.notifNewsletterInfo,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
