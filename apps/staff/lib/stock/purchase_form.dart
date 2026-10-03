import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../data/stock.dart';
import '../l10n/l10n.dart';
import '../shell/form_surface.dart';
import '../data/money.dart';

/// One shopping trip: what was bought and what the receipt said.
class PurchaseResult {
  const PurchaseResult({required this.quantities, required this.total});

  /// Stock item id -> how many arrived (only items with quantity > 0).
  final Map<String, int> quantities;

  /// The receipt total, piasters.
  final int total;
}

/// The "اشتريت" form: type how many of each item were bought on one trip, then what it cost in total.
/// Returns null if closed without saving.
Future<PurchaseResult?> showPurchaseForm(BuildContext context, List<StockItem> items) =>
    showFormSurface<PurchaseResult>(context, _PurchaseForm(items: items));

class _PurchaseForm extends StatefulWidget {
  const _PurchaseForm({required this.items});

  final List<StockItem> items;

  @override
  State<_PurchaseForm> createState() => _PurchaseFormState();
}

class _PurchaseFormState extends State<_PurchaseForm> {
  // One number field per item: type 50 instead of tapping + fifty times. Empty or 0 = not bought.
  late final Map<String, TextEditingController> _fields = {
    for (final item in widget.items) item.id: TextEditingController(),
  };
  final _total = TextEditingController();

  @override
  void dispose() {
    for (final field in _fields.values) {
      field.dispose();
    }
    _total.dispose();
    super.dispose();
  }

  int _quantityOf(String itemId) => int.tryParse(_fields[itemId]!.text) ?? 0;

  /// Stock item id -> how many, for the rows with a number above 0.
  Map<String, int> get _quantities => {
        for (final item in widget.items)
          if (_quantityOf(item.id) > 0) item.id: _quantityOf(item.id),
      };

  // Something bought and a total typed (0 is allowed: a gift).
  bool get _canSave => _quantities.isNotEmpty && parseMoney(_total.text) != null;

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
              controller: _fields[item.id]!,
              picked: _quantityOf(item.id) > 0,
              onChanged: () => setState(() {}), // redraw so the row highlights and the button can enable
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 10),
          Text(l10n.purchaseTotalLabel, style: AppText.label),
          const SizedBox(height: 10),
          TextField(
            key: const ValueKey('purchase-total'),
            controller: _total,
            keyboardType: moneyKeyboard,
            inputFormatters: moneyInputFormatters,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: _canSave
                ? () => Navigator.pop(context, PurchaseResult(quantities: _quantities, total: parseMoney(_total.text)!))
                : null,
            style: FilledButton.styleFrom(minimumSize: const Size(0, 60)),
            child: Text(l10n.purchaseConfirm, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

/// One item in the list: its name and a field for how many were bought. Cream once a number is typed.
class _PurchaseRow extends StatelessWidget {
  const _PurchaseRow({required this.item, required this.controller, required this.picked, required this.onChanged});

  final StockItem item;
  final TextEditingController controller;
  final bool picked;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: picked ? AppColors.running : AppColors.raised,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 6),
        child: Row(
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
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                decoration: const InputDecoration(hintText: '0'),
                onChanged: (_) => onChanged(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
