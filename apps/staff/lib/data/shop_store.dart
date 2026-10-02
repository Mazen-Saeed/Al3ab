import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'unit.dart';

/// The shop's live data (for now: the units) and the actions that change it.
///
/// Screens read from it and call its methods; they never edit units themselves.
/// It is a ChangeNotifier: every change (and every clock tick) tells the screens
/// listening to it to redraw. Today the data is in memory; when SQLite arrives,
/// only this class changes, the screens stay the same.
class ShopStore extends ChangeNotifier {
  /// [tick]: also notify once a second, so running timers move. Tests turn it off.
  ShopStore(List<Unit> units, {bool tick = true}) : _units = List.of(units) {
    if (tick) _clock = Timer.periodic(const Duration(seconds: 1), (_) => notifyListeners());
  }

  final List<Unit> _units;
  Timer? _clock;

  /// Read-only view of the units (no copy).
  UnmodifiableListView<Unit> get units => UnmodifiableListView(_units);

  Unit unitById(String id) => _units.firstWhere((u) => u.id == id);

  /// A free unit starts running now. [plannedMinutes] null = open time.
  void startSession(String unitId, {required bool isMulti, int? plannedMinutes}) {
    _replace(unitById(unitId).copyWith(
      status: UnitStatus.running,
      startedAt: DateTime.now(),
      isMulti: isMulti,
      plannedMinutes: plannedMinutes,
    ));
  }

  /// Extend a planned session by [minutes] (from its planned end, or from now if already over).
  /// minutes == null: drop the plan, the session becomes open time. The bill never changes:
  /// it is always the time actually played.
  void addTime(String unitId, int? minutes) {
    final unit = unitById(unitId);
    _replace(minutes == null
        ? unit.copyWith(makeOpen: true)
        : unit.copyWith(plannedMinutes: unit.plannedMinutesAfterAdding(minutes)));
  }

  void _replace(Unit updated) {
    final index = _units.indexWhere((u) => u.id == updated.id);
    _units[index] = updated;
    notifyListeners();
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }
}
