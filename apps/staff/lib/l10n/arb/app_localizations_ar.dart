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
  String amountEgp(int amount) {
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
  String sessionStarted(String time, int price) {
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
}
