import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_repository.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../settings/settings_widgets.dart';
import '../web/browser_notifications.dart';
import '../ui/snack.dart';
import '../ui/site_scaffold.dart';
import '../ui/tokens.dart';

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
    final previous = _prefs;
    final next = previous.copyWithKey(key, value);
    setState(() => _optimistic = next);
    try {
      await ref.read(profileRepositoryProvider).setNotifications(uid, next);
    } catch (_) {
      if (mounted) setState(() => _optimistic = previous);
      showSnack(l10n.saveError);
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

  Future<void> _sendTest() async {
    final l10n = AppLocalizations.of(context);
    final shown = await showTestNotification(
      l10n.testNotificationTitle,
      l10n.testNotificationBody,
    );
    // Phones may still hide it (e.g. browser notifications off for the
    // whole browser), so say what happened either way.
    showSnack(shown ? l10n.testNotificationSent : l10n.testNotificationFailed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ref.watch(profileProvider);
    final user = ref.watch(authStateProvider).value;
    final prefs = _prefs;

    // Tile subtitles ellipsize by default; these explanations may wrap.
    FTile toggle(String key, bool value, String title, String info) => FTile(
      title: Text(title),
      subtitle: Text(info, overflow: TextOverflow.visible),
      suffix: FSwitch(value: value, onChange: (v) => _set(key, v)),
      onPress: () => _set(key, !value),
    );

    final pushHint = switch (_push) {
      PushSupport.unsupported => l10n.pushUnsupported,
      PushSupport.denied => l10n.pushDenied,
      _ => null,
    };
    final pushOn = prefs.push && _push == PushSupport.granted;
    final pushAvailable =
        _push != PushSupport.unsupported && _push != PushSupport.denied;

    return SiteScaffold(
      title: l10n.notifications,
      maxWidth: SiteWidth.form,
      accountNav: true,
      body: ListView(
        padding: Insets.page,
        children: [
          SettingsSectionTitle(l10n.channels),
          SettingsGroup(
            children: [
              FTile(
                prefix: const Icon(FLucideIcons.mail),
                title: Text(l10n.channelEmail),
                subtitle: Text(
                  l10n.channelEmailInfo(user?.email ?? ''),
                  overflow: TextOverflow.visible,
                ),
                suffix: FSwitch(
                  value: prefs.email,
                  onChange: (v) => _set('email', v),
                ),
                onPress: () => _set('email', !prefs.email),
              ),
              FTile(
                prefix: const Icon(FLucideIcons.bellRing),
                title: Text(l10n.channelPush),
                subtitle: pushHint == null
                    ? null
                    : Text(pushHint, overflow: TextOverflow.visible),
                enabled: pushAvailable,
                suffix: FSwitch(
                  value: pushOn,
                  enabled: pushAvailable,
                  onChange: _setPush,
                ),
                onPress: pushAvailable ? () => _setPush(!pushOn) : null,
              ),
            ],
          ),
          AnimatedSize(
            duration: Motion.normal,
            child: pushOn
                ? Padding(
                    padding: const EdgeInsets.only(top: Space.md),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FButton(
                        variant: .ghost,
                        size: .sm,
                        mainAxisSize: MainAxisSize.min,
                        prefix: const Icon(FLucideIcons.send),
                        onPress: _sendTest,
                        child: Text(l10n.sendTestNotification),
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
          // Only what is actually sent. Event reminders, price alerts and
          // the newsletter come back once they exist.
          SettingsSectionTitle(l10n.buying),
          SettingsGroup(
            children: [
              toggle(
                'orderUpdates',
                prefs.orderUpdates,
                l10n.notifOrderUpdates,
                l10n.notifOrderUpdatesInfo,
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
        ],
      ),
    );
  }
}
