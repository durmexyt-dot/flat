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

  @override
  String get orderPendingPayment => 'Awaiting payment';

  @override
  String get orderPaid => 'Paid';

  @override
  String get orderTicketsSent => 'Tickets delivered';

  @override
  String get orderCompleted => 'Completed';

  @override
  String get orderCancelled => 'Cancelled';

  @override
  String get orderRefunded => 'Refunded';

  @override
  String get orderDisputed => 'In dispute';

  @override
  String get payoutPending => 'Waiting for event';

  @override
  String get payoutScheduled => 'Scheduled';

  @override
  String get payoutProcessing => 'Processing';

  @override
  String get payoutPaid => 'Paid out';

  @override
  String get payoutFailed => 'Failed';

  @override
  String get buyerNextPendingPayment =>
      'Complete payment to secure the tickets.';

  @override
  String get buyerNextPaid =>
      'The seller is sending the tickets. You\'ll get them before the event at the latest.';

  @override
  String get buyerNextTicketsSent =>
      'Your tickets were delivered. Check your email or the organizer\'s app.';

  @override
  String get buyerNextCompleted => 'Enjoy the event!';

  @override
  String get buyerNextCancelled =>
      'The order was cancelled. You weren\'t charged.';

  @override
  String get buyerNextRefunded =>
      'The amount was refunded to your payment method.';

  @override
  String get buyerNextDisputed =>
      'Our team is reviewing the order and will get back to you.';

  @override
  String get sellerNextPendingPayment =>
      'The buyer is paying. The tickets are reserved.';

  @override
  String get sellerNextPaid =>
      'Send the tickets to the buyer as soon as possible.';

  @override
  String get sellerNextTicketsSent => 'Your payout follows after the event.';

  @override
  String get sellerNextCompleted => 'Sale complete. See your payouts.';

  @override
  String get sellerNextCancelled =>
      'Order cancelled. The tickets are back on sale.';

  @override
  String get sellerNextRefunded =>
      'The buyer was refunded. There\'s no payout for this sale.';

  @override
  String get sellerNextDisputed =>
      'The buyer reported a problem. The payout waits for the outcome.';

  @override
  String get payoutNextPending =>
      'The money is released once the event has taken place.';

  @override
  String get payoutNextScheduled => 'The payout is in the next payout run.';

  @override
  String get payoutNextProcessing =>
      'The bank is processing the transfer, usually 1–3 business days.';

  @override
  String get payoutNextPaid => 'The money is in your account.';

  @override
  String get payoutNextFailed =>
      'Check your payout method. We\'ll retry after you update it.';

  @override
  String get invoice => 'Invoice';

  @override
  String get orderNumber => 'Order number';

  @override
  String get orderDate => 'Order date';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get saleAmount => 'Sale amount';

  @override
  String get sellerFeeLabel => 'Seller fee';

  @override
  String get yourEarnings => 'Your earnings';

  @override
  String get copied => 'Copied';

  @override
  String get copy => 'Copy';

  @override
  String get whatsNext => 'What\'s next';

  @override
  String get statusHistory => 'Progress';

  @override
  String get orderDetails => 'Order details';

  @override
  String get saleDetails => 'Sale details';

  @override
  String get payoutDetails => 'Payout details';

  @override
  String get purchases => 'Purchases & invoices';

  @override
  String get sales => 'Sales';

  @override
  String get payouts => 'Payouts';

  @override
  String get payoutMethod => 'Payout method';

  @override
  String get noPurchases => 'No purchases yet';

  @override
  String get noPurchasesInfo =>
      'Tickets you buy and their invoices show up here.';

  @override
  String get noSales => 'No sales yet';

  @override
  String get noSalesInfo =>
      'When someone buys your tickets, you\'ll see it here.';

  @override
  String get noPayouts => 'No payouts yet';

  @override
  String get noPayoutsInfo =>
      'Money from sales reaches your account after the event.';

  @override
  String get filterInProgress => 'In progress';

  @override
  String get filterCompleted => 'Completed';

  @override
  String get filterCancelled => 'Cancelled';

  @override
  String get payoutsUpcoming => 'Coming to you';

  @override
  String get payoutsPaidTotal => 'Paid out so far';

  @override
  String expectedOn(String date) {
    return 'Expected $date';
  }

  @override
  String get payoutOrders => 'Orders in this payout';

  @override
  String get failureReason => 'Reason';

  @override
  String get setUpPayout => 'Add payout method';

  @override
  String get payoutMethodMissing =>
      'Add a bank account to receive money from sales.';

  @override
  String get accountHolder => 'Account holder';

  @override
  String get iban => 'IBAN';

  @override
  String get ibanInvalid => 'Invalid IBAN';

  @override
  String get payoutMethodInfo =>
      'Payouts arrive in this account 3–5 business days after the event.';

  @override
  String get payoutMethodSaved => 'Payout method saved';

  @override
  String get change => 'Change';

  @override
  String get buyer => 'Buyer';

  @override
  String get support => 'Support';

  @override
  String get helpCenter => 'Help center';

  @override
  String get contactSupport => 'Contact support';

  @override
  String get about => 'About';

  @override
  String get aboutText =>
      'Stubswap is a safe marketplace to buy and sell event tickets.';

  @override
  String get getHelpOrder => 'Get help with this order';

  @override
  String get getHelpPayout => 'Get help with this payout';

  @override
  String get topic => 'Topic';

  @override
  String get topicOrder => 'Purchase';

  @override
  String get topicSale => 'Sale';

  @override
  String get topicPayout => 'Payout';

  @override
  String get topicAccount => 'Account';

  @override
  String get topicOther => 'Other';

  @override
  String get reference => 'Order or listing number';

  @override
  String get message => 'Message';

  @override
  String get messageHint =>
      'Describe what happened. The more detail, the faster we can help.';

  @override
  String get messageTooShort => 'Please write at least 20 characters';

  @override
  String get send => 'Send';

  @override
  String get requestSent => 'Request sent';

  @override
  String requestSentInfo(String number, String email) {
    return 'Your request number is $number. We\'ll reply to $email, usually within 24 hours.';
  }

  @override
  String get done => 'Done';

  @override
  String get stillNeedHelp => 'Didn\'t find an answer?';

  @override
  String get faqBuySafeQ => 'Is buying on Stubswap safe?';

  @override
  String get faqBuySafeA =>
      'Yes. We hold the money until you have your tickets. If they don\'t arrive on time or aren\'t valid, you get your money back.';

  @override
  String get faqWhenTicketsQ => 'When will I get my tickets?';

  @override
  String get faqWhenTicketsA =>
      'The seller sends them after payment, before the event at the latest. You can follow the status in Purchases & invoices.';

  @override
  String get faqFeesQ => 'What are the fees?';

  @override
  String faqFeesA(String buyer, String seller) {
    return 'Buyers pay a $buyer% service fee on the ticket price. Sellers pay $seller% of the sale price.';
  }

  @override
  String get faqPayoutWhenQ => 'When do I get paid for a sale?';

  @override
  String get faqPayoutWhenA =>
      'After the event the payout is scheduled and reaches your IBAN within 3–5 business days.';

  @override
  String get faqSendTicketsQ => 'How do I send tickets to the buyer?';

  @override
  String get faqSendTicketsA =>
      'Transfer e-tickets and mobile tickets to the buyer\'s email through the organizer. Send paper tickets by registered mail.';

  @override
  String get faqCancelQ => 'What if an event is cancelled?';

  @override
  String get faqCancelA =>
      'Buyers get a full refund and sales are cancelled without a fee for the seller.';

  @override
  String get checkout => 'Checkout';

  @override
  String payAmount(String amount) {
    return 'Pay $amount';
  }

  @override
  String get testModeBadge => 'Test mode · no real money';

  @override
  String get stripeSimulator => 'Stripe simulator';

  @override
  String get simulatorInfo =>
      'Simulated payment. Will be replaced by real Stripe later.';

  @override
  String get cardNumber => 'Card number';

  @override
  String get cardExpiry => 'Expiry';

  @override
  String get cardCvc => 'CVC';

  @override
  String get simulateSuccess => 'Payment succeeds';

  @override
  String get simulateSuccessInfo => 'Turn off to simulate a declined card.';

  @override
  String get declineReason => 'Decline reason';

  @override
  String get failCardDeclined => 'Card declined';

  @override
  String get failInsufficientFunds => 'Insufficient funds';

  @override
  String get failExpiredCard => 'Card expired';

  @override
  String get failProcessingError => 'Processing error';

  @override
  String get failSoldOut => 'The tickets sold out in the meantime';

  @override
  String get processingPayment => 'Processing payment…';

  @override
  String get paymentSucceeded => 'Payment successful';

  @override
  String get paymentFailedTitle => 'Payment failed';

  @override
  String paymentFailedInfo(String reason) {
    return '$reason. You weren\'t charged. Try again or use another card.';
  }

  @override
  String get tryAgain => 'Try again';

  @override
  String get payNow => 'Pay now';

  @override
  String get markTicketsSent => 'Mark tickets as sent';

  @override
  String get ticketsMarkedSent => 'The buyer has been notified';

  @override
  String get buyerEmail => 'Tickets go to';

  @override
  String get notAvailableAnymore => 'This listing is no longer available';

  @override
  String get payoutRequiredTitle => 'Add a payout method first';

  @override
  String get payoutRequiredInfo =>
      'To pay you for your sales we need your bank account (IBAN). After that you can list tickets right away.';

  @override
  String get navEvents => 'Events';

  @override
  String get navMyTickets => 'My tickets';

  @override
  String get openAccountMenu => 'Open account menu';

  @override
  String get heroTitle => 'Tickets for concerts, sports and festivals';

  @override
  String get heroSubtitle =>
      'Buy safely from fans or sell the tickets you can\'t use.';

  @override
  String get howSellingWorks => 'How selling works';

  @override
  String get sellStep1 => 'List your tickets: event, seats and price.';

  @override
  String get sellStep2 =>
      'A buyer pays. We hold the money until the tickets arrive.';

  @override
  String get sellStep3 => 'Send the tickets and mark them as sent.';

  @override
  String get sellStep4 => 'After the event the money reaches your IBAN.';

  @override
  String get ibanBadFormat =>
      'An IBAN starts with a country code and two digits, e.g. BA39 …';

  @override
  String ibanWrongLength(String country, int expected, int actual) {
    return 'An IBAN for $country has $expected characters, you entered $actual.';
  }

  @override
  String get ibanBadChecksum =>
      'The check digits don\'t match. Please check the IBAN\'s digits.';

  @override
  String get cancelSale => 'Cancel sale';

  @override
  String get cancelSaleTitle => 'Cancel this sale?';

  @override
  String get cancelSaleInfo =>
      'The buyer gets all their money back and the tickets go back into your listing. There\'s no payout for this sale. This can\'t be undone.';

  @override
  String get keepSale => 'No, keep it';

  @override
  String get saleCancelled => 'Sale cancelled. The buyer has been refunded.';

  @override
  String get buyerNextCancelledBySeller =>
      'The seller cancelled the sale. You\'ve been refunded in full.';

  @override
  String get sellerNextCancelledBySeller =>
      'You cancelled this sale. The buyer has been refunded and the tickets are on sale again.';

  @override
  String get cannotBuyOwnListing =>
      'These are your tickets. You can\'t buy your own listing.';

  @override
  String get openListing => 'Open listing';
}
