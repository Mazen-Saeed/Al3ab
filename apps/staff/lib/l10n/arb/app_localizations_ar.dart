// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'ألعب';

  @override
  String get homeTitle => 'الصالة';

  @override
  String get unitFree => 'فاضي';

  @override
  String get unitWaitingPayment => 'لسة متدفعش';

  @override
  String get unitMaintenance => 'صيانة';

  @override
  String get unitTapToStart => 'دوس عشان نبدأ';

  @override
  String get modeSingle => 'فردي';

  @override
  String get modeMulti => 'زوجي';

  @override
  String amountEgp(String amount) {
    return '$amount جنيه';
  }

  @override
  String reservedAt(String time) {
    return 'حجز $time';
  }

  @override
  String reservedInMinutes(int minutes) {
    return 'حجز بعد $minutes دقيقة';
  }

  @override
  String timeMorning(String hour) {
    return '$hour الصبح';
  }

  @override
  String timeNoon(String hour) {
    return '$hour الظهر';
  }

  @override
  String timeAfternoon(String hour) {
    return '$hour العصر';
  }

  @override
  String timeNight(String hour) {
    return '$hour بليل';
  }

  @override
  String get viewByPlace => 'حسب المكان';

  @override
  String get viewByType => 'حسب النوع';

  @override
  String get typePlayStation => 'بلايستيشن';

  @override
  String get typePingPong => 'بينج بونج';

  @override
  String get typeBilliards => 'بلياردو';

  @override
  String get typePc => 'كمبيوتر';

  @override
  String privateRoomsOf(String type) {
    return 'غرف ال$type المميزة';
  }

  @override
  String get blockShared => 'مشتركة';

  @override
  String get blockPrivate => 'مميزة';

  @override
  String floorSummary(int running, int free) {
    return 'شغال $running · فاضي $free';
  }

  @override
  String get navQuickSale => 'بيع سريع';

  @override
  String get navReservations => 'الحجوزات';

  @override
  String get navShift => 'الخزينة';

  @override
  String get switchStaff => 'تبديل الموظف';

  @override
  String sessionStarted(String time, String price) {
    return 'بدأ $time · $price جنيه في الساعة';
  }

  @override
  String get playTime => 'وقت اللعب';

  @override
  String get noOrdersYet => 'مفيش طلبات لسة';

  @override
  String get total => 'الإجمالي';

  @override
  String get addOrder => 'طلب';

  @override
  String get moveUnit => 'نقل';

  @override
  String get switchToMulti => 'حوّل زوجي';

  @override
  String get switchToSingle => 'حوّل فردي';

  @override
  String get endAndPay => 'إنهاء ودفع';

  @override
  String get navManage => 'الإدارة';

  @override
  String get statusOffline => 'مفيش نت · كل حاجة محفوظة على الجهاز';

  @override
  String get startSessionTitle => 'بدء جلسة';

  @override
  String get playType => 'نوع اللعب';

  @override
  String pricePerHour(String price) {
    return '$price جنيه في الساعة';
  }

  @override
  String get customerOptional => 'العميل (اختياري)';

  @override
  String get customerHint => 'الاسم أو رقم الموبايل';

  @override
  String get startTimer => 'ابدأ الوقت';

  @override
  String reservedWarning(String time) {
    return 'الجهاز ده محجوز $time';
  }

  @override
  String get durationLabel => 'المدة';

  @override
  String get durationOpen => 'مفتوح';

  @override
  String get duration30 => 'نص ساعة';

  @override
  String get duration60 => 'ساعة';

  @override
  String get duration120 => 'ساعتين';

  @override
  String get durationCustom => 'مدة تانية';

  @override
  String get customHoursHint => 'عدد الساعات (مثلا 2.25)';

  @override
  String get duration15 => 'ربع ساعة';

  @override
  String get customHoursNote => '2.25 يعني ساعتين وربع';

  @override
  String get timeLeft => 'باقي';

  @override
  String get timeOver => 'زيادة';

  @override
  String alertTenMinutes(String unit) {
    return 'باقي 10 دقايق على $unit';
  }

  @override
  String alertOneMinute(String unit) {
    return 'باقي دقيقة على $unit';
  }

  @override
  String alertTimeUp(String unit) {
    return 'وقت $unit خلص';
  }

  @override
  String get addTime => 'زوّد وقت';

  @override
  String get addTimeConfirm => 'زوّد';

  @override
  String get makeOpenConfirm => 'حوّل لمفتوح';

  @override
  String get setTime => 'حدّد وقت';

  @override
  String get setTimeConfirm => 'حدّد';

  @override
  String get fromNowNote => 'المدة بتتحسب من دلوقتي';

  @override
  String get addToBill => 'ضيف للحساب';

  @override
  String get ordersTitle => 'الطلبات';

  @override
  String orderLine(String name, int quantity, String price) {
    return '$name · $quantity × $price';
  }

  @override
  String get removeItem => 'شيل';

  @override
  String get checkoutTitle => 'الحساب';

  @override
  String get billSubtotal => 'المجموع';

  @override
  String get discountLabel => 'خصم';

  @override
  String get discountReasonHint => 'سبب الخصم';

  @override
  String get paymentMethodLabel => 'طريقة الدفع';

  @override
  String get payCash => 'كاش';

  @override
  String get payInstapay => 'إنستاباي';

  @override
  String get payWallet => 'محفظة';

  @override
  String get amountDue => 'المطلوب';

  @override
  String get confirmPayment => 'تأكيد الدفع';

  @override
  String get maintenanceButton => 'حطه في صيانة';

  @override
  String get maintenanceNoteLabel => 'سبب الصيانة (اختياري)';

  @override
  String get maintenanceNoteHint => 'مثلاً: الدراع بايظ';

  @override
  String get backToWork => 'رجّعه شغال';

  @override
  String get payManuallyHint => 'لو الكود مش شغال حوّل على';

  @override
  String get hoursOne => 'ساعة';

  @override
  String get hoursTwo => 'ساعتين';

  @override
  String hoursFew(int count) {
    return '$count ساعات';
  }

  @override
  String hoursMany(int count) {
    return '$count ساعة';
  }

  @override
  String get minutesOne => 'دقيقة';

  @override
  String get minutesTwo => 'دقيقتين';

  @override
  String minutesFew(int count) {
    return '$count دقايق';
  }

  @override
  String minutesMany(int count) {
    return '$count دقيقة';
  }

  @override
  String hoursAndMinutes(String hours, String minutes) {
    return '$hours و$minutes';
  }

  @override
  String get lessThanMinute => 'أقل من دقيقة';

  @override
  String get productsTitle => 'المنيو والمخزون';

  @override
  String get newProduct => 'منتج للمنيو';

  @override
  String get productNameLabel => 'اسم المنتج';

  @override
  String get productPriceLabel => 'السعر بالجنيه';

  @override
  String get saveProduct => 'حفظ';

  @override
  String get deleteProduct => 'امسح المنتج';

  @override
  String get stockTitle => 'المخزون';

  @override
  String stockLeft(int count) {
    return 'باقي $count';
  }

  @override
  String stockShort(int count) {
    return 'ناقص $count';
  }

  @override
  String get stockLow => 'قرب يخلص';

  @override
  String get stockKindAuto => 'بيتخصم مع كل بيعة';

  @override
  String get stockKindManual => 'بيتسجّل بإيدك';

  @override
  String get stockLowLabel => 'نبّهني لما يقل عن (اختياري)';

  @override
  String get stockCurrentLabel => 'الموجود دلوقتي (اختياري)';

  @override
  String get stockBought => 'اشتريت';

  @override
  String get stockOpened => 'فتحت علبة';

  @override
  String get stockCount => 'تعديل الرقم';

  @override
  String get stockRecord => 'سجّل';

  @override
  String get menuTitle => 'المنيو';

  @override
  String get menuSubtitle => 'اللي بتبيعه للزبون';

  @override
  String get stockSubtitle => 'اللي عندك في المحل، حتى السكر والأكواب';

  @override
  String get addToStock => 'صنف جديد';

  @override
  String get stockPickProduct => 'أنهي منتج؟';

  @override
  String get stockKindLabel => 'بيتحسب إزاي؟';

  @override
  String get stockKindAutoHint =>
      'زي البيبسي والشيبسي: كل ما تبيع واحد بينقص لوحده';

  @override
  String get stockKindManualHint =>
      'زي الشاي والقهوة: إنت اللي بتسجّل لما تشتري أو تفتح علبة';

  @override
  String get stockEdit => 'إعدادات الصنف';

  @override
  String get saveStockItem => 'حفظ';

  @override
  String get removeFromStock => 'شيله من المخزون';

  @override
  String get stockCountedLabel => 'عدّيت كام في المحل؟';

  @override
  String get stockCountHint => 'عدّ اللي في المحل واكتب العدد الصح';

  @override
  String stockDiffShort(int count) {
    return 'ناقص $count عن البرنامج';
  }

  @override
  String stockDiffExtra(int count) {
    return 'زيادة $count عن البرنامج';
  }

  @override
  String get stockDiffNone => 'زي بعض';

  @override
  String get stockNoteLabel => 'السبب (اختياري)';

  @override
  String get stockNoteHint => 'مثلاً: وقع واتكسر';

  @override
  String get purchaseTitle => 'اشتريت إيه؟';

  @override
  String get purchaseTotalLabel => 'الإجمالي';

  @override
  String get purchasePaidHint => 'دفعت كام (إجمالي الصنف ده)';

  @override
  String get purchaseConfirm => 'سجّل الشراء';

  @override
  String get stockNewWhat => 'هتضيف إيه؟';

  @override
  String get stockNewProduct => 'منتج من المنيو';

  @override
  String get stockNewInternal => 'مستلزمات للمحل (حاجة مش بتتباع)';

  @override
  String get stockInternalName => 'اسم الحاجة';

  @override
  String get stockInternalHint => 'زي السكر واللبن ';

  @override
  String get placesTitle => 'الرومز والأجهزة';

  @override
  String get newPlace => 'روم جديد';

  @override
  String get newDevice => 'جهاز جديد';

  @override
  String get editDevice => 'تعديل الجهاز';

  @override
  String get placeNameLabel => 'اسم الروم';

  @override
  String get placeNameHint => 'مثلا: صالة 1، VIP 1';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get deviceNameLabel => 'اسم الجهاز';

  @override
  String get deviceNameHint => 'مثلا: PS5-1';

  @override
  String get deviceTypeLabel => 'النوع';

  @override
  String get singlePriceLabel => 'سعر الساعة فردي بالجنيه';

  @override
  String get multiPriceLabel => 'سعر الساعة زوجي بالجنيه (اختياري)';

  @override
  String get save => 'حفظ';

  @override
  String get deleteDevice => 'امسح الجهاز';

  @override
  String get deviceBusyHint => 'الجهاز شغال دلوقتي، فتقدر تغيّر الاسم بس.';

  @override
  String get pricesTitle => 'الأسعار';

  @override
  String get newPriceCategory => 'سعر جديد';

  @override
  String get priceNameLabel => 'اسم السعر';

  @override
  String get priceNameHint => 'مثلا: PS5 عادي، VIP';

  @override
  String get priceCategoryLabel => 'السعر';

  @override
  String get noPriceCategoryHint => 'ضيف سعر الأول من الإدارة > الأسعار';

  @override
  String get deletePriceCategory => 'امسح السعر';

  @override
  String get priceCategoryInUse => 'السعر ده مستخدم في أجهزة، فمينفعش يتمسح.';

  @override
  String get quickSaleSell => 'بيع';

  @override
  String get quickSaleDone => 'تم البيع';

  @override
  String get moveSessionHint =>
      'الوقت اللي فات بيتحاسب بسعر الجهاز ده، والباقي بسعر الجهاز الجديد.';

  @override
  String get moveNoFreeUnits => 'مفيش أجهزة فاضية دلوقتي';

  @override
  String get stopClock => 'وقّف الوقت';

  @override
  String get resumeClock => 'كمّل الوقت';

  @override
  String get clockStopped => 'الوقت واقف · مستني الدفع';

  @override
  String get stopAll => 'وقف كله';

  @override
  String get resumeAll => 'كمل كله';
}
