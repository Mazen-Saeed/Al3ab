import 'package:al3b_staff/data/sample_data.dart';
import 'package:al3b_staff/data/unit.dart';
import 'package:al3b_staff/data/units_provider.dart';
import 'package:al3b_staff/l10n/arb/app_localizations_ar.dart';
import 'package:al3b_staff/l10n/arb/app_localizations_en.dart';
import 'package:al3b_staff/shell/pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'helpers.dart';

// These tests use pumpApp() / pump() instead of pumpAndSettle(): the clock never stops.
void main() {
  final l10n = AppLocalizationsAr();
  _checkoutTests();
  _maintenanceTests();
  _productsTests();
  _stockTests();
  _placesTests();
  _quickSaleTests();
  _resizeTests();

  testWidgets('Settings switches the language to English and back', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text(l10n.settingsTitle));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('English'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(AppLocalizationsEn().settingsTitle), findsOneWidget);

    await tester.tap(find.text('العربية'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(l10n.settingsTitle), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('start form: a 15 minute choice and the 2.25 note, then start', (tester) async {
    await pumpApp(tester);

    final tile = find.text('PS5-3'); // free
    await tester.ensureVisible(tile);
    await tester.tap(tile);
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(l10n.duration15), findsOneWidget);
    await tester.tap(find.text(l10n.durationCustom));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(l10n.customHoursNote), findsOneWidget); // "2.25 = two hours and a quarter"

    await tester.tap(find.text(l10n.duration15));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(l10n.customHoursNote), findsNothing); // "other" closed
    await tester.ensureVisible(find.text(l10n.startTimer));
    await tester.tap(find.text(l10n.startTimer));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(l10n.floorSummary(7, 3)), findsOneWidget); // PS5-3 is running now
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Floor screen shows the sample units', (tester) async {
    await pumpApp(tester);

    expect(find.text(sampleVenueName), findsOneWidget); // venue name in the top bar
    expect(find.text('PS5-1'), findsWidgets); // tile (+ panel on wide screens)
    expect(find.text('بلياردو 2'), findsOneWidget);

    await tester.pumpWidget(const SizedBox()); // unmount: stops the clock
  });

  testWidgets('tapping a free unit and pressing start makes it run', (tester) async {
    await pumpApp(tester);
    expect(find.text(l10n.floorSummary(6, 4)), findsOneWidget); // 6 running, 4 free

    final tile = find.text('بلياردو 2'); // free, and has no multi price
    await tester.ensureVisible(tile); // it may be below the fold in the test window
    await tester.tap(tile);
    await tester.pump(const Duration(milliseconds: 400)); // the form opens

    await tester.tap(find.text(l10n.startTimer));
    await tester.pump(const Duration(milliseconds: 400)); // the form closes

    expect(find.text(l10n.floorSummary(7, 3)), findsOneWidget); // now 7 running, 3 free

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('wide screen: the panel is hidden at first, opens for a running unit, closes with X', (tester) async {
    tester.view.physicalSize = const Size(1400, 900); // a wide window
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpApp(tester);
    expect(find.text(l10n.endAndPay), findsNothing); // nothing selected: no panel

    await tester.tap(find.text('PS5-1')); // a running unit
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(l10n.endAndPay), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(l10n.endAndPay), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('an open session gets a time limit, and a fixed one can become open again', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpApp(tester);
    final container = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
    Unit unitNow(String id) => container.read(unitsProvider).byId(id);

    // PS5-1 is running with no limit (open time): the panel offers to set one.
    expect(unitNow('ps5-1').plannedMinutes, isNull);
    await tester.tap(find.text('PS5-1'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(l10n.makeOpenConfirm), findsNothing); // it is already open
    await tester.tap(find.text(l10n.setTime));
    await _letAnimationFinish(tester);
    expect(find.text(l10n.durationOpen), findsNothing); // no "open" choice when setting a limit
    expect(find.text(l10n.fromNowNote), findsOneWidget);
    await tester.tap(find.text(l10n.duration60));
    await tester.tap(find.text(l10n.setTimeConfirm));
    await _letAnimationFinish(tester);
    expect(unitNow('ps5-1').plannedMinutes, isNotNull);
    expect(find.text(l10n.makeOpenConfirm), findsOneWidget); // now it can go back to open

    // And back: one tap turns it open again.
    await tester.tap(find.text(l10n.makeOpenConfirm));
    await tester.pump(const Duration(milliseconds: 100));
    expect(unitNow('ps5-1').plannedMinutes, isNull);
    expect(find.text(l10n.setTime), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  // Overflow errors are reported by Flutter as test exceptions, so just using the form at
  // each size and checking tester.takeException() is null catches layout problems.
  for (final (name, size) in [
    ('phone', const Size(360, 740)),
    ('medium', const Size(900, 700)),
    ('wide', const Size(1400, 900)),
  ]) {
    testWidgets('order form works at $name width', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpApp(tester);
      await tester.tap(find.text('PS5-1').first); // a running unit
      await _letAnimationFinish(tester); // the phone/medium panel slides up as a bottom sheet
      await tester.tap(find.text(l10n.addOrder));
      await _letAnimationFinish(tester);
      await tester.tap(find.text('بيبسي'));
      await tester.pump(const Duration(milliseconds: 100)); // redraw so the next tap sees quantity 1
      await tester.tap(find.text('بيبسي')); // two Pepsi
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.textContaining(l10n.addToBill));
      await _letAnimationFinish(tester);

      expect(find.text(l10n.orderLine('بيبسي', 2, '15')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

// Pay a running unit at each size: open its panel, checkout, pick InstaPay, confirm.
// Afterwards the unit is free: the Floor summary goes from 6 running / 4 free to 5 / 5.
void _checkoutTests() {
  final l10n = AppLocalizationsAr();
  for (final (name, size) in [
    ('phone', const Size(360, 740)),
    ('medium', const Size(900, 700)),
    ('wide', const Size(1400, 900)),
  ]) {
    testWidgets('checkout works at $name width', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpApp(tester);
      await tester.tap(find.text('PS5-1').first);
      await _letAnimationFinish(tester);
      await tester.tap(find.text(l10n.endAndPay));
      await _letAnimationFinish(tester);

      expect(find.byType(QrImageView), findsNothing); // cash: nothing to scan
      await tester.tap(find.text(l10n.payInstapay));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(QrImageView), findsOneWidget); // InstaPay: the QR shows
      await tester.tap(find.text(l10n.confirmPayment));
      await _letAnimationFinish(tester);

      expect(find.text(l10n.floorSummary(5, 5)), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

// Put a free unit in maintenance from its start form, then bring it back from its panel.
void _maintenanceTests() {
  final l10n = AppLocalizationsAr();
  for (final (name, size) in [
    ('phone', const Size(360, 740)),
    ('medium', const Size(900, 700)),
    ('wide', const Size(1400, 900)),
  ]) {
    testWidgets('maintenance round trip at $name width', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      Future<void> tapText(String text) async {
        await tester.ensureVisible(find.text(text)); // forms can be taller than a phone screen
        await tester.tap(find.text(text));
      }

      await pumpApp(tester);
      await tester.tap(find.text('PS5-3')); // a free unit: the start form opens
      await _letAnimationFinish(tester);
      await tapText(l10n.maintenanceButton); // -> the maintenance form
      await _letAnimationFinish(tester);
      await tapText(l10n.maintenanceButton); // confirm
      await _letAnimationFinish(tester);
      expect(find.text(l10n.floorSummary(6, 3)), findsOneWidget);

      await tester.tap(find.text('PS5-3')); // now in maintenance: its panel opens
      await _letAnimationFinish(tester);
      await tapText(l10n.backToWork);
      await _letAnimationFinish(tester);
      expect(find.text(l10n.floorSummary(6, 4)), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

// Manage -> Products -> add a product: it shows up in the grid. (Three sizes, like the others.)
void _productsTests() {
  final l10n = AppLocalizationsAr();
  for (final (name, size) in [
    ('phone', const Size(360, 740)),
    ('medium', const Size(900, 700)),
    ('wide', const Size(1400, 900)),
  ]) {
    testWidgets('adding a product at $name width', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpApp(tester);
      await tester.tap(find.byIcon(Icons.tune_rounded)); // the Manage tab (same icon on every layout)
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text(l10n.productsTitle));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text(l10n.newProduct));
      await _letAnimationFinish(tester);

      await tester.enterText(find.byType(TextField).at(0), 'كولا');
      await tester.enterText(find.byType(TextField).at(1), '12');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.ensureVisible(find.text(l10n.saveProduct));
      await tester.tap(find.text(l10n.saveProduct));
      await _letAnimationFinish(tester);

      expect(find.text('كولا'), findsOneWidget);
      expect(find.text(l10n.amountEgp('12')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a price with piasters at $name width', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpApp(tester);
      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text(l10n.productsTitle));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text(l10n.newProduct));
      await _letAnimationFinish(tester);

      await tester.enterText(find.byType(TextField).at(0), 'قهوة تركي');
      await tester.enterText(find.byType(TextField).at(1), '7,5'); // 7.50, a comma works too
      await tester.pump(const Duration(milliseconds: 100));
      await tester.ensureVisible(find.text(l10n.saveProduct));
      await tester.tap(find.text(l10n.saveProduct));
      await _letAnimationFinish(tester);

      expect(find.text('قهوة تركي'), findsOneWidget);
      expect(find.text(l10n.amountEgp('7.50')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

// Manage -> Places and devices: add a device, add a place, open a busy device. (Three sizes.)
void _placesTests() {
  final l10n = AppLocalizationsAr();
  for (final (name, size) in [
    ('phone', const Size(360, 740)),
    ('medium', const Size(900, 700)),
    ('shop PC, 1366x768 at 125%', const Size(1100, 540)),
    ('wide', const Size(1400, 900)),
  ]) {
    Future<void> openPlaces(WidgetTester tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpApp(tester);
      await tester.tap(find.byIcon(Icons.tune_rounded)); // the Manage tab
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text(l10n.placesTitle));
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('tapping Manage in the nav goes back to the Manage list at $name width', (tester) async {
      await openPlaces(tester);
      expect(find.text(l10n.newPlace), findsOneWidget); // inside Rooms and devices

      await tester.tap(find.byIcon(Icons.tune_rounded)); // the Manage button in the nav
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(l10n.newPlace), findsNothing);
      expect(find.text(l10n.placesTitle), findsOneWidget); // the list entry
      expect(find.text(l10n.productsTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('adding a PC to a room at $name width', (tester) async {
      await openPlaces(tester);
      await tester.ensureVisible(find.text(l10n.newDevice).first);
      await tester.tap(find.text(l10n.newDevice).first);
      await _letAnimationFinish(tester);

      await tester.enterText(find.byType(TextField).at(0), 'PC-1');
      await tester.tap(find.text(l10n.typePc));
      await tester.tap(find.text('PS4')); // the price category: 60 an hour
      await tester.pump(const Duration(milliseconds: 100));
      await tester.ensureVisible(find.text(l10n.save));
      await tester.tap(find.text(l10n.save));
      await _letAnimationFinish(tester);

      expect(find.text('PC-1'), findsOneWidget);
      expect(find.text('${l10n.typePc} · ${l10n.pricePerHour('60')}'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the pair price is only offered for kinds that have one at $name width', (tester) async {
      await openPlaces(tester);
      await tester.ensureVisible(find.text(l10n.newDevice).first);
      await tester.tap(find.text(l10n.newDevice).first);
      await _letAnimationFinish(tester);

      await tester.tap(find.text('PS5 عادي')); // a category with a pair price
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('${l10n.pricePerHour('50')} · ${l10n.pricePerHour('70')}'), findsOneWidget); // PlayStation: single and pair
      await tester.tap(find.text(l10n.typeBilliards));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(l10n.pricePerHour('50')), findsOneWidget); // billiards: one price only
      await tester.tap(find.text(l10n.typePingPong));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('${l10n.pricePerHour('50')} · ${l10n.pricePerHour('70')}'), findsOneWidget); // ping pong has a pair price too
      expect(tester.takeException(), isNull);
    });

    testWidgets('a new place with its first device at $name width', (tester) async {
      await openPlaces(tester);
      await tester.tap(find.text(l10n.newPlace));
      await _letAnimationFinish(tester);

      await tester.enterText(find.byType(TextField).at(0), 'VIP 3');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.ensureVisible(find.text(l10n.save));
      await tester.tap(find.text(l10n.save));
      await _letAnimationFinish(tester);

      // The second form: the first device of the new place.
      await tester.enterText(find.byType(TextField).at(0), 'PS5-7');
      await tester.tap(find.text('VIP')); // the price category
      await tester.pump(const Duration(milliseconds: 100));
      await tester.ensureVisible(find.text(l10n.save));
      await tester.tap(find.text(l10n.save));
      await _letAnimationFinish(tester);

      expect(find.text('VIP 3'), findsOneWidget);
      expect(find.text('PS5-7'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dragging a room by its grip onto another room puts it there at $name width', (tester) async {
      await openPlaces(tester);
      tester.view.physicalSize = Size(size.width, 2400); // tall: both rooms are on screen to drop on
      await tester.pump(const Duration(milliseconds: 100));
      final container = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
      String firstRoom() => container.read(unitsProvider).first.roomName;
      expect(firstRoom(), 'صالة 1');

      // The grip of the first room, dropped on the name of the second room.
      final grip = find.byIcon(Icons.drag_indicator).first;
      final target = find.text('صالة 2');
      await tester.drag(grip, tester.getCenter(target) - tester.getCenter(grip));
      await _letAnimationFinish(tester);

      expect(container.read(unitsProvider).byRoom.keys.toList().take(2), ['hall-2', 'hall-1']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a device with a session can only be renamed at $name width', (tester) async {
      await openPlaces(tester);
      await tester.ensureVisible(find.text('PS5-1'));
      await tester.tap(find.text('PS5-1')); // running in the sample data
      await _letAnimationFinish(tester);

      expect(find.text(l10n.deviceBusyHint), findsOneWidget);
      expect(find.text(l10n.deleteDevice), findsNothing);
      expect(find.text(l10n.priceCategoryLabel), findsNothing); // type and prices are not offered
      expect(find.text(l10n.typePc), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('dragging a device onto another room moves it there', (tester) async {
    tester.view.physicalSize = const Size(1000, 1600); // tall: every room is on screen
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text(l10n.placesTitle));
    await tester.pump(const Duration(milliseconds: 300));
    final container = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
    expect(container.read(unitsProvider).byId('ps5-1').roomId, 'hall-1');

    // The grip of the first device on screen (PS5-1, in hall 1), dropped on hall 2's "new device".
    final grip = find.byIcon(Icons.drag_indicator).at(1); // 0 is hall 1's own grip
    final target = find.text(l10n.newDevice).at(1);
    await tester.drag(grip, tester.getCenter(target) - tester.getCenter(grip));
    await _letAnimationFinish(tester);

    final moved = container.read(unitsProvider).byId('ps5-1');
    expect(moved.roomId, 'hall-2');
    expect(moved.roomName, 'صالة 2');
    expect(tester.takeException(), isNull);
  });
}

// Manage -> Products -> the inventory section. (Three sizes, like the others.)
void _stockTests() {
  final l10n = AppLocalizationsAr();
  for (final (name, size) in [
    ('phone', const Size(360, 740)),
    ('medium', const Size(900, 700)),
    ('wide', const Size(1400, 900)),
  ]) {
    Future<void> openProducts(WidgetTester tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpApp(tester);
      await tester.tap(find.byIcon(Icons.tune_rounded)); // the Manage tab
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text(l10n.productsTitle));
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('a shopping trip from the inventory button at $name width', (tester) async {
      await openProducts(tester);

      await tester.ensureVisible(find.text(l10n.stockBought));
      await tester.tap(find.text(l10n.stockBought));
      await _letAnimationFinish(tester);

      final pepsi = find.byKey(const ValueKey('buy-stock-pepsi'));
      await tester.ensureVisible(pepsi);
      await tester.enterText(pepsi, '50'); // typed once, not fifty taps
      await tester.pump(const Duration(milliseconds: 100));
      final paid = find.byKey(const ValueKey('paid-stock-pepsi')); // opens once a number is typed
      await tester.ensureVisible(paid);
      await tester.enterText(paid, '600'); // what that line cost
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(l10n.amountEgp('600')), findsOneWidget); // the total is worked out
      await tester.ensureVisible(find.text(l10n.purchaseConfirm));
      await tester.tap(find.text(l10n.purchaseConfirm));
      await _letAnimationFinish(tester);

      expect(find.text(l10n.stockLeft(74)), findsOneWidget); // Pepsi: 24 + 50
      expect(tester.takeException(), isNull);
    });

    testWidgets('fixing a count shows the gap and saves at $name width', (tester) async {
      await openProducts(tester);

      expect(find.text(l10n.stockLow), findsOneWidget); // only chips is low

      await tester.ensureVisible(find.text(l10n.stockLeft(24))); // Pepsi's row
      await tester.tap(find.text(l10n.stockLeft(24)));
      await _letAnimationFinish(tester);
      await tester.enterText(find.byType(TextField).at(0), '22'); // Pepsi opens on the count form
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(l10n.stockDiffShort(2)), findsOneWidget); // 22 against 24
      await tester.ensureVisible(find.text(l10n.stockRecord));
      await tester.tap(find.text(l10n.stockRecord));
      await _letAnimationFinish(tester);

      expect(find.text(l10n.stockLeft(22)), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('one tap on "opened" takes one off at $name width', (tester) async {
      await openProducts(tester);

      await tester.ensureVisible(find.text(l10n.stockLeft(3))); // Tea's row (recorded by hand)
      await tester.tap(find.text(l10n.stockLeft(3)));
      await _letAnimationFinish(tester);
      expect(find.byType(TextField), findsNothing); // no quantity to type
      await tester.tap(find.text(l10n.stockOpened));
      await _letAnimationFinish(tester);

      expect(find.text(l10n.stockLeft(2)), findsOneWidget); // 3 - 1
      expect(tester.takeException(), isNull);
    });

    testWidgets('adding an internal item at $name width', (tester) async {
      await openProducts(tester);

      await tester.ensureVisible(find.text(l10n.addToStock));
      await tester.tap(find.text(l10n.addToStock));
      await _letAnimationFinish(tester);
      // Every sample product is already counted, so the form opens on "something only used".
      await tester.enterText(find.byType(TextField).at(0), 'اكواب'); // the name
      await tester.enterText(find.byType(TextField).at(1), '7'); // how many on the shelf now
      await tester.pump(const Duration(milliseconds: 100));
      await tester.ensureVisible(find.text(l10n.saveStockItem));
      await tester.tap(find.text(l10n.saveStockItem));
      await _letAnimationFinish(tester);

      expect(find.text('اكواب'), findsOneWidget);
      expect(find.text(l10n.stockLeft(7)), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('adding a product to the inventory at $name width', (tester) async {
      await openProducts(tester);

      // A new product is not counted yet: add one, then count it.
      await tester.tap(find.text(l10n.newProduct));
      await _letAnimationFinish(tester);
      await tester.enterText(find.byType(TextField).at(0), 'كولا');
      await tester.enterText(find.byType(TextField).at(1), '12');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.ensureVisible(find.text(l10n.saveProduct));
      await tester.tap(find.text(l10n.saveProduct));
      await _letAnimationFinish(tester);

      await tester.ensureVisible(find.text(l10n.addToStock));
      await tester.tap(find.text(l10n.addToStock));
      await _letAnimationFinish(tester);
      final pickCola = find.descendant(of: find.byType(Pill), matching: find.text('كولا'));
      await tester.ensureVisible(pickCola);
      await tester.tap(pickCola);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField).at(0), '5'); // how many on the shelf now
      await tester.pump(const Duration(milliseconds: 100));
      await tester.ensureVisible(find.text(l10n.saveStockItem));
      await tester.tap(find.text(l10n.saveStockItem));
      await _letAnimationFinish(tester);

      expect(find.text(l10n.stockLeft(5)), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

// Resizing the window across the phone/PC line must not throw the current page away.
void _resizeTests() {
  final l10n = AppLocalizationsAr();
  testWidgets('resizing keeps you on the Products page', (tester) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1400, 900); // wide: side nav

    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text(l10n.productsTitle));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(l10n.newProduct), findsOneWidget);

    tester.view.physicalSize = const Size(360, 740); // phone: bottom bar
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(l10n.newProduct), findsOneWidget); // still on Products

    tester.view.physicalSize = const Size(1400, 900); // and back
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(l10n.newProduct), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

/// The first pump only starts a route animation (sheet or dialog); the second one plays it.
Future<void> _letAnimationFinish(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 500));
}

// Quick sale: tap a product, press sell, a paid bill is saved.
void _quickSaleTests() {
  final l10n = AppLocalizationsAr();
  testWidgets('selling a drink from the Quick sale page', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.local_drink_outlined).first); // the Quick sale tab (first: the nav)
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(l10n.quickSaleSell), findsOneWidget); // nothing picked yet

    await tester.tap(find.text('بيبسي').last);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('${l10n.quickSaleSell} · ${l10n.amountEgp('15')}'), findsOneWidget);

    await tester.tap(find.text('${l10n.quickSaleSell} · ${l10n.amountEgp('15')}'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('${l10n.quickSaleDone} · ${l10n.amountEgp('15')}'), findsOneWidget);
    expect(find.text(l10n.quickSaleSell), findsOneWidget); // cleared, ready for the next customer
    expect(tester.takeException(), isNull);
  });
}
