import 'product.dart';

enum PaymentMethod { cash, instapay, wallet }

/// A paid session, saved as a receipt. It copies everything it needs (unit name, prices,
/// order lines), so later changes to units or products never rewrite old bills.
class Bill {
  const Bill({
    required this.unitId,
    required this.unitName,
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

  final String unitId;
  final String unitName;
  final DateTime startedAt;
  final DateTime endedAt;
  final bool isMulti;
  final int hourlyPrice; // the price per hour that applied (single or multi)
  final int playCost;
  final List<OrderLine> lines;
  final int discount; // EGP taken off, never more than the subtotal
  final String? discountReason;
  final PaymentMethod method;

  int get ordersTotal => lines.fold(0, (sum, line) => sum + line.total);
  int get subtotal => playCost + ordersTotal;

  /// What the customer paid.
  int get total => subtotal - discount;
}
