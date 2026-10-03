import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/shop_store.dart';
import '../data/unit.dart';
import '../l10n/l10n.dart';
import '../shell/layout.dart';
import 'floor_sections.dart';
import 'floor_widgets.dart';
import 'session_panel.dart';
import 'set_maintenance.dart';
import 'start_session.dart';

/// The Floor screen (home): all units in sections, with the selected unit's panel
/// next to them on wide screens (a bottom sheet on smaller ones).
/// How units are grouped lives in floor_sections.dart; the data and the actions in ShopStore.
class FloorScreen extends StatefulWidget {
  const FloorScreen({super.key, required this.store});

  final ShopStore store;

  @override
  State<FloorScreen> createState() => _FloorScreenState();
}

class _FloorScreenState extends State<FloorScreen> {
  bool _byType = false; // the toggle: false = by place, true = by type
  String? _selectedId; // which unit the side panel shows; null = none, panel hidden

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder redraws this part whenever the store notifies:
    // every second (timers) and after any change (start, add time).
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final l10n = context.l10n;
        final units = widget.store.units;
        final isWide = screenSizeOf(context) == ScreenSize.wide;
        final selected = _selectedId == null ? null : widget.store.unitById(_selectedId!);
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
              store: widget.store,
              unitId: selected.id,
              width: 340,
              onClose: () => setState(() => _selectedId = null),
            ),
          ],
        );
      },
    );
  }

  /// Tap on a tile. Free unit: open the start form. Otherwise select it, and on smaller
  /// screens also open its panel in a bottom sheet.
  Future<void> _select(Unit unit, {required bool openSheet}) async {
    if (unit.status == UnitStatus.free) {
      final result = await showStartSession(context, unit);
      // null = closed without starting. `mounted` = this screen still exists after the wait.
      // result.customerText is ignored until the database exists.
      if (result == null || !mounted) return;
      if (result.wantsMaintenance) {
        final maintenance = await showSetMaintenance(context, unit);
        if (maintenance != null) widget.store.setMaintenance(unit.id, note: maintenance.note);
      } else {
        widget.store.startSession(unit.id, isMulti: result.isMulti, plannedMinutes: result.plannedMinutes);
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
            store: widget.store,
            unitId: unit.id,
            onClose: () => Navigator.pop(context), // closes the sheet
          ),
        ),
      ),
    ).whenComplete(() {
      // Sheet closed (X, swipe down, tap outside): clear the highlight ring on the tile.
      if (mounted) setState(() => _selectedId = null);
    });
  }
}
