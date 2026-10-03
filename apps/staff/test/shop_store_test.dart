import 'package:al3b_staff/data/bill.dart';
import 'package:al3b_staff/data/product.dart';
import 'package:al3b_staff/data/shop_store.dart';
import 'package:al3b_staff/data/stock.dart';
import 'package:al3b_staff/data/unit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  test('startSession makes the unit run with the chosen mode and plan, and notifies', () {
    final store = ShopStore([testUnit(multi: 70)], tick: false);
    var notified = 0;
    store.addListener(() => notified++);

    store.startSession('u1', isMulti: true, plannedMinutes: 120);

    final unit = store.unitById('u1');
    expect(unit.status, UnitStatus.running);
    expect(unit.isMulti, isTrue);
    expect(unit.plannedMinutes, 120);
    expect(unit.startedAt, isNotNull);
    expect(notified, 1);
  });

  test('startSession without a plan is open time', () {
    final store = ShopStore([testUnit()], tick: false);
    store.startSession('u1', isMulti: false);
    expect(store.unitById('u1').plannedMinutes, isNull);
  });

  test('addTime extends a planned session', () {
    final store = ShopStore(
      [testUnit(status: UnitStatus.running, planned: 60, startedAt: ago(const Duration(minutes: 10)))],
      tick: false,
    );
    store.addTime('u1', 30);
    expect(store.unitById('u1').plannedMinutes, 90);
  });

  test('addTime with null switches the session to open time', () {
    final store = ShopStore(
      [testUnit(status: UnitStatus.running, planned: 60, startedAt: ago(const Duration(minutes: 10)))],
      tick: false,
    );
    store.addTime('u1', null);
    expect(store.unitById('u1').plannedMinutes, isNull);
  });

  test('changing one unit leaves the others alone', () {
    final store = ShopStore([testUnit(id: 'a'), testUnit(id: 'b')], tick: false);
    store.startSession('a', isMulti: false);
    expect(store.unitById('a').status, UnitStatus.running);
    expect(store.unitById('b').status, UnitStatus.free);
  });

  group('orders', () {
    const pepsi = Product(id: 'pepsi', name: 'بيبسي', price: 15);
    const tea = Product(id: 'tea', name: 'شاي', price: 10);
    ShopStore makeStore() => ShopStore([testUnit()], products: [pepsi, tea], tick: false);

    test('addOrder adds lines and ordersTotal sums them', () {
      final store = makeStore();
      store.addOrder('u1', {'pepsi': 2, 'tea': 1});
      expect(store.ordersFor('u1').length, 2);
      expect(store.ordersTotal('u1'), 40);
    });

    test('ordering the same product again raises its quantity', () {
      final store = makeStore();
      store.addOrder('u1', {'pepsi': 1});
      store.addOrder('u1', {'pepsi': 2});
      expect(store.ordersFor('u1').single.quantity, 3);
    });

    test('removeOrderLine takes the whole line off', () {
      final store = makeStore();
      store.addOrder('u1', {'pepsi': 2, 'tea': 1});
      store.removeOrderLine('u1', 'pepsi');
      expect(store.ordersFor('u1').map((l) => l.productId), ['tea']);
    });

    test('a unit without orders has an empty bill', () {
      expect(makeStore().ordersTotal('u1'), 0);
    });
  });

  group('endAndPay', () {
    final start = DateTime(2026, 1, 1, 10);
    final oneHourLater = start.add(const Duration(hours: 1));
    const pepsi = Product(id: 'pepsi', name: 'بيبسي', price: 15);

    // A unit running since 10:00 at 50 EGP/hour, with 2 Pepsi ordered: bill = 50 + 30.
    ShopStore makeStore() {
      final store = ShopStore(
        [testUnit(status: UnitStatus.running, startedAt: start, planned: 60)],
        products: [pepsi],
        tick: false,
      );
      store.addOrder('u1', {'pepsi': 2});
      return store;
    }

    test('saves the bill, clears the orders and frees the unit', () {
      final store = makeStore();
      final bill = store.endAndPay('u1', endedAt: oneHourLater, method: PaymentMethod.cash);

      expect(bill.playCost, 50);
      expect(bill.ordersTotal, 30);
      expect(bill.total, 80);
      expect(store.bills.single, same(bill));
      expect(store.ordersFor('u1'), isEmpty);

      final unit = store.unitById('u1');
      expect(unit.status, UnitStatus.free);
      expect(unit.startedAt, isNull);
      expect(unit.plannedMinutes, isNull);
    });

    test('a discount is taken off the total and kept with its reason', () {
      final bill = makeStore().endAndPay(
        'u1',
        endedAt: oneHourLater,
        discount: 10,
        discountReason: 'زبون دايم',
        method: PaymentMethod.instapay,
      );
      expect(bill.total, 70);
      expect(bill.discountReason, 'زبون دايم');
      expect(bill.method, PaymentMethod.instapay);
    });

    test('a discount can never be more than the subtotal', () {
      final bill = makeStore().endAndPay('u1', endedAt: oneHourLater, discount: 500, method: PaymentMethod.cash);
      expect(bill.discount, 80);
      expect(bill.total, 0);
    });

    test('other units are not touched', () {
      final store = ShopStore(
        [testUnit(id: 'a', status: UnitStatus.running, startedAt: start), testUnit(id: 'b', status: UnitStatus.running, startedAt: start)],
        tick: false,
      );
      store.endAndPay('a', endedAt: oneHourLater, method: PaymentMethod.cash);
      expect(store.unitById('b').status, UnitStatus.running);
    });
  });

  group('maintenance', () {
    test('a free unit goes into maintenance with its note, and back to free', () {
      final store = ShopStore([testUnit()], tick: false);
      store.setMaintenance('u1', note: 'الدراع بايظ');
      expect(store.unitById('u1').status, UnitStatus.maintenance);
      expect(store.unitById('u1').note, 'الدراع بايظ');

      store.clearMaintenance('u1');
      expect(store.unitById('u1').status, UnitStatus.free);
      expect(store.unitById('u1').note, isNull);
    });

    test('a running unit can not be put in maintenance', () {
      final store = ShopStore(
        [testUnit(status: UnitStatus.running, startedAt: ago(const Duration(minutes: 5)))],
        tick: false,
      );
      store.setMaintenance('u1');
      expect(store.unitById('u1').status, UnitStatus.running);
    });
  });

  group('products', () {
    test('add, update and delete change the menu and notify', () {
      final store = ShopStore([testUnit()], tick: false);
      var notified = 0;
      store.addListener(() => notified++);

      store.addProduct('كولا', 12);
      final id = store.products.single.id;
      expect(store.products.single.name, 'كولا');

      store.updateProduct(id, name: 'كولا كبيرة', price: 20);
      expect(store.products.single.price, 20);

      store.deleteProduct(id);
      expect(store.products, isEmpty);
      expect(notified, 3);
    });

    test('a bill keeps its lines after the product is deleted', () {
      final store = ShopStore(
        [testUnit(status: UnitStatus.running, startedAt: ago(const Duration(minutes: 5)))],
        products: [const Product(id: 'a', name: 'شاي', price: 10)],
        tick: false,
      );
      store.addOrder('u1', {'a': 2});
      store.deleteProduct('a');
      expect(store.ordersFor('u1').single.name, 'شاي');
      expect(store.ordersTotal('u1'), 20);
    });
  });

  group('stock', () {
    // Pepsi: subtracted on every sale. Tea: counted in packets, staff record by hand.
    ShopStore stockStore() => ShopStore(
          [testUnit(status: UnitStatus.running, startedAt: ago(const Duration(minutes: 5)))],
          products: [
            const Product(id: 'pepsi', name: 'بيبسي', price: 15, stockItemId: 's-pepsi'),
            const Product(id: 'tea', name: 'شاي', price: 10, stockItemId: 's-tea'),
          ],
          stockItems: [
            const StockItem(id: 's-pepsi', name: 'بيبسي', deductsOnSale: true, onHand: 24),
            const StockItem(id: 's-tea', name: 'شاي', deductsOnSale: false, onHand: 3),
          ],
          tick: false,
        );

    int onHand(ShopStore store, String id) => store.stockItems.firstWhere((s) => s.id == id).onHand;

    test('an order subtracts from an item that deducts on sale', () {
      final store = stockStore();
      store.addOrder('u1', {'pepsi': 2});
      expect(onHand(store, 's-pepsi'), 22);
    });

    test('an order of a hand-counted item subtracts nothing', () {
      final store = stockStore();
      store.addOrder('u1', {'tea': 5});
      expect(onHand(store, 's-tea'), 3);
    });

    test('removing an order line gives the stock back', () {
      final store = stockStore();
      store.addOrder('u1', {'pepsi': 2});
      store.removeOrderLine('u1', 'pepsi');
      expect(onHand(store, 's-pepsi'), 24);
    });

    test('selling more than is on hand is allowed and goes below 0', () {
      final store = stockStore();
      store.addOrder('u1', {'pepsi': 30});
      expect(onHand(store, 's-pepsi'), -6);
    });

    test('a shopping trip adds every item and saves one total', () {
      final store = stockStore();
      store.recordPurchase({'s-tea': 10, 's-pepsi': 6}, total: 480);

      expect(onHand(store, 's-tea'), 13);
      expect(onHand(store, 's-pepsi'), 30);
      final trip = store.purchases.single;
      expect(trip.total, 480);
      expect(store.stockMovements.map((m) => (m.kind, m.quantity, m.purchaseId)).toList(), [
        (StockMovementKind.purchase, 10, trip.id),
        (StockMovementKind.purchase, 6, trip.id),
      ]);
    });

    test('a shopping trip with nothing picked, or an unknown item, saves nothing', () {
      final store = stockStore();
      store.recordPurchase({'s-tea': 0}, total: 50);
      store.recordPurchase({'nope': 3}, total: 50);
      expect(store.purchases, isEmpty);
      expect(store.stockMovements, isEmpty);
    });

    test('opening a tin takes one off and writes the log', () {
      final store = stockStore();
      store.recordOpened('s-tea');
      expect(onHand(store, 's-tea'), 2);
      expect(store.stockMovements.single.kind, StockMovementKind.opened);
    });

    test('a count replaces the number and keeps what the app expected and the reason', () {
      final store = stockStore();
      store.recordCount('s-pepsi', 20, note: '  وقعت وانكسرت ');
      expect(onHand(store, 's-pepsi'), 20);

      final entry = store.stockMovements.single;
      expect(entry.kind, StockMovementKind.count);
      expect(entry.quantity, 20);
      expect(entry.expected, 24); // 20 found against 24 expected: 4 missing
      expect(entry.note, 'وقعت وانكسرت');
    });

    test('a count without a reason has no note', () {
      final store = stockStore();
      store.recordCount('s-tea', 3, note: '   ');
      expect(store.stockMovements.single.note, isNull);
    });

    test('a count of 0 is allowed; a negative count is ignored', () {
      final store = stockStore();
      store.recordCount('s-tea', 0);
      expect(onHand(store, 's-tea'), 0);
      store.recordCount('s-tea', -1);
      expect(store.stockMovements.length, 1);
    });

    test('isLow is true at or below the level, never without one', () {
      const item = StockItem(id: 'x', name: 'x', deductsOnSale: true, onHand: 6, lowStockAt: 6);
      expect(item.isLow, isTrue);
      expect(item.withOnHand(7).isLow, isFalse);
      expect(const StockItem(id: 'y', name: 'y', deductsOnSale: true).isLow, isFalse);
    });

    test('editing a product keeps its stock item', () {
      final store = stockStore();
      store.updateProduct('pepsi', name: 'بيبسي كبير', price: 20);
      expect(store.products.firstWhere((p) => p.id == 'pepsi').stockItemId, 's-pepsi');
    });

    test('startTracking creates a stock item named like the product, with the first count', () {
      final store = ShopStore([testUnit()], products: [const Product(id: 'c', name: 'كولا', price: 12)], tick: false);
      store.startTracking('c', deductsOnSale: true, lowStockAt: 2, count: 5);

      final item = store.stockItemOf(store.products.single)!;
      expect(item.name, 'كولا');
      expect(item.deductsOnSale, isTrue);
      expect(item.onHand, 5);
      expect(item.lowStockAt, 2);
      expect(store.stockMovements.single.kind, StockMovementKind.count);
    });

    test('a product starts uncounted, and counting it takes it off the untracked list', () {
      final store = ShopStore([testUnit()], tick: false);
      store.addProduct('خدمة', 5);
      expect(store.products.single.stockItemId, isNull);
      expect(store.untrackedProducts.length, 1);

      store.startTracking(store.products.single.id, deductsOnSale: true);
      expect(store.untrackedProducts, isEmpty);
    });

    test('startTracking on a product that is already counted does nothing', () {
      final store = stockStore();
      store.startTracking('pepsi', deductsOnSale: false, count: 99);
      expect(store.stockItems.length, 2);
      expect(onHand(store, 's-pepsi'), 24);
    });

    test('updateStockItem changes how it is counted and keeps the number', () {
      final store = stockStore();
      store.updateStockItem('s-pepsi', deductsOnSale: false, lowStockAt: 3);
      final item = store.stockItems.firstWhere((s) => s.id == 's-pepsi');
      expect(item.deductsOnSale, isFalse);
      expect(item.lowStockAt, 3);
      expect(item.onHand, 24);
    });

    test('stopTracking removes the item and its log; the product stays, uncounted', () {
      final store = stockStore();
      store.recordOpened('s-pepsi');
      store.stopTracking('s-pepsi');

      expect(store.stockItems.map((s) => s.id), ['s-tea']);
      expect(store.stockMovements, isEmpty);
      expect(store.products.firstWhere((p) => p.id == 'pepsi').stockItemId, isNull);
      store.addOrder('u1', {'pepsi': 1}); // must not crash
    });

    test('deleting a product removes its stock item', () {
      final store = stockStore();
      store.deleteProduct('pepsi');
      expect(store.stockItems.map((s) => s.id), ['s-tea']);
    });

    test('renaming a product renames its stock item', () {
      final store = stockStore();
      store.updateProduct('pepsi', name: 'بيبسي كبير', price: 15);
      expect(store.stockItems.firstWhere((s) => s.id == 's-pepsi').name, 'بيبسي كبير');
    });

    test('an internal item has no product and is always counted by hand', () {
      final store = stockStore();
      store.addInternalItem('سكر', lowStockAt: 2, count: 6);

      final sugar = store.stockItems.last;
      expect(sugar.name, 'سكر');
      expect(sugar.deductsOnSale, isFalse);
      expect(sugar.onHand, 6);
      expect(store.isInternal(sugar), isTrue);
      expect(store.isInternal(store.stockItems.first), isFalse); // Pepsi has a product
    });

    test('an internal item can be bought, renamed and removed', () {
      final store = stockStore();
      store.addInternalItem('سكر');
      final id = store.stockItems.last.id;

      store.recordPurchase({id: 4}, total: 40);
      expect(onHand(store, id), 4);

      store.updateStockItem(id, name: 'سكر ناعم', deductsOnSale: false, lowStockAt: 1);
      expect(store.stockItems.last.name, 'سكر ناعم');

      store.stopTracking(id);
      expect(store.stockItems.any((s) => s.id == id), isFalse);
    });
  });
}
