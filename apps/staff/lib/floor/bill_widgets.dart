import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/product.dart';
import '../l10n/l10n.dart';
import '../data/money.dart';

/// A label on one side, an amount on the other. Used by the session panel and Checkout.
class BillRow extends StatelessWidget {
  const BillRow({super.key, required this.label, required this.value, this.detail, this.bold = false});

  final String label;
  final String value;
  final String? detail; // small grey line under the label
  final bool bold; // section headings (like "Orders") are bold

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 15, fontWeight: bold ? FontWeight.w700 : FontWeight.w400);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: style),
              if (detail != null) Text(detail!, style: AppText.small),
            ],
          ),
        ),
        Text(value, style: style),
      ],
    );
  }
}

/// One ordered product on a bill: "Pepsi · 2 × 15" and its total.
/// With [onRemove], a small button at the start takes the line off (session panel).
/// Without it (Checkout) the line is read-only.
class OrderRow extends StatelessWidget {
  const OrderRow({super.key, required this.line, this.onRemove});

  final OrderLine line;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Remove button first (start side), then the name, then the amount at the very end,
    // so every amount lines up in one column with the totals above.
    return Row(
      children: [
        if (onRemove != null) ...[
          IconButton(
            onPressed: onRemove,
            tooltip: l10n.removeItem,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: const Icon(Icons.remove_circle_outline, size: 20, color: AppColors.textMuted),
          ),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(l10n.orderLine(line.name, line.quantity, formatMoney(line.unitPrice)), style: AppText.small),
        ),
        Text(l10n.amountEgp(formatMoney(line.total)), style: AppText.small),
      ],
    );
  }
}
