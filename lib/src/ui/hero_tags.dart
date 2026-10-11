/// Tags for shared element (Hero) transitions.
///
/// Every element that should fly between two screens gets one tag here, so
/// source and destination are guaranteed to match. For elements that exist
/// once per item (e.g. event cards), add a function that builds the tag from
/// the item id, like `static String event(String id) => 'event-$id';`.
abstract final class HeroTags {
  static const brandMark = 'brand-mark';
  static const brandWordmark = 'brand-wordmark';
  static const brandTagline = 'brand-tagline';
  static const avatar = 'avatar';
  static String listing(String id) => 'listing-$id';
  static String order(String id) => 'order-$id';
  static String payout(String id) => 'payout-$id';
  static String event(String id) => 'event-$id';
}
