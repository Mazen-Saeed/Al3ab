import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../l10n/l10n.dart';
import 'unit.dart';
import 'unit_tile.dart';

/// The Floor screen (home): all units in sections.
///
/// A room with 2+ units is a shared hall; a room with exactly one unit is a
/// private room. Two views, switched with the toggle in the top bar:
/// - By place: one section per owner-made group (each hall keeps its own block)
///   or per ungrouped room. Private rooms are gathered per type ("غرف البلايستيشن
///   المميزة") and placed right after the shared sections of that type.
/// - By type: one section per type, split into "shared" and "private" blocks.
class FloorScreen extends StatefulWidget {
  const FloorScreen({super.key});

  @override
  State<FloorScreen> createState() => _FloorScreenState();
}

class _FloorScreenState extends State<FloorScreen> {
  bool _byType = false; // the toggle: false = by place, true = by type

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final units = buildSampleUnits();
    final sections = _byType ? _sectionsByType(units, l10n) : _sectionsByPlace(units, l10n);

    final running = units.where((u) => u.status == UnitStatus.running).length;
    final free = units.where((u) => u.status == UnitStatus.free).length;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        centerTitle: false,
        // Title: the venue's name + a live summary, instead of a generic word.
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sampleVenueName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            Text(
              l10n.floorSummary(running, free),
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 20),
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(l10n.viewByPlace)),
                ButtonSegment(value: true, label: Text(l10n.viewByType)),
              ],
              selected: {_byType},
              showSelectedIcon: false,
              // Tapping a segment changes the state and redraws the screen.
              onSelectionChanged: (selection) => setState(() => _byType = selection.first),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final section in sections) _SectionView(section: section),
          ],
        ),
      ),
    );
  }

  /// Units per room, keeping the original order.
  Map<String, List<Unit>> _groupByRoom(List<Unit> units) {
    final byRoom = <String, List<Unit>>{};
    for (final unit in units) {
      byRoom.putIfAbsent(unit.roomId, () => []).add(unit);
    }
    return byRoom;
  }

  String _typeName(UnitType type, AppLocalizations l10n) => switch (type) {
        UnitType.playstation => l10n.typePlayStation,
        UnitType.pingPong => l10n.typePingPong,
        UnitType.billiards => l10n.typeBilliards,
      };

  /// By place.
  List<_Section> _sectionsByPlace(List<Unit> units, AppLocalizations l10n) {
    // 1. Shared rooms go into their group's section (one block per room, so halls
    //    never mix) or into their own section if they have no group.
    //    Private rooms are collected per type.
    final shared = <String, _Section>{}; // keyed by group id or room id, keeps order
    final privateByType = <UnitType, List<Unit>>{};

    for (final room in _groupByRoom(units).values) {
      final first = room.first;
      if (room.length == 1) {
        privateByType.putIfAbsent(first.type, () => []).add(first);
      } else if (first.groupId != null) {
        shared
            .putIfAbsent(first.groupId!, () => _Section(title: first.groupName!, blocks: []))
            .blocks
            .add(_Block(heading: first.roomName, units: room));
      } else {
        shared[first.roomId] = _Section(title: first.roomName, blocks: [_Block(units: room)]);
      }
    }

    // 2. Place each type's private rooms right after the last shared section
    //    that has units of that type (PS private rooms under the PS halls).
    final sections = shared.values.toList();
    for (final entry in privateByType.entries) {
      final private = _Section(
        title: l10n.privateRoomsOf(_typeName(entry.key, l10n)),
        blocks: [_Block(units: entry.value, showRoomNames: true)],
      );
      final lastIndex = sections.lastIndexWhere((s) => s.hasType(entry.key));
      if (lastIndex == -1) {
        sections.add(private); // no shared rooms of this type: put it at the end
      } else {
        sections.insert(lastIndex + 1, private);
      }
    }
    return sections;
  }

  /// By type: one section per type, with a "shared" and a "private" block.
  List<_Section> _sectionsByType(List<Unit> units, AppLocalizations l10n) {
    final roomSize = {
      for (final room in _groupByRoom(units).entries) room.key: room.value.length,
    };
    bool isPrivate(Unit u) => roomSize[u.roomId] == 1;

    final sections = <_Section>[];
    for (final type in UnitType.values) {
      final ofType = units.where((u) => u.type == type).toList();
      if (ofType.isEmpty) continue;

      final sharedUnits = ofType.where((u) => !isPrivate(u)).toList();
      final privateUnits = ofType.where(isPrivate).toList();
      final both = sharedUnits.isNotEmpty && privateUnits.isNotEmpty;

      sections.add(_Section(
        title: _typeName(type, l10n),
        blocks: [
          // Headings only when both kinds exist; otherwise they add nothing.
          if (sharedUnits.isNotEmpty)
            _Block(heading: both ? l10n.blockShared : null, units: sharedUnits),
          if (privateUnits.isNotEmpty)
            _Block(heading: both ? l10n.blockPrivate : null, units: privateUnits, showRoomNames: true),
        ],
      ));
    }
    return sections;
  }
}

/// One section's data: a title and one or more blocks of units.
class _Section {
  _Section({required this.title, required this.blocks});

  final String title; // "صالات البلايستيشن المشتركة", "غرف البلايستيشن المميزة"
  final List<_Block> blocks;

  bool hasType(UnitType type) => blocks.any((b) => b.units.any((u) => u.type == type));
}

/// A run of tiles inside a section, with an optional small heading ("صالة 1", "مميزة").
class _Block {
  _Block({this.heading, required this.units, this.showRoomNames = false});

  final String? heading;
  final List<Unit> units;
  final bool showRoomNames; // private rooms: tile shows "VIP 1" instead of "PS5-5"
}

/// Draws one section: its title, then each block (optional heading + grid).
class _SectionView extends StatelessWidget {
  const _SectionView({required this.section});

  final _Section section;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w600),
          ),
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
            _UnitGrid(units: block.units, showRoomNames: block.showRoomNames),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

/// Tiles in a grid whose column count adapts to the available width.
class _UnitGrid extends StatelessWidget {
  const _UnitGrid({required this.units, required this.showRoomNames});

  final List<Unit> units;
  final bool showRoomNames;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      // The grid lives inside the page's scroll view, so it must not scroll
      // by itself and must take only the height its tiles need.
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240, // a tile is at most 240 wide → more columns on wider screens
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
          selected: unit.id == 'ps5-1',
        );
      },
    );
  }
}
