import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/clock_provider.dart';
import '../data/unit.dart';
import '../data/units_provider.dart';
import '../l10n/l10n.dart';
import '../shell/layout.dart';
import 'floor_sections.dart';
import 'floor_widgets.dart';
import 'session_panel.dart';
import 'set_maintenance.dart';
import 'start_session.dart';

/// The Floor screen (home): all units in sections, with the selected unit's panel
/// next to them on wide screens (a bottom sheet on smaller ones).
/// How units are grouped lives in floor_sections.dart; the data and the actions in units_provider.dart.
class FloorScreen extends ConsumerStatefulWidget {
  const FloorScreen({super.key});

  @override
  ConsumerState<FloorScreen> createState() => _FloorScreenState();
}

class _FloorScreenState extends ConsumerState<FloorScreen> {
  bool _byType = false; // the toggle: false = by place, true = by type
  String? _selectedId; // which unit the side panel shows; null = none, panel hidden

  @override
  Widget build(BuildContext context) {
    // Watching redraws this screen: every second (the clock, so timers move) and after any change
    // to the units (start, add time).
    ref.watch(clockProvider);
    final units = ref.watch(unitsProvider);
    final l10n = context.l10n;
    final isWide = screenSizeOf(context) == ScreenSize.wide;
    final selected = units.where((u) => u.id == _selectedId).firstOrNull; // null if none, or the unit was removed
    // The panel is for units with something to show. A free unit has nothing: tapping
    // it opens the start form instead.
    final showPanel = isWide && selected != null && selected.status != UnitStatus.free;
    final sections = buildFloorSections(units, l10n, byType: _byType);

    final running = units.where((u) => u.status == UnitStatus.running).length;
    final free = units.where((u) => u.status == UnitStatus.free).length;

    // The middle part (header, toggle, sections) is the same on every screen size.
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FloorHeader(running: running, free: free),
        const SizedBox(height: 16),
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: false, label: Text(l10n.viewByPlace)),
            ButtonSegment(value: true, label: Text(l10n.viewByType)),
          ],
          selected: {_byType},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => setState(() => _byType = selection.first),
        ),
        const SizedBox(height: 16),
        Expanded(
          // Only this part scrolls; header, nav and panel stay in place.
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final section in sections)
                  SectionView(
                    section: section,
                    selectedId: _selectedId,
                    onSelect: (unit) => _select(unit, openSheet: !isWide),
                  ),
              ],
            ),
          ),
        ),
      ],
    );

    if (!showPanel) return content; // no panel: the grid takes the full width

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch, // panel is full height
      children: [
        Expanded(child: content), // Expanded = "take all the width that's left"
        const SizedBox(width: 20),
        SessionPanel(
          unitId: selected.id,
          width: 340,
          onClose: () => setState(() => _selectedId = null),
          onMoved: (newId) => setState(() => _selectedId = newId), // follow the session
        ),
      ],
    );
  }

  /// Tap on a tile. Free unit: open the start form. Otherwise select it, and on smaller
  /// screens also open its panel in a bottom sheet.
  Future<void> _select(Unit unit, {required bool openSheet}) async {
    final units = ref.read(unitsProvider.notifier); // before the first await: ref is not safe once the screen is gone
    if (unit.status == UnitStatus.free) {
      final result = await showStartSession(context, unit);
      // null = closed without starting. `mounted` = this screen still exists after the wait.
      // result.customerText is ignored until the database exists.
      if (result == null || !mounted) return;
      if (result.wantsMaintenance) {
        final maintenance = await showSetMaintenance(context, unit);
        if (maintenance != null) units.setMaintenance(unit.id, note: maintenance.note);
      } else {
        units.startSession(unit.id, isMulti: result.isMulti, plannedMinutes: result.plannedMinutes);
      }
      return;
    }

    setState(() => _selectedId = unit.id);
    if (!openSheet) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true, // allow a taller sheet than the default half screen
      backgroundColor: Colors.transparent, // the panel draws its own rounded background
      builder: (context) => Padding(
        padding: const EdgeInsetsDirectional.all(12),
        child: SizedBox(
          width: double.infinity, // fill the sheet's width, whatever the content is
          // 620 on tall screens, but never taller than 85% of a short one.
          height: math.min(620, MediaQuery.sizeOf(context).height * 0.85),
          child: SessionPanel(
            unitId: unit.id,
            onClose: () => Navigator.pop(context), // closes the sheet
            onMoved: (_) => Navigator.pop(context), // the session left this unit: close the sheet
          ),
        ),
      ),
    ).whenComplete(() {
      // Sheet closed (X, swipe down, tap outside): clear the highlight ring on the tile.
      if (mounted) setState(() => _selectedId = null);
    });
  }
}
