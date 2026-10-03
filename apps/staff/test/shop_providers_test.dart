import 'package:al3b_staff/data/bill.dart';
import 'package:al3b_staff/data/bills_provider.dart';
import 'package:al3b_staff/data/catalog_provider.dart';
import 'package:al3b_staff/data/categories_provider.dart';
import 'package:al3b_staff/data/orders_provider.dart';
import 'package:al3b_staff/data/product.dart';
import 'package:al3b_staff/data/stock.dart';
import 'package:al3b_staff/data/unit.dart';
import 'package:al3b_staff/data/units_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

// These test the providers without any screen: a ProviderContainer is the same thing the app's
// ProviderScope holds. makeContainer (helpers.dart) starts it from the data a test gives.

Unit unitOf(ProviderContainer c, String id) => c.read(unitsProvider).byId(id);

void main() {
  group('units', () {
    test('startSession makes the unit run with the chosen mode and plan', () {
      final c = makeContainer(units: [testUnit(multi: 70)]);

      c.read(unitsProvider.notifier).startSession('u1', isMulti: true, plannedMinutes: 120);

      final unit = unitOf(c, 'u1');
      expect(unit.status, UnitStatus.running);
      expect(unit.isMulti, isTrue);
      expect(unit.plannedMinutes, 120);
      expect(unit.startedAt, isNotNull);
    });

    test('startSession without a plan is open time', () {
      final c = makeContainer();
      c.read(unitsProvider.notifier).startSession('u1', isMulti: false);
      expect(unitOf(c, 'u1').plannedMinutes, isNull);
    });

    test('addTime extends a planned session', () {
      final c = makeContainer(
        units: [testUnit(status: UnitStatus.running, planned: 60, startedAt: ago(const Duration(minutes: 10)))],
      );
      c.read(unitsProvider.notifier).addTime('u1', 30);
      expect(unitOf(c, 'u1').plannedMinutes, 90);
    });

    test('addTime with null switches the session to open time', () {
      final c = makeContainer(
        units: [testUnit(status: UnitStatus.running, planned: 60, startedAt: ago(const Duration(minutes: 10)))],
      );
      c.read(unitsProvider.notifier).addTime('u1', null);
      expect(unitOf(c, 'u1').plannedMinutes, isNull);
    });

    test('addTime on an open session gives it a time limit counted from now', () {
      final c = makeContainer(
        units: [testUnit(status: UnitStatus.running, startedAt: ago(const Duration(minutes: 40)))], // open time
      );
      c.read(unitsProvider.notifier).addTime('u1', 60);
      // 40 minutes played (a little more) + 60 more from now: 100 or 101 depending on the seconds
      expect(unitOf(c, 'u1').plannedMinutes, inInclusiveRange(100, 101));
    });

    test('a fixed session can become open and then fixed again', () {
      final c = makeContainer(
        units: [testUnit(status: UnitStatus.running, planned: 60, startedAt: ago(const Duration(minutes: 10)))],
      );
      final notifier = c.read(unitsProvider.notifier);

      notifier.addTime('u1', null);
      expect(unitOf(c, 'u1').plannedMinutes, isNull);

      notifier.addTime('u1', 30);
      expect(unitOf(c, 'u1').plannedMinutes, inInclusiveRange(40, 41)); // 10 played + 30 from now
    });

    test('changing one unit leaves the others alone', () {
      final c = makeContainer(units: [testUnit(id: 'a'), testUnit(id: 'b')]);
      c.read(unitsProvider.notifier).startSession('a', isMulti: false);
      expect(unitOf(c, 'a').status, UnitStatus.running);
      expect(unitOf(c, 'b').status, UnitStatus.free);
    });

    test('a change gives the screens a new list to redraw from', () {
      final c = makeContainer();
      final before = c.read(unitsProvider);
      c.read(unitsProvider.notifier).startSession('u1', isMulti: false);
      expect(identical(c.read(unitsProvider), before), isFalse);
    });
  });

  group('orders', () {
    const pepsi = Product(id: 'pepsi', name: 'بيبسي', price: 1500);
    const tea = Product(id: 'tea', name: 'شاي', price: 1000);
    ProviderContainer makeOrderContainer() => makeContainer(products: [pepsi, tea]);

    test('addOrder adds lines and the total sums them', () {
      final c = makeOrderContainer();
      c.read(ordersProvider.notifier).addOrder('u1', {'pepsi': 2, 'tea': 1});
      final orders = c.read(ordersProvider);
      expect(orders.forUnit('u1').length, 2);
      expect(orders.totalFor('u1'), 4000);
    });

    test('ordering the same product again raises its quantity', () {
      final c = makeOrderContainer();
      c.read(ordersProvider.notifier).addOrder('u1', {'pepsi': 1});
      c.read(ordersProvider.notifier).addOrder('u1', {'pepsi': 2});
      expect(c.read(ordersProvider).forUnit('u1').single.quantity, 3);
    });

    test('removeOrderLine takes the whole line off', () {
      final c = makeOrderContainer();
      c.read(ordersProvider.notifier).addOrder('u1', {'pepsi': 2, 'tea': 1});
      c.read(ordersProvider.notifier).removeOrderLine('u1', 'pepsi');
      expect(c.read(ordersProvider).forUnit('u1').map((l) => l.productId), ['tea']);
    });

    test('a unit without orders has an empty bill', () {
      final c = makeOrderContainer();
      expect(c.read(ordersProvider).forUnit('u1'), isEmpty);
      expect(c.read(ordersProvider).totalFor('u1'), 0);
    });
  });

  group('session changes', () {
    Unit running({String id = 'u1', int minutesAgo = 60, int hourly = 50, int? multi = 70}) =>
        testUnit(id: id, status: UnitStatus.running, hourly: hourly, multi: multi, startedAt: ago(Duration(minutes: minutesAgo)));

    test('switching single -> pair keeps the old price for the time so far', () {
      final c = makeContainer(units: [running()]);

      c.read(unitsProvider.notifier).switchMode('u1');

      final unit = unitOf(c, 'u1');
      expect(unit.isMulti, isTrue);
      expect(unit.carriedCost, 5000); // one hour at 50
      expect(unit.currentCost, 5000); // nothing more yet
      expect(unit.costAt(DateTime.now().add(const Duration(hours: 1))), 5000 + 7000); // the next hour at 70
    });

    test('single, then pair, then single again: each stretch is charged at its own price', () {
      final t0 = DateTime(2026, 1, 1, 20);
      DateTime at(int minutes) => t0.add(Duration(minutes: minutes));
      final single = testUnit(status: UnitStatus.running, hourly: 50, multi: 70, startedAt: t0);

      final pair = single.withModeSwitched(at(30)); // 30 min single at 50 = 25
      final single2 = pair.withModeSwitched(at(60)); // 30 min pair at 70 = 35

      expect(pair.costAt(at(60)), 2500 + 3500);
      expect(single2.isMulti, isFalse);
      expect(single2.costAt(at(90)), 2500 + 3500 + 2500); // 30 more min single at 50 = 25, total 85
    });

    test('switching is ignored without a pair price, and switching back works', () {
      final c = makeContainer(units: [running(multi: null)]);
      c.read(unitsProvider.notifier).switchMode('u1');
      expect(unitOf(c, 'u1').isMulti, isFalse);

      final d = makeContainer(units: [running()]);
      d.read(unitsProvider.notifier).switchMode('u1');
      d.read(unitsProvider.notifier).switchMode('u1');
      expect(unitOf(d, 'u1').isMulti, isFalse);
    });

    test('stopping the clock freezes the price and resuming does not charge the stopped time', () {
      final c = makeContainer(units: [running(minutesAgo: 30)]);

      c.read(unitsProvider.notifier).stopClock('u1');

      final stopped = unitOf(c, 'u1');
      expect(stopped.status, UnitStatus.waitingPayment);
      expect(stopped.amountDue, 2500); // half an hour at 50
      expect(stopped.costAt(DateTime.now().add(const Duration(hours: 2))), 2500); // it does not grow

      c.read(unitsProvider.notifier).resumeClock('u1');
      final resumed = unitOf(c, 'u1');
      expect(resumed.status, UnitStatus.running);
      expect(resumed.stoppedAt, isNull);
      expect(resumed.amountDue, isNull);
      expect(resumed.currentCost, 2500);
      expect(resumed.originalStart, stopped.startedAt); // the session keeps its identity (the alerts rely on it)
    });

    test('moving a session charges the old price so far and the new price after, and takes the orders along', () {
      final c = makeContainer(
        units: [running(), testUnit(id: 'u2', hourly: 80)],
        products: [const Product(id: 'a', name: 'شاي', price: 1000)],
      );
      c.read(ordersProvider.notifier).addOrder('u1', {'a': 1});

      c.read(unitsProvider.notifier).moveSession('u1', 'u2');

      expect(unitOf(c, 'u1').status, UnitStatus.free);
      final moved = unitOf(c, 'u2');
      expect(moved.status, UnitStatus.running);
      expect(moved.startedAt, isNotNull);
      expect(moved.carriedCost, 5000);
      expect(moved.costAt(DateTime.now().add(const Duration(hours: 1))), 5000 + 8000);
      expect(c.read(ordersProvider).forUnit('u1'), isEmpty);
      expect(c.read(ordersProvider).forUnit('u2').single.name, 'شاي');
    });

    test('moving needs a running session and a free unit', () {
      final c = makeContainer(units: [
        testUnit(id: 'u1'),
        running(id: 'u2'),
        running(id: 'u3'),
      ]);

      c.read(unitsProvider.notifier).moveSession('u1', 'u2'); // from a free unit
      c.read(unitsProvider.notifier).moveSession('u2', 'u3'); // to a busy unit

      expect(unitOf(c, 'u1').status, UnitStatus.free);
      expect(unitOf(c, 'u2').status, UnitStatus.running);
      expect(unitOf(c, 'u2').carriedCost, 0);
      expect(unitOf(c, 'u3').carriedCost, 0);
    });
  });

  group('power cut', () {
    test('stop all stops every running time session, resume all restarts only those', () {
      final c = makeContainer(units: [
        testUnit(id: 'a', status: UnitStatus.running, startedAt: ago(const Duration(minutes: 30))),
        testUnit(id: 'b', status: UnitStatus.running, startedAt: ago(const Duration(minutes: 30))),
        testUnit(id: 'f'),
      ]);
      final units = c.read(unitsProvider.notifier);
      units.stopClock('b'); // a customer waiting to pay, before the power cut

      units.stopAll();

      expect(unitOf(c, 'a').status, UnitStatus.waitingPayment);
      expect(unitOf(c, 'f').status, UnitStatus.free);
      expect(c.read(outageProvider), {'a'}); // 'b' was not stopped by the power cut

      units.resumeAll();

      expect(unitOf(c, 'a').status, UnitStatus.running);
      expect(unitOf(c, 'a').currentCost, 2500); // the stopped time is not charged
      expect(unitOf(c, 'b').status, UnitStatus.waitingPayment); // still waiting to pay
      expect(c.read(outageProvider), isEmpty);
    });

    test('a unit resumed by hand or paid leaves the power cut', () {
      final c = makeContainer(units: [
        testUnit(id: 'a', status: UnitStatus.running, startedAt: ago(const Duration(minutes: 30))),
        testUnit(id: 'b', status: UnitStatus.running, startedAt: ago(const Duration(minutes: 30))),
      ]);
      final units = c.read(unitsProvider.notifier);
      units.stopAll();

      units.resumeClock('a');
      units.free('b');

      expect(c.read(outageProvider), isEmpty);
    });
  });

  group('endAndPay', () {
    final start = DateTime(2026, 1, 1, 10);
    final oneHourLater = start.add(const Duration(hours: 1));
    const pepsi = Product(id: 'pepsi', name: 'بيبسي', price: 1500);

    // A unit running since 10:00 at 50 EGP/hour, with 2 Pepsi ordered: bill = 50 + 30.
    ProviderContainer makeRunning() {
      final c = makeContainer(
        units: [testUnit(status: UnitStatus.running, startedAt: start, planned: 60)],
        products: [pepsi],
      );
      c.read(ordersProvider.notifier).addOrder('u1', {'pepsi': 2});
      return c;
    }

    test('saves the bill, clears the orders and frees the unit', () {
      final c = makeRunning();
      final bill = c.read(billsProvider.notifier).endAndPay('u1', endedAt: oneHourLater, method: PaymentMethod.cash);

      expect(bill.playCost, 5000);
      expect(bill.ordersTotal, 3000);
      expect(bill.total, 8000);
      expect(c.read(billsProvider).single, same(bill));
      expect(c.read(ordersProvider).forUnit('u1'), isEmpty);

      final unit = unitOf(c, 'u1');
      expect(unit.status, UnitStatus.free);
      expect(unit.startedAt, isNull);
      expect(unit.plannedMinutes, isNull);
    });

    test('a discount is taken off the total and kept with its reason', () {
      final bill = makeRunning().read(billsProvider.notifier).endAndPay(
            'u1',
            endedAt: oneHourLater,
            discount: 1000,
            discountReason: 'زبون دايم',
            method: PaymentMethod.instapay,
          );
      expect(bill.total, 7000);
      expect(bill.discountReason, 'زبون دايم');
      expect(bill.method, PaymentMethod.instapay);
    });

    test('a discount can never be more than the subtotal', () {
      final bill = makeRunning()
          .read(billsProvider.notifier)
          .endAndPay('u1', endedAt: oneHourLater, discount: 50000, method: PaymentMethod.cash);
      expect(bill.discount, 8000);
      expect(bill.total, 0);
    });

    test('other units are not touched', () {
      final c = makeContainer(units: [
        testUnit(id: 'a', status: UnitStatus.running, startedAt: start),
        testUnit(id: 'b', status: UnitStatus.running, startedAt: start),
      ]);
      c.read(billsProvider.notifier).endAndPay('a', endedAt: oneHourLater, method: PaymentMethod.cash);
      expect(unitOf(c, 'b').status, UnitStatus.running);
    });
  });

  group('maintenance', () {
    test('a free unit goes into maintenance with its note, and back to free', () {
      final c = makeContainer();
      c.read(unitsProvider.notifier).setMaintenance('u1', note: 'الدراع بايظ');
      expect(unitOf(c, 'u1').status, UnitStatus.maintenance);
      expect(unitOf(c, 'u1').note, 'الدراع بايظ');

      c.read(unitsProvider.notifier).clearMaintenance('u1');
      expect(unitOf(c, 'u1').status, UnitStatus.free);
      expect(unitOf(c, 'u1').note, isNull);
    });

    test('a running unit can not be put in maintenance', () {
      final c = makeContainer(
        units: [testUnit(status: UnitStatus.running, startedAt: ago(const Duration(minutes: 5)))],
      );
      c.read(unitsProvider.notifier).setMaintenance('u1');
      expect(unitOf(c, 'u1').status, UnitStatus.running);
    });
  });

  group('products', () {
    test('add, update and delete change the menu', () {
      final c = makeContainer();
      final catalog = c.read(catalogProvider.notifier);

      catalog.addProduct('كولا', 1200);
      final id = c.read(catalogProvider).products.single.id;
      expect(c.read(catalogProvider).products.single.name, 'كولا');

      catalog.updateProduct(id, name: 'كولا كبيرة', price: 2000);
      expect(c.read(catalogProvider).products.single.price, 2000);

      catalog.deleteProduct(id);
      expect(c.read(catalogProvider).products, isEmpty);
    });

    test('a bill keeps its lines after the product is deleted', () {
      final c = makeContainer(
        units: [testUnit(status: UnitStatus.running, startedAt: ago(const Duration(minutes: 5)))],
        products: [const Product(id: 'a', name: 'شاي', price: 1000)],
      );
      c.read(ordersProvider.notifier).addOrder('u1', {'a': 2});
      c.read(catalogProvider.notifier).deleteProduct('a');
      expect(c.read(ordersProvider).forUnit('u1').single.name, 'شاي');
      expect(c.read(ordersProvider).totalFor('u1'), 2000);
    });
  });

  group('quick sale', () {
    ProviderContainer shop() => makeContainer(
          products: [
            const Product(id: 'pepsi', name: 'بيبسي', price: 1500, stockItemId: 's-pepsi'),
            const Product(id: 'tea', name: 'شاي', price: 1000),
          ],
          stockItems: [const StockItem(id: 's-pepsi', name: 'بيبسي', deductsOnSale: true, onHand: 24)],
        );

    test('saves a paid bill with no unit and takes the stock off the shelf', () {
      final c = shop();

      final bill = c.read(billsProvider.notifier).quickSale({'pepsi': 2, 'tea': 1}, method: PaymentMethod.wallet);

      expect(bill, isNotNull);
      expect(bill!.isQuickSale, isTrue);
      expect(bill.unitId, isNull);
      expect(bill.total, 4000); // 2 x 15 + 10
      expect(bill.method, PaymentMethod.wallet);
      expect(bill.lines.map((l) => l.name), ['بيبسي', 'شاي']);
      expect(c.read(billsProvider), [bill]);
      expect(c.read(catalogProvider).stockItems.single.onHand, 22);
    });

    test('an empty sale saves nothing', () {
      final c = shop();
      expect(c.read(billsProvider.notifier).quickSale({'pepsi': 0}, method: PaymentMethod.cash), isNull);
      expect(c.read(billsProvider), isEmpty);
    });
  });

  group('stock', () {
    // Pepsi: subtracted on every sale. Tea: counted in packets, staff record by hand.
    ProviderContainer stockContainer() => makeContainer(
          units: [testUnit(status: UnitStatus.running, startedAt: ago(const Duration(minutes: 5)))],
          products: [
            const Product(id: 'pepsi', name: 'بيبسي', price: 1500, stockItemId: 's-pepsi'),
            const Product(id: 'tea', name: 'شاي', price: 1000, stockItemId: 's-tea'),
          ],
          stockItems: [
            const StockItem(id: 's-pepsi', name: 'بيبسي', deductsOnSale: true, onHand: 24),
            const StockItem(id: 's-tea', name: 'شاي', deductsOnSale: false, onHand: 3),
          ],
        );

    int onHand(ProviderContainer c, String id) =>
        c.read(catalogProvider).stockItems.firstWhere((s) => s.id == id).onHand;

    test('an order subtracts from an item that deducts on sale', () {
      final c = stockContainer();
      c.read(ordersProvider.notifier).addOrder('u1', {'pepsi': 2});
      expect(onHand(c, 's-pepsi'), 22);
    });

    test('an order of a hand-counted item subtracts nothing', () {
      final c = stockContainer();
      c.read(ordersProvider.notifier).addOrder('u1', {'tea': 5});
      expect(onHand(c, 's-tea'), 3);
    });

    test('removing an order line gives the stock back', () {
      final c = stockContainer();
      c.read(ordersProvider.notifier).addOrder('u1', {'pepsi': 2});
      c.read(ordersProvider.notifier).removeOrderLine('u1', 'pepsi');
      expect(onHand(c, 's-pepsi'), 24);
    });

    test('selling more than is on hand is allowed and goes below 0', () {
      final c = stockContainer();
      c.read(ordersProvider.notifier).addOrder('u1', {'pepsi': 30});
      expect(onHand(c, 's-pepsi'), -6);
    });

    test('a shopping trip adds every item and saves the total of its lines', () {
      final c = stockContainer();
      c.read(catalogProvider.notifier).recordPurchase({
        's-tea': const PurchaseLine(quantity: 10, cost: 12000),
        's-pepsi': const PurchaseLine(quantity: 6, cost: 36000),
      });

      expect(onHand(c, 's-tea'), 13);
      expect(onHand(c, 's-pepsi'), 30);
      final trip = c.read(catalogProvider).purchases.single;
      expect(trip.total, 48000);
      expect(c.read(catalogProvider).movements.map((m) => (m.kind, m.quantity, m.cost, m.purchaseId)).toList(), [
        (StockMovementKind.purchase, 10, 12000, trip.id),
        (StockMovementKind.purchase, 6, 36000, trip.id),
      ]);
    });

    test('a shopping trip with nothing picked, or an unknown item, saves nothing', () {
      final c = stockContainer();
      c.read(catalogProvider.notifier).recordPurchase({'s-tea': const PurchaseLine(quantity: 0, cost: 5000)});
      c.read(catalogProvider.notifier).recordPurchase({'nope': const PurchaseLine(quantity: 3, cost: 5000)});
      expect(c.read(catalogProvider).purchases, isEmpty);
      expect(c.read(catalogProvider).movements, isEmpty);
    });

    test('what one costs comes from the latest purchase of its stock item', () {
      final c = stockContainer();
      final catalog = c.read(catalogProvider.notifier);
      StockItem pepsi() => c.read(catalogProvider).stockItems.firstWhere((s) => s.id == 's-pepsi');
      expect(c.read(catalogProvider).unitCostOf(pepsi()), isNull); // never bought with a price

      catalog.recordPurchase({'s-pepsi': const PurchaseLine(quantity: 24, cost: 28800)}); // 288 EGP for 24
      expect(c.read(catalogProvider).unitCostOf(pepsi()), 1200); // 12 EGP each

      catalog.recordPurchase({'s-pepsi': const PurchaseLine(quantity: 3, cost: 100)}); // 1 EGP for 3: rounded
      expect(c.read(catalogProvider).unitCostOf(pepsi()), 33);
    });

    test('opening a tin takes one off and writes the log', () {
      final c = stockContainer();
      c.read(catalogProvider.notifier).recordOpened('s-tea');
      expect(onHand(c, 's-tea'), 2);
      expect(c.read(catalogProvider).movements.single.kind, StockMovementKind.opened);
    });

    test('a count replaces the number and keeps what the app expected and the reason', () {
      final c = stockContainer();
      c.read(catalogProvider.notifier).recordCount('s-pepsi', 20, note: '  وقعت وانكسرت ');
      expect(onHand(c, 's-pepsi'), 20);

      final entry = c.read(catalogProvider).movements.single;
      expect(entry.kind, StockMovementKind.count);
      expect(entry.quantity, 20);
      expect(entry.expected, 24); // 20 found against 24 expected: 4 missing
      expect(entry.note, 'وقعت وانكسرت');
    });

    test('a count without a reason has no note', () {
      final c = stockContainer();
      c.read(catalogProvider.notifier).recordCount('s-tea', 3, note: '   ');
      expect(c.read(catalogProvider).movements.single.note, isNull);
    });

    test('a count of 0 is allowed; a negative count is ignored', () {
      final c = stockContainer();
      c.read(catalogProvider.notifier).recordCount('s-tea', 0);
      expect(onHand(c, 's-tea'), 0);
      c.read(catalogProvider.notifier).recordCount('s-tea', -1);
      expect(c.read(catalogProvider).movements.length, 1);
    });

    test('isLow is true at or below the level, never without one', () {
      const item = StockItem(id: 'x', name: 'x', deductsOnSale: true, onHand: 6, lowStockAt: 6);
      expect(item.isLow, isTrue);
      expect(item.withOnHand(7).isLow, isFalse);
      expect(const StockItem(id: 'y', name: 'y', deductsOnSale: true).isLow, isFalse);
    });

    test('editing a product keeps its stock item', () {
      final c = stockContainer();
      c.read(catalogProvider.notifier).updateProduct('pepsi', name: 'بيبسي كبير', price: 2000);
      expect(c.read(catalogProvider).products.firstWhere((p) => p.id == 'pepsi').stockItemId, 's-pepsi');
    });

    test('startTracking creates a stock item named like the product, with the first count', () {
      final c = makeContainer(products: [const Product(id: 'c', name: 'كولا', price: 1200)]);
      c.read(catalogProvider.notifier).startTracking('c', deductsOnSale: true, lowStockAt: 2, count: 5);

      final catalog = c.read(catalogProvider);
      final item = catalog.stockItemOf(catalog.products.single)!;
      expect(item.name, 'كولا');
      expect(item.deductsOnSale, isTrue);
      expect(item.onHand, 5);
      expect(item.lowStockAt, 2);
      expect(catalog.movements.single.kind, StockMovementKind.count);
    });

    test('a product starts uncounted, and counting it takes it off the untracked list', () {
      final c = makeContainer();
      c.read(catalogProvider.notifier).addProduct('خدمة', 5);
      expect(c.read(catalogProvider).products.single.stockItemId, isNull);
      expect(c.read(catalogProvider).untrackedProducts.length, 1);

      c.read(catalogProvider.notifier).startTracking(c.read(catalogProvider).products.single.id, deductsOnSale: true);
      expect(c.read(catalogProvider).untrackedProducts, isEmpty);
    });

    test('startTracking on a product that is already counted does nothing', () {
      final c = stockContainer();
      c.read(catalogProvider.notifier).startTracking('pepsi', deductsOnSale: false, count: 99);
      expect(c.read(catalogProvider).stockItems.length, 2);
      expect(onHand(c, 's-pepsi'), 24);
    });

    test('updateStockItem changes how it is counted and keeps the number', () {
      final c = stockContainer();
      c.read(catalogProvider.notifier).updateStockItem('s-pepsi', deductsOnSale: false, lowStockAt: 3);
      final item = c.read(catalogProvider).stockItems.firstWhere((s) => s.id == 's-pepsi');
      expect(item.deductsOnSale, isFalse);
      expect(item.lowStockAt, 3);
      expect(item.onHand, 24);
    });

    test('stopTracking removes the item and its log; the product stays, uncounted', () {
      final c = stockContainer();
      c.read(catalogProvider.notifier).recordOpened('s-pepsi');
      c.read(catalogProvider.notifier).stopTracking('s-pepsi');

      final catalog = c.read(catalogProvider);
      expect(catalog.stockItems.map((s) => s.id), ['s-tea']);
      expect(catalog.movements, isEmpty);
      expect(catalog.products.firstWhere((p) => p.id == 'pepsi').stockItemId, isNull);
      c.read(ordersProvider.notifier).addOrder('u1', {'pepsi': 1}); // must not crash
    });

    test('deleting a product removes its stock item', () {
      final c = stockContainer();
      c.read(catalogProvider.notifier).deleteProduct('pepsi');
      expect(c.read(catalogProvider).stockItems.map((s) => s.id), ['s-tea']);
    });

    test('renaming a product renames its stock item', () {
      final c = stockContainer();
      c.read(catalogProvider.notifier).updateProduct('pepsi', name: 'بيبسي كبير', price: 1500);
      expect(c.read(catalogProvider).stockItems.firstWhere((s) => s.id == 's-pepsi').name, 'بيبسي كبير');
    });

    test('an internal item has no product and is always counted by hand', () {
      final c = stockContainer();
      c.read(catalogProvider.notifier).addInternalItem('سكر', lowStockAt: 2, count: 6);

      final catalog = c.read(catalogProvider);
      final sugar = catalog.stockItems.last;
      expect(sugar.name, 'سكر');
      expect(sugar.deductsOnSale, isFalse);
      expect(sugar.onHand, 6);
      expect(catalog.isInternal(sugar), isTrue);
      expect(catalog.isInternal(catalog.stockItems.first), isFalse); // Pepsi has a product
    });

    test('an internal item can be bought, renamed and removed', () {
      final c = stockContainer();
      c.read(catalogProvider.notifier).addInternalItem('سكر');
      final id = c.read(catalogProvider).stockItems.last.id;

      c.read(catalogProvider.notifier).recordPurchase({id: const PurchaseLine(quantity: 4, cost: 4000)});
      expect(onHand(c, id), 4);

      c.read(catalogProvider.notifier).updateStockItem(id, name: 'سكر ناعم', deductsOnSale: false, lowStockAt: 1);
      expect(c.read(catalogProvider).stockItems.last.name, 'سكر ناعم');

      c.read(catalogProvider.notifier).stopTracking(id);
      expect(c.read(catalogProvider).stockItems.any((s) => s.id == id), isFalse);
    });

    test('new rows get their own UUID v7 ids', () {
      final c = makeContainer();
      c.read(catalogProvider.notifier).addProduct('أ', 1);
      c.read(catalogProvider.notifier).addProduct('ب', 2);
      final ids = c.read(catalogProvider).products.map((p) => p.id).toList();
      expect(ids.toSet().length, 2); // different
      expect(ids.first.length, 36); // 8-4-4-4-12 plus the dashes
      expect(ids.first[14], '7'); // the version digit of a v7 UUID
    });
  });

  group('places', () {
    Unit unitIn(String id, String roomId, {UnitStatus status = UnitStatus.free}) => Unit(
          id: id,
          name: id,
          type: UnitType.playstation,
          roomId: roomId,
          roomName: 'room $roomId',
          status: status,
          hourlyPrice: 5000,
        );

    test('addUnit joins the room and copies its name', () {
      final c = makeContainer(units: [unitIn('a', 'r1')]);

      c.read(unitsProvider.notifier).addUnit('r1', name: 'PC-1', type: UnitType.pc, hourlyPrice: 3000);

      final added = c.read(unitsProvider).last;
      expect(added.name, 'PC-1');
      expect(added.type, UnitType.pc);
      expect(added.roomId, 'r1');
      expect(added.roomName, 'room r1');
      expect(added.status, UnitStatus.free);
      expect(added.multiHourlyPrice, isNull);
      expect(added.id.length, 36);
    });

    test('addRoom makes a new room with its first unit at the end', () {
      final c = makeContainer(units: [unitIn('a', 'r1')]);

      c.read(unitsProvider.notifier).addRoom('VIP 3', unitName: 'PS5-7', type: UnitType.playstation, hourlyPrice: 9000, multiHourlyPrice: 12000);

      final units = c.read(unitsProvider);
      expect(units.byRoom.length, 2);
      final vip = units.last;
      expect(vip.name, 'PS5-7');
      expect(vip.roomName, 'VIP 3');
      expect(vip.roomId, isNot('r1'));
      expect(vip.multiHourlyPrice, 12000);
    });

    test('updateUnit changes a free unit completely', () {
      final c = makeContainer(units: [unitIn('a', 'r1')]);

      c.read(unitsProvider.notifier).updateUnit('a', name: 'PC-9', type: UnitType.pc, hourlyPrice: 2500, multiHourlyPrice: 4000);

      final unit = unitOf(c, 'a');
      expect(unit.name, 'PC-9');
      expect(unit.type, UnitType.pc);
      expect(unit.hourlyPrice, 2500);
      expect(unit.multiHourlyPrice, 4000);
    });

    test('updateUnit on a unit with a session only renames it', () {
      final c = makeContainer(units: [unitIn('a', 'r1', status: UnitStatus.running)]);

      c.read(unitsProvider.notifier).updateUnit('a', name: 'PS5-Z', type: UnitType.pc, hourlyPrice: 1);

      final unit = unitOf(c, 'a');
      expect(unit.name, 'PS5-Z');
      expect(unit.type, UnitType.playstation);
      expect(unit.hourlyPrice, 5000);
      expect(unit.status, UnitStatus.running);
    });

    test('changing a price category reprices its free units and waits for the ones with a session', () {
      final c = makeContainer(units: [
        Unit(id: 'free', name: 'free', type: UnitType.playstation, roomId: 'r1', roomName: 'r', categoryId: 'cat-ps4', status: UnitStatus.free, hourlyPrice: 6000, multiHourlyPrice: 8000),
        Unit(id: 'busy', name: 'busy', type: UnitType.playstation, roomId: 'r1', roomName: 'r', categoryId: 'cat-ps4', status: UnitStatus.running, hourlyPrice: 6000, multiHourlyPrice: 8000),
        Unit(id: 'other', name: 'other', type: UnitType.playstation, roomId: 'r1', roomName: 'r', categoryId: 'cat-vip', status: UnitStatus.free, hourlyPrice: 9000),
      ]);

      c.read(categoriesProvider.notifier).update('cat-ps4', name: 'PS4', hourlyPrice: 7000, multiHourlyPrice: 9000);

      expect(unitOf(c, 'free').hourlyPrice, 7000);
      expect(unitOf(c, 'free').multiHourlyPrice, 9000);
      expect(unitOf(c, 'busy').hourlyPrice, 6000); // the running bill keeps its price
      expect(unitOf(c, 'other').hourlyPrice, 9000);

      c.read(unitsProvider.notifier).free('busy'); // paid: now it takes the new price
      expect(unitOf(c, 'busy').hourlyPrice, 7000);
    });

    test('a category gives the pair price only to the kinds that can have one', () {
      final c = makeContainer(units: [
        Unit(id: 'bil', name: 'bil', type: UnitType.billiards, roomId: 'r1', roomName: 'r', categoryId: 'cat-ps5', status: UnitStatus.free, hourlyPrice: 1),
      ]);

      c.read(categoriesProvider.notifier).update('cat-ps5', name: 'x', hourlyPrice: 5000, multiHourlyPrice: 7000);

      expect(unitOf(c, 'bil').hourlyPrice, 5000);
      expect(unitOf(c, 'bil').multiHourlyPrice, isNull);
    });

    test('a category in use cannot be removed, an unused one can', () {
      final c = makeContainer(units: [
        Unit(id: 'a', name: 'a', type: UnitType.pc, roomId: 'r1', roomName: 'r', categoryId: 'cat-vip', status: UnitStatus.free, hourlyPrice: 9000),
      ]);

      c.read(categoriesProvider.notifier).remove('cat-vip');
      c.read(categoriesProvider.notifier).remove('cat-ps4');

      final ids = c.read(categoriesProvider).map((x) => x.id);
      expect(ids, contains('cat-vip'));
      expect(ids, isNot(contains('cat-ps4')));
    });

    test('moveRoomOnto takes the place of the target: after it going down, before it going up', () {
      final c = makeContainer(units: [unitIn('a', 'r1'), unitIn('b', 'r2'), unitIn('c', 'r3')]);
      List<String> rooms() => c.read(unitsProvider).byRoom.keys.toList();

      c.read(unitsProvider.notifier).moveRoomOnto('r1', 'r2');
      expect(rooms(), ['r2', 'r1', 'r3']);

      c.read(unitsProvider.notifier).moveRoomOnto('r3', 'r2');
      expect(rooms(), ['r3', 'r2', 'r1']);
    });

    test('removeUnit removes a free unit, ignores one with a session, and an emptied room disappears', () {
      final c = makeContainer(units: [
        unitIn('a', 'r1'),
        unitIn('b', 'r2', status: UnitStatus.running),
        unitIn('c', 'r3', status: UnitStatus.waitingPayment),
      ]);
      final notifier = c.read(unitsProvider.notifier);

      notifier.removeUnit('b');
      notifier.removeUnit('c');
      expect(c.read(unitsProvider).length, 3);

      notifier.removeUnit('a');
      expect(c.read(unitsProvider).map((u) => u.id), ['b', 'c']);
      expect(c.read(unitsProvider).byRoom.containsKey('r1'), isFalse);
    });

    test('renameRoom renames every unit in the room and leaves the others', () {
      final c = makeContainer(units: [unitIn('a', 'r1'), unitIn('b', 'r1'), unitIn('c', 'r2')]);

      c.read(unitsProvider.notifier).renameRoom('r1', 'Hall A');

      expect(unitOf(c, 'a').roomName, 'Hall A');
      expect(unitOf(c, 'b').roomName, 'Hall A');
      expect(unitOf(c, 'c').roomName, 'room r2');
    });

    test('byRoom keeps the order of the first unit of each room', () {
      final units = [unitIn('a', 'r2'), unitIn('b', 'r1'), unitIn('c', 'r2')];
      expect(units.byRoom.keys.toList(), ['r2', 'r1']);
      expect(units.byRoom['r2']!.map((u) => u.id), ['a', 'c']);
    });

    test('moveRoom puts a room before another one, or at the end, and keeps its units together', () {
      final c = makeContainer(units: [unitIn('a', 'r1'), unitIn('b', 'r1'), unitIn('c', 'r2'), unitIn('d', 'r3')]);
      final notifier = c.read(unitsProvider.notifier);

      notifier.moveRoom('r1'); // no "before": to the end
      expect(c.read(unitsProvider).byRoom.keys.toList(), ['r2', 'r3', 'r1']);
      expect(c.read(unitsProvider).map((u) => u.id), ['c', 'd', 'a', 'b']);

      notifier.moveRoom('r1', beforeRoomId: 'r2'); // back to the top
      expect(c.read(unitsProvider).byRoom.keys.toList(), ['r1', 'r2', 'r3']);

      notifier.moveRoom('r3', beforeRoomId: 'r3'); // dropped on itself: nothing changes
      expect(c.read(unitsProvider).byRoom.keys.toList(), ['r1', 'r2', 'r3']);
    });

    test('moveUnit puts a unit before another one in the same room', () {
      final c = makeContainer(units: [unitIn('a', 'r1'), unitIn('b', 'r1'), unitIn('c', 'r1'), unitIn('d', 'r2')]);
      final notifier = c.read(unitsProvider.notifier);

      notifier.moveUnit('c', 'r1', beforeUnitId: 'a');
      expect(c.read(unitsProvider).map((u) => u.id), ['c', 'a', 'b', 'd']);

      notifier.moveUnit('c', 'r1'); // no "before": to the end of its room
      expect(c.read(unitsProvider).map((u) => u.id), ['a', 'b', 'c', 'd']);

      notifier.moveUnit('b', 'r1', beforeUnitId: 'b'); // dropped on itself: nothing changes
      expect(c.read(unitsProvider).map((u) => u.id), ['a', 'b', 'c', 'd']);
    });

    test('moveUnit between rooms takes the new room, keeps its session, and an emptied room disappears', () {
      final c = makeContainer(units: [
        unitIn('a', 'r1'),
        unitIn('b', 'r1', status: UnitStatus.running),
        unitIn('d', 'r2'),
      ]);
      final notifier = c.read(unitsProvider.notifier);

      notifier.moveUnit('b', 'r2', beforeUnitId: 'd');
      expect(c.read(unitsProvider).map((u) => u.id), ['a', 'b', 'd']);
      final moved = unitOf(c, 'b');
      expect(moved.roomId, 'r2');
      expect(moved.roomName, 'room r2');
      expect(moved.status, UnitStatus.running); // the session is untouched
      expect(c.read(unitsProvider).byRoom['r2']!.map((u) => u.id), ['b', 'd']);

      notifier.moveUnit('a', 'r2'); // r1's last unit leaves: r1 is gone
      expect(c.read(unitsProvider).byRoom.keys.toList(), ['r2']);
      expect(c.read(unitsProvider).byRoom['r2']!.map((u) => u.id), ['b', 'd', 'a']);
    });
  });
}
