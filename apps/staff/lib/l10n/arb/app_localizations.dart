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

  /// Money amount in Egyptian pounds, already formatted (see formatMoney)
  ///
  /// In en, this message translates to:
  /// **'{amount} EGP'**
  String amountEgp(String amount);

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

  /// Unit type name: a gaming PC
  ///
  /// In en, this message translates to:
  /// **'PC'**
  String get typePc;

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
  /// **'Bookings'**
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
  String sessionStarted(String time, String price);

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

  /// Small title above the unit name in the start-session form
  ///
  /// In en, this message translates to:
  /// **'Start session'**
  String get startSessionTitle;

  /// Label above the single/multi choice
  ///
  /// In en, this message translates to:
  /// **'Play type'**
  String get playType;

  /// Price shown under a single/multi option
  ///
  /// In en, this message translates to:
  /// **'{price} EGP per hour'**
  String pricePerHour(String price);

  /// Label of the customer field in the start-session form
  ///
  /// In en, this message translates to:
  /// **'Customer (optional)'**
  String get customerOptional;

  /// Placeholder inside the customer field
  ///
  /// In en, this message translates to:
  /// **'Name or phone number'**
  String get customerHint;

  /// Main button of the start-session form
  ///
  /// In en, this message translates to:
  /// **'Start timer'**
  String get startTimer;

  /// Warning in the start-session form when the unit has an upcoming booking; time is like "9 at night" (see friendlyTime)
  ///
  /// In en, this message translates to:
  /// **'This unit is booked {time}'**
  String reservedWarning(String time);

  /// Label above the planned-time choices in the start form
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// Duration choice: no planned time, timer counts up
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get durationOpen;

  /// Duration choice
  ///
  /// In en, this message translates to:
  /// **'30 min'**
  String get duration30;

  /// Duration choice
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get duration60;

  /// Duration choice
  ///
  /// In en, this message translates to:
  /// **'2 hours'**
  String get duration120;

  /// Duration choice that opens a minutes field
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get durationCustom;

  /// Placeholder of the custom duration field; decimals allowed (2.25 = two hours and a quarter)
  ///
  /// In en, this message translates to:
  /// **'Number of hours, e.g. 2.25'**
  String get customHoursHint;

  /// Duration choice
  ///
  /// In en, this message translates to:
  /// **'15 min'**
  String get duration15;

  /// Small note under the custom duration field: how to read the decimals
  ///
  /// In en, this message translates to:
  /// **'2.25 means two hours and a quarter'**
  String get customHoursNote;

  /// Small label next to a countdown timer: time left of the planned time
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get timeLeft;

  /// Small label next to a timer that passed the planned time and keeps counting
  ///
  /// In en, this message translates to:
  /// **'Over'**
  String get timeOver;

  /// Alert banner: 10 minutes before a planned session ends
  ///
  /// In en, this message translates to:
  /// **'10 minutes left on {unit}'**
  String alertTenMinutes(String unit);

  /// Alert banner: 1 minute before a planned session ends
  ///
  /// In en, this message translates to:
  /// **'1 minute left on {unit}'**
  String alertOneMinute(String unit);

  /// Alert banner: the planned time ran out
  ///
  /// In en, this message translates to:
  /// **'{unit}: time is up'**
  String alertTimeUp(String unit);

  /// Button in the running-session panel (planned sessions) and title of the add-time form
  ///
  /// In en, this message translates to:
  /// **'Add time'**
  String get addTime;

  /// Main button of the add-time form
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addTimeConfirm;

  /// Button in the panel of a fixed-time session: turn it into open time (removes the planned time)
  ///
  /// In en, this message translates to:
  /// **'Make it open'**
  String get makeOpenConfirm;

  /// Button in the panel of an open session and title of its form: turn it into a fixed time
  ///
  /// In en, this message translates to:
  /// **'Set a time limit'**
  String get setTime;

  /// Main button of the form that gives an open session a time limit
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get setTimeConfirm;

  /// Small note in the set-a-time-limit form
  ///
  /// In en, this message translates to:
  /// **'The time is counted from now'**
  String get fromNowNote;

  /// Main button of the order form: puts the chosen products on the session's bill
  ///
  /// In en, this message translates to:
  /// **'Add to bill'**
  String get addToBill;

  /// Heading of the ordered products on a session's bill, next to their sum
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTitle;

  /// One ordered product on the bill, e.g. Pepsi · 2 × 15
  ///
  /// In en, this message translates to:
  /// **'{name} · {quantity} × {price}'**
  String orderLine(String name, int quantity, String price);

  /// Tooltip of the small button that takes an order line off the bill
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeItem;

  /// Title of the checkout form (the bill)
  ///
  /// In en, this message translates to:
  /// **'Bill'**
  String get checkoutTitle;

  /// Bill sum before the discount
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get billSubtotal;

  /// Label of the discount field (amount in EGP)
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discountLabel;

  /// Hint of the field where staff write why a discount was given
  ///
  /// In en, this message translates to:
  /// **'Reason for the discount'**
  String get discountReasonHint;

  /// Label above the payment method choices
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethodLabel;

  /// Payment method: cash
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get payCash;

  /// Payment method: InstaPay
  ///
  /// In en, this message translates to:
  /// **'InstaPay'**
  String get payInstapay;

  /// Payment method: mobile wallet
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get payWallet;

  /// Amount the customer has to pay, big number at the bottom of checkout
  ///
  /// In en, this message translates to:
  /// **'To pay'**
  String get amountDue;

  /// Main button of checkout: saves the bill and frees the unit
  ///
  /// In en, this message translates to:
  /// **'Confirm payment'**
  String get confirmPayment;

  /// Button that takes a free unit out of service; also the confirm button of the maintenance form
  ///
  /// In en, this message translates to:
  /// **'Put in maintenance'**
  String get maintenanceButton;

  /// Label of the optional reason field in the maintenance form
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get maintenanceNoteLabel;

  /// Example shown inside the maintenance reason field
  ///
  /// In en, this message translates to:
  /// **'e.g. broken controller'**
  String get maintenanceNoteHint;

  /// Button in the panel of a unit in maintenance: makes it free again
  ///
  /// In en, this message translates to:
  /// **'Back to work'**
  String get backToWork;

  /// Small line above the account number/handle under the payment QR code
  ///
  /// In en, this message translates to:
  /// **'If the code does not work, transfer to'**
  String get payManuallyHint;

  /// One hour (exactly)
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hoursOne;

  /// Two hours (Arabic dual)
  ///
  /// In en, this message translates to:
  /// **'2 hours'**
  String get hoursTwo;

  /// 3 to 10 hours
  ///
  /// In en, this message translates to:
  /// **'{count} hours'**
  String hoursFew(int count);

  /// 11 or more hours
  ///
  /// In en, this message translates to:
  /// **'{count} hours'**
  String hoursMany(int count);

  /// One minute (exactly)
  ///
  /// In en, this message translates to:
  /// **'minute'**
  String get minutesOne;

  /// Two minutes (Arabic dual)
  ///
  /// In en, this message translates to:
  /// **'2 minutes'**
  String get minutesTwo;

  /// 3 to 10 minutes
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String minutesFew(int count);

  /// 11 or more minutes
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String minutesMany(int count);

  /// Joins hours and minutes: 1 hour and 20 minutes
  ///
  /// In en, this message translates to:
  /// **'{hours} and {minutes}'**
  String hoursAndMinutes(String hours, String minutes);

  /// Time played when under one minute
  ///
  /// In en, this message translates to:
  /// **'Less than a minute'**
  String get lessThanMinute;

  /// Title of the Products page and the Manage entry for it
  ///
  /// In en, this message translates to:
  /// **'Menu and stock'**
  String get productsTitle;

  /// The card/heading for adding a product
  ///
  /// In en, this message translates to:
  /// **'New menu item'**
  String get newProduct;

  /// Label of the product name field
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get productNameLabel;

  /// Label of the product price field
  ///
  /// In en, this message translates to:
  /// **'Price in EGP'**
  String get productPriceLabel;

  /// Main button of the product form
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveProduct;

  /// Button in the edit-product form that removes the product
  ///
  /// In en, this message translates to:
  /// **'Delete product'**
  String get deleteProduct;

  /// Title of the Stock page and the Manage entry for it
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stockTitle;

  /// How many of a stock item are on the shelf
  ///
  /// In en, this message translates to:
  /// **'{count} left'**
  String stockLeft(int count);

  /// Shown when more was sold than the shelf count says (number on hand below 0)
  ///
  /// In en, this message translates to:
  /// **'Short by {count}'**
  String stockShort(int count);

  /// Warning under the number when a stock item is at or below its low-stock level
  ///
  /// In en, this message translates to:
  /// **'Running low'**
  String get stockLow;

  /// Stock item kind: each sale takes one off (cans, bags)
  ///
  /// In en, this message translates to:
  /// **'Subtracts on every sale'**
  String get stockKindAuto;

  /// Stock item kind: sales take nothing off, staff record bought/opened/counted (tea, coffee)
  ///
  /// In en, this message translates to:
  /// **'You record it by hand'**
  String get stockKindManual;

  /// Label of the low-stock level field
  ///
  /// In en, this message translates to:
  /// **'Warn me below (optional)'**
  String get stockLowLabel;

  /// Label of the starting count when adding a stock item
  ///
  /// In en, this message translates to:
  /// **'On the shelf now (optional)'**
  String get stockCurrentLabel;

  /// Action: more of the item arrived
  ///
  /// In en, this message translates to:
  /// **'Bought'**
  String get stockBought;

  /// Action: a tin/packet was opened for use (tea, coffee)
  ///
  /// In en, this message translates to:
  /// **'Opened one'**
  String get stockOpened;

  /// Action: staff counted the shelf
  ///
  /// In en, this message translates to:
  /// **'Edit number'**
  String get stockCount;

  /// Main button of the stock action form
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get stockRecord;

  /// Heading of the menu section (what customers buy) on the Menu and stock page
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuTitle;

  /// Grey line under the Menu heading
  ///
  /// In en, this message translates to:
  /// **'What you sell to customers'**
  String get menuSubtitle;

  /// Grey line under the Stock heading
  ///
  /// In en, this message translates to:
  /// **'What you have in the shop, even sugar and cups'**
  String get stockSubtitle;

  /// Card that starts counting a product in stock
  ///
  /// In en, this message translates to:
  /// **'New item'**
  String get addToStock;

  /// Label above the choice of which product to start counting
  ///
  /// In en, this message translates to:
  /// **'Which product?'**
  String get stockPickProduct;

  /// Label above the two choices for how a stock item is counted
  ///
  /// In en, this message translates to:
  /// **'How is it counted?'**
  String get stockKindLabel;

  /// Explains the subtracts-on-every-sale choice
  ///
  /// In en, this message translates to:
  /// **'Like Pepsi or chips: every sale takes one off by itself'**
  String get stockKindAutoHint;

  /// Explains the record-by-hand choice
  ///
  /// In en, this message translates to:
  /// **'Like tea or coffee: you record it when you buy or open a tin'**
  String get stockKindManualHint;

  /// Link in the stock action form that opens the edit form
  ///
  /// In en, this message translates to:
  /// **'Item settings'**
  String get stockEdit;

  /// Main button of the stock item form
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveStockItem;

  /// Button in the edit form that stops counting a product
  ///
  /// In en, this message translates to:
  /// **'Remove from stock'**
  String get removeFromStock;

  /// Label of the number field when staff fix the count
  ///
  /// In en, this message translates to:
  /// **'How many are in the shop?'**
  String get stockCountedLabel;

  /// Hint under the count field
  ///
  /// In en, this message translates to:
  /// **'Count what is in the shop and type the real number'**
  String get stockCountHint;

  /// Shown while counting: the shelf has less than the app expected
  ///
  /// In en, this message translates to:
  /// **'{count} fewer than the app says'**
  String stockDiffShort(int count);

  /// Shown while counting: the shelf has more than the app expected
  ///
  /// In en, this message translates to:
  /// **'{count} more than the app says'**
  String stockDiffExtra(int count);

  /// Shown while counting: the shelf matches the app
  ///
  /// In en, this message translates to:
  /// **'Same as the app'**
  String get stockDiffNone;

  /// Label of the optional reason when fixing a count
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get stockNoteLabel;

  /// Hint inside the reason field
  ///
  /// In en, this message translates to:
  /// **'e.g. one fell and broke'**
  String get stockNoteHint;

  /// Heading of the shopping-trip form
  ///
  /// In en, this message translates to:
  /// **'What did you buy?'**
  String get purchaseTitle;

  /// Label of the worked-out total of the shopping trip
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get purchaseTotalLabel;

  /// Hint of the cost field under an item picked in the shopping-trip form
  ///
  /// In en, this message translates to:
  /// **'Paid (total for this item, EGP)'**
  String get purchasePaidHint;

  /// Main button of the shopping-trip form
  ///
  /// In en, this message translates to:
  /// **'Save purchase'**
  String get purchaseConfirm;

  /// Label above the choice between a menu product and an internal item
  ///
  /// In en, this message translates to:
  /// **'What are you adding?'**
  String get stockNewWhat;

  /// Choice: count a product that is sold
  ///
  /// In en, this message translates to:
  /// **'A menu product'**
  String get stockNewProduct;

  /// Choice: an item used but not sold (sugar, milk)
  ///
  /// In en, this message translates to:
  /// **'Shop supplies (not sold)'**
  String get stockNewInternal;

  /// Label of the name of an internal item
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get stockInternalName;

  /// Hint under the internal item name label
  ///
  /// In en, this message translates to:
  /// **'Like sugar, milk and cups'**
  String get stockInternalHint;

  /// Manage entry and title of the Places page
  ///
  /// In en, this message translates to:
  /// **'Rooms and devices'**
  String get placesTitle;

  /// Button and form title: add a room or hall
  ///
  /// In en, this message translates to:
  /// **'New room'**
  String get newPlace;

  /// Button and form title: add a unit to a room
  ///
  /// In en, this message translates to:
  /// **'New device'**
  String get newDevice;

  /// Form title: change a unit
  ///
  /// In en, this message translates to:
  /// **'Edit device'**
  String get editDevice;

  /// Label of the room name field
  ///
  /// In en, this message translates to:
  /// **'Room name'**
  String get placeNameLabel;

  /// Hint of the room name field
  ///
  /// In en, this message translates to:
  /// **'For example Hall 1, VIP 1'**
  String get placeNameHint;

  /// Manage entry and title of the Settings page
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Label above the language choices in Settings
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// Label of the unit name field
  ///
  /// In en, this message translates to:
  /// **'Device name'**
  String get deviceNameLabel;

  /// Hint of the unit name field
  ///
  /// In en, this message translates to:
  /// **'For example PS5-1'**
  String get deviceNameHint;

  /// Label above the unit type choices
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get deviceTypeLabel;

  /// Label of the single hourly price field
  ///
  /// In en, this message translates to:
  /// **'Price per hour, single (EGP)'**
  String get singlePriceLabel;

  /// Label of the optional multi hourly price field
  ///
  /// In en, this message translates to:
  /// **'Price per hour, pair (EGP, optional)'**
  String get multiPriceLabel;

  /// Main button of the Places forms
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Button that removes a unit
  ///
  /// In en, this message translates to:
  /// **'Delete device'**
  String get deleteDevice;

  /// Shown in the unit form while a session is running
  ///
  /// In en, this message translates to:
  /// **'This device has a session now, so only the name can change.'**
  String get deviceBusyHint;

  /// Manage entry and title of the Prices page
  ///
  /// In en, this message translates to:
  /// **'Prices'**
  String get pricesTitle;

  /// Button that adds a price category
  ///
  /// In en, this message translates to:
  /// **'New price'**
  String get newPriceCategory;

  /// Label of the name field in the price form
  ///
  /// In en, this message translates to:
  /// **'Price name'**
  String get priceNameLabel;

  /// Hint of the name field in the price form
  ///
  /// In en, this message translates to:
  /// **'For example PS5 regular, VIP'**
  String get priceNameHint;

  /// Label above the price choices in the device form
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceCategoryLabel;

  /// Shown in the device form when no price exists
  ///
  /// In en, this message translates to:
  /// **'Add a price first in Manage > Prices'**
  String get noPriceCategoryHint;

  /// Delete button of the price form
  ///
  /// In en, this message translates to:
  /// **'Delete price'**
  String get deletePriceCategory;

  /// Hint in the price form when devices use it
  ///
  /// In en, this message translates to:
  /// **'This price is used by devices, so it cannot be deleted.'**
  String get priceCategoryInUse;

  /// Button that completes a quick sale
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get quickSaleSell;

  /// Message after a quick sale
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get quickSaleDone;

  /// Hint in the move form
  ///
  /// In en, this message translates to:
  /// **'The time so far is charged at this unit price, the rest at the new unit price.'**
  String get moveSessionHint;

  /// Shown in the move form when nothing is free
  ///
  /// In en, this message translates to:
  /// **'No free units right now'**
  String get moveNoFreeUnits;

  /// Button that stops the clock of a session
  ///
  /// In en, this message translates to:
  /// **'Stop the clock'**
  String get stopClock;

  /// Button that restarts a stopped clock
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeClock;

  /// Shown on the timer card when the clock is stopped
  ///
  /// In en, this message translates to:
  /// **'Clock stopped · waiting for payment'**
  String get clockStopped;

  /// Floor header button that stops every running clock (power cut)
  ///
  /// In en, this message translates to:
  /// **'Stop all'**
  String get stopAll;

  /// Floor header button that restarts the clocks stopped by Stop all
  ///
  /// In en, this message translates to:
  /// **'Resume all'**
  String get resumeAll;
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
