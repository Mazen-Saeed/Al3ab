// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Al3b';

  @override
  String get homeTitle => 'Floor';

  @override
  String get unitFree => 'Free';

  @override
  String get unitWaitingPayment => 'Waiting for payment';

  @override
  String get unitMaintenance => 'Maintenance';

  @override
  String get unitTapToStart => 'Tap to start';

  @override
  String get modeSingle => 'Single';

  @override
  String get modeMulti => 'Multi';

  @override
  String amountEgp(int amount) {
    return '$amount EGP';
  }

  @override
  String reservedAt(String time) {
    return 'Booked $time';
  }

  @override
  String reservedInMinutes(int minutes) {
    return 'Booked in $minutes minutes';
  }

  @override
  String timeMorning(String hour) {
    return '$hour in the morning';
  }

  @override
  String timeNoon(String hour) {
    return '$hour at noon';
  }

  @override
  String timeAfternoon(String hour) {
    return '$hour in the afternoon';
  }

  @override
  String timeNight(String hour) {
    return '$hour at night';
  }

  @override
  String get viewByPlace => 'By place';

  @override
  String get viewByType => 'By type';

  @override
  String get typePlayStation => 'PlayStation';

  @override
  String get typePingPong => 'Ping pong';

  @override
  String get typeBilliards => 'Billiards';

  @override
  String privateRoomsOf(String type) {
    return 'Private $type rooms';
  }

  @override
  String get blockShared => 'Shared';

  @override
  String get blockPrivate => 'Private';

  @override
  String floorSummary(int running, int free) {
    return 'Running $running · Free $free';
  }

  @override
  String get navQuickSale => 'Quick sale';

  @override
  String get navReservations => 'Reservations';

  @override
  String get navShift => 'Cash box';

  @override
  String get switchStaff => 'Switch staff';

  @override
  String sessionStarted(String time, int price) {
    return 'Started $time · $price EGP/hour';
  }

  @override
  String get playTime => 'Play time';

  @override
  String get noOrdersYet => 'No orders yet';

  @override
  String get total => 'Total';

  @override
  String get addOrder => 'Order';

  @override
  String get moveUnit => 'Move';

  @override
  String get switchToMulti => 'Make multi';

  @override
  String get switchToSingle => 'Make single';

  @override
  String get endAndPay => 'End & pay';

  @override
  String get navManage => 'Manage';

  @override
  String get statusOffline =>
      'No internet · everything is saved on this device';

  @override
  String get startSessionTitle => 'Start session';

  @override
  String get playType => 'Play type';

  @override
  String pricePerHour(int price) {
    return '$price EGP per hour';
  }

  @override
  String get customerOptional => 'Customer (optional)';

  @override
  String get customerHint => 'Name or phone number';

  @override
  String get startTimer => 'Start timer';

  @override
  String reservedWarning(String time) {
    return 'This unit is booked $time';
  }

  @override
  String get durationLabel => 'Duration';

  @override
  String get durationOpen => 'Open';

  @override
  String get duration30 => '30 min';

  @override
  String get duration60 => '1 hour';

  @override
  String get duration120 => '2 hours';

  @override
  String get durationCustom => 'Other';

  @override
  String get customHoursHint => 'Number of hours, e.g. 2.5';

  @override
  String get timeLeft => 'Left';

  @override
  String get timeOver => 'Over';

  @override
  String alertTenMinutes(String unit) {
    return '10 minutes left on $unit';
  }

  @override
  String alertOneMinute(String unit) {
    return '1 minute left on $unit';
  }

  @override
  String alertTimeUp(String unit) {
    return '$unit: time is up';
  }

  @override
  String get addTime => 'Add time';

  @override
  String get addTimeConfirm => 'Add';

  @override
  String get makeOpenConfirm => 'Make it open';
}
