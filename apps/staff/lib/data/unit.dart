/// What kind of thing is rented by time.
enum UnitType { playstation, pingPong, billiards }

/// What a unit is doing right now. Each state looks different on the Floor screen.
enum UnitStatus { free, running, waitingPayment, maintenance }

/// One rentable unit as the Floor screen needs it (PS5-1, Ping pong 1, Billiards 2...).
///
/// This is screen data, not the database row: later it will be built from
/// the local SQLite tables (units, sessions, sessions_units, reservations).
class Unit {
  const Unit({
    required this.id,
    required this.name,
    required this.type,
    required this.roomId,
    required this.roomName,
    this.groupId,
    this.groupName,
    required this.status,
    required this.hourlyPrice,
    this.multiHourlyPrice,
    this.startedAt,
    this.isMulti = false,
    this.plannedMinutes,
    this.nextReservationAt,
    this.note,
    this.amountDue,
  });

  final String id;
  final String name; // shown on the tile: "PS5-1"
  final UnitType type;
  final String roomId; // which room the unit is in
  final String roomName; // "صالة 1", "VIP 1" (typed by the owner)
  final String? groupId; // optional owner-made group of rooms
  final String? groupName; // "الصالات"
  final UnitStatus status;

  // Prices in whole EGP for now (real money handling comes with the database).
  final int hourlyPrice;
  final int? multiHourlyPrice; // null = no multi mode, don't ask "single or multi?"

  final DateTime? startedAt; // set while running
  final bool isMulti;
  final int? plannedMinutes; // countdown length; null = open time (counts up)
  final DateTime? nextReservationAt; // upcoming booking, if any
  final String? note; // e.g. maintenance reason
  final int? amountDue; // set while waiting for payment

  bool get hasMultiMode => multiHourlyPrice != null;

  /// A copy of this unit with some fields changed. Unit is immutable (all fields
  /// final), so "changing" a unit means making a new one — like a C# `with` on a record.
  /// Limit: only plannedMinutes can be cleared (makeOpen); other nullable fields can't yet.
  Unit copyWith({UnitStatus? status, DateTime? startedAt, bool? isMulti, int? plannedMinutes, bool makeOpen = false}) => Unit(
        id: id,
        name: name,
        type: type,
        roomId: roomId,
        roomName: roomName,
        groupId: groupId,
        groupName: groupName,
        status: status ?? this.status,
        hourlyPrice: hourlyPrice,
        multiHourlyPrice: multiHourlyPrice,
        startedAt: startedAt ?? this.startedAt,
        isMulti: isMulti ?? this.isMulti,
        // makeOpen: true = drop the plan (the normal `??` can't set a value back to null)
        plannedMinutes: makeOpen ? null : plannedMinutes ?? this.plannedMinutes,
        nextReservationAt: nextReservationAt,
        note: note,
        amountDue: amountDue,
      );

  /// Time played so far (zero if not running).
  Duration get elapsed =>
      startedAt == null ? Duration.zero : DateTime.now().difference(startedAt!);

  /// Planned time minus played time. Null = open time. Negative = over the planned time.
  Duration? get remaining =>
      plannedMinutes == null ? null : Duration(minutes: plannedMinutes!) - elapsed;

  bool get isOvertime => remaining != null && remaining!.isNegative;

  /// Countdown running and under a minute left (the "warn staff" moment).
  bool get isEndingSoon =>
      remaining != null && !remaining!.isNegative && remaining! <= const Duration(minutes: 1);

  /// Last minute or overtime: the UI paints the timer red-orange.
  bool get needsAttention => isEndingSoon || isOvertime;

  /// The planned length after adding [extra] minutes: counted from the planned end,
  /// or from now if the session is already over its plan ("another half hour").
  int plannedMinutesAfterAdding(int extra) {
    final base = isOvertime ? (elapsed.inSeconds / 60).ceil() : plannedMinutes!;
    return base + extra;
  }

  /// Play-time cost so far, rounded down to whole EGP.
  int get currentCost {
    final price = isMulti ? multiHourlyPrice! : hourlyPrice;
    return (elapsed.inSeconds * price / 3600).floor();
  }
}
