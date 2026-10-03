import 'product.dart';

enum PaymentMethod { cash, instapay, wallet }

/// A paid session, saved as a receipt. It copies everything it needs (unit name, prices,
/// order lines), so later changes to units or products never rewrite old bills.
class Bill {
  const Bill({
    this.unitId,
    this.unitName,
    required this.startedAt,
    required this.endedAt,
    required this.isMulti,
    required this.hourlyPrice,
    required this.playCost,
    required this.lines,
    required this.discount,
    this.discountReason,
    required this.method,
  });

  final String? unitId; // null = a quick sale (no unit, no session)
  final String? unitName;
  final DateTime startedAt;
  final DateTime endedAt;
  final bool isMulti;
  final int hourlyPrice; // the price per hour that applied (single or multi)
  final int playCost;
  final List<OrderLine> lines;
  final int discount; // piasters taken off, never more than the subtotal
  final String? discountReason;
  final PaymentMethod method;

  /// Drinks or snacks sold to someone who is not playing: a bill with order lines and no unit.
  Bill.quickSale({required DateTime at, required this.lines, required this.method})
      : unitId = null,
        unitName = null,
        startedAt = at,
        endedAt = at,
        isMulti = false,
        hourlyPrice = 0,
        playCost = 0,
        discount = 0,
        discountReason = null;

  bool get isQuickSale => unitId == null;

  int get ordersTotal => lines.fold(0, (sum, line) => sum + line.total);
  int get subtotal => playCost + ordersTotal;

  /// What the customer paid.
  int get total => subtotal - discount;
}
