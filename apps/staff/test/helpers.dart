import 'package:al3b_staff/data/sample_data.dart';
import 'package:al3b_staff/data/unit.dart';
import 'package:al3b_staff/main.dart';
import 'package:flutter_test/flutter_test.dart';

/// A unit for tests, with sensible defaults. Only pass what the test cares about.
Unit testUnit({
  String id = 'u1',
  UnitStatus status = UnitStatus.free,
  int hourly = 50,
  int? multi,
  DateTime? startedAt,
  bool isMulti = false,
  int? planned,
}) =>
    Unit(
      id: id,
      name: 'PS5-1',
      type: UnitType.playstation,
      roomId: 'r1',
      roomName: 'صالة 1',
      status: status,
      hourlyPrice: hourly,
      multiHourlyPrice: multi,
      startedAt: startedAt,
      isMulti: isMulti,
      plannedMinutes: planned,
    );

/// A moment [d] ago. Unit uses DateTime.now(), so tests build their times from it
/// and leave a few seconds of margin in what they expect.
DateTime ago(Duration d) => DateTime.now().subtract(d);

/// Starts the whole app and waits until the Floor screen is showing.
/// The first start loads translations asynchronously, so it can take a few frames.
/// (pumpAndSettle() can't be used: the store's clock keeps scheduling frames.)
Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  for (var i = 0; i < 20 && find.text(sampleVenueName).evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
