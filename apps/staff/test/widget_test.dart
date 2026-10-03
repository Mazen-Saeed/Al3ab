import 'package:al3b_staff/data/sample_data.dart';
import 'package:al3b_staff/l10n/arb/app_localizations_ar.dart';
import 'package:al3b_staff/l10n/arb/app_localizations_en.dart';
import 'package:al3b_staff/shell/pill.dart';
import 'package:flutter/material.dart';
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
  _resizeTests();

  testWidgets('the Manage page switches the language to English and back', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('English'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(AppLocalizationsEn().productsTitle), findsOneWidget);

    await tester.tap(find.text('العربية'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(l10n.productsTitle), findsOneWidget);

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

      expect(find.text(l10n.orderLine('بيبسي', 2, 15)), findsOneWidget);
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
      expect(find.text(l10n.amountEgp(12)), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
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
      final total = find.byKey(const ValueKey('purchase-total'));
      await tester.ensureVisible(total);
      await tester.enterText(total, '1200'); // the receipt total
      await tester.pump(const Duration(milliseconds: 100));
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
