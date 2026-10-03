import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/clock_provider.dart';
import '../data/unit.dart';
import '../data/units_provider.dart';
import '../l10n/l10n.dart';
import 'notice_board.dart';

/// Warns staff when a planned session has 10 minutes left, 1 minute left, and when time is up.
///
/// It sits above every page (see main.dart), so alerts keep working whatever page is open.
/// It checks every second (the clock) and whenever the units change (adding time re-arms the alerts).
class SessionAlerts extends ConsumerStatefulWidget {
  const SessionAlerts({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SessionAlerts> createState() => _SessionAlertsState();
}

class _SessionAlertsState extends ConsumerState<SessionAlerts> {
  static const _thresholds = [Duration(minutes: 10), Duration(minutes: 1), Duration.zero];

  /// Alerts already handled, so each one fires only once. Key = unit + session start +
  /// planned length + threshold, so adding time to a session re-arms its alerts.
  final _alerted = <String>{};

  @override
  void initState() {
    super.initState();
    // Thresholds already crossed when the app opens are marked as done without a banner:
    // the tile is red anyway, and an old alert is just noise.
    _check(announce: false);
  }

  void _check({required bool announce}) {
    for (final unit in ref.read(unitsProvider)) {
      final remaining = unit.remaining;
      if (unit.status != UnitStatus.running || remaining == null) continue;

      Duration? smallest;
      for (final threshold in _thresholds) {
        if (remaining > threshold) continue; // not reached yet
        final start = (unit.originalStart ?? unit.startedAt!).millisecondsSinceEpoch; // a resume does not change it
        final key = '${unit.id}:$start:${unit.plannedMinutes}:${threshold.inSeconds}';
        // Set.add returns true only if the key was new. So this is "first time we see it".
        if (_alerted.add(key)) smallest = threshold;
      }
      // If several were crossed at once, only the smallest one is shown.
      if (announce && smallest != null) _announce(unit, smallest);
    }
  }

  void _announce(Unit unit, Duration threshold) {
    final l10n = context.l10n;
    final board = ref.read(noticeBoardProvider.notifier);
    switch (threshold.inMinutes) {
      case 10:
        board.show(NoticeKind.endingSoon, l10n.alertTenMinutes(unit.name), autoHide: const Duration(seconds: 10));
      case 1:
        board.show(NoticeKind.lastMinute, l10n.alertOneMinute(unit.name), autoHide: const Duration(seconds: 15));
      default:
        // Time is up: stays until staff close it.
        board.show(NoticeKind.timeUp, l10n.alertTimeUp(unit.name));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check on every clock tick and on every change to the units.
    ref.listen(clockProvider, (previous, next) => _check(announce: true));
    ref.listen(unitsProvider, (previous, next) => _check(announce: true));
    return widget.child;
  }
}
