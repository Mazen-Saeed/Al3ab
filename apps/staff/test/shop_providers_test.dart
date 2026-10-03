import 'package:al3b_staff/data/bill.dart';
import 'package:al3b_staff/data/bills_provider.dart';
import 'package:al3b_staff/data/catalog_provider.dart';
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

    test('a product can have a cost price, change it, and clear it', () {
      final c = makeContainer();
      final catalog = c.read(catalogProvider.notifier);

      catalog.addProduct('كولا', 1200, costPrice: 850); // sells for 12, costs 8.50
      final id = c.read(catalogProvider).products.single.id;
      expect(c.read(catalogProvider).products.single.costPrice, 850);

      catalog.updateProduct(id, name: 'كولا', price: 1200, costPrice: 900);
      expect(c.read(catalogProvider).products.single.costPrice, 900);

      catalog.updateProduct(id, name: 'كولا', price: 1200); // no cost price: cleared
      expect(c.read(catalogProvider).products.single.costPrice, isNull);
    });

    test('a product without a cost price has none by default', () {
      final c = makeContainer();
      c.read(catalogProvider.notifier).addProduct('كولا', 1200);
      expect(c.read(catalogProvider).products.single.costPrice, isNull);
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

    test('a shopping trip adds every item and saves one total', () {
      final c = stockContainer();
      c.read(catalogProvider.notifier).recordPurchase({'s-tea': 10, 's-pepsi': 6}, total: 48000);

      expect(onHand(c, 's-tea'), 13);
      expect(onHand(c, 's-pepsi'), 30);
      final trip = c.read(catalogProvider).purchases.single;
      expect(trip.total, 48000);
      expect(c.read(catalogProvider).movements.map((m) => (m.kind, m.quantity, m.purchaseId)).toList(), [
        (StockMovementKind.purchase, 10, trip.id),
        (StockMovementKind.purchase, 6, trip.id),
      ]);
    });

    test('a shopping trip with nothing picked, or an unknown item, saves nothing', () {
      final c = stockContainer();
      c.read(catalogProvider.notifier).recordPurchase({'s-tea': 0}, total: 5000);
      c.read(catalogProvider.notifier).recordPurchase({'nope': 3}, total: 5000);
      expect(c.read(catalogProvider).purchases, isEmpty);
      expect(c.read(catalogProvider).movements, isEmpty);
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

      c.read(catalogProvider.notifier).recordPurchase({id: 4}, total: 4000);
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
}
