import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Sudan Goods'**
  String get appTitle;

  /// Greets the user by name
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}!'**
  String greeting(String name);

  /// Item count label with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String itemsCount(num count);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sectionAccount;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get changeEmail;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @manageAddresses.
  ///
  /// In en, this message translates to:
  /// **'Manage addresses'**
  String get manageAddresses;

  /// No description provided for @changeEmailVerifyBeforeLabel.
  ///
  /// In en, this message translates to:
  /// **'Verify before updating'**
  String get changeEmailVerifyBeforeLabel;

  /// No description provided for @changeEmailVerifyBeforeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send a verification link to the new email first'**
  String get changeEmailVerifyBeforeSubtitle;

  /// No description provided for @changeEmailSyncNow.
  ///
  /// In en, this message translates to:
  /// **'I verified, sync now'**
  String get changeEmailSyncNow;

  /// No description provided for @sectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get sectionNotifications;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive updates and promotions'**
  String get pushNotificationsSubtitle;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email notifications'**
  String get emailNotifications;

  /// No description provided for @emailNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get messages to your inbox'**
  String get emailNotificationsSubtitle;

  /// No description provided for @orderStatusUpdates.
  ///
  /// In en, this message translates to:
  /// **'Order status updates'**
  String get orderStatusUpdates;

  /// No description provided for @orderStatusUpdatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your orders in real time'**
  String get orderStatusUpdatesSubtitle;

  /// No description provided for @sectionPrivacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get sectionPrivacySecurity;

  /// No description provided for @twoFactorAuth.
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication'**
  String get twoFactorAuth;

  /// No description provided for @twoFactorAuthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add extra protection to your account'**
  String get twoFactorAuthSubtitle;

  /// No description provided for @blockedUsers.
  ///
  /// In en, this message translates to:
  /// **'Blocked users'**
  String get blockedUsers;

  /// No description provided for @dataAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data & privacy'**
  String get dataAndPrivacy;

  /// No description provided for @dataAndPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your data and preferences'**
  String get dataAndPrivacySubtitle;

  /// No description provided for @sectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get sectionGeneral;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguage;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose system, light, or dark'**
  String get themeSubtitle;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select theme'**
  String get selectTheme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @regionAndCurrency.
  ///
  /// In en, this message translates to:
  /// **'Region & currency'**
  String get regionAndCurrency;

  /// No description provided for @selectRegionCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select region & currency'**
  String get selectRegionCurrency;

  /// No description provided for @sectionHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get sectionHelpSupport;

  /// No description provided for @faqs.
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get faqs;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get dangerZone;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @regionUAE.
  ///
  /// In en, this message translates to:
  /// **'United Arab Emirates'**
  String get regionUAE;

  /// No description provided for @regionUS.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get regionUS;

  /// No description provided for @regionSudan.
  ///
  /// In en, this message translates to:
  /// **'Sudan'**
  String get regionSudan;

  /// Formats region and currency together
  ///
  /// In en, this message translates to:
  /// **'{region} ({currency})'**
  String regionCurrencyFormat(String region, String currency);

  /// Shown in a snackbar for features not yet implemented
  ///
  /// In en, this message translates to:
  /// **'{feature} coming soon'**
  String comingSoonWithFeature(String feature);

  /// Dialog title asking to confirm an action
  ///
  /// In en, this message translates to:
  /// **'{action}?'**
  String confirmActionTitle(String action);

  /// Dialog message asking to confirm an action
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to proceed with {action}?'**
  String confirmActionMessage(String action);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @failedToLoadSettings.
  ///
  /// In en, this message translates to:
  /// **'Failed to load settings. Please try again.'**
  String get failedToLoadSettings;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for products or stores'**
  String get searchHint;

  /// No description provided for @searchEmptyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type a query and press search'**
  String get searchEmptyPrompt;

  /// Label shown above results with the search query
  ///
  /// In en, this message translates to:
  /// **'Results for: \"{query}\"'**
  String searchResultsFor(String query);

  /// Title shown when no search results are found
  ///
  /// In en, this message translates to:
  /// **'No results for: \"{query}\"'**
  String searchNoResultsTitle(String query);

  /// No description provided for @searchNoResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try different keywords or request the item.'**
  String get searchNoResultsSubtitle;

  /// No description provided for @storesWithMatches.
  ///
  /// In en, this message translates to:
  /// **'Stores with matching products'**
  String get storesWithMatches;

  /// No description provided for @matchingProducts.
  ///
  /// In en, this message translates to:
  /// **'Matching products'**
  String get matchingProducts;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearSearch;

  /// No description provided for @wantedCTA.
  ///
  /// In en, this message translates to:
  /// **'Request it'**
  String get wantedCTA;

  /// No description provided for @wantedSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Request a product'**
  String get wantedSheetTitle;

  /// No description provided for @wantedProductNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get wantedProductNameLabel;

  /// No description provided for @wantedNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get wantedNotesLabel;

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit request'**
  String get submitRequest;

  /// No description provided for @wantedSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Request submitted. Thank you!'**
  String get wantedSubmitted;

  /// No description provided for @wantedSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit request. Please try again.'**
  String get wantedSubmitFailed;

  /// No description provided for @allStoresTitle.
  ///
  /// In en, this message translates to:
  /// **'All Stores'**
  String get allStoresTitle;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @failedToLoadStores.
  ///
  /// In en, this message translates to:
  /// **'Failed to load stores'**
  String get failedToLoadStores;

  /// No description provided for @noStoresAvailable.
  ///
  /// In en, this message translates to:
  /// **'No stores available'**
  String get noStoresAvailable;

  /// No description provided for @storeDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Store Details'**
  String get storeDetailsTitle;

  /// No description provided for @storeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Store not found'**
  String get storeNotFound;

  /// No description provided for @storeNotFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The store you\'re looking for doesn\'t exist or has been removed.'**
  String get storeNotFoundSubtitle;

  /// No description provided for @collectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collectionsTitle;

  /// No description provided for @noCollectionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No collections available'**
  String get noCollectionsAvailable;

  /// No description provided for @browseCategories.
  ///
  /// In en, this message translates to:
  /// **'Browse Categories'**
  String get browseCategories;

  /// No description provided for @filterButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterButtonLabel;

  /// No description provided for @filterSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter Stores'**
  String get filterSheetTitle;

  /// No description provided for @filterReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get filterReset;

  /// No description provided for @filterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get filterApply;

  /// No description provided for @filterOpenNow.
  ///
  /// In en, this message translates to:
  /// **'Open Now'**
  String get filterOpenNow;

  /// No description provided for @filterOpenNowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only show currently open stores'**
  String get filterOpenNowSubtitle;

  /// No description provided for @filterFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get filterFeatured;

  /// No description provided for @filterFeaturedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only show featured stores'**
  String get filterFeaturedSubtitle;

  /// No description provided for @filterFreeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Free Delivery'**
  String get filterFreeDelivery;

  /// No description provided for @filterFreeDeliverySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only show stores with free delivery offers'**
  String get filterFreeDeliverySubtitle;

  /// No description provided for @filterMinOrder.
  ///
  /// In en, this message translates to:
  /// **'Minimum Order'**
  String get filterMinOrder;

  /// No description provided for @featuredStores.
  ///
  /// In en, this message translates to:
  /// **'Featured Stores'**
  String get featuredStores;

  /// No description provided for @topPicksBadge.
  ///
  /// In en, this message translates to:
  /// **'⭐ Top picks'**
  String get topPicksBadge;

  /// No description provided for @noFeaturedStores.
  ///
  /// In en, this message translates to:
  /// **'No featured stores'**
  String get noFeaturedStores;

  /// No description provided for @popularProducts.
  ///
  /// In en, this message translates to:
  /// **'Popular Products'**
  String get popularProducts;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get outOfStock;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Good day! 👋'**
  String get homeGreeting;

  /// Indicates current delivery location
  ///
  /// In en, this message translates to:
  /// **'Delivering to {place}'**
  String deliveringTo(String place);

  /// No description provided for @failedToLoadCategories.
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories'**
  String get failedToLoadCategories;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @storeOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get storeOpen;

  /// No description provided for @storeClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get storeClosed;

  /// Minimum order amount label
  ///
  /// In en, this message translates to:
  /// **'Min. Order: {amount}'**
  String minOrderWithAmount(String amount);

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhoto;

  /// No description provided for @tapToChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to change photo'**
  String get tapToChangePhoto;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @handle.
  ///
  /// In en, this message translates to:
  /// **'Handle'**
  String get handle;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @searchMessagesHint.
  ///
  /// In en, this message translates to:
  /// **'Search messages'**
  String get searchMessagesHint;

  /// No description provided for @newMessage.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get newMessage;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @startConversationPrompt.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with a store or support'**
  String get startConversationPrompt;

  /// No description provided for @failedToLoadMessages.
  ///
  /// In en, this message translates to:
  /// **'Failed to load messages. Please try again.'**
  String get failedToLoadMessages;

  /// No description provided for @startNewMessage.
  ///
  /// In en, this message translates to:
  /// **'Start new message'**
  String get startNewMessage;

  /// No description provided for @messageAStore.
  ///
  /// In en, this message translates to:
  /// **'Message a store'**
  String get messageAStore;

  /// Label for starting chat with an entity
  ///
  /// In en, this message translates to:
  /// **'Chat with {name}'**
  String chatWith(String name);

  /// No description provided for @mustLoginToViewOrders.
  ///
  /// In en, this message translates to:
  /// **'You need to be logged in to view orders.'**
  String get mustLoginToViewOrders;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @failedToLoadOrders.
  ///
  /// In en, this message translates to:
  /// **'Failed to load orders.'**
  String get failedToLoadOrders;

  /// No description provided for @deleteOrderQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete Order?'**
  String get deleteOrderQuestion;

  /// No description provided for @deleteOrderExplanation.
  ///
  /// In en, this message translates to:
  /// **'This order has not been confirmed yet. Do you want to delete it?'**
  String get deleteOrderExplanation;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @orderDeleted.
  ///
  /// In en, this message translates to:
  /// **'Order deleted'**
  String get orderDeleted;

  /// No description provided for @failedToDeleteOrder.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete order.'**
  String get failedToDeleteOrder;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// No description provided for @ordersEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Your orders will appear here. Start shopping to place your first order!'**
  String get ordersEmptyHint;

  /// Order number label with short id
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String orderNumber(String id);

  /// No description provided for @deleteOrder.
  ///
  /// In en, this message translates to:
  /// **'Delete order'**
  String get deleteOrder;

  /// No description provided for @unknownStore.
  ///
  /// In en, this message translates to:
  /// **'Unknown store'**
  String get unknownStore;

  /// No description provided for @orderStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderStatusPending;

  /// No description provided for @orderStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get orderStatusConfirmed;

  /// No description provided for @orderStatusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get orderStatusPreparing;

  /// No description provided for @orderStatusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get orderStatusProcessing;

  /// No description provided for @orderStatusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get orderStatusShipped;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// No description provided for @failedToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile. Please try again.'**
  String get failedToLoadProfile;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// No description provided for @addShortBioPrompt.
  ///
  /// In en, this message translates to:
  /// **'Add a short bio to personalize your profile'**
  String get addShortBioPrompt;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @recentOrder.
  ///
  /// In en, this message translates to:
  /// **'Recent order'**
  String get recentOrder;

  /// No description provided for @viewedAStore.
  ///
  /// In en, this message translates to:
  /// **'Viewed a store'**
  String get viewedAStore;

  /// No description provided for @leftAReview.
  ///
  /// In en, this message translates to:
  /// **'Left a review'**
  String get leftAReview;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// Validation message asking user to enter a field value
  ///
  /// In en, this message translates to:
  /// **'Please enter {field}'**
  String pleaseEnterField(String field);

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// Login failure message with error details
  ///
  /// In en, this message translates to:
  /// **'Login failed: {error}'**
  String loginFailedWithError(String error);

  /// No description provided for @verifyEmailPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email.'**
  String get verifyEmailPrompt;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to'**
  String get verifyEmailSubtitle;

  /// No description provided for @verifyEmailInstructions.
  ///
  /// In en, this message translates to:
  /// **'Open the link in your inbox to continue. This page will update automatically.'**
  String get verifyEmailInstructions;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent!'**
  String get verificationEmailSent;

  /// No description provided for @resendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend verification email'**
  String get resendVerificationEmail;

  /// No description provided for @verificationTimeoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Verification is taking longer than expected. Please check your inbox or sign out and try again.'**
  String get verificationTimeoutMessage;

  /// Resend cooldown label with remaining seconds
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendCooldown(int seconds);

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email. We will send you a reset link.'**
  String get resetPasswordInstructions;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent to your email.'**
  String get resetLinkSent;

  /// Generic error message with details
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(String message);

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender:'**
  String get genderLabel;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @birthdayLabel.
  ///
  /// In en, this message translates to:
  /// **'Birthday:'**
  String get birthdayLabel;

  /// No description provided for @birthdayAgeError.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 13 years old'**
  String get birthdayAgeError;

  /// No description provided for @addressTitle.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressTitle;

  /// No description provided for @addressLabelPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Label (e.g. Home)'**
  String get addressLabelPlaceholder;

  /// No description provided for @street.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get street;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @postalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal Code'**
  String get postalCode;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @registrationSuccessVerifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Your registration was successful. Please verify your email.'**
  String get registrationSuccessVerifyEmail;

  /// Registration failure message with error details
  ///
  /// In en, this message translates to:
  /// **'Registration failed: {error}'**
  String registrationFailedWithError(String error);

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cartTitle;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @cartsAllTitle.
  ///
  /// In en, this message translates to:
  /// **'All Carts'**
  String get cartsAllTitle;

  /// No description provided for @failedToLoadStoreData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load store data'**
  String get failedToLoadStoreData;

  /// No description provided for @removeCart.
  ///
  /// In en, this message translates to:
  /// **'Remove cart'**
  String get removeCart;

  /// No description provided for @removeCartConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this cart?'**
  String get removeCartConfirmation;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @cartRemoved.
  ///
  /// In en, this message translates to:
  /// **'Cart removed'**
  String get cartRemoved;

  /// No description provided for @checkoutAllCarts.
  ///
  /// In en, this message translates to:
  /// **'Checkout all carts'**
  String get checkoutAllCarts;

  /// No description provided for @cartIsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartIsEmptyTitle;

  /// No description provided for @addItemsToBeginCheckout.
  ///
  /// In en, this message translates to:
  /// **'Add items to begin checkout'**
  String get addItemsToBeginCheckout;

  /// No description provided for @failedToLoadStore.
  ///
  /// In en, this message translates to:
  /// **'Failed to load store'**
  String get failedToLoadStore;

  /// No description provided for @cartCleared.
  ///
  /// In en, this message translates to:
  /// **'Cart cleared'**
  String get cartCleared;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @totalWeight.
  ///
  /// In en, this message translates to:
  /// **'Total weight'**
  String get totalWeight;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get deliveryFee;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View cart'**
  String get viewCart;

  /// No description provided for @checkoutThisStore.
  ///
  /// In en, this message translates to:
  /// **'Checkout this store'**
  String get checkoutThisStore;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get placeOrder;

  /// No description provided for @addDeliveryNotes.
  ///
  /// In en, this message translates to:
  /// **'Add delivery notes'**
  String get addDeliveryNotes;

  /// No description provided for @addNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a note to this order'**
  String get addNoteTitle;

  /// No description provided for @addNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Please ring the bell or leave at the door'**
  String get addNoteHint;

  /// No description provided for @saveNote.
  ///
  /// In en, this message translates to:
  /// **'Save note'**
  String get saveNote;

  /// No description provided for @langArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get langArabic;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @actionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get actionGetStarted;

  /// No description provided for @languagePickerTaglineEn.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the biggest Sudanese\nonline shopping hub'**
  String get languagePickerTaglineEn;

  /// No description provided for @languagePickerTaglineAr.
  ///
  /// In en, this message translates to:
  /// **'مرحبا بيك في اكبر مركز تسوق الكتروني سوداني'**
  String get languagePickerTaglineAr;

  /// Onboarding step counter label
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onbStepProgress(int current, int total);

  /// No description provided for @appStartLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load app settings. Please try again.'**
  String get appStartLoadError;

  /// No description provided for @languagePickerSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languagePickerSectionTitle;

  /// No description provided for @onbIllustrationLanguage.
  ///
  /// In en, this message translates to:
  /// **'3D illustration of language selection with English and Arabic options'**
  String get onbIllustrationLanguage;

  /// No description provided for @onbIllustrationWelcome.
  ///
  /// In en, this message translates to:
  /// **'3D illustration of discovering products from local stores'**
  String get onbIllustrationWelcome;

  /// No description provided for @onbIllustrationOrder.
  ///
  /// In en, this message translates to:
  /// **'3D illustration of fast direct ordering and delivery'**
  String get onbIllustrationOrder;

  /// No description provided for @onbIllustrationDiscover.
  ///
  /// In en, this message translates to:
  /// **'3D illustration of browsing stores and receiving updates'**
  String get onbIllustrationDiscover;

  /// No description provided for @onbIllustrationStart.
  ///
  /// In en, this message translates to:
  /// **'3D illustration of getting started and ready to shop'**
  String get onbIllustrationStart;

  /// No description provided for @onbTitle1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Sudan Goods'**
  String get onbTitle1;

  /// No description provided for @onbSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Discover authentic Sudanese products from trusted local stores.'**
  String get onbSubtitle1;

  /// No description provided for @onbBody1.
  ///
  /// In en, this message translates to:
  /// **'Bringing Sudanese products closer to you.'**
  String get onbBody1;

  /// No description provided for @onbTitle2.
  ///
  /// In en, this message translates to:
  /// **'Order without waiting'**
  String get onbTitle2;

  /// No description provided for @onbSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Shop directly from sellers—no need to wait for travelers.'**
  String get onbSubtitle2;

  /// No description provided for @onbBody2.
  ///
  /// In en, this message translates to:
  /// **'No need to wait for travelers—buy directly from trusted sellers.'**
  String get onbBody2;

  /// No description provided for @onbTitle3.
  ///
  /// In en, this message translates to:
  /// **'Made for our community'**
  String get onbTitle3;

  /// No description provided for @onbBody3.
  ///
  /// In en, this message translates to:
  /// **'We connect Sudanese sellers with Sudanese buyers everywhere.'**
  String get onbBody3;

  /// No description provided for @onbTitle4.
  ///
  /// In en, this message translates to:
  /// **'Fast delivery'**
  String get onbTitle4;

  /// No description provided for @onbBody4.
  ///
  /// In en, this message translates to:
  /// **'Get items to your door in about 3 days.'**
  String get onbBody4;

  /// No description provided for @onbTitle5.
  ///
  /// In en, this message translates to:
  /// **'Stay in the loop'**
  String get onbTitle5;

  /// No description provided for @onbSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Follow stores, get updates, and request hard-to-find items.'**
  String get onbSubtitle3;

  /// No description provided for @onbBody5.
  ///
  /// In en, this message translates to:
  /// **'Follow stores and get notified when new products arrive.'**
  String get onbBody5;

  /// No description provided for @onbTitle6.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find it?'**
  String get onbTitle6;

  /// No description provided for @onbBody6.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Wanted\" and we\'ll try to source it for you.'**
  String get onbBody6;

  /// No description provided for @onbTitle7.
  ///
  /// In en, this message translates to:
  /// **'Start in minutes'**
  String get onbTitle7;

  /// No description provided for @onbSubtitle4.
  ///
  /// In en, this message translates to:
  /// **'Create your account, add an address, and start shopping today.'**
  String get onbSubtitle4;

  /// No description provided for @onbBody7.
  ///
  /// In en, this message translates to:
  /// **'Register with your address and start shopping Sudanese products.'**
  String get onbBody7;

  /// No description provided for @onbTitle8.
  ///
  /// In en, this message translates to:
  /// **'Together for Sudan'**
  String get onbTitle8;

  /// No description provided for @onbBody8.
  ///
  /// In en, this message translates to:
  /// **'We\'re building something for our beloved Sudan. Contact us anytime.'**
  String get onbBody8;

  /// No description provided for @resetOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Reset onboarding'**
  String get resetOnboarding;

  /// No description provided for @resetOnboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show the welcome walkthrough on next app start'**
  String get resetOnboardingSubtitle;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @onboardingResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Onboarding reset. It will appear on next launch.'**
  String get onboardingResetSuccess;

  /// No description provided for @orderDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetailsTitle;

  /// No description provided for @itemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get itemsTitle;

  /// No description provided for @deliverySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get deliverySectionTitle;

  /// No description provided for @statusSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusSectionTitle;

  /// No description provided for @orderStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Order status'**
  String get orderStatusLabel;

  /// No description provided for @paymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentLabel;

  /// No description provided for @createdAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdAtLabel;

  /// No description provided for @updatedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updatedAtLabel;

  /// No description provided for @summarySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summarySectionTitle;

  /// Order placed timestamp label
  ///
  /// In en, this message translates to:
  /// **'Placed on {date}'**
  String placedOnWithDate(String date);

  /// Order details loading failure with error details
  ///
  /// In en, this message translates to:
  /// **'Failed to load order: {error}'**
  String failedToLoadOrderWithError(String error);

  /// No description provided for @orderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found'**
  String get orderNotFound;

  /// Displays quantity and unit price for a line item
  ///
  /// In en, this message translates to:
  /// **'{qty} × {price}'**
  String qtyAndPrice(num qty, String price);

  /// No description provided for @navInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get navInfo;

  /// No description provided for @infoTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Info'**
  String get infoTabTitle;

  /// No description provided for @infoTabSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get in touch or learn more about us'**
  String get infoTabSubtitle;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @contactUsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send us a message, we reply within 24 hours'**
  String get contactUsSubtitle;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @aboutUsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn more about Sudan Goods'**
  String get aboutUsSubtitle;

  /// No description provided for @contactFormTitle.
  ///
  /// In en, this message translates to:
  /// **'We\'d love to hear from you'**
  String get contactFormTitle;

  /// No description provided for @contactFormSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in the form below and we\'ll get back to you shortly.'**
  String get contactFormSubtitle;

  /// No description provided for @contactFormEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Your email'**
  String get contactFormEmailLabel;

  /// No description provided for @contactFormSubjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get contactFormSubjectLabel;

  /// No description provided for @contactFormMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Your message'**
  String get contactFormMessageLabel;

  /// No description provided for @contactFormMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your question or feedback...'**
  String get contactFormMessageHint;

  /// No description provided for @contactFormCharCount.
  ///
  /// In en, this message translates to:
  /// **'{count}/500'**
  String contactFormCharCount(int count);

  /// No description provided for @contactFormSendButton.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get contactFormSendButton;

  /// No description provided for @contactFormSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Message sent!'**
  String get contactFormSuccessTitle;

  /// No description provided for @contactFormSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Thank you for reaching out. We\'ll get back to you within 24 hours.'**
  String get contactFormSuccessSubtitle;

  /// No description provided for @contactFormSendAnother.
  ///
  /// In en, this message translates to:
  /// **'Send another message'**
  String get contactFormSendAnother;

  /// No description provided for @contactFormError.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message. Please try again.'**
  String get contactFormError;

  /// No description provided for @contactFormValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a message'**
  String get contactFormValidationEmpty;

  /// No description provided for @contactFormValidationTooShort.
  ///
  /// In en, this message translates to:
  /// **'Message must be at least 10 characters'**
  String get contactFormValidationTooShort;

  /// No description provided for @subjectGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get subjectGeneral;

  /// No description provided for @subjectOrderIssue.
  ///
  /// In en, this message translates to:
  /// **'Order Issue'**
  String get subjectOrderIssue;

  /// No description provided for @subjectFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get subjectFeedback;

  /// No description provided for @aboutUsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load About Us content. Please try again.'**
  String get aboutUsLoadError;

  /// No description provided for @aboutUsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Content coming soon'**
  String get aboutUsEmpty;

  /// No description provided for @aboutUsPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get aboutUsPhone;

  /// No description provided for @aboutUsEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get aboutUsEmail;

  /// No description provided for @aboutUsWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get aboutUsWebsite;

  /// No description provided for @aboutUsInstagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get aboutUsInstagram;

  /// No description provided for @aboutUsTwitter.
  ///
  /// In en, this message translates to:
  /// **'X (Twitter)'**
  String get aboutUsTwitter;

  /// No description provided for @aboutUsFacebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get aboutUsFacebook;

  /// No description provided for @aboutUsSocial.
  ///
  /// In en, this message translates to:
  /// **'Follow Us'**
  String get aboutUsSocial;

  /// No description provided for @contactUsTag.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get contactUsTag;

  /// No description provided for @aboutUsTag.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get aboutUsTag;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add Address'**
  String get addAddress;

  /// No description provided for @saveAddress.
  ///
  /// In en, this message translates to:
  /// **'Save Address'**
  String get saveAddress;

  /// No description provided for @deleteAddress.
  ///
  /// In en, this message translates to:
  /// **'Delete Address'**
  String get deleteAddress;

  /// No description provided for @deleteAddressConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this address?'**
  String get deleteAddressConfirmation;

  /// No description provided for @defaultAddress.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultAddress;

  /// No description provided for @noAddressesYet.
  ///
  /// In en, this message translates to:
  /// **'No saved addresses'**
  String get noAddressesYet;

  /// No description provided for @addAddressPrompt.
  ///
  /// In en, this message translates to:
  /// **'Add an address to use for delivery.'**
  String get addAddressPrompt;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get addressLabel;

  /// No description provided for @addressLabelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Home, Work'**
  String get addressLabelHint;

  /// No description provided for @streetHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 123 Main St'**
  String get streetHint;

  /// No description provided for @cityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Khartoum'**
  String get cityHint;

  /// No description provided for @failedToDeleteAddress.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete address. Please try again.'**
  String get failedToDeleteAddress;

  /// No description provided for @failedToSaveAddress.
  ///
  /// In en, this message translates to:
  /// **'Failed to save address. Please try again.'**
  String get failedToSaveAddress;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
