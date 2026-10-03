import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  /// Extend a planned session by [minutes] (from its planned end, or from now if already over).
  /// minutes == null: drop the plan, the session becomes open time. The bill never changes:
  /// it is always the time actually played.
  void addTime(String unitId, int? minutes) {
    final unit = state.byId(unitId);
    _replace(minutes == null
        ? unit.copyWith(makeOpen: true)
        : unit.copyWith(plannedMinutes: unit.plannedMinutesAfterAdding(minutes)));
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

  /// The session is over and paid: the unit is free again. (Called by the bills when a bill is saved.)
  void free(String unitId) => _replace(state.byId(unitId).asFree());

  void _replace(Unit updated) {
    state = [
      for (final unit in state)
        if (unit.id == updated.id) updated else unit,
    ];
  }
}

final unitsProvider = NotifierProvider<UnitsNotifier, List<Unit>>(UnitsNotifier.new);

extension UnitsById on List<Unit> {
  Unit byId(String id) => firstWhere((unit) => unit.id == id);
}
