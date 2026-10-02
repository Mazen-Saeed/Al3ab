import 'package:al3b_staff/data/shop_store.dart';
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
}
