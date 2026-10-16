// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String datesNearbyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events near you',
      one: '1 event near you',
    );
    return '$_temp0';
  }

  @override
  String get datesNoneNearby => 'No events near you';

  @override
  String datesNoneNearbyInfo(String city) {
    return 'There is no date in or around $city right now.';
  }

  @override
  String datesElsewhereCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events at other venues',
      one: '1 event at another venue',
    );
    return '$_temp0';
  }

  @override
  String datesAllCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dates',
      one: '1 date',
    );
    return '$_temp0';
  }

  @override
  String get datesPickCity => 'Choose your city to see events near you';

  @override
  String datesNearCity(String city) {
    return 'Near $city';
  }

  @override
  String get showTickets => 'Show tickets';

  @override
  String get noTicketsAvailable => 'No tickets';

  @override
  String ticketsFrom(String price) {
    return 'from $price';
  }

  @override
  String get ticketsPageTitle => 'Tickets';

  @override
  String get otherDates => 'Other dates';

  @override
  String get seatMapSoon => 'Seat map coming soon';

  @override
  String get seatMapSoonInfo =>
      'There is no seat map for this venue yet. Each offer shows its section and row.';

  @override
  String get seatMapHint => 'Tap a section to see only its offers';

  @override
  String get seatMapStage => 'Stage';

  @override
  String seatMapSectionOffers(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offers',
      one: '1 offer',
      zero: 'no offers',
    );
    return '$name: $_temp0';
  }

  @override
  String sectionFilter(String name) {
    return 'Section: $name';
  }

  @override
  String get filtersMore => 'Price and ticket type';

  @override
  String get filterPrice => 'Price per ticket';

  @override
  String get filterTicketType => 'Ticket type';

  @override
  String get filterTogether => 'Seats together';

  @override
  String get filterTogetherInfo =>
      'Only offers whose seller says the seats are next to each other';

  @override
  String get filtersReset => 'Reset filters';

  @override
  String get offersNoneForFilters => 'No offer matches the filters';

  @override
  String get offerTogether => 'Together';

  @override
  String get sellTogether => 'The seats are next to each other';

  @override
  String get sellTogetherInfo =>
      'Buyers who want seats together find you more easily.';

  @override
  String get sellSectionsOfVenue => 'Sections of this venue';

  @override
  String get eventPerformer => 'Performer / tour (optional)';

  @override
  String get eventPerformerInfo =>
      'Dates of the same performer in other cities are shown together.';

  @override
  String get adminSeatMaps => 'Seat maps';

  @override
  String get adminSeatMapsInfo =>
      'Venue sections, for buyers on the tickets page';

  @override
  String get seatMapNone => 'No map';

  @override
  String seatMapSectionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sections',
      one: '1 section',
    );
    return '$_temp0';
  }

  @override
  String get seatMapTitle => 'Seat map';

  @override
  String get seatMapPicture => 'Floor plan picture (optional)';

  @override
  String get seatMapPictureHint =>
      'The picture is not cropped. Without one the sections are drawn on a blank area.';

  @override
  String get seatMapDrawHint =>
      'Drag to draw a section. Tap a section to rename or delete it.';

  @override
  String get seatMapDrawSection => 'Section';

  @override
  String get seatMapSectionName => 'Section name';

  @override
  String seatMapSectionDefault(int n) {
    return 'Section $n';
  }

  @override
  String get seatMapDeleteSection => 'Delete section';

  @override
  String get seatMapRemoveStage => 'Remove stage';

  @override
  String get seatMapDelete => 'Delete map';

  @override
  String get seatMapDeleteInfo =>
      'Buyers will no longer see a map for this venue.';

  @override
  String seatMapUnmatched(String names) {
    return 'Sections from offers missing on the map: $names';
  }

  @override
  String get seatMapDuplicate => 'Two sections have the same name';

  @override
  String get seatMapVenues => 'Venues from events';

  @override
  String get quantityDecrease => 'One ticket fewer';

  @override
  String get quantityIncrease => 'One more ticket';

  @override
  String get offersHowMany => 'How many tickets do you need together?';

  @override
  String get navInbox => 'Requests';

  @override
  String get navSell => 'Sell';

  @override
  String get accountGroupHelp => 'Help';

  @override
  String get accountGroupTeam => 'Team';

  @override
  String get profileAndSettings => 'Profile & settings';

  @override
  String get offerAmountAtCheckout => 'You choose how many in the next step.';

  @override
  String get offerAvailable => 'available';

  @override
  String get offerPerTicket => 'per ticket';

  @override
  String get offerNoSeats => 'No seats given';

  @override
  String eventsOffersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offers',
      one: '1 offer',
    );
    return '$_temp0';
  }

  @override
  String get offersAnyAmount => 'All';

  @override
  String offersAmount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tickets',
      one: 'ticket',
    );
    return '$count $_temp0';
  }

  @override
  String offersAmountOrMore(int count) {
    return '$count+';
  }

  @override
  String offersNoneForAmount(int count) {
    return 'No offer for $count tickets together';
  }

  @override
  String get offersNoneForAmountInfo =>
      'Try fewer tickets or check back later.';

  @override
  String get eventsHaveTickets => 'Got tickets for this event?';

  @override
  String get eventsHaveTicketsInfo => 'Sell them safely to fans who need them.';

  @override
  String get signInToContinue => 'Sign in or create an account to continue.';

  @override
  String get handoverSection => 'Ticket handover';

  @override
  String get handoverTitle => 'How did you hand over the tickets?';

  @override
  String get handoverSubmit => 'Tickets handed over';

  @override
  String get handoverInfoMobile =>
      'Transfer the tickets in the organizer’s app (e.g. Eventim, Ticketmaster) to the buyer’s account and say to whom. These details help if there is a problem.';

  @override
  String get handoverInfoPaper =>
      'Send the tickets by post or courier (with a tracking number if you have one) or hand them over in person. These details help if there is a problem.';

  @override
  String get handoverAppTransfer => 'Transfer in the app';

  @override
  String get handoverPost => 'Post';

  @override
  String get handoverCourier => 'Courier';

  @override
  String get handoverInPerson => 'In person';

  @override
  String get handoverRecipient => 'Transferred to';

  @override
  String get handoverRecipientInfo =>
      'Name or email of the buyer’s account in the organizer’s app';

  @override
  String get handoverRecipientMissing =>
      'Say who you transferred the tickets to';

  @override
  String get handoverTracking => 'Tracking number';

  @override
  String get handoverTrackingInfo => 'Optional, but recommended';

  @override
  String get handoverNote => 'Note';

  @override
  String get handoverNoteInPerson => 'Where and when you met';

  @override
  String get handoverSentAt => 'Handed over';

  @override
  String get handoverConfirm => 'Confirm receipt';

  @override
  String get handoverConfirmInfo =>
      'Confirm receipt once you have the tickets. If they don’t arrive, report a problem.';

  @override
  String get handoverConfirmed => 'Thanks! Receipt confirmed.';

  @override
  String handoverConfirmedAt(String date) {
    return 'The buyer confirmed receipt on $date';
  }

  @override
  String get handoverWaiting => 'The buyer hasn’t confirmed receipt yet.';

  @override
  String get dataExportSection => 'Your data';

  @override
  String get dataExport => 'Download my data';

  @override
  String get dataExportInfo =>
      'Everything Stubswap stores about your account (profile, listings, orders, payouts, requests, invoices) as a JSON file.';

  @override
  String get dataExportDone => 'Data downloaded.';

  @override
  String get invoicesTitle => 'Invoices';

  @override
  String get invoicesInfo =>
      'Stubswap’s invoices for the service fee of your purchases and sales.';

  @override
  String get invoicesEmpty => 'No invoices yet';

  @override
  String get invoicesPlatform => 'Stubswap invoices';

  @override
  String get invoiceTitle => 'Invoice';

  @override
  String get invoiceCreditNote => 'Credit note';

  @override
  String get invoiceNotFound => 'Invoice not found';

  @override
  String get invoiceRecipient => 'Bill to';

  @override
  String get invoiceTaxId => 'Tax no. (JIB)';

  @override
  String get invoiceVatNumber => 'VAT no.';

  @override
  String get invoiceFeeBuyer => 'Service fee for buying tickets';

  @override
  String get invoiceFeeSeller => 'Fee for selling tickets';

  @override
  String get invoiceOrder => 'Order';

  @override
  String invoiceBase(int percent, String amount) {
    return '$percent % of the ticket price $amount';
  }

  @override
  String get invoiceNet => 'Net amount';

  @override
  String invoiceVat(int percent) {
    return 'VAT $percent %';
  }

  @override
  String get invoiceVatTotal => 'VAT';

  @override
  String get invoiceNoVat => 'No VAT';

  @override
  String get invoiceGross => 'Total';

  @override
  String invoiceCreditFor(String number) {
    return 'Cancels invoice $number.';
  }

  @override
  String get invoicePaidBuyer => 'Paid with the ticket purchase.';

  @override
  String get invoicePaidSeller => 'Deducted from the sale’s payout.';

  @override
  String get invoiceFooter =>
      'This invoice was issued electronically and is valid without a signature.';

  @override
  String get invoiceDownload => 'Download PDF';

  @override
  String get invoiceDownloadUnavailable =>
      'Downloading isn’t available here yet.';

  @override
  String get adminInvoicesTitle => 'Platform invoices';

  @override
  String get adminInvoicesInfo =>
      'All invoices per month, totals and export for accounting';

  @override
  String get invoicesPrevMonth => 'Previous month';

  @override
  String get invoicesNextMonth => 'Next month';

  @override
  String invoicesCount(int count) {
    return '$count invoices';
  }

  @override
  String get invoicesExport => 'Export CSV (Excel)';

  @override
  String get invoicesNoneInMonth => 'No invoices in this month.';

  @override
  String get moderationTitle => 'Moderation';

  @override
  String get moderationInfo => 'Reports, copied tickets, blocking users';

  @override
  String get moderationOpen => 'Open';

  @override
  String get moderationHandled => 'Handled';

  @override
  String get moderationUsers => 'Users';

  @override
  String get moderationNoOpen => 'No open reports';

  @override
  String get moderationNoHandled => 'No handled reports yet';

  @override
  String get moderationDuplicate => 'Copied ticket';

  @override
  String get moderationDuplicateInfo =>
      'The same ticket file was already uploaded for another listing. The copy is blocked and won’t be delivered. Check the seller.';

  @override
  String get moderationReport => 'Reported listing';

  @override
  String get moderationNote => 'Team note';

  @override
  String get moderationOpenSeller => 'Seller';

  @override
  String get moderationRemoveListing => 'Remove listing';

  @override
  String get moderationRemoveListingInfo =>
      'The listing is taken off sale right away. The seller gets an email with the reason. Existing purchases stay.';

  @override
  String get moderationListingRemoved => 'Listing removed';

  @override
  String get moderationResolve => 'Resolved';

  @override
  String get moderationDismiss => 'Dismiss';

  @override
  String get moderationReason => 'Reason';

  @override
  String get moderationReasonInfo =>
      'Optional; shown in the log and in the email to the user.';

  @override
  String get moderationFindUser => 'Find a user';

  @override
  String get moderationFindUserInfo => 'Exact email address or username.';

  @override
  String get moderationSearch => 'Search';

  @override
  String get moderationUserNotFound => 'No user found.';

  @override
  String get moderationUser => 'User';

  @override
  String get moderationBlock => 'Block';

  @override
  String get moderationUnblock => 'Unblock';

  @override
  String get moderationBlockInfo =>
      'The user can no longer sell, buy or add events. Their active listings are removed.';

  @override
  String get moderationUnblockInfo =>
      'The user can sell and buy again. Removed listings stay removed.';

  @override
  String get moderationBlocked => 'User blocked';

  @override
  String get moderationUnblocked => 'User unblocked';

  @override
  String get moderationIsBlocked => 'Blocked';

  @override
  String get moderationNewSeller => 'New seller (limits)';

  @override
  String get moderationTrustedSeller => 'No limits';

  @override
  String moderationStats(int listings, int sales) {
    return '$listings active listings · $sales completed sales';
  }

  @override
  String get moderationTrust => 'Lift limits';

  @override
  String get moderationUntrust => 'Restore limits';

  @override
  String get moderationListings => 'Listings';

  @override
  String get moderationOrders => 'Orders';

  @override
  String get moderationAsBuyer => 'Buyer';

  @override
  String get moderationAsSeller => 'Seller';

  @override
  String get moderationLog => 'Team log';

  @override
  String get moderationNone => 'None.';

  @override
  String get moderationRefund => 'Refund';

  @override
  String moderationRefundInfo(String number) {
    return 'The buyer gets the full amount for $number back, the seller no payout. This can’t be undone.';
  }

  @override
  String get moderationRefunded => 'Refunded';

  @override
  String get reportReasonFake => 'Fake or invalid tickets';

  @override
  String get reportReasonPrice => 'Price too high';

  @override
  String get reportReasonWrongEvent => 'Wrong event or details';

  @override
  String get reportReasonSpam => 'Spam or scam';

  @override
  String get reportReasonOther => 'Other';

  @override
  String get reportListing => 'Report listing';

  @override
  String get reportListingInfo =>
      'Something wrong with this listing? The Stubswap team will check it.';

  @override
  String get reportDetails => 'Details (optional)';

  @override
  String get reportSend => 'Send report';

  @override
  String get reportSent => 'Thanks! The team will check the listing.';

  @override
  String get reportAlready => 'You already reported this listing.';

  @override
  String get accountBlocked => 'Your account is blocked';

  @override
  String get accountBlockedInfo =>
      'You can’t sell or buy. Contact support if you have questions.';

  @override
  String get sellNewSeller => 'New seller';

  @override
  String get sellLimitReached => 'Limit for new sellers reached';

  @override
  String sellLimitInfo(int listings, int tickets, int sales) {
    return 'As a new seller you can have up to $listings active listings with at most $tickets tickets each. After $sales completed sales the limits are lifted.';
  }

  @override
  String resaleLimitHint(int percent) {
    return 'At most $percent % above the face value';
  }

  @override
  String resaleMaxPrice(String price, int percent) {
    return 'At most $price ($percent % above the face value)';
  }

  @override
  String resaleTooHigh(String price) {
    return 'The highest allowed price is $price';
  }

  @override
  String get resaleNeedsFaceValue =>
      'This listing has no face value. Withdraw it and list it again with the face value.';

  @override
  String get statusRemoved => 'Removed';

  @override
  String numberBetween(int min, int max) {
    return 'Enter a number from $min to $max';
  }

  @override
  String get resaleTitle => 'Resale rules';

  @override
  String get resaleIntro =>
      'Decide how far above the face value tickets may be resold. Single events can have their own limit.';

  @override
  String get resaleRules => 'Rules';

  @override
  String get resaleLimitPrice => 'Limit the price';

  @override
  String get resaleLimitPriceInfo =>
      'The price per ticket may be at most a set percentage above the face value.';

  @override
  String get resaleRequireFace => 'Face value required';

  @override
  String get resaleRequireFaceInfo =>
      'Sellers must enter the price printed on the ticket. Always required with a price limit.';

  @override
  String get resaleMarkup => 'At most above the face value';

  @override
  String get resaleMarkupInfo => '0 % means: at most the face value.';

  @override
  String resaleExample(String face, String max) {
    return 'Example: a ticket with a face value of $face may cost at most $max.';
  }

  @override
  String get resaleNotice =>
      'Applies to new listings and price changes. Existing listings stay until the seller changes them.';

  @override
  String get resaleEventMarkup => 'This event’s own limit';

  @override
  String get resaleEventMarkupInfo =>
      'At most % above the face value. Empty: the general rule.';

  @override
  String get limitsTitle => 'Limits for new sellers';

  @override
  String get limitsIntro =>
      'New sellers may only offer a few tickets until they have completed some sales. This protects buyers from fake tickets.';

  @override
  String get limitsListings => 'Active listings at most';

  @override
  String get limitsListingsInfo =>
      'How many listings a new seller may have at a time.';

  @override
  String get limitsTickets => 'Tickets per listing at most';

  @override
  String get limitsTicketsInfo => 'How many tickets one listing may have.';

  @override
  String get limitsTrusted => 'No limits after sales';

  @override
  String get limitsTrustedInfo =>
      'After how many completed sales the limits are lifted. The team can also lift them by hand.';

  @override
  String get limitsNotice =>
      'Applies right away to new listings. Existing ones stay.';

  @override
  String get companyTitle => 'Company details';

  @override
  String get companyIntro =>
      'These details are printed on the invoices for the service fee. They apply to new invoices.';

  @override
  String get companyName => 'Company name';

  @override
  String get companyAddress => 'Address';

  @override
  String get companyTaxId => 'Tax number (JIB)';

  @override
  String get companyVatNumber => 'VAT number (PDV)';

  @override
  String get companyVat => 'VAT (PDV)';

  @override
  String get companyVatInfo =>
      'Included in the service fee (17 % in BiH; 0 if the company is not VAT registered).';

  @override
  String get companyEmail => 'Email for invoices';

  @override
  String get companyPrefix => 'Invoice prefix';

  @override
  String get companyPrefixInfo => '2–6 letters, e.g. SSW → SSW-2026-00001';

  @override
  String get companyPrefixInvalid => '2 to 6 letters without spaces';

  @override
  String get companyNotice =>
      'Invoice numbers run per year without gaps. Check tax questions with your accountant.';

  @override
  String get disputeOpenOrder => 'Open order';

  @override
  String get deliveryPageTitle => 'Tickets for this listing';

  @override
  String get deliveryFilesSection => 'Uploaded tickets';

  @override
  String deliveryProgress(int done, int total) {
    return '$done of $total tickets uploaded';
  }

  @override
  String get deliveryAddFile => 'Add tickets';

  @override
  String get deliveryAllUploaded => 'All tickets are uploaded.';

  @override
  String get deliveryInfoTitle => 'How it works';

  @override
  String get deliveryInfo =>
      'Tickets are sent to the buyer automatically right after payment. Upload them at least 24 hours before the event – otherwise buyers are refunded automatically.';

  @override
  String get deliveryFileTypes =>
      'PDF, PNG, JPG or WebP, up to 10 MB per file.';

  @override
  String get deliveryManualTitle => 'Mobile and paper tickets';

  @override
  String get deliveryManualInfo =>
      'You hand these tickets to the buyer directly (e.g. by transfer in the organizer\'s app or in person). Then confirm the delivery in the sale.';

  @override
  String get deliveryNoFiles => 'No tickets uploaded yet.';

  @override
  String get deliveryWaiting => 'Waiting for a buyer';

  @override
  String deliverySentTo(String order) {
    return 'Sent to buyer $order';
  }

  @override
  String deliveryFileTickets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tickets',
      one: '$count ticket',
    );
    return '$_temp0';
  }

  @override
  String get deliveryHowManyTitle => 'How many tickets are in the file?';

  @override
  String get deliveryHowManyInfo =>
      'One PDF can hold several tickets. The buyer gets the whole file.';

  @override
  String get deliveryUpload => 'Upload';

  @override
  String get deliveryUploaded => 'Tickets uploaded';

  @override
  String get deliveryUploading => 'Uploading…';

  @override
  String get deliveryWrongType =>
      'This file type is not supported. Use PDF, PNG, JPG or WebP.';

  @override
  String get deliveryTooBig => 'The file is larger than 10 MB.';

  @override
  String get deliveryUploadError => 'Upload failed. Please try again.';

  @override
  String get deliveryPickUnsupported =>
      'Uploading files works only in the web browser for now.';

  @override
  String get deliveryDeleteTitle => 'Delete file?';

  @override
  String get deliveryDeleteInfo =>
      'The file has not been sent to a buyer yet and will be removed.';

  @override
  String get deliveryDelete => 'Delete';

  @override
  String get deliveryDeleted => 'File deleted';

  @override
  String get deliveryNoAccessTitle => 'No access';

  @override
  String get deliveryNoAccess =>
      'Only the seller can upload tickets for this listing.';

  @override
  String get deliveryMissingBadge => 'Tickets not uploaded';

  @override
  String get deliveryUploadAction => 'Upload tickets';

  @override
  String deliverySalesWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have $count sold tickets that are not uploaded yet',
      one: 'You have $count sold ticket that is not uploaded yet',
    );
    return '$_temp0';
  }

  @override
  String deliveryDeadline(String date) {
    return 'Deadline: $date';
  }

  @override
  String get deliverySellerMissingTitle => 'Tickets not uploaded yet';

  @override
  String deliverySellerMissingInfo(String date) {
    return 'Upload them by $date. If they are late, the buyer is refunded automatically.';
  }

  @override
  String get deliveryBuyerSection => 'Your tickets';

  @override
  String get deliveryDownload => 'Download';

  @override
  String deliveryBuyerWaiting(String date) {
    return 'The seller hasn\'t sent the tickets yet. Deadline: $date. If they don\'t, you are refunded automatically.';
  }

  @override
  String get deliveryDownloadError => 'Download failed.';

  @override
  String get deliveryCancelSeller => 'Cancelled by the seller';

  @override
  String get deliveryCancelExpired => 'Payment not completed within 15 minutes';

  @override
  String get deliveryCancelDeadline => 'Tickets not sent in time – refunded';

  @override
  String get deliveryCancelEvent => 'Event cancelled – refunded';

  @override
  String get deliveryCancelSupport => 'Resolved by support – refunded';

  @override
  String get deliveryAlertArrivedTitle => 'Your tickets have arrived';

  @override
  String deliveryAlertArrivedBody(String event) {
    return '$event: download them in your order.';
  }

  @override
  String get deliveryAlertRefundTitle => 'Refund';

  @override
  String deliveryAlertRefundBody(String event, String reason) {
    return '$event: $reason';
  }

  @override
  String get deliveryAlertDeadlineTitle =>
      'Sale cancelled – tickets not uploaded';

  @override
  String deliveryAlertDeadlineBody(String event) {
    return '$event: the buyer was refunded.';
  }

  @override
  String reservationHeld(String time) {
    return 'The tickets are held for you for $time';
  }

  @override
  String get reservationHint =>
      'Once you start paying, the tickets are held for you for 15 minutes.';

  @override
  String get reservationExpiredTitle => 'Reservation expired';

  @override
  String get reservationExpiredInfo =>
      'The payment wasn\'t completed within 15 minutes, so the tickets are back on sale. Nothing was charged.';

  @override
  String get reservationBackToListing => 'Back to the listing';

  @override
  String get disputeReport => 'Report a problem';

  @override
  String get disputeSheetTitle => 'Report a problem with the order';

  @override
  String get disputeSheetInfo =>
      'Our team checks your report. Until it decides, the order is on hold and the seller isn\'t paid out.';

  @override
  String get disputeReasonLabel => 'What\'s wrong?';

  @override
  String get disputeReasonNotReceived => 'Tickets not received';

  @override
  String get disputeReasonInvalid => 'Ticket not valid';

  @override
  String get disputeReasonWrongTickets => 'Wrong tickets';

  @override
  String get disputeReasonEventChanged => 'Event changed';

  @override
  String get disputeReasonOther => 'Other';

  @override
  String get disputeTextLabel => 'Describe the problem';

  @override
  String get disputeTextHint =>
      'What happened? E.g. the ticket was refused at the entrance.';

  @override
  String get disputeTextTooShort => 'Write at least 10 characters.';

  @override
  String get disputeSubmit => 'Send report';

  @override
  String get disputeSent => 'Report sent. We\'ll get back to you.';

  @override
  String get disputeBoxTitle => 'Reported problem';

  @override
  String get disputeStatusLine =>
      'Problem reported – waiting for support\'s decision';

  @override
  String get disputeStatusOpen => 'Waiting for a decision';

  @override
  String get disputeStatusRefund => 'Decision: buyer refunded';

  @override
  String get disputeStatusReject => 'Decision: report rejected';

  @override
  String disputeNote(String note) {
    return 'Team note: $note';
  }

  @override
  String get disputeOpenRequest => 'Open the support request';

  @override
  String get disputeErrorTooLate => 'This order can no longer be reported.';

  @override
  String get disputeErrorPermission => 'You\'re not allowed to do this.';

  @override
  String get disputeErrorInvalid => 'Check your input and try again.';

  @override
  String get disputeErrorNotFound => 'Not found.';

  @override
  String get disputeStaffTitle => 'Team decision';

  @override
  String get disputeStaffBuyer => 'Buyer (ID)';

  @override
  String get disputeStaffSeller => 'Seller (ID)';

  @override
  String get disputeRefund => 'Refund the buyer';

  @override
  String get disputeReject => 'Reject the report';

  @override
  String get disputeRefundConfirm =>
      'The buyer gets a full refund and the seller no payout.';

  @override
  String get disputeRejectConfirm =>
      'The order continues as before the report.';

  @override
  String get disputeNoteLabel => 'Note (the buyer sees it)';

  @override
  String get disputeDecided => 'Decision saved';

  @override
  String disputeStaffHint(String order) {
    return 'This is a problem report for order $order. You decide in the order details.';
  }

  @override
  String get disputeAlertOpenedTitle => 'The buyer reported a problem';

  @override
  String disputeAlertOpenedBody(String event) {
    return '$event: the payout waits for support\'s decision.';
  }

  @override
  String get disputeAlertRejectedTitle => 'Decision on your report';

  @override
  String disputeAlertRejectedBody(String event) {
    return '$event: the report was rejected, the order continues.';
  }

  @override
  String get eventChangeSection => 'Cancel or postpone';

  @override
  String get eventChangeCancel => 'Cancel event';

  @override
  String get eventChangeCancelInfo =>
      'All buyers are refunded automatically and all listings are withdrawn. This can\'t be undone.';

  @override
  String get eventChangeReason => 'Reason for cancelling';

  @override
  String get eventChangeReasonHint => 'E.g. the artist cancelled.';

  @override
  String eventChangeCancelled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Event cancelled, $count buyers are refunded',
      one: 'Event cancelled, $count buyer is refunded',
    );
    return '$_temp0';
  }

  @override
  String get eventChangePostpone => 'Postpone event';

  @override
  String get eventChangePostponeInfo =>
      'Bought tickets stay valid for the new date. Buyers see a note on the event page.';

  @override
  String get eventChangeNewDate => 'New date';

  @override
  String get eventChangePickDate => 'Pick the new date';

  @override
  String get eventChangePostponed => 'Event postponed';

  @override
  String get eventChangeCancelledBanner =>
      'This event is cancelled and can no longer be edited.';

  @override
  String eventChangeCancelReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String eventChangePostponedFrom(String date) {
    return 'Postponed, original date: $date';
  }

  @override
  String get eventChangeFilterCancelled => 'Cancelled';

  @override
  String get sellerUploadNow => 'Upload';

  @override
  String get sellerTicketsMissing => 'Tickets not uploaded yet';

  @override
  String sellerTicketsMissingInfo(int done, int total) {
    return '$done of $total tickets uploaded. Upload them now – buyers get them right after paying. Deadline: 24 hours before the event, otherwise buyers are refunded.';
  }

  @override
  String get sellerTicketsButton => 'Tickets (upload)';

  @override
  String get sellerUploadNowHint =>
      'Listing published. Upload the tickets now – buyers get them right after paying. You can also do it later.';

  @override
  String get eventPageCancelled => 'Event cancelled';

  @override
  String get eventPageCancelledInfo =>
      'All buyers are refunded automatically. No more tickets are sold.';

  @override
  String get eventPagePostponed => 'Event postponed';

  @override
  String eventPagePostponedInfo(String date) {
    return 'Original date: $date. Bought tickets stay valid for the new date.';
  }

  @override
  String get eventStatusCancelled => 'Cancelled';

  @override
  String get eventStatusPostponed => 'Postponed';

  @override
  String get legalImprintTitle => 'Imprint';

  @override
  String get legalTermsTitle => 'Terms of use';

  @override
  String get legalPrivacyTitle => 'Privacy policy';

  @override
  String get legalCookiesTitle => 'Cookies';

  @override
  String get legalFooterTitle => 'Legal';

  @override
  String get legalTermsLink => 'terms of use';

  @override
  String get legalPrivacyLink => 'privacy policy';

  @override
  String legalAcceptTerms(String terms, String privacy) {
    return 'I accept the $terms and the $privacy';
  }

  @override
  String get legalAcceptRequired =>
      'To sign up, accept the terms of use and the privacy policy.';

  @override
  String legalContinueAccept(String terms, String privacy) {
    return 'By continuing you accept the $terms and the $privacy.';
  }

  @override
  String priceInclFee(String percent) {
    return 'incl. $percent% service fee';
  }

  @override
  String get priceFaceValue => 'Face value per ticket';

  @override
  String get priceFaceValueInfo =>
      'The price printed on the ticket, without fees';

  @override
  String get priceFaceValueShort => 'Face value';

  @override
  String get priceFaceValueInvalid => 'Enter the ticket\'s face value';

  @override
  String get priceSalePrice => 'Sale price';

  @override
  String priceSellerFee(String percent) {
    return 'Seller fee ($percent%)';
  }

  @override
  String get priceYouReceive => 'You receive per ticket';

  @override
  String get priceProfit => 'Profit per ticket';

  @override
  String get priceTotalProfit => 'Total profit';

  @override
  String priceForQuantity(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tickets',
      one: '1 ticket',
    );
    return 'For $_temp0';
  }

  @override
  String get priceBelowFaceValue =>
      'After the fee you receive less than the face value.';

  @override
  String get staffNoMarketTitle => 'Team accounts don\'t buy or sell';

  @override
  String get staffNoMarketInfo =>
      'Admin and support accounts are for team work only. Use a regular account to buy and sell.';

  @override
  String get eventsUserDateTooFar => 'The date can be at most two years ahead';

  @override
  String get homeCityPick => 'Choose a city';

  @override
  String get homeCitySearch => 'Search cities';

  @override
  String homeCityUseTyped(String city) {
    return 'Use “$city”';
  }

  @override
  String get homeCityUseLocation => 'Use my location';

  @override
  String get homeCityLocationUnavailable =>
      'Location isn’t available. Please choose a city.';

  @override
  String get homeCityClear => 'Remove';

  @override
  String get homeCityFromLocation => 'Based on your location';

  @override
  String get homeCityMostEvents => 'City with the most events';

  @override
  String get homeAllTypes => 'All types';

  @override
  String get homeRecentlyViewed => 'Recently viewed';

  @override
  String get homePopular => 'Popular events';

  @override
  String get homeRecommended => 'Recommended for you';

  @override
  String homeNearby(String city) {
    return 'Happening near $city';
  }

  @override
  String get homeNearbyChange => 'Change';

  @override
  String get homePopularCategories => 'Popular categories';

  @override
  String get homeAllEvents => 'All events';

  @override
  String homeAllEventsOfType(String type) {
    return 'All events: $type';
  }

  @override
  String get homeSearchResults => 'Search results';

  @override
  String get homeAddEvent => 'Add an event';

  @override
  String get homeScrollBack => 'Previous';

  @override
  String get homeScrollForward => 'Next';

  @override
  String get footerClaim => 'Safe ticket resale – from fans, for fans.';

  @override
  String get footerCompany => 'Our company';

  @override
  String get footerQuestions => 'Any questions?';

  @override
  String footerCopyright(int year) {
    return '© $year Stubswap';
  }

  @override
  String footerVersion(String version) {
    return 'Version $version';
  }

  @override
  String get infoAboutTitle => 'About us';

  @override
  String get infoPressTitle => 'Press';

  @override
  String get infoHowTitle => 'How it works';

  @override
  String get infoSafetyTitle => 'Buying safely';

  @override
  String get infoNotFound => 'Page not found';

  @override
  String get infoNotFoundInfo => 'This page doesn’t exist or has moved.';

  @override
  String get infoAboutIntro =>
      'Stubswap is a marketplace where fans in Bosnia and Herzegovina and the region safely resell tickets for concerts, sports, culture and festivals.';

  @override
  String get infoAboutFansTitle => 'From fans, for fans';

  @override
  String get infoAboutFansText =>
      'Can’t make it? Offer your ticket to someone who wants to go instead of letting it go to waste. Sold out? Someone may be selling theirs right now.';

  @override
  String get infoAboutTrustTitle => 'Safety first';

  @override
  String get infoAboutTrustText =>
      'Payments go through Stubswap: sellers are paid only after the event, and our support team helps if something goes wrong.';

  @override
  String get infoPressIntro =>
      'Writing about Stubswap? We’re happy to answer media questions.';

  @override
  String get infoPressFactsTitle => 'In short';

  @override
  String get infoPressFact1 =>
      'An online marketplace for ticket resale between fans.';

  @override
  String get infoPressFact2 =>
      'Focused on Bosnia and Herzegovina and the region.';

  @override
  String get infoPressFact3 =>
      'Available on the web and on mobile, in Bosnian, German and English.';

  @override
  String get infoPressContactTitle => 'Press contact';

  @override
  String get infoPressContactText =>
      'Please send media enquiries through the help center. We’ll get back to you as soon as we can.';

  @override
  String get infoHowBuyTitle => 'Buying';

  @override
  String get infoHowBuy1 => 'Find your event and compare offers from fans.';

  @override
  String get infoHowBuy2 =>
      'Pay safely – we hold the money until your tickets arrive.';

  @override
  String get infoHowBuy3 =>
      'The seller sends you the tickets; follow the status in Purchases & invoices.';

  @override
  String get infoHowSellTitle => 'Selling';

  @override
  String get infoSafetyIntro =>
      'On Stubswap you buy from other fans – and we make sure everything goes right.';

  @override
  String get infoSafetyPaymentTitle => 'Money held until the event';

  @override
  String get infoSafetyPaymentText =>
      'You pay through Stubswap, never directly to the seller. The seller is paid only after the event.';

  @override
  String get infoSafetySellersTitle => 'Verified sellers';

  @override
  String get infoSafetySellersText =>
      'Sellers must verify their email address before they can publish an offer.';

  @override
  String get infoSafetySupportTitle => 'Support when you need it';

  @override
  String get infoSafetySupportText =>
      'If tickets don’t arrive or aren’t valid, contact support – we’ll refund you.';

  @override
  String get eventStatusConfirmed => 'Confirmed';

  @override
  String get eventStatusPending => 'Not confirmed';

  @override
  String get eventStatusHidden => 'Hidden';

  @override
  String get eventStatusPendingInfo =>
      'A user added this event and our team hasn\'t checked it yet. You can still buy and sell tickets.';

  @override
  String get eventsUserNewTitle => 'Add an event';

  @override
  String get eventsUserInfoTitle => 'Our team will check this event';

  @override
  String get eventsUserInfo =>
      'Until then it\'s marked as “Not confirmed”. You can sell tickets for it right away.';

  @override
  String get eventsUserVerifyFirst =>
      'Confirm your email address to add events.';

  @override
  String get eventsUserAdded => 'Event added – awaiting review';

  @override
  String get eventsUserNotListed => 'Event not listed?';

  @override
  String get eventsUserAddIt => 'Add it';

  @override
  String get eventsUserNoneToSellInfo =>
      'No upcoming events yet. Add your event and sell tickets for it right away.';

  @override
  String get eventsReviewEdit => 'Edit / review';

  @override
  String get eventsReviewConfirm => 'Confirm';

  @override
  String get eventsReviewConfirmTitle => 'Confirm event?';

  @override
  String get eventsReviewConfirmInfo =>
      'Check the name, place and date. Everybody will see the event as confirmed.';

  @override
  String get eventsReviewConfirmedToast => 'Event confirmed';

  @override
  String eventsReviewTabPending(int count) {
    return 'To review ($count)';
  }

  @override
  String get eventsReviewTabConfirmed => 'Confirmed';

  @override
  String get eventsReviewTabHidden => 'Hidden';

  @override
  String get eventsReviewTabPast => 'Past';

  @override
  String get eventsReviewEmptyPending => 'Nothing to review';

  @override
  String get eventsReviewEmptyPendingInfo =>
      'When a user adds an event, it shows up here.';

  @override
  String get eventsReviewEmpty => 'No events here';

  @override
  String eventsReviewAddedBy(String who) {
    return 'Added by: $who';
  }

  @override
  String get eventsReviewAddedByYou => 'you';

  @override
  String get eventsReviewAddedByUser => 'a user';

  @override
  String get eventsReviewQueue => 'Events to review';

  @override
  String get eventsReviewNoAccessInfo =>
      'Only team members can open this page.';

  @override
  String get genreFootball => 'Football';

  @override
  String get genreBasketball => 'Basketball';

  @override
  String get genreHandball => 'Handball';

  @override
  String get genreTennis => 'Tennis';

  @override
  String get genreVolleyball => 'Volleyball';

  @override
  String get genreCombat => 'Combat sports';

  @override
  String get genreMotorsport => 'Motorsport';

  @override
  String get genreOtherSport => 'Other sports';

  @override
  String get genreRock => 'Rock';

  @override
  String get genrePop => 'Pop';

  @override
  String get genreFolk => 'Folk';

  @override
  String get genreJazz => 'Jazz';

  @override
  String get genreHiphop => 'Hip-hop';

  @override
  String get genreElectronic => 'Electronic';

  @override
  String get genreClassical => 'Classical';

  @override
  String get genreOtherMusic => 'Other music';

  @override
  String get genreDrama => 'Theatre';

  @override
  String get genreOpera => 'Opera';

  @override
  String get genreBallet => 'Ballet';

  @override
  String get genreStandup => 'Stand-up comedy';

  @override
  String get genreMusical => 'Musical';

  @override
  String get genreExhibition => 'Exhibitions';

  @override
  String get genreFilm => 'Film';

  @override
  String get genreMusicFestival => 'Music festivals';

  @override
  String get genreFilmFestival => 'Film festivals';

  @override
  String get genreFoodFestival => 'Food festivals';

  @override
  String get genreOtherFestival => 'Other festivals';

  @override
  String get genreFamily => 'Family';

  @override
  String get genreConference => 'Conferences';

  @override
  String get genreOtherEvent => 'Other';

  @override
  String get genreLabel => 'Subcategory';

  @override
  String get genreNone => 'No subcategory';

  @override
  String get supportUser => 'User';

  @override
  String get supportMyRequests => 'My requests';

  @override
  String get supportNoRequests => 'You have no support requests yet.';

  @override
  String get supportStatusOpen => 'Open';

  @override
  String get supportStatusAnswered => 'Answered';

  @override
  String get supportStatusClosed => 'Closed';

  @override
  String get supportNewAnswer => 'New answer';

  @override
  String get supportRequestSent => 'Request sent';

  @override
  String get supportMessageTooShort => 'Write at least 10 characters';

  @override
  String get supportAnswerInApp =>
      'We answer here in the app, usually within 24 hours. You\'ll get a notification.';

  @override
  String get supportImages => 'Pictures';

  @override
  String supportImagesInfo(int count) {
    return 'Screenshots or photos, up to $count';
  }

  @override
  String get supportAddImage => 'Add picture';

  @override
  String get supportRemoveImage => 'Remove picture';

  @override
  String get supportImageError => 'The picture can\'t be read';

  @override
  String get supportImage => 'Picture';

  @override
  String get supportTeamName => 'Stubswap Support';

  @override
  String get supportYou => 'You';

  @override
  String get supportTicket => 'Request';

  @override
  String get supportCloseTicket => 'Close request';

  @override
  String get supportResolveTicket => 'Problem solved – close request';

  @override
  String get supportCloseConfirm => 'Close the request?';

  @override
  String get supportCloseConfirmInfo =>
      'A closed request takes no new messages. If the problem comes back, open a new request.';

  @override
  String get supportCloseConfirmStaff =>
      'The user won\'t be able to write in this request anymore.';

  @override
  String get supportClosed => 'The request is closed';

  @override
  String get supportClosedByUser => 'Closed by the user.';

  @override
  String get supportClosedByYou => 'Closed at your request.';

  @override
  String get supportClosedByStaff => 'Closed by support.';

  @override
  String get supportNewRequest => 'New request';

  @override
  String get supportWriteMessage => 'Write a message…';

  @override
  String get supportNotFound => 'Request not found';

  @override
  String get supportNoAccess => 'No access';

  @override
  String get supportNoAccessInfo => 'This page is for the support team only.';

  @override
  String get supportInbox => 'Support requests';

  @override
  String get supportFilterOpen => 'Open';

  @override
  String get supportFilterAnswered => 'Answered';

  @override
  String get supportFilterClosed => 'Closed';

  @override
  String get supportFilterAll => 'All';

  @override
  String get supportInboxEmpty => 'No requests';

  @override
  String get supportAppVersion => 'App version';

  @override
  String get supportEmail => 'Email';

  @override
  String get supportAlertAnswered => 'Support answered';

  @override
  String get supportAlertNew => 'New support request';

  @override
  String supportAlertNewMessage(String number) {
    return 'New message in request $number';
  }

  @override
  String get supportAlertOpen => 'Open';

  @override
  String get supportAdministration => 'Administration';

  @override
  String get adminTitle => 'Administration';

  @override
  String get adminTeamSection => 'Team';

  @override
  String get adminNoAccess => 'No access';

  @override
  String get adminNoAccessInfo => 'This page is for administrators only.';

  @override
  String get adminEvents => 'Events';

  @override
  String get adminEventsInfo => 'Add and edit events';

  @override
  String get adminFeesTitle => 'Service fee';

  @override
  String adminFeesSummary(int buyer, int seller) {
    return 'Buyer $buyer% · Seller $seller%';
  }

  @override
  String get adminTeamTitle => 'Team and support';

  @override
  String get adminTeamInfo => 'Support accounts and administrators';

  @override
  String get adminSupportInbox => 'Support requests';

  @override
  String get adminSupportInboxInfo => 'Answer users\' requests';

  @override
  String get adminBuyerFee => 'Buyer fee';

  @override
  String get adminBuyerFeeInfo =>
      'Paid by the buyer on top of the ticket price.';

  @override
  String get adminSellerFee => 'Seller fee';

  @override
  String get adminSellerFeeInfo =>
      'Deducted from the ticket price the seller receives.';

  @override
  String adminFeeRange(int max) {
    return 'Enter a whole number from 0 to $max';
  }

  @override
  String get adminFeeDecrease => 'Decrease';

  @override
  String get adminFeeIncrease => 'Increase';

  @override
  String adminFeesCurrent(String summary) {
    return 'Current: $summary';
  }

  @override
  String adminFeesExample(String price) {
    return 'Example for a $price ticket';
  }

  @override
  String get adminTicketPrice => 'Ticket price';

  @override
  String get adminBuyerPays => 'Buyer pays';

  @override
  String get adminSellerReceives => 'Seller receives';

  @override
  String get adminPlatformEarns => 'Stubswap earns';

  @override
  String get adminFeesNotice =>
      'The new fee only applies to listings published from now on. Existing listings and orders keep their fee.';

  @override
  String get adminFeesConfirmTitle => 'Change the fee?';

  @override
  String get adminFeesSave => 'Save fee';

  @override
  String get adminFeesSaved => 'Fee saved';

  @override
  String get adminRoleAdmin => 'Admin';

  @override
  String get adminRoleSupport => 'Support';

  @override
  String get adminTeamMembers => 'Team members';

  @override
  String adminGrantedAt(String date) {
    return 'Added $date';
  }

  @override
  String get adminYou => 'You';

  @override
  String get adminNoName => 'No name';

  @override
  String get adminRemoveSupport => 'Remove from support';

  @override
  String get adminRemoveSupportTitle => 'Remove from support?';

  @override
  String adminRemoveSupportBody(String name) {
    return '$name will no longer see support requests. The account stays.';
  }

  @override
  String get adminRemove => 'Remove';

  @override
  String get adminSupportRemoved => 'Removed from support';

  @override
  String get adminAdminsInfo =>
      'Admins are added only in the Firebase console (Firestore → roles → document with the user\'s ID, field role = admin).';

  @override
  String get adminAddSupport => 'Add a support account';

  @override
  String get adminAddSupportInfo =>
      'Search by exact email address or username. The user must have signed in to Stubswap at least once.';

  @override
  String get adminFindUserLabel => 'Email or username';

  @override
  String get adminFindUser => 'Search';

  @override
  String get adminUserNotFound => 'User not found';

  @override
  String get adminUserNotFoundInfo =>
      'Check the address or username. The user must have signed in at least once.';

  @override
  String get adminMakeSupport => 'Add as support';

  @override
  String get adminSupportAdded => 'Added to support';

  @override
  String adminAlreadyInTeam(String role) {
    return 'Already in the team as $role';
  }

  @override
  String get adminThatsYou => 'That\'s you';

  @override
  String eventsOffer(String price, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tickets',
      one: '1 ticket',
    );
    return 'from $price · $_temp0';
  }

  @override
  String get eventsNoOffers => 'No offers yet';

  @override
  String get eventsNoOffersInfo =>
      'Be the first to sell tickets for this event.';

  @override
  String get eventsSellForEvent => 'Sell tickets for this event';

  @override
  String get eventsOffers => 'Offers';

  @override
  String get eventsNotFound => 'Event not found';

  @override
  String get eventsNotFoundInfo =>
      'It may have been removed or is no longer available.';

  @override
  String get eventsIsOver =>
      'This event is over. Tickets for it are no longer sold.';

  @override
  String get eventsPick => 'Choose an event';

  @override
  String get eventsPickRequired => 'Choose an event';

  @override
  String get eventsChange => 'Change';

  @override
  String get eventsSearch => 'Search events';

  @override
  String get eventsNoneToSell => 'No events right now';

  @override
  String get eventsNoneToSellInfo =>
      'Events are added by the Stubswap team. As soon as a new event appears, you can sell tickets for it here.';

  @override
  String get eventsAllOffers => 'All offers for this event';

  @override
  String get eventsAdminTitle => 'Events';

  @override
  String get eventsAdminNoAccess => 'No access';

  @override
  String get eventsAdminNoAccessInfo =>
      'Only administrators can open this page.';

  @override
  String get eventsNew => 'New event';

  @override
  String get eventsEdit => 'Edit event';

  @override
  String get eventsHiddenBadge => 'Hidden';

  @override
  String get eventsPastBadge => 'Past';

  @override
  String get eventsUpcomingSection => 'Upcoming';

  @override
  String get eventsPastSection => 'Past';

  @override
  String get eventsHide => 'Hide event';

  @override
  String get eventsShow => 'Show event';

  @override
  String get eventsHideConfirm =>
      'The event will no longer be shown and no new offers can be created for it. Existing offers stay.';

  @override
  String get eventsShowConfirm =>
      'The event will be visible to everyone again and tickets can be sold for it.';

  @override
  String get eventsHiddenToast => 'Event hidden';

  @override
  String get eventsShownToast => 'Event visible again';

  @override
  String get eventsPicture => 'Picture';

  @override
  String get eventsPicturePick => 'Choose picture';

  @override
  String get eventsPictureReplace => 'Replace';

  @override
  String get eventsPictureRemove => 'Remove';

  @override
  String get eventsPictureHint => 'The picture is cropped to 16:9.';

  @override
  String get eventsPictureError => 'This picture can\'t be loaded';

  @override
  String get eventsCreated => 'Event created';

  @override
  String get eventsListingsKeepData =>
      'Existing offers keep the event details from when they were published.';

  @override
  String get eventsNameTooShort => 'At least 2 characters';

  @override
  String get eventsNoneYet => 'No events yet';

  @override
  String get eventsNoneYetInfo =>
      'Add the first event so sellers can publish offers.';

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
  String get continueAsGuest => 'Continue without signing in';

  @override
  String get signupTitle => 'Create your account';

  @override
  String get nameLabel => 'Name';

  @override
  String get nameRequired => 'Please enter your name';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

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
  String get errorWeakPassword => 'Password is too weak: at least 8 characters';

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
  String get errorPopupBlocked =>
      'Your browser blocked the Google sign-in window. Allow pop-ups for this site and try again';

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
  String get catTheater => 'Culture';

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
  String get purchases => 'My tickets';

  @override
  String get sales => 'Sold tickets';

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
  String get markTicketsSent => 'Enter the ticket handover';

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

  @override
  String alertSoldTitle(String event) {
    return 'Tickets sold: $event';
  }

  @override
  String alertSoldBody(String quantity, String amount) {
    return '$quantity pcs · $amount. Send the tickets to the buyer.';
  }

  @override
  String get alertTicketsSentTitle => 'Tickets sent';

  @override
  String alertTicketsSentBody(String event) {
    return '$event: the seller sent your tickets.';
  }

  @override
  String get alertRefundTitle => 'Sale cancelled';

  @override
  String alertRefundBody(String event) {
    return '$event: the seller cancelled, you\'ve been refunded.';
  }

  @override
  String get alertView => 'View';

  @override
  String get changeIban => 'Change IBAN';

  @override
  String get keepCurrentIban => 'Keep the saved IBAN';

  @override
  String get ibanHint => 'e.g. BA39 1290 0794 0102 8494';

  @override
  String get deleteAccountOpenOrders =>
      'You have open sales or purchases. Complete or cancel them before deleting your account.';

  @override
  String get newVersionTitle => 'New version available';

  @override
  String get newVersionBody =>
      'Reload the page to get the latest version of Stubswap.';

  @override
  String get reload => 'Reload';
}
