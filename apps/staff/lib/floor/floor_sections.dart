import '../data/unit.dart';
import '../data/units_provider.dart';
import '../l10n/l10n.dart';

/// One section's data: a title and one or more blocks of units.
class FloorSection {
  FloorSection({required this.title, required this.blocks});

  final String title; // "صالة 1", "غرف البلايستيشن المميزة"
  final List<FloorBlock> blocks;

  bool hasType(UnitType type) => blocks.any((b) => b.units.any((u) => u.type == type));
}

/// A run of tiles inside a section, with an optional small heading ("صالة 1", "مميزة").
class FloorBlock {
  FloorBlock({this.heading, required this.units, this.showRoomNames = false});

  final String? heading;
  final List<Unit> units;
  final bool showRoomNames; // private rooms: tile shows "VIP 1" instead of "PS5-5"
}

/// Turns the flat list of units into the sections the Floor screen draws.
///
/// A room with 2+ units is a shared hall; a room with exactly one unit is a private room.
/// - By place: one section per shared hall. Private rooms are gathered per type
///   ("غرف البلايستيشن المميزة") and placed right after the shared sections of that type.
/// - By type: one section per type, split into "shared" and "private" blocks.
List<FloorSection> buildFloorSections(
  List<Unit> units,
  AppLocalizations l10n, {
  required bool byType,
}) =>
    byType ? _sectionsByType(units, l10n) : _sectionsByPlace(units, l10n);

String unitTypeName(UnitType type, AppLocalizations l10n) => switch (type) {
      UnitType.playstation => l10n.typePlayStation,
      UnitType.pingPong => l10n.typePingPong,
      UnitType.billiards => l10n.typeBilliards,
      UnitType.pc => l10n.typePc,
    };

List<FloorSection> _sectionsByPlace(List<Unit> units, AppLocalizations l10n) {
  // 1. Every shared hall is its own section. Private rooms are collected per type.
  final shared = <FloorSection>[];
  final privateByType = <UnitType, List<Unit>>{};

  for (final room in units.byRoom.values) {
    final first = room.first;
    if (room.length == 1) {
      privateByType.putIfAbsent(first.type, () => []).add(first);
    } else {
      shared.add(FloorSection(title: first.roomName, blocks: [FloorBlock(units: room)]));
    }
  }

  // 2. Place each type's private rooms right after the last shared section
  //    that has units of that type (PS private rooms under the PS halls).
  final sections = shared;
  for (final entry in privateByType.entries) {
    final private = FloorSection(
      title: l10n.privateRoomsOf(unitTypeName(entry.key, l10n)),
      blocks: [FloorBlock(units: entry.value, showRoomNames: true)],
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

List<FloorSection> _sectionsByType(List<Unit> units, AppLocalizations l10n) {
  final roomSize = {
    for (final room in units.byRoom.entries) room.key: room.value.length,
  };
  bool isPrivate(Unit u) => roomSize[u.roomId] == 1;

  final sections = <FloorSection>[];
  for (final type in UnitType.values) {
    final ofType = units.where((u) => u.type == type).toList();
    if (ofType.isEmpty) continue;

    final sharedUnits = ofType.where((u) => !isPrivate(u)).toList();
    final privateUnits = ofType.where(isPrivate).toList();
    final both = sharedUnits.isNotEmpty && privateUnits.isNotEmpty;

    sections.add(FloorSection(
      title: unitTypeName(type, l10n),
      blocks: [
        // Headings only when both kinds exist; otherwise they add nothing.
        if (sharedUnits.isNotEmpty)
          FloorBlock(heading: both ? l10n.blockShared : null, units: sharedUnits),
        if (privateUnits.isNotEmpty)
          FloorBlock(heading: both ? l10n.blockPrivate : null, units: privateUnits, showRoomNames: true),
      ],
    ));
  }
  return sections;
}
