import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/sample_data.dart';
import '../data/unit.dart';
import '../l10n/l10n.dart';
import 'floor_sections.dart';
import 'unit_tile.dart';

/// Top of the Floor screen: venue name + summary, then status chips and quick sale.
class FloorHeader extends StatelessWidget {
  const FloorHeader({super.key, required this.running, required this.free});

  final int running;
  final int free;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Wrap = a Row that moves items to the next line when they don't fit.
    return Wrap(
      spacing: 10, // horizontal gap
      runSpacing: 12, // vertical gap between lines
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(sampleVenueName, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
              Text(l10n.floorSummary(running, free), style: AppText.label),
            ],
          ),
        ),
        // Connection: show nothing while online; a warning only when offline.
        if (!sampleIsOnline)
          _HeaderChip(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: AppColors.waitingPayment, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(l10n.statusOffline),
            ],
          ),
        FilledButton.tonalIcon(
          onPressed: () {}, // TODO: open quick sale
          icon: const Icon(Icons.add, size: 20),
          label: Text(l10n.navQuickSale),
        ),
      ],
    );
  }
}

/// A rounded pill used for status info in the header.
class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

/// Draws one section: its title, then each block (optional heading + grid).
class SectionView extends StatelessWidget {
  const SectionView({super.key, required this.section, required this.selectedId, required this.onSelect});

  final FloorSection section;
  final String? selectedId; // null = nothing selected
  final ValueChanged<Unit> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.title, style: AppText.sectionTitle),
          const SizedBox(height: 10),
          for (final block in section.blocks) ...[
            if (block.heading != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 4, bottom: 8),
                child: Text(
                  block.heading!,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            UnitGrid(
              units: block.units,
              showRoomNames: block.showRoomNames,
              selectedId: selectedId,
              onSelect: onSelect,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

/// Tiles in a grid whose column count adapts to the available width.
class UnitGrid extends StatelessWidget {
  const UnitGrid({
    super.key,
    required this.units,
    required this.showRoomNames,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Unit> units;
  final bool showRoomNames;
  final String? selectedId; // null = nothing selected
  final ValueChanged<Unit> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      // The grid lives inside the page's scroll view, so it must not scroll
      // by itself and must take only the height its tiles need.
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240, // a tile is at most 240 wide -> more columns on wider screens
        mainAxisExtent: 150, // every tile is 150 tall
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: units.length,
      itemBuilder: (context, index) {
        final unit = units[index];
        return UnitTile(
          unit: unit,
          title: showRoomNames ? unit.roomName : null,
          selected: unit.id == selectedId,
          onTap: () => onSelect(unit),
        );
      },
    );
  }
}
