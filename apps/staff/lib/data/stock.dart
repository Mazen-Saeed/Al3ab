/// Something bought and counted: a coffee tin, a tea packet, a can of Pepsi.
/// A Product is what is sold; several products may draw from one stock item.
class StockItem {
  const StockItem({
    required this.id,
    required this.name,
    required this.deductsOnSale,
    this.onHand = 0,
    this.lowStockAt,
  });

  final String id;
  final String name;

  /// true: every sale subtracts its quantity (Pepsi, chips).
  /// false: a sale subtracts nothing; staff record bought / opened / counted by hand (tea, coffee).
  final bool deductsOnSale;

  /// What is on the shelf now. May go below 0: an offline sale is never refused.
  final int onHand;

  /// Warn at or below this number. Null = no warning.
  final int? lowStockAt;

  bool get isLow => lowStockAt != null && onHand <= lowStockAt!;

  StockItem withName(String name) => StockItem(
        id: id,
        name: name,
        deductsOnSale: deductsOnSale,
        onHand: onHand,
        lowStockAt: lowStockAt,
      );

  StockItem withOnHand(int onHand) => StockItem(
        id: id,
        name: name,
        deductsOnSale: deductsOnSale,
        onHand: onHand,
        lowStockAt: lowStockAt,
      );
}

/// What staff did by hand to a stock item. Sales are not recorded here:
/// they already exist as order lines and bills.
enum StockMovementKind {
  /// More arrived on a shopping trip: quantity is how many (> 0).
  purchase,

  /// A tin/packet was opened for use (> 0, usually 1). For items a sale does not subtract.
  opened,

  /// The shelf was counted ("edit number"): quantity is what is there now (>= 0).
  /// Replaces the number on hand.
  count,
}

/// One entry in the log. Never changed after it is written (a mistake is fixed by a new entry).
class StockMovement {
  const StockMovement({
    required this.id,
    required this.stockItemId,
    required this.kind,
    required this.quantity,
    required this.at,
    this.purchaseId,
    this.expected,
    this.note,
  });

  final String id;
  final String stockItemId;
  final StockMovementKind kind;
  final int quantity;
  final DateTime at;

  /// Purchase only: the shopping trip it belongs to.
  final String? purchaseId;

  /// Count only: what the app expected on the shelf. quantity - expected = found extra (+) or missing (-).
  final int? expected;

  /// Count only: why the number changed ("a bottle broke"). Optional.
  final String? note;
}

/// One shopping trip: the total on the receipt. The items bought are
/// [StockMovement]s of kind purchase with this [id] as their purchaseId.
class Purchase {
  const Purchase({required this.id, required this.total, required this.at});

  final String id;
  final int total; // whole EGP
  final DateTime at;
}
