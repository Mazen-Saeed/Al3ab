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
  final DateTime? nextReservationAt; // upcoming booking, if any
  final String? note; // e.g. maintenance reason
  final int? amountDue; // set while waiting for payment

  bool get hasMultiMode => multiHourlyPrice != null;

  /// Time played so far (zero if not running).
  Duration get elapsed =>
      startedAt == null ? Duration.zero : DateTime.now().difference(startedAt!);

  /// Play-time cost so far, rounded down to whole EGP.
  int get currentCost {
    final price = isMulti ? multiHourlyPrice! : hourlyPrice;
    return (elapsed.inSeconds * price / 3600).floor();
  }
}

/// Sample venue name (owners type their own in Venue setup).
const sampleVenueName = 'محل التجربة';

/// 12 sample units matching the design. Replaced by real data later.
List<Unit> buildSampleUnits() {
  final now = DateTime.now();
  DateTime ago(int h, int m, int s) =>
      now.subtract(Duration(hours: h, minutes: m, seconds: s));

  return [
    // Two halls, grouped by the owner as "صالات البلايستيشن المشتركة"
    Unit(id: 'ps5-1', name: 'PS5-1', type: UnitType.playstation, roomId: 'hall-1', roomName: 'صالة 1', groupId: 'halls', groupName: 'صالات البلايستيشن المشتركة', status: UnitStatus.running, hourlyPrice: 50, multiHourlyPrice: 70, startedAt: ago(1, 24, 10)),
    Unit(id: 'ps5-2', name: 'PS5-2', type: UnitType.playstation, roomId: 'hall-1', roomName: 'صالة 1', groupId: 'halls', groupName: 'صالات البلايستيشن المشتركة', status: UnitStatus.running, hourlyPrice: 50, multiHourlyPrice: 70, startedAt: ago(0, 47, 33), isMulti: true),
    Unit(id: 'ps5-3', name: 'PS5-3', type: UnitType.playstation, roomId: 'hall-1', roomName: 'صالة 1', groupId: 'halls', groupName: 'صالات البلايستيشن المشتركة', status: UnitStatus.free, hourlyPrice: 50, multiHourlyPrice: 70, nextReservationAt: now.add(const Duration(hours: 1, minutes: 20))),
    Unit(id: 'ps5-4', name: 'PS5-4', type: UnitType.playstation, roomId: 'hall-2', roomName: 'صالة 2', groupId: 'halls', groupName: 'صالات البلايستيشن المشتركة', status: UnitStatus.running, hourlyPrice: 50, multiHourlyPrice: 70, startedAt: ago(0, 58, 2), nextReservationAt: now.add(const Duration(minutes: 15))),
    const Unit(id: 'ps4-1', name: 'PS4-1', type: UnitType.playstation, roomId: 'hall-2', roomName: 'صالة 2', groupId: 'halls', groupName: 'صالات البلايستيشن المشتركة', status: UnitStatus.waitingPayment, hourlyPrice: 60, multiHourlyPrice: 80, amountDue: 120),
    const Unit(id: 'ps4-2', name: 'PS4-2', type: UnitType.playstation, roomId: 'hall-2', roomName: 'صالة 2', groupId: 'halls', groupName: 'صالات البلايستيشن المشتركة', status: UnitStatus.maintenance, hourlyPrice: 60, multiHourlyPrice: 80, note: 'دراع بايظ'),
    // Table room (no group)
    Unit(id: 'pp-1', name: 'بينج بونج 1', type: UnitType.pingPong, roomId: 'tables', roomName: 'ترابيزات البينج والبلياردو', status: UnitStatus.running, hourlyPrice: 40, multiHourlyPrice: 60, startedAt: ago(0, 32, 10), isMulti: true),
    const Unit(id: 'pp-2', name: 'بينج بونج 2', type: UnitType.pingPong, roomId: 'tables', roomName: 'ترابيزات البينج والبلياردو', status: UnitStatus.free, hourlyPrice: 40, multiHourlyPrice: 60),
    Unit(id: 'bil-1', name: 'بلياردو 1', type: UnitType.billiards, roomId: 'tables', roomName: 'ترابيزات البينج والبلياردو', status: UnitStatus.running, hourlyPrice: 60, startedAt: ago(1, 5, 0)),
    const Unit(id: 'bil-2', name: 'بلياردو 2', type: UnitType.billiards, roomId: 'tables', roomName: 'ترابيزات البينج والبلياردو', status: UnitStatus.free, hourlyPrice: 60),
    // Private rooms (one unit each)
    Unit(id: 'ps5-5', name: 'PS5-5', type: UnitType.playstation, roomId: 'vip-1', roomName: 'VIP 1', status: UnitStatus.running, hourlyPrice: 90, multiHourlyPrice: 120, startedAt: ago(0, 5, 12), isMulti: true),
    const Unit(id: 'ps5-6', name: 'PS5-6', type: UnitType.playstation, roomId: 'vip-2', roomName: 'VIP 2', status: UnitStatus.free, hourlyPrice: 90, multiHourlyPrice: 120),
  ];
}
