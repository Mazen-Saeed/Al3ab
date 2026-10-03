import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ids.dart';
import 'price_category.dart';
import 'units_provider.dart';

/// The price categories when the app starts. Sample data for now; local SQLite later.
final initialCategoriesProvider = Provider<List<PriceCategory>>((ref) => const [
      PriceCategory(id: 'cat-ps5', name: 'PS5 عادي', hourlyPrice: 5000, multiHourlyPrice: 7000),
      PriceCategory(id: 'cat-ps4', name: 'PS4', hourlyPrice: 6000, multiHourlyPrice: 8000),
      PriceCategory(id: 'cat-vip', name: 'VIP', hourlyPrice: 9000, multiHourlyPrice: 12000),
      PriceCategory(id: 'cat-pingpong', name: 'بينج بونج عادي', hourlyPrice: 4000, multiHourlyPrice: 6000),
      PriceCategory(id: 'cat-billiards', name: 'بلياردو عادي', hourlyPrice: 6000),
    ]);

/// The price categories and what the owner does to them.
class CategoriesNotifier extends Notifier<List<PriceCategory>> {
  @override
  List<PriceCategory> build() => ref.watch(initialCategoriesProvider);

  void add({required String name, required int hourlyPrice, int? multiHourlyPrice}) {
    state = [
      ...state,
      PriceCategory(
        id: newId(),
        name: name,
        hourlyPrice: hourlyPrice,
        multiHourlyPrice: multiHourlyPrice,
      ),
    ];
  }

  /// Changes a category. Free devices take the new prices at once; a device with a session keeps its
  /// old prices until it is paid (the bill is worked out from them).
  void update(String id, {required String name, required int hourlyPrice, int? multiHourlyPrice}) {
    final updated = PriceCategory(
      id: id,
      name: name,
      hourlyPrice: hourlyPrice,
      multiHourlyPrice: multiHourlyPrice,
    );
    state = [for (final c in state) if (c.id == id) updated else c];
    ref.read(unitsProvider.notifier).applyCategory(updated);
  }

  /// Removes a category no device uses. One in use is ignored.
  void remove(String id) {
    if (ref.read(unitsProvider).any((u) => u.categoryId == id)) return;
    state = [for (final c in state) if (c.id != id) c];
  }
}

final categoriesProvider = NotifierProvider<CategoriesNotifier, List<PriceCategory>>(CategoriesNotifier.new);
