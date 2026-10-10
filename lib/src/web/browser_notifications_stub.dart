/// Push permission on this device. Native push needs Firebase Cloud
/// Messaging, which is not set up yet.
enum PushSupport { unsupported, notAsked, granted, denied }

PushSupport pushSupport() => PushSupport.unsupported;

Future<PushSupport> requestPushPermission() async => PushSupport.unsupported;

void showTestNotification(String title, String body) {}
