/// Tags for shared element (Hero) transitions.
///
/// Every element that should fly between two screens gets one tag here, so
/// source and destination are guaranteed to match. For elements that exist
/// once per item (e.g. list entries), add a function that builds the tag
/// from the item id, like `static String item(String id) => 'item-$id';`.
abstract final class HeroTags {
  static const appLogo = 'app-logo';
}
