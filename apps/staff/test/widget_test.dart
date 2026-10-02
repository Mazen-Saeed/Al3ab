import 'package:al3b_staff/l10n/arb/app_localizations_ar.dart';
import 'package:al3b_staff/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

// These tests use pumpApp() / pump() instead of pumpAndSettle(): the store's clock never stops.
void main() {
  final l10n = AppLocalizationsAr();

  testWidgets('Floor screen shows the sample units', (tester) async {
    await pumpApp(tester);

    expect(find.text('محل التجربة'), findsOneWidget); // venue name in the top bar
    expect(find.text('PS5-1'), findsWidgets); // tile (+ panel on wide screens)
    expect(find.text('بلياردو 2'), findsOneWidget);

    await tester.pumpWidget(const SizedBox()); // unmount: stops the store's clock
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
}
