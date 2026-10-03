import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'categories_provider.dart';
import 'ids.dart';
import 'orders_provider.dart';
import 'price_category.dart';
import 'sample_data.dart';
import 'unit.dart';

/// Where the units come from when the app starts. Sample data for now; local SQLite later.
/// Tests replace it to start from their own units.
final initialUnitsProvider = Provider<List<Unit>>((ref) => buildSampleUnits());

/// The units and what staff do to them: start a session, add time, maintenance.
///
/// The state is an immutable list: a change builds a NEW list, and that is what tells the
/// screens watching it to redraw (like replacing an immutable collection in C#).
class UnitsNotifier extends Notifier<List<Unit>> {
  @override
  List<Unit> build() => ref.watch(initialUnitsProvider);

  /// A free unit starts running now. [plannedMinutes] null = open time.
  void startSession(String unitId, {required bool isMulti, int? plannedMinutes}) {
    _replace(state.byId(unitId).copyWith(
      status: UnitStatus.running,
      startedAt: DateTime.now(),
      isMulti: isMulti,
      plannedMinutes: plannedMinutes,
    ));
  }

  /// Extend a planned session by [minutes] (from its planned end, or from now if already over). On an
  /// open session it sets a time limit: [minutes] from now. minutes == null: drop the plan, the
  /// session becomes open time. The bill never changes:
  /// it is always the time actually played.
  void addTime(String unitId, int? minutes) {
    final unit = state.byId(unitId);
    _replace(minutes == null
        ? unit.copyWith(makeOpen: true)
        : unit.copyWith(plannedMinutes: unit.plannedMinutesAfterAdding(minutes)));
  }

  /// Single <-> pair on a running session. The time so far keeps the old price, the rest takes the
  /// new one. Ignored for a unit without a pair price, or one that is not running.
  void switchMode(String unitId) {
    final unit = state.byId(unitId);
    if (unit.status != UnitStatus.running) return;
    if (!unit.isMulti && !unit.hasMultiMode) return;
    _replace(unit.withModeSwitched(DateTime.now()));
  }

  /// Stops the clock: the price stops growing and the unit waits for payment. Ignored for a unit that
  /// is not running.
  void stopClock(String unitId) {
    final unit = state.byId(unitId);
    if (unit.status != UnitStatus.running) return;
    _replace(unit.asStopped(DateTime.now()));
  }

  /// The customer is back: the clock runs again and the stopped time is not charged.
  void resumeClock(String unitId) {
    final unit = state.byId(unitId);
    if (unit.status != UnitStatus.waitingPayment) return;
    _replace(unit.asResumed(DateTime.now()));
    ref.read(outageProvider.notifier).forget(unitId);
  }

  /// "Stop everything" (the electricity went out): every running time session stops at the same moment.
  /// The units stopped here are remembered, so
  /// [resumeAll] only restarts these and not a customer who was waiting to pay before.
  void stopAll() {
    final now = DateTime.now();
    final stopped = <String>{};
    state = [
      for (final unit in state)
        if (unit.status == UnitStatus.running)
          () {
            stopped.add(unit.id);
            return unit.asStopped(now);
          }()
        else
          unit,
    ];
    ref.read(outageProvider.notifier).set(stopped);
  }

  /// The electricity is back: the units [stopAll] stopped run again, and the time in between is not charged.
  void resumeAll() {
    final now = DateTime.now();
    final ids = ref.read(outageProvider);
    state = [
      for (final unit in state)
        if (ids.contains(unit.id) && unit.status == UnitStatus.waitingPayment) unit.asResumed(now) else unit,
    ];
    ref.read(outageProvider.notifier).set(const {});
  }

  /// Moves a running session to a free unit ("نقل"): the time so far is charged at the old unit's
  /// price, the rest at the new unit's. The start time, the plan and the order lines go along. A pair
  /// session stays a pair session if the new unit has a pair price. The old unit is free again.
  /// Ignored if [fromId] is not running or [toId] is not free.
  void moveSession(String fromId, String toId) {
    final from = state.byId(fromId);
    final to = state.byId(toId);
    if (from.status != UnitStatus.running || to.status != UnitStatus.free) return;
    final now = DateTime.now();
    final moved = to.copyWith(
      status: UnitStatus.running,
      startedAt: from.startedAt,
      originalStart: from.originalStart,
      isMulti: from.isMulti && to.hasMultiMode,
      plannedMinutes: from.plannedMinutes,
      carriedCost: from.costAt(now),
      rateFrom: now,
    );
    state = [
      for (final unit in state)
        if (unit.id == toId) moved else unit,
    ];
    ref.read(ordersProvider.notifier).moveOrders(fromId, toId);
    free(fromId);
  }

  /// Takes a free unit out of service. A unit with a session must be paid first, so
  /// anything but a free unit is ignored.
  void setMaintenance(String unitId, {String? note}) {
    final unit = state.byId(unitId);
    if (unit.status != UnitStatus.free) return;
    _replace(unit.asInMaintenance(note));
  }

  /// Puts a unit in maintenance back to work (free).
  void clearMaintenance(String unitId) {
    final unit = state.byId(unitId);
    if (unit.status != UnitStatus.maintenance) return;
    _replace(unit.asFree());
  }

  /// Adds a free unit to a room that already exists. The room's name is copied from a unit in it.
  void addUnit(
    String roomId, {
    required String name,
    required UnitType type,
    required int hourlyPrice,
    int? multiHourlyPrice,
    String? categoryId,
  }) {
    final inRoom = state.firstWhere((u) => u.roomId == roomId);
    state = [
      ...state,
      Unit(
        id: newId(),
        name: name,
        type: type,
        roomId: roomId,
        roomName: inRoom.roomName,
        categoryId: categoryId,
        status: UnitStatus.free,
        hourlyPrice: hourlyPrice,
        multiHourlyPrice: multiHourlyPrice,
      ),
    ];
  }

  /// Makes a new room with its first unit. A room only exists while it has a unit, so there is
  /// no empty room. It starts at the end of the list.
  void addRoom(
    String roomName, {
    required String unitName,
    required UnitType type,
    required int hourlyPrice,
    int? multiHourlyPrice,
    String? categoryId,
  }) {
    state = [
      ...state,
      Unit(
        id: newId(),
        name: unitName,
        type: type,
        roomId: newId(),
        roomName: roomName,
        categoryId: categoryId,
        status: UnitStatus.free,
        hourlyPrice: hourlyPrice,
        multiHourlyPrice: multiHourlyPrice,
      ),
    ];
  }

  /// Changes a unit's name, type and prices. A unit with a session keeps its type and prices (the
  /// bill is worked out from them) and only the name changes.
  void updateUnit(
    String unitId, {
    required String name,
    required UnitType type,
    required int hourlyPrice,
    int? multiHourlyPrice,
    String? categoryId,
  }) {
    final unit = state.byId(unitId);
    _replace(unit.hasSession
        ? unit.withDetails(
            name: name,
            type: unit.type,
            hourlyPrice: unit.hourlyPrice,
            multiHourlyPrice: unit.multiHourlyPrice,
            categoryId: unit.categoryId,
          )
        : unit.withDetails(
            name: name,
            type: type,
            hourlyPrice: hourlyPrice,
            multiHourlyPrice: multiHourlyPrice,
            categoryId: categoryId,
          ));
  }

  /// Removes a unit. A unit with a session must be paid first, so it is ignored. A room whose
  /// last unit goes disappears with it.
  void removeUnit(String unitId) {
    if (state.byId(unitId).hasSession) return;
    state = [
      for (final unit in state)
        if (unit.id != unitId) unit,
    ];
  }

  /// Renames a room (every unit in it carries the room's name).
  void renameRoom(String roomId, String name) {
    state = [
      for (final unit in state)
        if (unit.roomId == roomId) unit.withRoom(roomId: roomId, roomName: name) else unit,
    ];
  }

  /// Drag and drop: puts a room before the room [beforeRoomId] (null = at the end), with its units
  /// kept together. The order of the list is the order everywhere, so the Floor screen follows it.
  void moveRoom(String roomId, {String? beforeRoomId}) {
    if (roomId == beforeRoomId) return;
    final rooms = state.byRoom;
    final order = rooms.keys.where((id) => id != roomId).toList();
    final at = beforeRoomId == null ? -1 : order.indexOf(beforeRoomId);
    order.insert(at == -1 ? order.length : at, roomId);
    state = [for (final id in order) ...rooms[id]!];
  }

  /// Drag and drop: a room dropped ON another room takes that room's place. Dragged down it lands
  /// after the target, dragged up it lands before it (like any re-sorting list).
  void moveRoomOnto(String roomId, String targetRoomId) {
    if (roomId == targetRoomId) return;
    final rooms = state.byRoom;
    final order = rooms.keys.toList();
    final to = order.indexOf(targetRoomId);
    order.remove(roomId);
    order.insert(to, roomId);
    state = [for (final id in order) ...rooms[id]!];
  }

  /// Drag and drop: puts a unit in [toRoomId], before the unit [beforeUnitId] (null = at the end of
  /// that room). It works inside one room (re-sorting) and between rooms. A room that loses its
  /// last unit disappears. A unit with a session can move too: the bill does not depend on the room.
  void moveUnit(String unitId, String toRoomId, {String? beforeUnitId}) {
    if (unitId == beforeUnitId) return;
    final unit = state.byId(unitId);
    final target = state.firstWhere((u) => u.roomId == toRoomId);
    final moved = unit.withRoom(roomId: toRoomId, roomName: target.roomName);

    final rooms = {
      for (final entry in state.byRoom.entries) entry.key: [...entry.value],
    };
    rooms[unit.roomId]!.removeWhere((u) => u.id == unitId);
    final inTarget = rooms[toRoomId]!;
    final at = beforeUnitId == null ? -1 : inTarget.indexWhere((u) => u.id == beforeUnitId);
    inTarget.insert(at == -1 ? inTarget.length : at, moved);
    state = [
      for (final units in rooms.values) ...units, // an emptied room has no units, so it vanishes
    ];
  }

  /// The session is over and paid: the unit is free again. (Called by the bills when a bill is saved.)
  /// The unit also takes its category's current prices (they may have changed during the session).
  void free(String unitId) {
    ref.read(outageProvider.notifier).forget(unitId);
    final unit = state.byId(unitId).asFree();
    final category = ref.read(categoriesProvider).where((c) => c.id == unit.categoryId).firstOrNull;
    _replace(category == null ? unit : unit.withCategory(category));
  }

  /// A category's prices changed: every device in it without a session takes them.
  void applyCategory(PriceCategory category) {
    state = [
      for (final unit in state)
        if (unit.categoryId == category.id && !unit.hasSession) unit.withCategory(category) else unit,
    ];
  }

  void _replace(Unit updated) {
    state = [
      for (final unit in state)
        if (unit.id == updated.id) updated else unit,
    ];
  }
}

final unitsProvider = NotifierProvider<UnitsNotifier, List<Unit>>(UnitsNotifier.new);

/// The units stopped by "stop everything" (empty = no power cut going on). The Floor header shows
/// "resume all" instead of "stop all" while it is not empty.
class OutageNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void set(Set<String> ids) => state = ids;

  /// A unit left the outage on its own (resumed by hand, or paid).
  void forget(String unitId) {
    if (state.contains(unitId)) state = {...state}..remove(unitId);
  }
}

final outageProvider = NotifierProvider<OutageNotifier, Set<String>>(OutageNotifier.new);

extension UnitsById on List<Unit> {
  Unit byId(String id) => firstWhere((unit) => unit.id == id);
}

/// The rooms, worked out from the units (there is no separate room table yet).
extension UnitsByRoom on List<Unit> {
  /// Units per room, keeping the original order.
  Map<String, List<Unit>> get byRoom {
    final rooms = <String, List<Unit>>{};
    for (final unit in this) {
      rooms.putIfAbsent(unit.roomId, () => []).add(unit);
    }
    return rooms;
  }
}
