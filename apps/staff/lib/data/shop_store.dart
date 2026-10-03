import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'bill.dart';
import 'payment_account.dart';
import 'product.dart';
import 'stock.dart';
import 'unit.dart';

/// The shop's live data (for now: the units) and the actions that change it.
///
/// Screens read from it and call its methods; they never edit units themselves.
/// It is a ChangeNotifier: every change (and every clock tick) tells the screens
/// listening to it to redraw. Today the data is in memory; when SQLite arrives,
/// only this class changes, the screens stay the same.
class ShopStore extends ChangeNotifier {
  /// [tick]: also notify once a second, so running timers move. Tests turn it off.
  ShopStore(
    List<Unit> units, {
    List<Product> products = const [],
    List<StockItem> stockItems = const [],
    this.paymentAccounts = const {},
    bool tick = true,
  })  : _units = List.of(units),
        _products = List.of(products),
        _stockItems = List.of(stockItems) {
    if (tick) _clock = Timer.periodic(const Duration(seconds: 1), (_) => notifyListeners());
  }

  final List<Unit> _units;
  Timer? _clock;

  final List<Product> _products;

  /// What the shop sells (the order form, Quick sale and the Products page show these).
  UnmodifiableListView<Product> get products => UnmodifiableListView(_products);

  final List<StockItem> _stockItems;

  /// Everything the shop buys and counts (the Stock page shows these).
  UnmodifiableListView<StockItem> get stockItems => UnmodifiableListView(_stockItems);

  /// What staff recorded by hand (bought, opened, counted), oldest first. Never edited.
  /// The "cups per tin" report reads this later.
  final List<StockMovement> _movements = [];
  UnmodifiableListView<StockMovement> get stockMovements => UnmodifiableListView(_movements);

  /// Shopping trips (the receipts), oldest first. Reports compare these with the bills.
  final List<Purchase> _purchases = [];
  UnmodifiableListView<Purchase> get purchases => UnmodifiableListView(_purchases);

  /// Where customers pay, per method (venue settings, later). Checkout shows a QR for these.
  /// A method without an entry (cash) shows nothing extra.
  final Map<PaymentMethod, PaymentAccount> paymentAccounts;

  /// Order lines per unit id, for the session running on that unit.
  final Map<String, List<OrderLine>> _orders = {};

  /// Paid bills, oldest first (the cash box and reports read these later).
  final List<Bill> _bills = [];
  UnmodifiableListView<Bill> get bills => UnmodifiableListView(_bills);

  /// Read-only view of the units (no copy).
  UnmodifiableListView<Unit> get units => UnmodifiableListView(_units);

  Unit unitById(String id) => _units.firstWhere((u) => u.id == id);

  /// A free unit starts running now. [plannedMinutes] null = open time.
  void startSession(String unitId, {required bool isMulti, int? plannedMinutes}) {
    _replace(unitById(unitId).copyWith(
      status: UnitStatus.running,
      startedAt: DateTime.now(),
      isMulti: isMulti,
      plannedMinutes: plannedMinutes,
    ));
  }

  /// Extend a planned session by [minutes] (from its planned end, or from now if already over).
  /// minutes == null: drop the plan, the session becomes open time. The bill never changes:
  /// it is always the time actually played.
  void addTime(String unitId, int? minutes) {
    final unit = unitById(unitId);
    _replace(minutes == null
        ? unit.copyWith(makeOpen: true)
        : unit.copyWith(plannedMinutes: unit.plannedMinutesAfterAdding(minutes)));
  }

  /// Adds a product to the menu. It is not counted in stock until [startTracking].
  void addProduct(String name, int price) {
    // TODO: UUID v7 like the database ids, when SQLite arrives.
    final id = 'p${DateTime.now().microsecondsSinceEpoch}';
    _products.add(Product(id: id, name: name, price: price));
    notifyListeners();
  }

  /// Changes a product's name and price. Bills already made keep the old values (they copied them).
  /// Its stock item is named after it, so it follows the new name.
  void updateProduct(String id, {required String name, required int price}) {
    final index = _products.indexWhere((p) => p.id == id);
    _products[index] = _products[index].copyWith(name: name, price: price);
    final stockIndex = _stockItems.indexWhere((s) => s.id == _products[index].stockItemId);
    if (stockIndex != -1) _stockItems[stockIndex] = _stockItems[stockIndex].withName(name);
    notifyListeners();
  }

  /// Removes a product from the menu, and its stock item with it.
  /// Old bills keep their lines (they copied the name and price).
  void deleteProduct(String id) {
    final stockId = _products.where((p) => p.id == id).firstOrNull?.stockItemId;
    _products.removeWhere((p) => p.id == id);
    if (stockId != null) _removeStockItem(stockId);
    notifyListeners();
  }

  /// The stock item a product draws from (null = not counted).
  StockItem? stockItemOf(Product product) {
    final id = product.stockItemId;
    return id == null ? null : _stockItems.where((s) => s.id == id).firstOrNull;
  }

  /// Products that are not counted in stock yet (the "add to stock" form offers these).
  List<Product> get untrackedProducts => [
        for (final product in _products)
          if (product.stockItemId == null) product,
      ];

  /// Starts counting a product in stock. Its stock item is named like the product.
  /// [count] > 0 is how many are on the shelf now (saved as a first count).
  void startTracking(String productId, {required bool deductsOnSale, int? lowStockAt, int count = 0}) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index == -1 || _products[index].stockItemId != null) return;
    // TODO: UUID v7 like the database ids, when SQLite arrives.
    final id = 's${DateTime.now().microsecondsSinceEpoch}';
    _stockItems.add(StockItem(id: id, name: _products[index].name, deductsOnSale: deductsOnSale, lowStockAt: lowStockAt));
    _products[index] = _products[index].withStockItem(id);
    if (count > 0) _writeMovement(id, StockMovementKind.count, count, setTo: count);
    notifyListeners();
  }

  /// Adds something that is used but not sold (sugar, milk, cups): a stock item with no product.
  /// Always counted by hand. [count] > 0 is how many are on the shelf now (saved as a first count).
  void addInternalItem(String name, {int? lowStockAt, int count = 0}) {
    // TODO: UUID v7 like the database ids, when SQLite arrives.
    final id = 's${DateTime.now().microsecondsSinceEpoch}';
    _stockItems.add(StockItem(id: id, name: name, deductsOnSale: false, lowStockAt: lowStockAt));
    if (count > 0) _writeMovement(id, StockMovementKind.count, count, setTo: count);
    notifyListeners();
  }

  /// true for an item no product draws from (sugar, milk): it has its own name.
  bool isInternal(StockItem item) => !_products.any((p) => p.stockItemId == item.id);

  /// Changes how an item is counted and its low-stock level. The number on hand stays.
  /// [name] renames it; only an internal item has a name of its own (a product's item follows the product).
  void updateStockItem(String stockItemId, {String? name, required bool deductsOnSale, int? lowStockAt}) {
    final index = _stockItems.indexWhere((s) => s.id == stockItemId);
    if (index == -1) return;
    final item = _stockItems[index];
    _stockItems[index] = StockItem(
      id: item.id,
      name: name ?? item.name,
      deductsOnSale: deductsOnSale,
      onHand: item.onHand,
      lowStockAt: lowStockAt,
    );
    notifyListeners();
  }

  /// Stops counting: the stock item and its log go. The product stays on the menu, uncounted.
  void stopTracking(String stockItemId) {
    _removeStockItem(stockItemId);
    notifyListeners();
  }

  /// Removes a stock item and its log, and unlinks its product. Does not notify: the caller does.
  void _removeStockItem(String stockItemId) {
    _stockItems.removeWhere((s) => s.id == stockItemId);
    _movements.removeWhere((m) => m.stockItemId == stockItemId);
    for (var i = 0; i < _products.length; i++) {
      if (_products[i].stockItemId == stockItemId) _products[i] = _products[i].withStockItem(null);
    }
  }

  /// The bill's order lines for a unit (empty if nothing was ordered).
  List<OrderLine> ordersFor(String unitId) => List.unmodifiable(_orders[unitId] ?? const []);

  /// Sum of the order lines for a unit.
  int ordersTotal(String unitId) => ordersFor(unitId).fold(0, (sum, line) => sum + line.total);

  /// Adds products to a unit's bill. [quantities]: product id -> how many.
  /// Ordering a product that is already on the bill raises that line's quantity.
  void addOrder(String unitId, Map<String, int> quantities) {
    final lines = _orders.putIfAbsent(unitId, () => []);
    quantities.forEach((productId, quantity) {
      if (quantity <= 0) return;
      final product = products.firstWhere((p) => p.id == productId);
      _sellFromStock(productId, quantity);
      final index = lines.indexWhere((l) => l.productId == productId);
      if (index == -1) {
        lines.add(OrderLine(productId: product.id, name: product.name, unitPrice: product.price, quantity: quantity));
      } else {
        lines[index] = lines[index].withQuantity(lines[index].quantity + quantity);
      }
    });
    notifyListeners();
  }

  /// Takes a whole line off the bill (the order was a mistake). No confirmation: the bill is still unpaid.
  void removeOrderLine(String unitId, String productId) {
    final lines = _orders[unitId];
    final index = lines?.indexWhere((l) => l.productId == productId) ?? -1;
    if (index == -1) return;
    _sellFromStock(productId, -lines![index].quantity); // negative: the stock comes back
    lines.removeAt(index);
    notifyListeners();
  }

  /// "اشتريت": one shopping trip. [quantities]: stock item id -> how many arrived. [total] is what
  /// the receipt said (whole EGP). Saves the trip and one log entry per item, and adds to the shelf.
  void recordPurchase(Map<String, int> quantities, {required int total}) {
    final bought = {
      for (final entry in quantities.entries)
        if (entry.value > 0 && _stockItems.any((s) => s.id == entry.key)) entry.key: entry.value,
    };
    if (bought.isEmpty || total < 0) return;
    // TODO: UUID v7 like the database ids, when SQLite arrives.
    final id = 'b${DateTime.now().microsecondsSinceEpoch}';
    _purchases.add(Purchase(id: id, total: total, at: DateTime.now()));
    bought.forEach((itemId, quantity) {
      _writeMovement(itemId, StockMovementKind.purchase, quantity, delta: quantity, purchaseId: id);
    });
    notifyListeners();
  }

  /// "فتحت علبة": [quantity] (usually 1) tins/packets were opened for use.
  void recordOpened(String stockItemId, [int quantity = 1]) {
    if (quantity <= 0) return;
    if (_writeMovement(stockItemId, StockMovementKind.opened, quantity, delta: -quantity)) notifyListeners();
  }

  /// "تعديل الرقم": the shelf was counted and [counted] is what is there. Replaces the number on hand.
  /// The log keeps what the app expected and the optional [note] (why it changed).
  void recordCount(String stockItemId, int counted, {String? note}) {
    if (counted < 0) return;
    final index = _stockItems.indexWhere((s) => s.id == stockItemId);
    if (index == -1) return;
    final trimmed = note?.trim();
    if (_writeMovement(
      stockItemId,
      StockMovementKind.count,
      counted,
      setTo: counted,
      expected: _stockItems[index].onHand,
      note: trimmed == null || trimmed.isEmpty ? null : trimmed,
    )) {
      notifyListeners();
    }
  }

  /// Writes the log entry and changes the number on hand, together. Does not notify: the caller does.
  /// false if the stock item does not exist.
  bool _writeMovement(
    String stockItemId,
    StockMovementKind kind,
    int quantity, {
    int? delta,
    int? setTo,
    String? purchaseId,
    int? expected,
    String? note,
  }) {
    final index = _stockItems.indexWhere((s) => s.id == stockItemId);
    if (index == -1) return false;
    final item = _stockItems[index];
    _stockItems[index] = item.withOnHand(setTo ?? item.onHand + delta!);
    // TODO: UUID v7 like the database ids, when SQLite arrives.
    _movements.add(StockMovement(
      id: 'm${DateTime.now().microsecondsSinceEpoch}',
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

  /// A sale takes [quantity] off the stock item of that product, if that item is subtracted on sale
  /// (negative [quantity] gives it back). No log entry: the order line is the record.
  /// Does not notify: the caller already does.
  void _sellFromStock(String productId, int quantity) {
    final product = _products.where((p) => p.id == productId).firstOrNull;
    final stockId = product?.stockItemId;
    if (stockId == null) return;
    final index = _stockItems.indexWhere((s) => s.id == stockId);
    if (index == -1 || !_stockItems[index].deductsOnSale) return;
    _stockItems[index] = _stockItems[index].withOnHand(_stockItems[index].onHand - quantity);
  }

  /// Takes a free unit out of service. A unit with a session must be paid first, so
  /// anything but a free unit is ignored.
  void setMaintenance(String unitId, {String? note}) {
    final unit = unitById(unitId);
    if (unit.status != UnitStatus.free) return;
    _replace(unit.asInMaintenance(note));
  }

  /// Puts a unit in maintenance back to work (free).
  void clearMaintenance(String unitId) {
    final unit = unitById(unitId);
    if (unit.status != UnitStatus.maintenance) return;
    _replace(unit.asFree());
  }

  /// Ends the session on [unitId] and saves its bill. [endedAt] is the moment the checkout
  /// form opened (the amount staff saw). A discount is clamped between 0 and the subtotal.
  Bill endAndPay(
    String unitId, {
    required DateTime endedAt,
    int discount = 0,
    String? discountReason,
    required PaymentMethod method,
  }) {
    final unit = unitById(unitId);
    final lines = ordersFor(unitId);
    final playCost = unit.costAt(endedAt);
    final subtotal = playCost + lines.fold<int>(0, (sum, line) => sum + line.total);

    final bill = Bill(
      unitId: unit.id,
      unitName: unit.name,
      startedAt: unit.startedAt!,
      endedAt: endedAt,
      isMulti: unit.isMulti,
      hourlyPrice: unit.isMulti ? unit.multiHourlyPrice! : unit.hourlyPrice,
      playCost: playCost,
      lines: lines,
      discount: math.min(math.max(discount, 0), subtotal),
      discountReason: discountReason,
      method: method,
    );
    _bills.add(bill);
    _orders.remove(unitId);
    _replace(unit.asFree()); // notifies the screens
    return bill;
  }

  void _replace(Unit updated) {
    final index = _units.indexWhere((u) => u.id == updated.id);
    _units[index] = updated;
    notifyListeners();
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }
}
