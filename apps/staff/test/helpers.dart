import 'package:al3b_staff/data/catalog_provider.dart';
import 'package:al3b_staff/data/money.dart';
import 'package:al3b_staff/data/preferences_provider.dart';
import 'package:al3b_staff/data/product.dart';
import 'package:al3b_staff/data/sample_data.dart';
import 'package:al3b_staff/data/stock.dart';
import 'package:al3b_staff/data/unit.dart';
import 'package:al3b_staff/data/units_provider.dart';
import 'package:al3b_staff/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      hourlyPrice: hourly * piastersPerPound, // tests say pounds, the model holds piasters
      multiHourlyPrice: multi == null ? null : multi * piastersPerPound,
      startedAt: startedAt,
      isMulti: isMulti,
      plannedMinutes: planned,
    );

/// A container for provider tests. It starts from the data given (default: one free unit, an empty
/// menu and stock) instead of the sample data, and is closed after the test.
ProviderContainer makeContainer({
  List<Unit>? units,
  List<Product> products = const [],
  List<StockItem> stockItems = const [],
}) {
  final container = ProviderContainer(overrides: [
    initialUnitsProvider.overrideWith((ref) => units ?? [testUnit()]),
    initialCatalogProvider.overrideWith((ref) => Catalog(products: products, stockItems: stockItems)),
  ]);
  addTearDown(container.dispose);
  return container;
}

/// A moment [d] ago. Unit uses DateTime.now(), so tests build their times from it
/// and leave a few seconds of margin in what they expect.
DateTime ago(Duration d) => DateTime.now().subtract(d);

/// Starts the whole app and waits until the Floor screen is showing.
/// The first start loads translations asynchronously, so it can take a few frames.
/// (pumpAndSettle() can't be used: the clock keeps scheduling frames.)
Future<void> pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({}); // saved settings kept in memory: a fresh install every time
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWith((ref) => prefs)],
      child: const MyApp(),
    ),
  );
  for (var i = 0; i < 20 && find.text(sampleVenueName).evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
