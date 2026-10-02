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
/// import 'arb/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// App name, shown in the window title
  ///
  /// In en, this message translates to:
  /// **'Al3b'**
  String get appTitle;

  /// Title of the main screen showing all units (PlayStation, ping pong, billiards)
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get homeTitle;

  /// Unit state: nothing running
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get unitFree;

  /// Unit state: session ended, bill not paid yet
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment'**
  String get unitWaitingPayment;

  /// Unit state: out of use
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get unitMaintenance;

  /// Hint on a free unit
  ///
  /// In en, this message translates to:
  /// **'Tap to start'**
  String get unitTapToStart;

  /// Play mode: one player / normal price
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get modeSingle;

  /// Play mode: several players / multi price
  ///
  /// In en, this message translates to:
  /// **'Multi'**
  String get modeMulti;

  /// Money amount in Egyptian pounds
  ///
  /// In en, this message translates to:
  /// **'{amount} EGP'**
  String amountEgp(int amount);

  /// Upcoming booking on a unit; time is like "9 at night" (see friendlyTime)
  ///
  /// In en, this message translates to:
  /// **'Booked {time}'**
  String reservedAt(String time);

  /// Booking starting soon on a running unit
  ///
  /// In en, this message translates to:
  /// **'Booked in {minutes} minutes'**
  String reservedInMinutes(int minutes);

  /// Friendly time of day, e.g. 9 at night. Hours 5-11
  ///
  /// In en, this message translates to:
  /// **'{hour} in the morning'**
  String timeMorning(String hour);

  /// Friendly time of day, e.g. 9 at night. Hours 12-15
  ///
  /// In en, this message translates to:
  /// **'{hour} at noon'**
  String timeNoon(String hour);

  /// Friendly time of day, e.g. 9 at night. Hours 16-17
  ///
  /// In en, this message translates to:
  /// **'{hour} in the afternoon'**
  String timeAfternoon(String hour);

  /// Friendly time of day, e.g. 9 at night. Hours 18-4
  ///
  /// In en, this message translates to:
  /// **'{hour} at night'**
  String timeNight(String hour);

  /// Floor screen toggle: sections by room/group
  ///
  /// In en, this message translates to:
  /// **'By place'**
  String get viewByPlace;

  /// Floor screen toggle: sections by unit type
  ///
  /// In en, this message translates to:
  /// **'By type'**
  String get viewByType;

  /// Unit type name
  ///
  /// In en, this message translates to:
  /// **'PlayStation'**
  String get typePlayStation;

  /// Unit type name
  ///
  /// In en, this message translates to:
  /// **'Ping pong'**
  String get typePingPong;

  /// Unit type name
  ///
  /// In en, this message translates to:
  /// **'Billiards'**
  String get typeBilliards;

  /// Section of private rooms (one unit each) of one type, e.g. Private PlayStation rooms
  ///
  /// In en, this message translates to:
  /// **'Private {type} rooms'**
  String privateRoomsOf(String type);

  /// Heading in the by-type view: units in shared halls
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get blockShared;

  /// Heading in the by-type view: units in private rooms
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get blockPrivate;

  /// Summary under the venue name on the Floor screen
  ///
  /// In en, this message translates to:
  /// **'Running {running} · Free {free}'**
  String floorSummary(int running, int free);

  /// Side nav: sell drinks/snacks without a session
  ///
  /// In en, this message translates to:
  /// **'Quick sale'**
  String get navQuickSale;

  /// Side nav: bookings
  ///
  /// In en, this message translates to:
  /// **'Reservations'**
  String get navReservations;

  /// Side nav: the cash drawer (open/close, hand over, expenses)
  ///
  /// In en, this message translates to:
  /// **'Cash box'**
  String get navShift;

  /// Button at the bottom of the side nav: change who is working
  ///
  /// In en, this message translates to:
  /// **'Switch staff'**
  String get switchStaff;

  /// Session panel: start time (friendly) and current hourly price
  ///
  /// In en, this message translates to:
  /// **'Started {time} · {price} EGP/hour'**
  String sessionStarted(String time, int price);

  /// Session panel line: cost of time played
  ///
  /// In en, this message translates to:
  /// **'Play time'**
  String get playTime;

  /// Session panel: no drinks/snacks ordered in this session
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// Session panel: total so far
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Session panel button: add drinks/snacks
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get addOrder;

  /// Session panel button: move the session to another unit
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get moveUnit;

  /// Session panel button: switch to multi price
  ///
  /// In en, this message translates to:
  /// **'Make multi'**
  String get switchToMulti;

  /// Session panel button: switch to single price
  ///
  /// In en, this message translates to:
  /// **'Make single'**
  String get switchToSingle;

  /// Session panel main button: end the session and go to checkout
  ///
  /// In en, this message translates to:
  /// **'End & pay'**
  String get endAndPay;

  /// Side nav: management screens (staff, units & prices, products, reports, settings). Owners/managers only
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get navManage;

  /// Header warning, shown only when the device is offline
  ///
  /// In en, this message translates to:
  /// **'No internet · everything is saved on this device'**
  String get statusOffline;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
