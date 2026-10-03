import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_theme.dart';
import '../data/categories_provider.dart';
import '../data/money.dart';
import '../data/unit.dart';
import '../data/units_provider.dart';
import '../floor/floor_sections.dart';
import '../l10n/l10n.dart';
import '../shell/add_card.dart';
import 'room_form.dart';
import 'unit_form.dart';

/// Manage > Rooms and devices: the rooms and the units in them. Add a room (with its first unit),
/// rename it, add, change or remove units, and drag the handles to put rooms and units in the order
/// the shop wants (the Floor screen follows the same order). A unit can also be dragged into
/// another room. Changes go through the units, so the Floor screen shows them straight away.
/// A unit with a session can only be renamed.
class PlacesScreen extends ConsumerWidget {
  const PlacesScreen({super.key, required this.onBack});

  final VoidCallback onBack; // back to the Manage list

  /// New room: its name first, then its first unit (a room only exists with a unit).
  Future<void> _newPlace(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(unitsProvider.notifier); // before the awaits: ref is not safe once the page is gone
    final categories = ref.read(categoriesProvider);
    final name = await showRoomForm(context);
    if (name == null || !context.mounted) return;
    final unit = await showUnitForm(context, heading: name, categories: categories);
    if (unit == null) return;
    notifier.addRoom(
      name,
      unitName: unit.name,
      type: unit.type,
      hourlyPrice: unit.hourlyPrice,
      multiHourlyPrice: unit.multiHourlyPrice,
      categoryId: unit.categoryId,
    );
  }

  Future<void> _editRoom(BuildContext context, WidgetRef ref, Unit inRoom) async {
    final notifier = ref.read(unitsProvider.notifier);
    final name = await showRoomForm(context, name: inRoom.roomName);
    if (name == null) return;
    notifier.renameRoom(inRoom.roomId, name);
  }

  Future<void> _addUnit(BuildContext context, WidgetRef ref, Unit inRoom) async {
    final notifier = ref.read(unitsProvider.notifier);
    final categories = ref.read(categoriesProvider);
    final result = await showUnitForm(context, heading: inRoom.roomName, categories: categories);
    if (result == null) return;
    notifier.addUnit(
      inRoom.roomId,
      name: result.name,
      type: result.type,
      hourlyPrice: result.hourlyPrice,
      multiHourlyPrice: result.multiHourlyPrice,
      categoryId: result.categoryId,
    );
  }

  Future<void> _editUnit(BuildContext context, WidgetRef ref, Unit unit) async {
    final notifier = ref.read(unitsProvider.notifier);
    final categories = ref.read(categoriesProvider);
    final result = await showUnitForm(context, heading: unit.name, categories: categories, unit: unit);
    if (result == null) return;
    if (result.delete) {
      notifier.removeUnit(unit.id);
    } else {
      notifier.updateUnit(
        unit.id,
        name: result.name,
        type: result.type,
        hourlyPrice: result.hourlyPrice,
        multiHourlyPrice: result.multiHourlyPrice,
        categoryId: result.categoryId,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final rooms = ref.watch(unitsProvider).byRoom.values.toList(); // redraws when units change
    final notifier = ref.read(unitsProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton.filledTonal(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
            const SizedBox(width: 14),
            Text(l10n.placesTitle, style: AppText.sectionTitle),
          ],
        ),
        const SizedBox(height: 18),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // A room dropped on "new room" goes to the end.
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: _DropSpot<_DraggedRoom>(
                    onDrop: (room) => notifier.moveRoom(room.roomId),
                    child: AddCard(label: l10n.newPlace, onTap: () => _newPlace(context, ref)),
                  ),
                ),
                const SizedBox(height: 12),
                _RoomGrid(
                  rooms: rooms,
                  itemBuilder: (units, width) => _RoomCard(
                    width: width,
                    units: units,
                    onEditRoom: () => _editRoom(context, ref, units.first),
                    onAddUnit: () => _addUnit(context, ref, units.first),
                    onEditUnit: (unit) => _editUnit(context, ref, unit),
                    onMoveUnit: (unitId, beforeUnitId) =>
                        notifier.moveUnit(unitId, units.first.roomId, beforeUnitId: beforeUnitId),
                    onMoveRoom: (roomId) => notifier.moveRoomOnto(roomId, units.first.roomId),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Room cards in rows that fit the space: one per row on a phone, more when there is room.
class _RoomGrid extends StatelessWidget {
  const _RoomGrid({required this.rooms, required this.itemBuilder});

  final List<List<Unit>> rooms;
  final Widget Function(List<Unit> units, double cardWidth) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final columns = math.max(1, ((constraints.maxWidth + spacing) / (340 + spacing)).floor());
        final cardWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [for (final units in rooms) itemBuilder(units, cardWidth)],
        );
      },
    );
  }
}

/// What a dragged room carries (a unit carries its id as a String, so the two never mix).
class _DraggedRoom {
  const _DraggedRoom(this.roomId);

  final String roomId;
}

/// The grip of a room. Dragging it carries the room; another room's card receives it.
class _RoomHandle extends StatelessWidget {
  const _RoomHandle({required this.units});

  final List<Unit> units;

  @override
  Widget build(BuildContext context) {
    const grip = Padding(
      padding: EdgeInsetsDirectional.all(6),
      child: Icon(Icons.drag_indicator, color: AppColors.textMuted),
    );
    return Draggable<_DraggedRoom>(
      data: _DraggedRoom(units.first.roomId),
      feedback: Material(
        color: AppColors.raised,
        elevation: 6,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 12),
          child: Text(units.first.roomName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ),
      ),
      childWhenDragging: const Opacity(opacity: 0.3, child: grip),
      child: grip,
    );
  }
}

/// One room: its name, its units (draggable), and "+ new device".
class _RoomCard extends StatelessWidget {
  const _RoomCard({
    required this.width,
    required this.units,
    required this.onEditRoom,
    required this.onAddUnit,
    required this.onEditUnit,
    required this.onMoveUnit,
    required this.onMoveRoom,
  });

  final double width;
  final List<Unit> units; // never empty: a room exists only while it has a unit
  final VoidCallback onEditRoom;
  final VoidCallback onAddUnit;
  final void Function(Unit unit) onEditUnit;
  final void Function(String unitId, String? beforeUnitId) onMoveUnit; // a unit was dropped here
  final void Function(String roomId) onMoveRoom; // a room was dropped on this one

  @override
  Widget build(BuildContext context) {
    final first = units.first;
    return SizedBox(
      width: width,
      child: _DropSpot<_DraggedRoom>(
        onDrop: (room) => onMoveRoom(room.roomId),
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _RoomHandle(units: units),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: onEditRoom,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.symmetric(vertical: 4, horizontal: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  first.roomName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                ),
                              ),
                              const Icon(Icons.edit_outlined, size: 20, color: AppColors.textMuted),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // A unit dropped on a row goes before it; dropped on "new device" it goes to the end.
                for (final unit in units)
                  _DropSpot<String>(
                    onDrop: (unitId) => onMoveUnit(unitId, unit.id),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(bottom: 8),
                      child: _UnitRow(unit: unit, onTap: () => onEditUnit(unit)),
                    ),
                  ),
                _DropSpot<String>(
                  onDrop: (unitId) => onMoveUnit(unitId, null),
                  child: AddCard(label: context.l10n.newDevice, onTap: onAddUnit),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UnitRow extends StatelessWidget {
  const _UnitRow({required this.unit, required this.onTap});

  final Unit unit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final price = l10n.pricePerHour(formatMoney(unit.hourlyPrice));
    return Material(
      color: AppColors.raised,
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          _UnitHandle(unit: unit),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text('${unitTypeName(unit.type, l10n)} · $price', style: AppText.small),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The grip of a unit. Dragging it carries the unit's id; a [_DropSpot] receives it.
class _UnitHandle extends StatelessWidget {
  const _UnitHandle({required this.unit});

  final Unit unit;

  @override
  Widget build(BuildContext context) {
    const grip = Padding(
      padding: EdgeInsetsDirectional.all(6),
      child: Icon(Icons.drag_indicator, color: AppColors.textMuted),
    );
    return Draggable<String>(
      data: unit.id,
      feedback: Material(
        color: AppColors.raised,
        elevation: 6,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 12),
          child: Text(unit.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      ),
      childWhenDragging: const Opacity(opacity: 0.3, child: grip),
      child: grip,
    );
  }
}

/// Where a dragged unit (T = String) or room (T = _DraggedRoom) can be dropped. A line shows above it while one is over it.
class _DropSpot<T extends Object> extends StatelessWidget {
  const _DropSpot({required this.onDrop, required this.child});

  final void Function(T dragged) onDrop;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DragTarget<T>(
      onAcceptWithDetails: (details) => onDrop(details.data),
      builder: (context, over, rejected) => DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: over.isEmpty ? Colors.transparent : AppColors.primary, width: 3)),
        ),
        child: child,
      ),
    );
  }
}
