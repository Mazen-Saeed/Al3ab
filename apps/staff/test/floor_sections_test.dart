import 'package:al3b_staff/data/sample_data.dart';
import 'package:al3b_staff/floor/floor_sections.dart';
import 'package:al3b_staff/l10n/arb/app_localizations_ar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppLocalizationsAr();
  final units = buildSampleUnits();

  test('by place: halls grouped, private rooms right after the PlayStation halls', () {
    final sections = buildFloorSections(units, l10n, byType: false);

    expect(sections.map((s) => s.title).toList(), [
      'صالات البلايستيشن المشتركة', // the owner's group of halls
      l10n.privateRoomsOf(l10n.typePlayStation), // PS private rooms come right after PS halls
      'ترابيزات البينج والبلياردو', // a room with no group
    ]);

    // Each hall keeps its own block inside the group, so halls never mix.
    final halls = sections[0];
    expect(halls.blocks.map((b) => b.heading).toList(), ['صالة 1', 'صالة 2']);

    final private = sections[1].blocks.single;
    expect(private.showRoomNames, isTrue); // tiles show "VIP 1", not "PS5-5"
    expect(private.units.map((u) => u.id).toList(), ['ps5-5', 'ps5-6']);
  });

  test('by type: one section per type, shared and private blocks only when both exist', () {
    final sections = buildFloorSections(units, l10n, byType: true);

    expect(sections.map((s) => s.title).toList(), [
      l10n.typePlayStation,
      l10n.typePingPong,
      l10n.typeBilliards,
    ]);

    final playstation = sections[0];
    expect(playstation.blocks.map((b) => b.heading).toList(), [l10n.blockShared, l10n.blockPrivate]);
    expect(playstation.blocks[1].showRoomNames, isTrue);

    // Ping pong has only shared tables: no heading needed.
    expect(sections[1].blocks.single.heading, isNull);
  });
}
