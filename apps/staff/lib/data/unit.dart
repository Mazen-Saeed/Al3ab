import 'money.dart';
import 'price_category.dart';

/// What kind of thing is rented by time.
enum UnitType { playstation, pingPong, billiards, pc }

extension UnitTypeRules on UnitType {
  /// Whether this kind can have a second price for two or more players. Billiards and PCs are one price.
  bool get hasPairPrice => this == UnitType.playstation || this == UnitType.pingPong;
}

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
    this.categoryId,
    required this.status,
    required this.hourlyPrice,
    this.multiHourlyPrice,
    this.startedAt,
    this.isMulti = false,
    this.plannedMinutes,
    this.nextReservationAt,
    this.note,
    this.amountDue,
    this.carriedCost = 0,
    this.rateFrom,
    this.stoppedAt,
    this.originalStart,
  });

  final String id;
  final String name; // shown on the tile: "PS5-1"
  final UnitType type;
  final String roomId; // which room the unit is in
  final String roomName; // "صالة 1", "VIP 1" (typed by the owner)
  final String? categoryId; // the price category it was priced from (null = none); the prices below are a copy
  final UnitStatus status;

  // Prices are piasters per hour (6000 = 60 EGP), see money.dart.
  final int hourlyPrice;
  final int? multiHourlyPrice; // null = no multi mode, don't ask "single or multi?"

  final DateTime? startedAt; // set while running
  final bool isMulti;
  final int? plannedMinutes; // countdown length; null = open time (counts up)
  final DateTime? nextReservationAt; // upcoming booking, if any
  final String? note; // e.g. maintenance reason
  final int? amountDue; // set while waiting for payment: the play cost when the clock was stopped

  // A session's price can change while it runs (moved to another device, single <-> pair). The time
  // before the change is already worked out: [carriedCost] piasters. From [rateFrom] (null = the
  // start) the current prices count. So the bill is the carried part plus the time since.
  final int carriedCost;
  final DateTime? rateFrom;
  final DateTime? stoppedAt; // the clock was stopped here (waiting for payment); null = running
  // The real start of the session once a resume has moved [startedAt] forward. It tells one session
  // from another (the alerts use it), so a resume does not look like a new session. Null = [startedAt].
  final DateTime? originalStart;

  bool get hasMultiMode => multiHourlyPrice != null;

  /// A session is running or waiting for payment: the unit's prices and type must not change
  /// under it (the bill is worked out from them), and it cannot be removed.
  bool get hasSession => status == UnitStatus.running || status == UnitStatus.waitingPayment;

  /// A copy of this unit with some fields changed. Unit is immutable (all fields
  /// final), so "changing" a unit means making a new one — like a C# `with` on a record.
  /// Limit: only plannedMinutes can be cleared (makeOpen); other nullable fields can't yet.
  Unit copyWith({
    UnitStatus? status,
    DateTime? startedAt,
    bool? isMulti,
    int? plannedMinutes,
    bool makeOpen = false,
    int? carriedCost,
    DateTime? rateFrom,
    bool clearStopped = false, // the clock runs again: drops the stop time and the amount due
    DateTime? originalStart,
  }) =>
      Unit(
        id: id,
        name: name,
        type: type,
        roomId: roomId,
        roomName: roomName,
        categoryId: categoryId,
        status: status ?? this.status,
        hourlyPrice: hourlyPrice,
        multiHourlyPrice: multiHourlyPrice,
        startedAt: startedAt ?? this.startedAt,
        isMulti: isMulti ?? this.isMulti,
        // makeOpen: true = drop the plan (the normal `??` can't set a value back to null)
        plannedMinutes: makeOpen ? null : plannedMinutes ?? this.plannedMinutes,
        nextReservationAt: nextReservationAt,
        note: note,
        amountDue: clearStopped ? null : amountDue,
        carriedCost: carriedCost ?? this.carriedCost,
        rateFrom: rateFrom ?? this.rateFrom,
        stoppedAt: clearStopped ? null : stoppedAt,
        originalStart: originalStart ?? this.originalStart,
      );

  /// Same unit with a new name, type and prices (Places page). [multiHourlyPrice] null removes
  /// the multi mode. Everything else (state, session, room) is kept.
  Unit withDetails({
    required String name,
    required UnitType type,
    required int hourlyPrice,
    int? multiHourlyPrice,
    String? categoryId,
  }) =>
      Unit(
        id: id,
        name: name,
        type: type,
        roomId: roomId,
        roomName: roomName,
        categoryId: categoryId,
        status: status,
        hourlyPrice: hourlyPrice,
        multiHourlyPrice: multiHourlyPrice,
        startedAt: startedAt,
        isMulti: isMulti,
        plannedMinutes: plannedMinutes,
        nextReservationAt: nextReservationAt,
        note: note,
        amountDue: amountDue,
        carriedCost: carriedCost,
        rateFrom: rateFrom,
        stoppedAt: stoppedAt,
        originalStart: originalStart,
      );

  /// Same unit priced from [category]: its hourly price, plus the pair price when this
  /// kind of unit can have one (the category itself does not know about kinds).
  Unit withCategory(PriceCategory category) => withDetails(
        name: name,
        type: type,
        hourlyPrice: category.hourlyPrice,
        multiHourlyPrice: type.hasPairPrice ? category.multiHourlyPrice : null,
        categoryId: category.id,
      );

  /// Same unit in another room (or its room renamed).
  Unit withRoom({required String roomId, required String roomName}) => Unit(
        id: id,
        name: name,
        type: type,
        roomId: roomId,
        roomName: roomName,
        categoryId: categoryId,
        status: status,
        hourlyPrice: hourlyPrice,
        multiHourlyPrice: multiHourlyPrice,
        startedAt: startedAt,
        isMulti: isMulti,
        plannedMinutes: plannedMinutes,
        nextReservationAt: nextReservationAt,
        note: note,
        amountDue: amountDue,
        carriedCost: carriedCost,
        rateFrom: rateFrom,
        stoppedAt: stoppedAt,
        originalStart: originalStart,
      );

  /// Time played until [now] (zero if not running).
  Duration elapsedAt(DateTime now) => startedAt == null ? Duration.zero : _clockAt(now).difference(startedAt!);

  /// The moment the clock shows: [now], or the stop time while it is stopped.
  DateTime _clockAt(DateTime now) => stoppedAt ?? now;

  /// Time played so far.
  Duration get elapsed => elapsedAt(DateTime.now());

  /// Planned time minus played time. Null = open time. Negative = over the planned time.
  Duration? get remaining =>
      plannedMinutes == null ? null : Duration(minutes: plannedMinutes!) - elapsed;

  bool get isOvertime => remaining != null && remaining!.isNegative;

  /// Countdown running and under a minute left (the "warn staff" moment).
  bool get isEndingSoon =>
      remaining != null && !remaining!.isNegative && remaining! <= const Duration(minutes: 1);

  /// Last minute or overtime: the UI paints the timer red-orange.
  bool get needsAttention => isEndingSoon || isOvertime;

  /// The planned length after adding [extra] minutes: counted from the planned end, or from now if
  /// the session is already over its plan ("another half hour") or has no plan (open time that
  /// becomes a fixed time: "one more hour from now").
  int plannedMinutesAfterAdding(int extra) {
    final base = isOvertime || plannedMinutes == null ? (elapsed.inSeconds / 60).ceil() : plannedMinutes!;
    return base + extra;
  }

  /// Play-time cost until [now] in piasters, rounded down to whole pounds (same rule as before
  /// the switch to piasters; whole ints only, no double). Checkout freezes [now] when it
  /// opens, so the amount on screen is exactly the amount saved in the bill.
  int costAt(DateTime now) {
    final price = isMulti ? multiHourlyPrice! : hourlyPrice;
    final since = rateFrom ?? startedAt;
    final seconds = since == null ? 0 : _clockAt(now).difference(since).inSeconds;
    return carriedCost + seconds * price ~/ (3600 * piastersPerPound) * piastersPerPound;
  }

  /// Play-time cost so far.
  int get currentCost => costAt(DateTime.now());

  /// The same session with the other mode (single <-> pair) from [now]: the time so far keeps the
  /// old price, the rest takes the new one.
  Unit withModeSwitched(DateTime now) => copyWith(isMulti: !isMulti, carriedCost: costAt(now), rateFrom: now);

  /// The clock stops at [now] and the unit waits for payment. The amount due is the play cost then.
  Unit asStopped(DateTime now) => Unit(
        id: id,
        name: name,
        type: type,
        roomId: roomId,
        roomName: roomName,
        categoryId: categoryId,
        status: UnitStatus.waitingPayment,
        hourlyPrice: hourlyPrice,
        multiHourlyPrice: multiHourlyPrice,
        startedAt: startedAt,
        isMulti: isMulti,
        plannedMinutes: plannedMinutes,
        nextReservationAt: nextReservationAt,
        note: note,
        amountDue: costAt(now),
        carriedCost: carriedCost,
        rateFrom: rateFrom,
        stoppedAt: now,
        originalStart: originalStart,
      );

  /// The clock runs again at [now]: the stopped time is not counted (start and price moment move on).
  Unit asResumed(DateTime now) {
    final gap = now.difference(stoppedAt ?? now);
    return copyWith(
      status: UnitStatus.running,
      startedAt: startedAt?.add(gap),
      rateFrom: rateFrom?.add(gap),
      clearStopped: true,
      originalStart: originalStart ?? startedAt,
    );
  }

  /// This unit after its session is paid: free again, nothing running.
  /// (copyWith can't clear startedAt, so this builds the free version directly.)
  Unit asFree() => Unit(
        id: id,
        name: name,
        type: type,
        roomId: roomId,
        roomName: roomName,
        categoryId: categoryId,
        status: UnitStatus.free,
        hourlyPrice: hourlyPrice,
        multiHourlyPrice: multiHourlyPrice,
        nextReservationAt: nextReservationAt,
      );

  /// This unit taken out of service, with an optional reason ("الدراع بايظ").
  Unit asInMaintenance(String? note) => Unit(
        id: id,
        name: name,
        type: type,
        roomId: roomId,
        roomName: roomName,
        categoryId: categoryId,
        status: UnitStatus.maintenance,
        hourlyPrice: hourlyPrice,
        multiHourlyPrice: multiHourlyPrice,
        nextReservationAt: nextReservationAt,
        note: note,
      );
}
