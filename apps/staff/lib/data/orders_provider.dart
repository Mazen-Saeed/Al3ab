import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'catalog_provider.dart';
import 'product.dart';

/// Order lines per unit id, for the session running on that unit. Immutable: a change makes a new map.
/// (Name, unit price and quantity are copied when ordering, so a later price change never changes an open bill.)
class OrdersNotifier extends Notifier<Map<String, List<OrderLine>>> {
  @override
  Map<String, List<OrderLine>> build() => const {};

  /// Adds products to a unit's bill. [quantities]: product id -> how many.
  /// Ordering a product that is already on the bill raises that line's quantity.
  /// A product that is counted in stock (and subtracts on sale) is taken off the shelf.
  void addOrder(String unitId, Map<String, int> quantities) {
    final catalog = ref.read(catalogProvider.notifier);
    final products = ref.read(catalogProvider).products;
    final lines = [...state.forUnit(unitId)];
    quantities.forEach((productId, quantity) {
      if (quantity <= 0) return;
      final product = products.firstWhere((p) => p.id == productId);
      catalog.sellFromStock(productId, quantity);
      final index = lines.indexWhere((l) => l.productId == productId);
      if (index == -1) {
        lines.add(OrderLine(productId: product.id, name: product.name, unitPrice: product.price, quantity: quantity));
      } else {
        lines[index] = lines[index].withQuantity(lines[index].quantity + quantity);
      }
    });
    state = {...state, unitId: lines};
  }

  /// Takes a whole line off the bill (the order was a mistake). No confirmation: the bill is still unpaid.
  /// The stock comes back.
  void removeOrderLine(String unitId, String productId) {
    final lines = [...state.forUnit(unitId)];
    final index = lines.indexWhere((l) => l.productId == productId);
    if (index == -1) return;
    ref.read(catalogProvider.notifier).sellFromStock(productId, -lines[index].quantity); // negative: stock comes back
    lines.removeAt(index);
    state = {...state, unitId: lines};
  }

  /// A unit's bill is done (paid): forget its lines. (Called by the bills when a bill is saved.)
  void clear(String unitId) {
    state = {
      for (final entry in state.entries)
        if (entry.key != unitId) entry.key: entry.value,
    };
  }
}

final ordersProvider = NotifierProvider<OrdersNotifier, Map<String, List<OrderLine>>>(OrdersNotifier.new);

extension OrdersView on Map<String, List<OrderLine>> {
  /// The bill's order lines for a unit (empty if nothing was ordered).
  List<OrderLine> forUnit(String unitId) => this[unitId] ?? const [];

  /// Sum of the order lines for a unit.
  int totalFor(String unitId) => forUnit(unitId).fold(0, (sum, line) => sum + line.total);
}
