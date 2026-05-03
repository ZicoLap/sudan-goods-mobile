// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'سلع السودان';

  @override
  String greeting(String name) {
    return 'مرحباً، $name!';
  }

  @override
  String itemsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عناصر',
      one: 'عنصر واحد',
      zero: 'لا توجد عناصر',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get sectionAccount => 'الحساب';

  @override
  String get changeEmail => 'تغيير البريد الإلكتروني';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get manageAddresses => 'إدارة العناوين';

  @override
  String get changeEmailVerifyBeforeLabel => 'تحقق قبل التحديث';

  @override
  String get changeEmailVerifyBeforeSubtitle => 'أرسل رابط التحقق إلى البريد الجديد أولاً';

  @override
  String get changeEmailSyncNow => 'لقد تحققت، مزامنة الآن';

  @override
  String get sectionNotifications => 'الإشعارات';

  @override
  String get pushNotifications => 'إشعارات الدفع';

  @override
  String get pushNotificationsSubtitle => 'استلام التحديثات والعروض';

  @override
  String get emailNotifications => 'إشعارات البريد الإلكتروني';

  @override
  String get emailNotificationsSubtitle => 'استلام الرسائل في بريدك';

  @override
  String get orderStatusUpdates => 'تحديثات حالة الطلب';

  @override
  String get orderStatusUpdatesSubtitle => 'تتبع طلباتك في الوقت الفعلي';

  @override
  String get sectionPrivacySecurity => 'الخصوصية والأمان';

  @override
  String get twoFactorAuth => 'التحقق بخطوتين';

  @override
  String get twoFactorAuthSubtitle => 'أضف حماية إضافية لحسابك';

  @override
  String get blockedUsers => 'المستخدمون المحظورون';

  @override
  String get dataAndPrivacy => 'البيانات والخصوصية';

  @override
  String get dataAndPrivacySubtitle => 'إدارة بياناتك وتفضيلاتك';

  @override
  String get sectionGeneral => 'عام';

  @override
  String get language => 'اللغة';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get theme => 'المظهر';

  @override
  String get themeSubtitle => 'اختر النظام أو الفاتح أو الداكن';

  @override
  String get selectTheme => 'اختر المظهر';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeSystem => 'النظام';

  @override
  String get regionAndCurrency => 'المنطقة والعملة';

  @override
  String get selectRegionCurrency => 'اختر المنطقة والعملة';

  @override
  String get sectionHelpSupport => 'المساعدة والدعم';

  @override
  String get faqs => 'الأسئلة الشائعة';

  @override
  String get contactSupport => 'تواصل مع الدعم';

  @override
  String get appVersion => 'إصدار التطبيق';

  @override
  String get dangerZone => 'منطقة الخطر';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get regionUAE => 'الإمارات العربية المتحدة';

  @override
  String get regionUS => 'الولايات المتحدة';

  @override
  String get regionSudan => 'السودان';

  @override
  String regionCurrencyFormat(String region, String currency) {
    return '$region ($currency)';
  }

  @override
  String comingSoonWithFeature(String feature) {
    return '$feature قادم قريباً';
  }

  @override
  String confirmActionTitle(String action) {
    return '$action؟';
  }

  @override
  String confirmActionMessage(String action) {
    return 'هل أنت متأكد أنك تريد المتابعة في $action؟';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get failedToLoadSettings => 'فشل تحميل الإعدادات. يرجى المحاولة مرة أخرى.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get searchTitle => 'البحث';

  @override
  String get searchHint => 'ابحث عن المنتجات أو المتاجر';

  @override
  String get searchEmptyPrompt => 'اكتب عبارة ثم اضغط بحث';

  @override
  String searchResultsFor(String query) {
    return 'النتائج عن: \"$query\"';
  }

  @override
  String searchNoResultsTitle(String query) {
    return 'لا نتائج لـ: \"$query\"';
  }

  @override
  String get searchNoResultsSubtitle => 'جرّب كلمات أخرى أو اطلب المنتج.';

  @override
  String get storesWithMatches => 'متاجر تحتوي منتجات مطابقة';

  @override
  String get matchingProducts => 'منتجات مطابقة';

  @override
  String get clearSearch => 'مسح';

  @override
  String get wantedCTA => 'مطلوب';

  @override
  String get wantedSheetTitle => 'طلب منتج';

  @override
  String get wantedProductNameLabel => 'اسم المنتج';

  @override
  String get wantedNotesLabel => 'ملاحظات (اختياري)';

  @override
  String get submitRequest => 'إرسال الطلب';

  @override
  String get wantedSubmitted => 'تم إرسال الطلب. شكراً!';

  @override
  String get wantedSubmitFailed => 'فشل إرسال الطلب. الرجاء المحاولة لاحقاً.';

  @override
  String get allStoresTitle => 'جميع المتاجر';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get failedToLoadStores => 'فشل تحميل المتاجر';

  @override
  String get noStoresAvailable => 'لا توجد متاجر متاحة';

  @override
  String get storeDetailsTitle => 'تفاصيل المتجر';

  @override
  String get storeNotFound => 'المتجر غير موجود';

  @override
  String get storeNotFoundSubtitle => 'المتجر الذي تبحث عنه غير موجود أو تمت إزالته.';

  @override
  String get collectionsTitle => 'المجموعات';

  @override
  String get noCollectionsAvailable => 'لا توجد مجموعات متاحة';

  @override
  String get browseCategories => 'تصفح الفئات';

  @override
  String get featuredStores => 'متاجر مميزة';

  @override
  String get topPicksBadge => '⭐ اختيارات مميزة';

  @override
  String get noFeaturedStores => 'لا توجد متاجر مميزة';

  @override
  String get popularProducts => 'المنتجات الشائعة';

  @override
  String get outOfStock => 'غير متوفر';

  @override
  String get homeGreeting => 'يوم سعيد! 👋';

  @override
  String deliveringTo(String place) {
    return 'التوصيل إلى $place';
  }

  @override
  String get failedToLoadCategories => 'فشل تحميل الفئات';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navOrders => 'الطلبات';

  @override
  String get navSearch => 'البحث';

  @override
  String get navMessages => 'الرسائل';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get storeOpen => 'مفتوح';

  @override
  String get storeClosed => 'مغلق';

  @override
  String minOrderWithAmount(String amount) {
    return 'الحد الأدنى للطلب: $amount';
  }

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get profilePhoto => 'صورة الملف الشخصي';

  @override
  String get tapToChangePhoto => 'انقر لتغيير الصورة';

  @override
  String get change => 'تغيير';

  @override
  String get name => 'الاسم';

  @override
  String get handle => 'المعرف';

  @override
  String get bio => 'نبذة';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get changePhoto => 'تغيير الصورة';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get chooseFromGallery => 'اختر من المعرض';

  @override
  String get searchMessagesHint => 'ابحث في الرسائل';

  @override
  String get newMessage => 'رسالة جديدة';

  @override
  String get noMessagesYet => 'لا توجد رسائل بعد';

  @override
  String get startConversationPrompt => 'ابدأ محادثة مع متجر أو الدعم';

  @override
  String get failedToLoadMessages => 'فشل تحميل الرسائل. يرجى المحاولة مرة أخرى.';

  @override
  String get startNewMessage => 'بدء رسالة جديدة';

  @override
  String get messageAStore => 'مراسلة متجر';

  @override
  String chatWith(String name) {
    return 'الدردشة مع $name';
  }

  @override
  String get mustLoginToViewOrders => 'يجب تسجيل الدخول لعرض الطلبات.';

  @override
  String get myOrders => 'طلباتي';

  @override
  String get failedToLoadOrders => 'فشل تحميل الطلبات.';

  @override
  String get deleteOrderQuestion => 'حذف الطلب؟';

  @override
  String get deleteOrderExplanation => 'لم يتم تأكيد هذا الطلب بعد. هل تريد حذفه؟';

  @override
  String get delete => 'حذف';

  @override
  String get orderDeleted => 'تم حذف الطلب';

  @override
  String get failedToDeleteOrder => 'فشل حذف الطلب.';

  @override
  String get noOrdersYet => 'لا توجد طلبات بعد';

  @override
  String get ordersEmptyHint => 'ستظهر طلباتك هنا. ابدأ التسوق لوضع أول طلب!';

  @override
  String orderNumber(String id) {
    return 'طلب #$id';
  }

  @override
  String get deleteOrder => 'حذف الطلب';

  @override
  String get unknownStore => 'متجر غير معروف';

  @override
  String get orderStatusPending => 'قيد الانتظار';

  @override
  String get orderStatusConfirmed => 'مؤكد';

  @override
  String get orderStatusPreparing => 'قيد التحضير';

  @override
  String get orderStatusProcessing => 'قيد المعالجة';

  @override
  String get orderStatusShipped => 'تم الشحن';

  @override
  String get orderStatusDelivered => 'تم التسليم';

  @override
  String get orderStatusCancelled => 'ملغي';

  @override
  String get failedToLoadProfile => 'فشل تحميل الملف الشخصي. يرجى المحاولة مرة أخرى.';

  @override
  String get recentActivity => 'النشاط الأخير';

  @override
  String get addShortBioPrompt => 'أضف نبذة قصيرة لتخصيص ملفك الشخصي';

  @override
  String get showLess => 'عرض أقل';

  @override
  String get readMore => 'قراءة المزيد';

  @override
  String get favorites => 'المفضلات';

  @override
  String get reviews => 'المراجعات';

  @override
  String get recentOrder => 'طلب حديث';

  @override
  String get viewedAStore => 'تم عرض متجر';

  @override
  String get leftAReview => 'ترك مراجعة';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'تسجيل';

  @override
  String get or => 'أو';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String pleaseEnterField(String field) {
    return 'يرجى إدخال $field';
  }

  @override
  String loginFailedWithError(String error) {
    return 'فشل تسجيل الدخول: $error';
  }

  @override
  String get verifyEmailPrompt => 'يرجى التحقق من بريدك الإلكتروني.';

  @override
  String get send => 'إرسال';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordInstructions => 'أدخل بريدك الإلكتروني المسجل. سنرسل لك رابط إعادة التعيين.';

  @override
  String get resetLinkSent => 'تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني.';

  @override
  String errorWithMessage(String message) {
    return 'خطأ: $message';
  }

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get phone => 'الهاتف';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get next => 'التالي';

  @override
  String get genderLabel => 'الجنس:';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get birthdayLabel => 'تاريخ الميلاد:';

  @override
  String get birthdayAgeError => 'يجب أن يكون عمرك 13 عامًا على الأقل';

  @override
  String get addressTitle => 'العنوان';

  @override
  String get addressLabelPlaceholder => 'التسمية (مثال: المنزل)';

  @override
  String get street => 'الشارع';

  @override
  String get city => 'المدينة';

  @override
  String get country => 'الدولة';

  @override
  String get postalCode => 'الرمز البريدي';

  @override
  String get back => 'رجوع';

  @override
  String get registrationSuccessVerifyEmail => 'تم التسجيل بنجاح. يرجى التحقق من بريدك الإلكتروني.';

  @override
  String registrationFailedWithError(String error) {
    return 'فشل التسجيل: $error';
  }

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get cartTitle => 'سلة التسوق';

  @override
  String get cartEmpty => 'سلة التسوق فارغة';

  @override
  String get cartsAllTitle => 'جميع السلال';

  @override
  String get failedToLoadStoreData => 'فشل تحميل بيانات المتجر';

  @override
  String get removeCart => 'إزالة السلة';

  @override
  String get removeCartConfirmation => 'هل أنت متأكد من إزالة هذه السلة؟';

  @override
  String get remove => 'إزالة';

  @override
  String get cartRemoved => 'تمت إزالة السلة';

  @override
  String get checkoutAllCarts => 'الدفع لكل السلال';

  @override
  String get cartIsEmptyTitle => 'سلة التسوق فارغة';

  @override
  String get addItemsToBeginCheckout => 'أضف عناصر لبدء عملية الدفع';

  @override
  String get failedToLoadStore => 'فشل تحميل المتجر';

  @override
  String get cartCleared => 'تم تفريغ السلة';

  @override
  String get clear => 'إفراغ';

  @override
  String get subtotal => 'الإجمالي الفرعي';

  @override
  String get totalWeight => 'الوزن الكلي';

  @override
  String get deliveryFee => 'رسوم التوصيل';

  @override
  String get total => 'الإجمالي';

  @override
  String get kg => 'كجم';

  @override
  String get checkout => 'الدفع';

  @override
  String get viewCart => 'عرض السلة';

  @override
  String get checkoutThisStore => 'الدفع لهذا المتجر';

  @override
  String get placeOrder => 'إتمام الطلب';

  @override
  String get addDeliveryNotes => 'أضف ملاحظات التوصيل';

  @override
  String get addNoteTitle => 'أضف ملاحظة لهذا الطلب';

  @override
  String get addNoteHint => 'مثال: يرجى قرع الجرس أو تركها عند الباب';

  @override
  String get saveNote => 'حفظ الملاحظة';

  @override
  String get langArabic => 'العربية';

  @override
  String get langEnglish => 'الإنجليزية';

  @override
  String get actionSkip => 'تخطي';

  @override
  String get actionNext => 'التالي';

  @override
  String get actionGetStarted => 'ابدأ الآن';

  @override
  String get onbTitle1 => 'مرحباً بك في سلع السودان';

  @override
  String get onbBody1 => 'نقرّب المنتجات السودانية إليك.';

  @override
  String get onbTitle2 => 'اطلب بلا انتظار';

  @override
  String get onbBody2 => 'لا حاجة لانتظار المسافرين—اشترِ مباشرة من باعة موثوقين.';

  @override
  String get onbTitle3 => 'لأجل مجتمعنا';

  @override
  String get onbBody3 => 'نصل الباعة السودانيين بالمشترين السودانيين في كل مكان.';

  @override
  String get onbTitle4 => 'توصيل سريع';

  @override
  String get onbBody4 => 'تصل إلى باب منزلك خلال نحو ٣ أيام.';

  @override
  String get onbTitle5 => 'ابقَ على اطلاع';

  @override
  String get onbBody5 => 'تابِع المتاجر وتلقَّ إشعاراً عند توفر منتجات جديدة.';

  @override
  String get onbTitle6 => 'لم تجد ما تريد؟';

  @override
  String get onbBody6 => 'اضغط \"مطلوب\" وسنحاول توفيره لك قريباً.';

  @override
  String get onbTitle7 => 'ابدأ خلال دقائق';

  @override
  String get onbBody7 => 'سجّل عنوانك وابدأ شراء المنتجات السودانية.';

  @override
  String get onbTitle8 => 'معاً من أجل السودان';

  @override
  String get onbBody8 => 'نبني شيئاً لبلدنا الحبيب. تواصل معنا في أي وقت.';

  @override
  String get resetOnboarding => 'إعادة تشغيل الإرشادات';

  @override
  String get resetOnboardingSubtitle => 'عرض جولة الترحيب عند تشغيل التطبيق القادم';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get onboardingResetSuccess => 'تمت إعادة الإرشادات. ستظهر عند التشغيل القادم.';

  @override
  String get orderDetailsTitle => 'تفاصيل الطلب';

  @override
  String get itemsTitle => 'العناصر';

  @override
  String get deliverySectionTitle => 'التوصيل';

  @override
  String get statusSectionTitle => 'الحالة';

  @override
  String get orderStatusLabel => 'حالة الطلب';

  @override
  String get paymentLabel => 'الدفع';

  @override
  String get createdAtLabel => 'تم الإنشاء';

  @override
  String get updatedAtLabel => 'تم التحديث';

  @override
  String get summarySectionTitle => 'الملخص';

  @override
  String placedOnWithDate(String date) {
    return 'تم الطلب في $date';
  }

  @override
  String failedToLoadOrderWithError(String error) {
    return 'فشل تحميل الطلب: $error';
  }

  @override
  String get orderNotFound => 'الطلب غير موجود';

  @override
  String qtyAndPrice(num qty, String price) {
    return '$qty × $price';
  }

  @override
  String get navInfo => 'معلومات';

  @override
  String get infoTabTitle => 'مساعدة ومعلومات';

  @override
  String get infoTabSubtitle => 'تواصل معنا أو تعرّف علينا أكثر';

  @override
  String get contactUs => 'تواصل معنا';

  @override
  String get contactUsSubtitle => 'أرسل لنا رسالة، نرد خلال 24 ساعة';

  @override
  String get aboutUs => 'من نحن';

  @override
  String get aboutUsSubtitle => 'تعرّف على بضائع السودان';

  @override
  String get contactFormTitle => 'يسعدنا سماعك';

  @override
  String get contactFormSubtitle => 'املأ النموذج أدناه وسنتواصل معك قريباً.';

  @override
  String get contactFormEmailLabel => 'بريدك الإلكتروني';

  @override
  String get contactFormSubjectLabel => 'الموضوع';

  @override
  String get contactFormMessageLabel => 'رسالتك';

  @override
  String get contactFormMessageHint => 'اشرح سؤالك أو ملاحظاتك...';

  @override
  String contactFormCharCount(int count) {
    return '$count/500';
  }

  @override
  String get contactFormSendButton => 'إرسال الرسالة';

  @override
  String get contactFormSuccessTitle => 'تم الإرسال!';

  @override
  String get contactFormSuccessSubtitle => 'شكراً لتواصلك. سنرد عليك خلال 24 ساعة.';

  @override
  String get contactFormSendAnother => 'إرسال رسالة أخرى';

  @override
  String get contactFormError => 'فشل إرسال الرسالة. يرجى المحاولة مجدداً.';

  @override
  String get contactFormValidationEmpty => 'يرجى كتابة رسالة';

  @override
  String get contactFormValidationTooShort => 'يجب أن تكون الرسالة 10 أحرف على الأقل';

  @override
  String get subjectGeneral => 'عام';

  @override
  String get subjectOrderIssue => 'مشكلة في الطلب';

  @override
  String get subjectFeedback => 'ملاحظات';

  @override
  String get aboutUsLoadError => 'فشل تحميل محتوى من نحن. يرجى المحاولة مجدداً.';

  @override
  String get aboutUsEmpty => 'المحتوى قريباً';

  @override
  String get aboutUsPhone => 'الهاتف';

  @override
  String get aboutUsEmail => 'البريد الإلكتروني';

  @override
  String get aboutUsWebsite => 'الموقع الإلكتروني';

  @override
  String get aboutUsInstagram => 'إنستغرام';

  @override
  String get aboutUsTwitter => 'إكس (تويتر)';

  @override
  String get aboutUsFacebook => 'فيسبوك';

  @override
  String get aboutUsSocial => 'تابعنا';

  @override
  String get contactUsTag => 'مجاني';

  @override
  String get aboutUsTag => 'معلومات';

  @override
  String get addAddress => 'إضافة عنوان';

  @override
  String get saveAddress => 'حفظ العنوان';

  @override
  String get deleteAddress => 'حذف العنوان';

  @override
  String get deleteAddressConfirmation => 'هل أنت متأكد من حذف هذا العنوان؟';

  @override
  String get defaultAddress => 'افتراضي';

  @override
  String get noAddressesYet => 'لا توجد عناوين محفوظة';

  @override
  String get addAddressPrompt => 'أضف عنواناً لاستخدامه في التوصيل.';

  @override
  String get addressLabel => 'التسمية';

  @override
  String get addressLabelHint => 'مثال: المنزل، العمل';

  @override
  String get streetHint => 'مثال: شارع النيل 123';

  @override
  String get cityHint => 'مثال: الخرطوم';

  @override
  String get failedToDeleteAddress => 'فشل حذف العنوان. يرجى المحاولة مرة أخرى.';

  @override
  String get failedToSaveAddress => 'فشل حفظ العنوان. يرجى المحاولة مرة أخرى.';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';
}
