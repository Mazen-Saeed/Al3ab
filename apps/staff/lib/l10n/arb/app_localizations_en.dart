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
  String amountEgp(String amount) {
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
  String get typePc => 'PC';

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
  String get navReservations => 'Bookings';

  @override
  String get navShift => 'Cash box';

  @override
  String get switchStaff => 'Switch staff';

  @override
  String sessionStarted(String time, String price) {
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
  String pricePerHour(String price) {
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
  String get customHoursHint => 'Number of hours, e.g. 2.25';

  @override
  String get duration15 => '15 min';

  @override
  String get customHoursNote => '2.25 means two hours and a quarter';

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

  @override
  String get setTime => 'Set a time limit';

  @override
  String get setTimeConfirm => 'Set';

  @override
  String get fromNowNote => 'The time is counted from now';

  @override
  String get addToBill => 'Add to bill';

  @override
  String get ordersTitle => 'Orders';

  @override
  String orderLine(String name, int quantity, String price) {
    return '$name · $quantity × $price';
  }

  @override
  String get removeItem => 'Remove';

  @override
  String get checkoutTitle => 'Bill';

  @override
  String get billSubtotal => 'Total';

  @override
  String get discountLabel => 'Discount';

  @override
  String get discountReasonHint => 'Reason for the discount';

  @override
  String get paymentMethodLabel => 'Payment method';

  @override
  String get payCash => 'Cash';

  @override
  String get payInstapay => 'InstaPay';

  @override
  String get payWallet => 'Wallet';

  @override
  String get amountDue => 'To pay';

  @override
  String get confirmPayment => 'Confirm payment';

  @override
  String get maintenanceButton => 'Put in maintenance';

  @override
  String get maintenanceNoteLabel => 'Reason (optional)';

  @override
  String get maintenanceNoteHint => 'e.g. broken controller';

  @override
  String get backToWork => 'Back to work';

  @override
  String get payManuallyHint => 'If the code does not work, transfer to';

  @override
  String get hoursOne => 'hour';

  @override
  String get hoursTwo => '2 hours';

  @override
  String hoursFew(int count) {
    return '$count hours';
  }

  @override
  String hoursMany(int count) {
    return '$count hours';
  }

  @override
  String get minutesOne => 'minute';

  @override
  String get minutesTwo => '2 minutes';

  @override
  String minutesFew(int count) {
    return '$count minutes';
  }

  @override
  String minutesMany(int count) {
    return '$count minutes';
  }

  @override
  String hoursAndMinutes(String hours, String minutes) {
    return '$hours and $minutes';
  }

  @override
  String get lessThanMinute => 'Less than a minute';

  @override
  String get productsTitle => 'Menu and stock';

  @override
  String get newProduct => 'New menu item';

  @override
  String get productNameLabel => 'Product name';

  @override
  String get productPriceLabel => 'Price in EGP';

  @override
  String get saveProduct => 'Save';

  @override
  String get deleteProduct => 'Delete product';

  @override
  String get stockTitle => 'Stock';

  @override
  String stockLeft(int count) {
    return '$count left';
  }

  @override
  String stockShort(int count) {
    return 'Short by $count';
  }

  @override
  String get stockLow => 'Running low';

  @override
  String get stockKindAuto => 'Subtracts on every sale';

  @override
  String get stockKindManual => 'You record it by hand';

  @override
  String get stockLowLabel => 'Warn me below (optional)';

  @override
  String get stockCurrentLabel => 'On the shelf now (optional)';

  @override
  String get stockBought => 'Bought';

  @override
  String get stockOpened => 'Opened one';

  @override
  String get stockCount => 'Edit number';

  @override
  String get stockRecord => 'Record';

  @override
  String get menuTitle => 'Menu';

  @override
  String get menuSubtitle => 'What you sell to customers';

  @override
  String get stockSubtitle => 'What you have in the shop, even sugar and cups';

  @override
  String get addToStock => 'New item';

  @override
  String get stockPickProduct => 'Which product?';

  @override
  String get stockKindLabel => 'How is it counted?';

  @override
  String get stockKindAutoHint =>
      'Like Pepsi or chips: every sale takes one off by itself';

  @override
  String get stockKindManualHint =>
      'Like tea or coffee: you record it when you buy or open a tin';

  @override
  String get stockEdit => 'Item settings';

  @override
  String get saveStockItem => 'Save';

  @override
  String get removeFromStock => 'Remove from stock';

  @override
  String get stockCountedLabel => 'How many are in the shop?';

  @override
  String get stockCountHint =>
      'Count what is in the shop and type the real number';

  @override
  String stockDiffShort(int count) {
    return '$count fewer than the app says';
  }

  @override
  String stockDiffExtra(int count) {
    return '$count more than the app says';
  }

  @override
  String get stockDiffNone => 'Same as the app';

  @override
  String get stockNoteLabel => 'Reason (optional)';

  @override
  String get stockNoteHint => 'e.g. one fell and broke';

  @override
  String get purchaseTitle => 'What did you buy?';

  @override
  String get purchaseTotalLabel => 'Total';

  @override
  String get purchasePaidHint => 'Paid (total for this item, EGP)';

  @override
  String get purchaseConfirm => 'Save purchase';

  @override
  String get stockNewWhat => 'What are you adding?';

  @override
  String get stockNewProduct => 'A menu product';

  @override
  String get stockNewInternal => 'Shop supplies (not sold)';

  @override
  String get stockInternalName => 'Name';

  @override
  String get stockInternalHint => 'Like sugar, milk and cups';

  @override
  String get placesTitle => 'Rooms and devices';

  @override
  String get newPlace => 'New room';

  @override
  String get newDevice => 'New device';

  @override
  String get editDevice => 'Edit device';

  @override
  String get placeNameLabel => 'Room name';

  @override
  String get placeNameHint => 'For example Hall 1, VIP 1';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageLabel => 'Language';

  @override
  String get deviceNameLabel => 'Device name';

  @override
  String get deviceNameHint => 'For example PS5-1';

  @override
  String get deviceTypeLabel => 'Type';

  @override
  String get singlePriceLabel => 'Price per hour, single (EGP)';

  @override
  String get multiPriceLabel => 'Price per hour, pair (EGP, optional)';

  @override
  String get save => 'Save';

  @override
  String get deleteDevice => 'Delete device';

  @override
  String get deviceBusyHint =>
      'This device has a session now, so only the name can change.';

  @override
  String get pricesTitle => 'Prices';

  @override
  String get newPriceCategory => 'New price';

  @override
  String get priceNameLabel => 'Price name';

  @override
  String get priceNameHint => 'For example PS5 regular, VIP';

  @override
  String get priceCategoryLabel => 'Price';

  @override
  String get noPriceCategoryHint => 'Add a price first in Manage > Prices';

  @override
  String get deletePriceCategory => 'Delete price';

  @override
  String get priceCategoryInUse =>
      'This price is used by devices, so it cannot be deleted.';

  @override
  String get quickSaleSell => 'Sell';

  @override
  String get quickSaleDone => 'Sold';

  @override
  String get moveSessionHint =>
      'The time so far is charged at this unit price, the rest at the new unit price.';

  @override
  String get moveNoFreeUnits => 'No free units right now';

  @override
  String get stopClock => 'Stop the clock';

  @override
  String get resumeClock => 'Resume';

  @override
  String get clockStopped => 'Clock stopped · waiting for payment';

  @override
  String get stopAll => 'Stop all';

  @override
  String get resumeAll => 'Resume all';
}
