import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../data/money.dart';
import '../data/stock.dart';
import '../l10n/l10n.dart';
import '../shell/form_surface.dart';

/// One shopping trip: what was bought and what each line cost.
class PurchaseResult {
  const PurchaseResult({required this.lines});

  /// Stock item id -> how many arrived and what was paid for them (only items with quantity > 0).
  final Map<String, PurchaseLine> lines;
}

/// The "اشتريت" form: type how many of each item were bought on one trip, and for each one what it
/// cost (like the receipt). The total is worked out. Returns null if closed without saving.
Future<PurchaseResult?> showPurchaseForm(BuildContext context, List<StockItem> items) =>
    showFormSurface<PurchaseResult>(context, _PurchaseForm(items: items));

class _PurchaseForm extends StatefulWidget {
  const _PurchaseForm({required this.items});

  final List<StockItem> items;

  @override
  State<_PurchaseForm> createState() => _PurchaseFormState();
}

class _PurchaseFormState extends State<_PurchaseForm> {
  // Per item: how many (type 50 instead of tapping + fifty times; empty or 0 = not bought) and, once
  // a number is typed, what that line cost.
  late final Map<String, TextEditingController> _fields = {
    for (final item in widget.items) item.id: TextEditingController(),
  };
  late final Map<String, TextEditingController> _costs = {
    for (final item in widget.items) item.id: TextEditingController(),
  };

  @override
  void dispose() {
    for (final field in [..._fields.values, ..._costs.values]) {
      field.dispose();
    }
    super.dispose();
  }

  int _quantityOf(String itemId) => int.tryParse(_fields[itemId]!.text) ?? 0;

  /// Every item with a number above 0 whose cost is typed (0 is allowed: a gift).
  Map<String, PurchaseLine> get _lines => {
        for (final item in widget.items)
          if (_quantityOf(item.id) > 0 && parseMoney(_costs[item.id]!.text) != null)
            item.id: PurchaseLine(quantity: _quantityOf(item.id), cost: parseMoney(_costs[item.id]!.text)!),
      };

  int get _pickedCount => widget.items.where((item) => _quantityOf(item.id) > 0).length;

  // Something bought, and every bought item has its cost.
  bool get _canSave => _pickedCount > 0 && _lines.length == _pickedCount;

  int get _total => _lines.values.fold(0, (sum, line) => sum + line.cost);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsetsDirectional.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormHeader(title: l10n.stockTitle, heading: l10n.purchaseTitle),
          const SizedBox(height: 18),
          // No scroll view here: showFormSurface already scrolls the whole form if it is too tall.
          for (final item in widget.items) ...[
            _PurchaseRow(
              item: item,
              quantity: _fields[item.id]!,
              cost: _costs[item.id]!,
              picked: _quantityOf(item.id) > 0,
              onChanged: () => setState(() {}), // redraw so the row opens its cost field and the button can enable
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Text(l10n.purchaseTotalLabel, style: AppText.label)),
              Text(
                l10n.amountEgp(formatMoney(_total)),
                key: const ValueKey('purchase-total'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: _canSave ? () => Navigator.pop(context, PurchaseResult(lines: _lines)) : null,
            style: FilledButton.styleFrom(minimumSize: const Size(0, 60)),
            child: Text(l10n.purchaseConfirm, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

/// One item in the list: its name and a field for how many were bought. Once a number is typed the
/// row turns cream and asks what that line cost.
class _PurchaseRow extends StatelessWidget {
  const _PurchaseRow({
    required this.item,
    required this.quantity,
    required this.cost,
    required this.picked,
    required this.onChanged,
  });

  final StockItem item;
  final TextEditingController quantity;
  final TextEditingController cost;
  final bool picked;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: picked ? AppColors.running : AppColors.raised,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: picked ? AppColors.textOnLight : AppColors.text,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 96,
                  child: TextField(
                    key: ValueKey('buy-${item.id}'),
                    controller: quantity,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(hintText: '0'),
                    onChanged: (_) => onChanged(),
                  ),
                ),
              ],
            ),
            if (picked) ...[
              const SizedBox(height: 4),
              TextField(
                key: ValueKey('paid-${item.id}'),
                controller: cost,
                keyboardType: moneyKeyboard,
                inputFormatters: moneyInputFormatters,
                decoration: InputDecoration(hintText: context.l10n.purchasePaidHint),
                onChanged: (_) => onChanged(),
              ),
              const SizedBox(height: 6),
            ],
          ],
        ),
      ),
    );
  }
}
