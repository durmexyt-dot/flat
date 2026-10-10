// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Stubswap';

  @override
  String get splashTagline => 'Buy and sell tickets for events';

  @override
  String get loginWelcome => 'Welcome to Stubswap';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get keepSignedIn => 'Keep me signed in';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get loginButton => 'Sign in';

  @override
  String get orDivider => 'or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign up';

  @override
  String get continueAsGuest => 'Browse events as guest';

  @override
  String get signupTitle => 'Create your account';

  @override
  String get nameLabel => 'Name';

  @override
  String get nameRequired => 'Please enter your name';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get passwordsDontMatch => 'Passwords don\'t match';

  @override
  String get createAccountButton => 'Create account';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get resetTitle => 'Reset your password';

  @override
  String get resetInfo =>
      'Enter your email and we\'ll send you a link to reset your password.';

  @override
  String get resetButton => 'Send link';

  @override
  String resetSent(String email) {
    return 'If an account exists for $email, we\'ve sent a reset link.';
  }

  @override
  String get backToLogin => 'Back to sign in';

  @override
  String get emailRequired => 'Please enter your email address';

  @override
  String get emailInvalid => 'Please enter a valid email address';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get errorInvalidCredentials => 'Incorrect email or password';

  @override
  String get errorEmailInUse => 'This email is already registered';

  @override
  String get errorWeakPassword => 'Password is too weak';

  @override
  String get errorUserDisabled => 'This account has been disabled';

  @override
  String get errorTooManyRequests =>
      'Too many attempts. Please try again later';

  @override
  String get errorNetwork => 'No internet connection';

  @override
  String get errorMethodDisabled => 'This sign-in method is not enabled';

  @override
  String get errorUnknown => 'Something went wrong. Please try again';

  @override
  String homeGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get homeGuest => 'You\'re browsing as a guest';

  @override
  String get homeHeadline => 'Find tickets for your next event';

  @override
  String get searchHint => 'Search events, artists, venues';

  @override
  String get catConcerts => 'Concerts';

  @override
  String get catSports => 'Sports';

  @override
  String get catTheater => 'Theater';

  @override
  String get catFestivals => 'Festivals';

  @override
  String get noEvents => 'No events yet';

  @override
  String get noEventsInfo =>
      'Soon you\'ll be able to buy and sell tickets here.';

  @override
  String get sellTickets => 'Sell tickets';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get guestSignInPrompt => 'Sign in to buy and sell tickets';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get currency => 'Currency';

  @override
  String get account => 'Account';

  @override
  String get signedInAs => 'Signed in as';

  @override
  String get guest => 'Guest';

  @override
  String get signInOrUp => 'Sign in or sign up';

  @override
  String get logoutButton => 'Sign out';

  @override
  String get themeModeLabel => 'Mode';

  @override
  String get themeColor => 'Theme color';

  @override
  String get colorViolet => 'Violet';

  @override
  String get colorIndigo => 'Indigo';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorTeal => 'Teal';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorRed => 'Red';

  @override
  String get colorPink => 'Pink';

  @override
  String get textSize => 'Text size';

  @override
  String get textSizeMinimum => 'Minimum';

  @override
  String get textSizeDefault => 'Default';

  @override
  String get textSizeLarge => 'Large';

  @override
  String get textSizeExtraLarge => 'Extra large';

  @override
  String get uiStyle => 'UI style';

  @override
  String get uiRounded => 'Rounded';

  @override
  String get uiSoft => 'Soft';

  @override
  String get uiCrisp => 'Crisp';

  @override
  String get preview => 'Preview';

  @override
  String get previewTickets => '2 tickets · Floor';

  @override
  String get previewButton => 'Buy tickets';

  @override
  String get profileTitle => 'Profile';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameHint =>
      '3–20 characters: lowercase letters, numbers, _ and .';

  @override
  String get usernameInvalid => 'Invalid username';

  @override
  String get usernameTaken => 'Username is taken';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get saveError => 'Couldn\'t save';

  @override
  String get statListed => 'Listed';

  @override
  String get statSold => 'Sold';

  @override
  String get statBought => 'Bought';

  @override
  String get statTickets => 'tickets';

  @override
  String get profilePublic => 'Public profile';

  @override
  String get profilePrivate => 'Private profile';

  @override
  String get personalization => 'Personalization';

  @override
  String get loadError => 'Couldn\'t load';

  @override
  String get loadErrorInfo => 'Check your connection and try again.';

  @override
  String get retry => 'Try again';

  @override
  String get photoError => 'Couldn\'t load the photo';

  @override
  String memberSince(String date) {
    return 'Member since $date';
  }

  @override
  String get privacySecurity => 'Privacy & security';

  @override
  String get privacy => 'Privacy';

  @override
  String get profileVisibility => 'Profile visibility';

  @override
  String get visibilityPublicInfo =>
      'Buyers see your name, username and photo on your listings.';

  @override
  String get visibilityPrivateInfo =>
      'Buyers only see that the seller is verified. Name and photo stay hidden.';

  @override
  String get security => 'Security';

  @override
  String get emailVerified => 'Verified';

  @override
  String get emailNotVerified => 'Not verified';

  @override
  String get verifyEmailInfo =>
      'Verify your email before selling tickets so buyers can reach you.';

  @override
  String get sendVerification => 'Send verification link';

  @override
  String verificationSent(String email) {
    return 'Link sent to $email';
  }

  @override
  String get checkVerification => 'I\'ve verified';

  @override
  String get signInMethods => 'Sign-in methods';

  @override
  String get methodPassword => 'Email and password';

  @override
  String get changePassword => 'Change password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get passwordChanged => 'Password changed';

  @override
  String get dangerZone => 'Danger zone';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountInfo =>
      'Your profile and active listings will be removed permanently. Orders and payouts are kept as long as the law requires.';

  @override
  String get deleteAccountConfirm => 'Confirm with your password';

  @override
  String get deleteAccountGoogle => 'You\'ll confirm with your Google account.';

  @override
  String get cancel => 'Cancel';

  @override
  String get notifications => 'Notifications';

  @override
  String get channels => 'Channels';

  @override
  String get channelEmail => 'Email';

  @override
  String channelEmailInfo(String email) {
    return 'Notifications to $email';
  }

  @override
  String get channelPush => 'Push on this device';

  @override
  String get pushUnsupported =>
      'This browser doesn\'t support notifications. On iPhone, add Stubswap to your home screen.';

  @override
  String get pushDenied =>
      'Notifications are blocked in your browser settings.';

  @override
  String get sendTestNotification => 'Send test notification';

  @override
  String get testNotificationTitle => 'Stubswap notifications work';

  @override
  String get testNotificationBody =>
      'This is how you\'ll hear when your tickets sell.';

  @override
  String get buying => 'Buying';

  @override
  String get selling => 'Selling';

  @override
  String get other => 'Other';

  @override
  String get notifOrderUpdates => 'Order updates';

  @override
  String get notifOrderUpdatesInfo => 'Payment, ticket delivery, refunds';

  @override
  String get notifEventReminders => 'Event reminders';

  @override
  String get notifEventRemindersInfo =>
      'A day before events you have tickets for';

  @override
  String get notifPriceAlerts => 'Price alerts';

  @override
  String get notifPriceAlertsInfo => 'When prices drop for events you follow';

  @override
  String get notifSaleUpdates => 'Ticket sales';

  @override
  String get notifSaleUpdatesInfo =>
      'When tickets sell and you need to send them';

  @override
  String get notifPayoutUpdates => 'Payouts';

  @override
  String get notifPayoutUpdatesInfo => 'Scheduled, sent or failed payouts';

  @override
  String get notifNewsletter => 'News and offers';

  @override
  String get notifNewsletterInfo => 'Occasionally, about new events';

  @override
  String get sellTitle => 'Sell tickets';

  @override
  String get event => 'Event';

  @override
  String get eventName => 'Event name';

  @override
  String get venue => 'Venue';

  @override
  String get city => 'City';

  @override
  String get dateTime => 'Date and time';

  @override
  String get pickDate => 'Pick a date';

  @override
  String get category => 'Category';

  @override
  String get tickets => 'Tickets';

  @override
  String get ticketType => 'Ticket type';

  @override
  String get ticketEticket => 'E-ticket';

  @override
  String get ticketMobile => 'Mobile';

  @override
  String get ticketPaper => 'Paper';

  @override
  String get quantity => 'Quantity';

  @override
  String get section => 'Section';

  @override
  String get row => 'Row';

  @override
  String get seats => 'Seats';

  @override
  String get optional => 'optional';

  @override
  String get price => 'Price';

  @override
  String get pricePerTicket => 'Price per ticket';

  @override
  String buyerPays(String percent) {
    return 'Buyer pays (incl. $percent% fee)';
  }

  @override
  String youReceive(String percent) {
    return 'You receive per ticket ($percent% fee)';
  }

  @override
  String get totalPayout => 'Total payout';

  @override
  String get noteLabel => 'Note for buyers';

  @override
  String get publishListing => 'Publish listing';

  @override
  String get listingPublished => 'Listing published';

  @override
  String get required => 'Required';

  @override
  String get dateInPast => 'Date must be in the future';

  @override
  String get priceInvalid => 'Enter a valid price';

  @override
  String get verifyBeforeSelling =>
      'Verify your email so buyers can trust your listings.';

  @override
  String get verifyNow => 'Verify';

  @override
  String get myListings => 'My listings';

  @override
  String get filterAll => 'All';

  @override
  String get statusActive => 'Active';

  @override
  String get statusReserved => 'Reserved';

  @override
  String get statusSoldOut => 'Sold out';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusWithdrawn => 'Withdrawn';

  @override
  String get ended => 'Ended';

  @override
  String get noListings => 'No listings yet';

  @override
  String get noListingsInfo =>
      'Got tickets you can\'t use? Sell them in minutes.';

  @override
  String ticketsLeft(String count, String total) {
    return '$count of $total available';
  }

  @override
  String ticketsCount(String count) {
    return '$count pcs';
  }

  @override
  String get perTicket => 'per ticket';

  @override
  String get listingDetails => 'Listing details';

  @override
  String get editPrice => 'Change price';

  @override
  String get withdrawListing => 'Withdraw listing';

  @override
  String get withdrawConfirm =>
      'Buyers will no longer see this listing. Continue?';

  @override
  String get listingWithdrawn => 'Listing withdrawn';

  @override
  String get listingNotFound => 'Listing not found';

  @override
  String get yourListing => 'Your listing';

  @override
  String get buyTickets => 'Buy tickets';

  @override
  String get total => 'Total';

  @override
  String get serviceFee => 'Service fee';

  @override
  String get checkoutSoonTitle => 'Checkout coming soon';

  @override
  String get checkoutSoonInfo =>
      'Secure checkout with buyer protection is on its way. You can already browse the listing.';

  @override
  String get buyerProtection =>
      'Buyer protection: valid tickets on time or your money back.';

  @override
  String get sellerVerified => 'Verified seller';

  @override
  String searchNoResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get upcomingEvents => 'Upcoming events';

  @override
  String fromPrice(String price) {
    return 'from $price';
  }

  @override
  String get ok => 'OK';
}
