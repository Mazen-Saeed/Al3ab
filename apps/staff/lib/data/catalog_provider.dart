import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ids.dart';
import 'product.dart';
import 'sample_data.dart';
import 'stock.dart';

/// The menu and the stock, together: products and stock items point at each other
/// (a product draws from a stock item; deleting a product removes its stock item), so they
/// change as one piece. Immutable: every change makes a new [Catalog].
class Catalog {
  const Catalog({
    this.products = const [],
    this.stockItems = const [],
    this.movements = const [],
    this.purchases = const [],
  });

  /// What the shop sells (the order form, Quick sale and the Products page show these).
  final List<Product> products;

  /// Everything the shop buys and counts (the Stock page shows these).
  final List<StockItem> stockItems;

  /// What staff recorded by hand (bought, opened, counted), oldest first. Never edited.
  /// The "cups per tin" report reads this later.
  final List<StockMovement> movements;

  /// Shopping trips (the receipts), oldest first. Reports compare these with the bills.
  final List<Purchase> purchases;

  Catalog copyWith({
    List<Product>? products,
    List<StockItem>? stockItems,
    List<StockMovement>? movements,
    List<Purchase>? purchases,
  }) =>
      Catalog(
        products: products ?? this.products,
        stockItems: stockItems ?? this.stockItems,
        movements: movements ?? this.movements,
        purchases: purchases ?? this.purchases,
      );

  /// The stock item a product draws from (null = not counted).
  StockItem? stockItemOf(Product product) {
    final id = product.stockItemId;
    return id == null ? null : stockItems.where((s) => s.id == id).firstOrNull;
  }

  /// Products that are not counted in stock yet (the "add to stock" form offers these).
  List<Product> get untrackedProducts => [
        for (final product in products)
          if (product.stockItemId == null) product,
      ];

  /// true for an item no product draws from (sugar, milk): it has its own name.
  bool isInternal(StockItem item) => !products.any((p) => p.stockItemId == item.id);
}

/// Where the menu and stock come from when the app starts. Sample data for now; local SQLite later.
/// Tests replace it to start from their own data.
final initialCatalogProvider = Provider<Catalog>(
  (ref) => const Catalog(products: sampleProducts, stockItems: sampleStockItems),
);

/// The menu and stock, and the actions that change them.
class CatalogNotifier extends Notifier<Catalog> {
  @override
  Catalog build() => ref.watch(initialCatalogProvider);

  /// Adds a product to the menu. It is not counted in stock until [startTracking].
  void addProduct(String name, int price) {
    state = state.copyWith(products: [...state.products, Product(id: newId(), name: name, price: price)]);
  }

  /// Changes a product's name and price. Bills already made keep the old values (they copied them).
  /// Its stock item is named after it, so it follows the new name.
  void updateProduct(String id, {required String name, required int price}) {
    final products = [...state.products];
    final index = products.indexWhere((p) => p.id == id);
    products[index] = products[index].copyWith(name: name, price: price);
    final items = [...state.stockItems];
    final stockIndex = items.indexWhere((s) => s.id == products[index].stockItemId);
    if (stockIndex != -1) items[stockIndex] = items[stockIndex].withName(name);
    state = state.copyWith(products: products, stockItems: items);
  }

  /// Removes a product from the menu, and its stock item with it.
  /// Old bills keep their lines (they copied the name and price).
  void deleteProduct(String id) {
    final stockId = state.products.where((p) => p.id == id).firstOrNull?.stockItemId;
    var next = state.copyWith(products: [
      for (final product in state.products)
        if (product.id != id) product,
    ]);
    if (stockId != null) next = _withoutStockItem(next, stockId);
    state = next;
  }

  /// Starts counting a product in stock. Its stock item is named like the product.
  /// [count] > 0 is how many are on the shelf now (saved as a first count).
  void startTracking(String productId, {required bool deductsOnSale, int? lowStockAt, int count = 0}) {
    final index = state.products.indexWhere((p) => p.id == productId);
    if (index == -1 || state.products[index].stockItemId != null) return;
    final id = newId();
    final items = [
      ...state.stockItems,
      StockItem(id: id, name: state.products[index].name, deductsOnSale: deductsOnSale, lowStockAt: lowStockAt),
    ];
    final products = [...state.products];
    products[index] = products[index].withStockItem(id);
    final movements = [...state.movements];
    if (count > 0) _writeMovement(items, movements, id, StockMovementKind.count, count, setTo: count);
    state = state.copyWith(products: products, stockItems: items, movements: movements);
  }

  /// Adds something that is used but not sold (sugar, milk, cups): a stock item with no product.
  /// Always counted by hand. [count] > 0 is how many are on the shelf now (saved as a first count).
  void addInternalItem(String name, {int? lowStockAt, int count = 0}) {
    final id = newId();
    final items = [
      ...state.stockItems,
      StockItem(id: id, name: name, deductsOnSale: false, lowStockAt: lowStockAt),
    ];
    final movements = [...state.movements];
    if (count > 0) _writeMovement(items, movements, id, StockMovementKind.count, count, setTo: count);
    state = state.copyWith(stockItems: items, movements: movements);
  }

  /// Changes how an item is counted and its low-stock level. The number on hand stays.
  /// [name] renames it; only an internal item has a name of its own (a product's item follows the product).
  void updateStockItem(String stockItemId, {String? name, required bool deductsOnSale, int? lowStockAt}) {
    final items = [...state.stockItems];
    final index = items.indexWhere((s) => s.id == stockItemId);
    if (index == -1) return;
    final item = items[index];
    items[index] = StockItem(
      id: item.id,
      name: name ?? item.name,
      deductsOnSale: deductsOnSale,
      onHand: item.onHand,
      lowStockAt: lowStockAt,
    );
    state = state.copyWith(stockItems: items);
  }

  /// Stops counting: the stock item and its log go. The product stays on the menu, uncounted.
  void stopTracking(String stockItemId) => state = _withoutStockItem(state, stockItemId);

  /// "اشتريت": one shopping trip. [quantities]: stock item id -> how many arrived. [total] is what
  /// the receipt said (whole EGP). Saves the trip and one log entry per item, and adds to the shelf.
  void recordPurchase(Map<String, int> quantities, {required int total}) {
    final bought = {
      for (final entry in quantities.entries)
        if (entry.value > 0 && state.stockItems.any((s) => s.id == entry.key)) entry.key: entry.value,
    };
    if (bought.isEmpty || total < 0) return;
    final id = newId();
    final items = [...state.stockItems];
    final movements = [...state.movements];
    bought.forEach((itemId, quantity) {
      _writeMovement(items, movements, itemId, StockMovementKind.purchase, quantity, delta: quantity, purchaseId: id);
    });
    state = state.copyWith(
      stockItems: items,
      movements: movements,
      purchases: [...state.purchases, Purchase(id: id, total: total, at: DateTime.now())],
    );
  }

  /// "فتحت علبة": [quantity] (usually 1) tins/packets were opened for use.
  void recordOpened(String stockItemId, [int quantity = 1]) {
    if (quantity <= 0) return;
    final items = [...state.stockItems];
    final movements = [...state.movements];
    if (_writeMovement(items, movements, stockItemId, StockMovementKind.opened, quantity, delta: -quantity)) {
      state = state.copyWith(stockItems: items, movements: movements);
    }
  }

  /// "تعديل الرقم": the shelf was counted and [counted] is what is there. Replaces the number on hand.
  /// The log keeps what the app expected and the optional [note] (why it changed).
  void recordCount(String stockItemId, int counted, {String? note}) {
    if (counted < 0) return;
    final items = [...state.stockItems];
    final index = items.indexWhere((s) => s.id == stockItemId);
    if (index == -1) return;
    final movements = [...state.movements];
    final trimmed = note?.trim();
    if (_writeMovement(
      items,
      movements,
      stockItemId,
      StockMovementKind.count,
      counted,
      setTo: counted,
      expected: items[index].onHand,
      note: trimmed == null || trimmed.isEmpty ? null : trimmed,
    )) {
      state = state.copyWith(stockItems: items, movements: movements);
    }
  }

  /// A sale takes [quantity] off the stock item of that product, if that item is subtracted on sale
  /// (negative [quantity] gives it back). No log entry: the order line is the record.
  /// Called by the orders when a line is added or removed.
  void sellFromStock(String productId, int quantity) {
    final stockId = state.products.where((p) => p.id == productId).firstOrNull?.stockItemId;
    if (stockId == null) return;
    final index = state.stockItems.indexWhere((s) => s.id == stockId);
    if (index == -1 || !state.stockItems[index].deductsOnSale) return;
    final items = [...state.stockItems];
    items[index] = items[index].withOnHand(items[index].onHand - quantity);
    state = state.copyWith(stockItems: items);
  }
}

final catalogProvider = NotifierProvider<CatalogNotifier, Catalog>(CatalogNotifier.new);

/// The catalog without one stock item: its log goes, and its product (if any) is unlinked.
Catalog _withoutStockItem(Catalog catalog, String stockItemId) => catalog.copyWith(
      stockItems: [
        for (final item in catalog.stockItems)
          if (item.id != stockItemId) item,
      ],
      movements: [
        for (final movement in catalog.movements)
          if (movement.stockItemId != stockItemId) movement,
      ],
      products: [
        for (final product in catalog.products) product.stockItemId == stockItemId ? product.withStockItem(null) : product,
      ],
    );

/// Writes the log entry and changes the number on hand, together, in the lists given (the caller
/// then saves them as the new state). false if the stock item does not exist.
bool _writeMovement(
  List<StockItem> items,
  List<StockMovement> movements,
  String stockItemId,
  StockMovementKind kind,
  int quantity, {
  int? delta,
  int? setTo,
  String? purchaseId,
  int? expected,
  String? note,
}) {
  final index = items.indexWhere((s) => s.id == stockItemId);
  if (index == -1) return false;
  items[index] = items[index].withOnHand(setTo ?? items[index].onHand + delta!);
  movements.add(StockMovement(
    id: newId(),
    stockItemId: stockItemId,
    kind: kind,
    quantity: quantity,
    at: DateTime.now(),
    purchaseId: purchaseId,
    expected: expected,
    note: note,
  ));
  return true;
}
