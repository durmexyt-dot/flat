/// Push permission on this device. Native push needs Firebase Cloud
/// Messaging, which is not set up yet.
enum PushSupport { unsupported, notAsked, granted, denied }

PushSupport pushSupport() => PushSupport.unsupported;

Future<PushSupport> requestPushPermission() async => PushSupport.unsupported;

Future<bool> showTestNotification(String title, String body) async => false;

/// Outside the browser the app is visible while it runs.
bool pageHidden() => false;

void showSystemNotification(
  String title,
  String body, {
  String? tag,
  void Function()? onClick,
}) {}
