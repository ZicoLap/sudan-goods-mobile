// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sudan Goods';

  @override
  String greeting(String name) {
    return 'Hello, $name!';
  }

  @override
  String itemsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionAccount => 'Account';

  @override
  String get changeEmail => 'Change email';

  @override
  String get changePassword => 'Change password';

  @override
  String get manageAddresses => 'Manage addresses';

  @override
  String get changeEmailVerifyBeforeLabel => 'Verify before updating';

  @override
  String get changeEmailVerifyBeforeSubtitle => 'Send a verification link to the new email first';

  @override
  String get changeEmailSyncNow => 'I verified, sync now';

  @override
  String get sectionNotifications => 'Notifications';

  @override
  String get pushNotifications => 'Push notifications';

  @override
  String get pushNotificationsSubtitle => 'Receive updates and promotions';

  @override
  String get emailNotifications => 'Email notifications';

  @override
  String get emailNotificationsSubtitle => 'Get messages to your inbox';

  @override
  String get orderStatusUpdates => 'Order status updates';

  @override
  String get orderStatusUpdatesSubtitle => 'Track your orders in real time';

  @override
  String get sectionPrivacySecurity => 'Privacy & Security';

  @override
  String get twoFactorAuth => 'Two-factor authentication';

  @override
  String get twoFactorAuthSubtitle => 'Add extra protection to your account';

  @override
  String get blockedUsers => 'Blocked users';

  @override
  String get dataAndPrivacy => 'Data & privacy';

  @override
  String get dataAndPrivacySubtitle => 'Manage your data and preferences';

  @override
  String get sectionGeneral => 'General';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get theme => 'Theme';

  @override
  String get themeSubtitle => 'Choose system, light, or dark';

  @override
  String get selectTheme => 'Select theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get regionAndCurrency => 'Region & currency';

  @override
  String get selectRegionCurrency => 'Select region & currency';

  @override
  String get sectionHelpSupport => 'Help & Support';

  @override
  String get faqs => 'FAQs';

  @override
  String get contactSupport => 'Contact support';

  @override
  String get appVersion => 'App version';

  @override
  String get dangerZone => 'Danger zone';

  @override
  String get logout => 'Log out';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get regionUAE => 'United Arab Emirates';

  @override
  String get regionUS => 'United States';

  @override
  String get regionSudan => 'Sudan';

  @override
  String regionCurrencyFormat(String region, String currency) {
    return '$region ($currency)';
  }

  @override
  String comingSoonWithFeature(String feature) {
    return '$feature coming soon';
  }

  @override
  String confirmActionTitle(String action) {
    return '$action?';
  }

  @override
  String confirmActionMessage(String action) {
    return 'Are you sure you want to proceed with $action?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get failedToLoadSettings => 'Failed to load settings. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Search for products or stores';

  @override
  String get searchEmptyPrompt => 'Type a query and press search';

  @override
  String searchResultsFor(String query) {
    return 'Results for: \"$query\"';
  }

  @override
  String searchNoResultsTitle(String query) {
    return 'No results for: \"$query\"';
  }

  @override
  String get searchNoResultsSubtitle => 'Try different keywords or request the item.';

  @override
  String get storesWithMatches => 'Stores with matching products';

  @override
  String get matchingProducts => 'Matching products';

  @override
  String get clearSearch => 'Clear';

  @override
  String get wantedCTA => 'Request it';

  @override
  String get wantedSheetTitle => 'Request a product';

  @override
  String get wantedProductNameLabel => 'Product name';

  @override
  String get wantedNotesLabel => 'Notes (optional)';

  @override
  String get submitRequest => 'Submit request';

  @override
  String get wantedSubmitted => 'Request submitted. Thank you!';

  @override
  String get wantedSubmitFailed => 'Failed to submit request. Please try again.';

  @override
  String get allStoresTitle => 'All Stores';

  @override
  String get viewAll => 'View all';

  @override
  String get failedToLoadStores => 'Failed to load stores';

  @override
  String get noStoresAvailable => 'No stores available';

  @override
  String get collectionsTitle => 'Collections';

  @override
  String get noCollectionsAvailable => 'No collections available';

  @override
  String get browseCategories => 'Browse Categories';

  @override
  String get featuredStores => 'Featured Stores';

  @override
  String get topPicksBadge => '⭐ Top picks';

  @override
  String get noFeaturedStores => 'No featured stores';

  @override
  String get popularProducts => 'Popular Products';

  @override
  String get outOfStock => 'Out of stock';

  @override
  String get homeGreeting => 'Good day! 👋';

  @override
  String deliveringTo(String place) {
    return 'Delivering to $place';
  }

  @override
  String get failedToLoadCategories => 'Failed to load categories';

  @override
  String get navHome => 'Home';

  @override
  String get navOrders => 'Orders';

  @override
  String get navSearch => 'Search';

  @override
  String get navMessages => 'Messages';

  @override
  String get navProfile => 'Profile';

  @override
  String get storeOpen => 'Open';

  @override
  String get storeClosed => 'Closed';

  @override
  String minOrderWithAmount(String amount) {
    return 'Min. Order: $amount';
  }

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get profilePhoto => 'Profile photo';

  @override
  String get tapToChangePhoto => 'Tap to change photo';

  @override
  String get change => 'Change';

  @override
  String get name => 'Name';

  @override
  String get handle => 'Handle';

  @override
  String get bio => 'Bio';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get searchMessagesHint => 'Search messages';

  @override
  String get newMessage => 'New message';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get startConversationPrompt => 'Start a conversation with a store or support';

  @override
  String get failedToLoadMessages => 'Failed to load messages. Please try again.';

  @override
  String get startNewMessage => 'Start new message';

  @override
  String get messageAStore => 'Message a store';

  @override
  String chatWith(String name) {
    return 'Chat with $name';
  }

  @override
  String get mustLoginToViewOrders => 'You need to be logged in to view orders.';

  @override
  String get myOrders => 'My Orders';

  @override
  String get failedToLoadOrders => 'Failed to load orders.';

  @override
  String get deleteOrderQuestion => 'Delete Order?';

  @override
  String get deleteOrderExplanation => 'This order has not been confirmed yet. Do you want to delete it?';

  @override
  String get delete => 'Delete';

  @override
  String get orderDeleted => 'Order deleted';

  @override
  String get failedToDeleteOrder => 'Failed to delete order.';

  @override
  String get noOrdersYet => 'No orders yet';

  @override
  String get ordersEmptyHint => 'Your orders will appear here. Start shopping to place your first order!';

  @override
  String orderNumber(String id) {
    return 'Order #$id';
  }

  @override
  String get deleteOrder => 'Delete order';

  @override
  String get unknownStore => 'Unknown store';

  @override
  String get orderStatusPending => 'Pending';

  @override
  String get orderStatusConfirmed => 'Confirmed';

  @override
  String get orderStatusPreparing => 'Preparing';

  @override
  String get orderStatusProcessing => 'Processing';

  @override
  String get orderStatusShipped => 'Shipped';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get failedToLoadProfile => 'Failed to load profile. Please try again.';

  @override
  String get recentActivity => 'Recent activity';

  @override
  String get addShortBioPrompt => 'Add a short bio to personalize your profile';

  @override
  String get showLess => 'Show less';

  @override
  String get readMore => 'Read more';

  @override
  String get favorites => 'Favorites';

  @override
  String get reviews => 'Reviews';

  @override
  String get recentOrder => 'Recent order';

  @override
  String get viewedAStore => 'Viewed a store';

  @override
  String get leftAReview => 'Left a review';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get or => 'OR';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String pleaseEnterField(String field) {
    return 'Please enter $field';
  }

  @override
  String loginFailedWithError(String error) {
    return 'Login failed: $error';
  }

  @override
  String get verifyEmailPrompt => 'Please verify your email.';

  @override
  String get send => 'Send';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordInstructions => 'Enter your registered email. We will send you a reset link.';

  @override
  String get resetLinkSent => 'Reset link sent to your email.';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get phone => 'Phone';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get next => 'Next';

  @override
  String get genderLabel => 'Gender:';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get birthdayLabel => 'Birthday:';

  @override
  String get addressTitle => 'Address';

  @override
  String get addressLabelPlaceholder => 'Label (e.g. Home)';

  @override
  String get street => 'Street';

  @override
  String get city => 'City';

  @override
  String get country => 'Country';

  @override
  String get postalCode => 'Postal Code';

  @override
  String get back => 'Back';

  @override
  String get registrationSuccessVerifyEmail => 'Your registration was successful. Please verify your email.';

  @override
  String registrationFailedWithError(String error) {
    return 'Registration failed: $error';
  }

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get cartTitle => 'Cart';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get cartsAllTitle => 'All Carts';

  @override
  String get failedToLoadStoreData => 'Failed to load store data';

  @override
  String get removeCart => 'Remove cart';

  @override
  String get removeCartConfirmation => 'Are you sure you want to remove this cart?';

  @override
  String get remove => 'Remove';

  @override
  String get cartRemoved => 'Cart removed';

  @override
  String get checkoutAllCarts => 'Checkout all carts';

  @override
  String get cartIsEmptyTitle => 'Your cart is empty';

  @override
  String get addItemsToBeginCheckout => 'Add items to begin checkout';

  @override
  String get failedToLoadStore => 'Failed to load store';

  @override
  String get cartCleared => 'Cart cleared';

  @override
  String get clear => 'Clear';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get totalWeight => 'Total weight';

  @override
  String get deliveryFee => 'Delivery fee';

  @override
  String get total => 'Total';

  @override
  String get kg => 'kg';

  @override
  String get checkout => 'Checkout';

  @override
  String get viewCart => 'View cart';

  @override
  String get checkoutThisStore => 'Checkout this store';

  @override
  String get placeOrder => 'Place order';

  @override
  String get addDeliveryNotes => 'Add delivery notes';

  @override
  String get addNoteTitle => 'Add a note to this order';

  @override
  String get addNoteHint => 'e.g. Please ring the bell or leave at the door';

  @override
  String get saveNote => 'Save note';

  @override
  String get langArabic => 'Arabic';

  @override
  String get langEnglish => 'English';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionNext => 'Next';

  @override
  String get actionGetStarted => 'Get started';

  @override
  String get onbTitle1 => 'Welcome to Sudan Goods';

  @override
  String get onbBody1 => 'Bringing Sudanese products closer to you.';

  @override
  String get onbTitle2 => 'Order without waiting';

  @override
  String get onbBody2 => 'No need to wait for travelers—buy directly from trusted sellers.';

  @override
  String get onbTitle3 => 'Made for our community';

  @override
  String get onbBody3 => 'We connect Sudanese sellers with Sudanese buyers everywhere.';

  @override
  String get onbTitle4 => 'Fast delivery';

  @override
  String get onbBody4 => 'Get items to your door in about 3 days.';

  @override
  String get onbTitle5 => 'Stay in the loop';

  @override
  String get onbBody5 => 'Follow stores and get notified when new products arrive.';

  @override
  String get onbTitle6 => 'Can\'t find it?';

  @override
  String get onbBody6 => 'Tap \"Wanted\" and we\'ll try to source it for you.';

  @override
  String get onbTitle7 => 'Start in minutes';

  @override
  String get onbBody7 => 'Register with your address and start shopping Sudanese products.';

  @override
  String get onbTitle8 => 'Together for Sudan';

  @override
  String get onbBody8 => 'We\'re building something for our beloved Sudan. Contact us anytime.';

  @override
  String get resetOnboarding => 'Reset onboarding';

  @override
  String get resetOnboardingSubtitle => 'Show the welcome walkthrough on next app start';

  @override
  String get reset => 'Reset';

  @override
  String get onboardingResetSuccess => 'Onboarding reset. It will appear on next launch.';

  @override
  String get orderDetailsTitle => 'Order Details';

  @override
  String get itemsTitle => 'Items';

  @override
  String get deliverySectionTitle => 'Delivery';

  @override
  String get statusSectionTitle => 'Status';

  @override
  String get orderStatusLabel => 'Order status';

  @override
  String get paymentLabel => 'Payment';

  @override
  String get createdAtLabel => 'Created';

  @override
  String get updatedAtLabel => 'Updated';

  @override
  String get summarySectionTitle => 'Summary';

  @override
  String placedOnWithDate(String date) {
    return 'Placed on $date';
  }

  @override
  String failedToLoadOrderWithError(String error) {
    return 'Failed to load order: $error';
  }

  @override
  String get orderNotFound => 'Order not found';

  @override
  String qtyAndPrice(num qty, String price) {
    return '$qty × $price';
  }
}
