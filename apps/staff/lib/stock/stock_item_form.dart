import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../data/product.dart';
import '../data/stock.dart';
import '../l10n/l10n.dart';
import '../shell/form_surface.dart';
import '../shell/pill.dart';

/// What staff did in the stock item form.
class StockItemFormResult {
  const StockItemFormResult({
    this.productId,
    this.name,
    required this.deductsOnSale,
    this.lowStockAt,
    this.count = 0,
  }) : delete = false;

  /// "Remove from stock" instead of saving.
  const StockItemFormResult.delete()
      : productId = null,
        name = null,
        deductsOnSale = true,
        lowStockAt = null,
        count = 0,
        delete = true;

  /// New item for a menu product: which product to start counting.
  final String? productId;

  /// An item with no product (sugar, milk): its own name.
  final String? name;
  final bool deductsOnSale;
  final int? lowStockAt;

  /// New item only: how many are on the shelf now.
  final int count;
  final bool delete;
}

/// Add something to the inventory ([item] null: a product from [untracked], or an internal item)
/// or edit an item ([itemIsInternal]: it has no product, so it has its own name).
/// Returns null if closed without saving.
Future<StockItemFormResult?> showStockItemForm(
  BuildContext context, {
  StockItem? item,
  bool itemIsInternal = false,
  List<Product> untracked = const [],
}) =>
    showFormSurface<StockItemFormResult>(
      context,
      _StockItemForm(item: item, itemIsInternal: itemIsInternal, untracked: untracked),
    );

class _StockItemForm extends StatefulWidget {
  const _StockItemForm({this.item, required this.itemIsInternal, required this.untracked});

  final StockItem? item;
  final bool itemIsInternal;
  final List<Product> untracked;

  @override
  State<_StockItemForm> createState() => _StockItemFormState();
}

class _StockItemFormState extends State<_StockItemForm> {
  late final _name = TextEditingController(text: widget.itemIsInternal ? widget.item?.name : null);
  late final _low = TextEditingController(text: widget.item?.lowStockAt?.toString());
  final _count = TextEditingController();
  late bool _deductsOnSale = widget.item?.deductsOnSale ?? true;

  // Internal = used but not sold. Editing keeps what the item is; adding starts with a menu product
  // if there is one still uncounted.
  late bool _internal = widget.item != null ? widget.itemIsInternal : widget.untracked.isEmpty;
  String? _productId; // adding a menu product only

  @override
  void dispose() {
    _name.dispose();
    _low.dispose();
    _count.dispose();
    super.dispose();
  }

  bool get _canSave => _internal ? _name.text.trim().isNotEmpty : (widget.item != null || _productId != null);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final item = widget.item;
    return Padding(
      padding: const EdgeInsetsDirectional.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormHeader(title: l10n.stockTitle, heading: item?.name ?? l10n.addToStock),
          if (item == null && widget.untracked.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(l10n.stockNewWhat, style: AppText.label),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Pill(label: l10n.stockNewProduct, selected: !_internal, onTap: () => setState(() => _internal = false)),
                Pill(label: l10n.stockNewInternal, selected: _internal, onTap: () => setState(() => _internal = true)),
              ],
            ),
          ],
          if (item == null && !_internal) ...[
            const SizedBox(height: 18),
            Text(l10n.stockPickProduct, style: AppText.label),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final product in widget.untracked)
                  Pill(
                    label: product.name,
                    selected: _productId == product.id,
                    onTap: () => setState(() => _productId = product.id),
                  ),
              ],
            ),
          ],
          if (_internal) ...[
            const SizedBox(height: 18),
            Text(l10n.stockInternalName, style: AppText.label),
            const SizedBox(height: 4),
            Text(l10n.stockInternalHint, style: AppText.small),
            const SizedBox(height: 10),
            TextField(controller: _name, onChanged: (_) => setState(() {})),
          ] else ...[
            const SizedBox(height: 18),
            Text(l10n.stockKindLabel, style: AppText.label),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Pill(label: l10n.stockKindAuto, selected: _deductsOnSale, onTap: () => setState(() => _deductsOnSale = true)),
                Pill(label: l10n.stockKindManual, selected: !_deductsOnSale, onTap: () => setState(() => _deductsOnSale = false)),
              ],
            ),
            const SizedBox(height: 8),
            Text(_deductsOnSale ? l10n.stockKindAutoHint : l10n.stockKindManualHint, style: AppText.small),
          ],
          if (item == null) ...[
            // Only for a new item: after that, the number changes through اشتريت / تعديل الرقم,
            // so the log of what happened stays complete.
            const SizedBox(height: 18),
            Text(l10n.stockCurrentLabel, style: AppText.label),
            const SizedBox(height: 10),
            TextField(
              controller: _count,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
          const SizedBox(height: 18),
          Text(l10n.stockLowLabel, style: AppText.label),
          const SizedBox(height: 10),
          TextField(
            controller: _low,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: _canSave
                ? () => Navigator.pop(
                      context,
                      StockItemFormResult(
                        productId: _internal ? null : _productId,
                        name: _internal ? _name.text.trim() : null,
                        deductsOnSale: _internal ? false : _deductsOnSale, // an internal item is always counted by hand
                        lowStockAt: int.tryParse(_low.text),
                        count: int.tryParse(_count.text) ?? 0,
                      ),
                    )
                : null,
            style: FilledButton.styleFrom(minimumSize: const Size(0, 60)),
            child: Text(l10n.saveStockItem, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          if (item != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context, const StockItemFormResult.delete()),
              style: TextButton.styleFrom(foregroundColor: AppColors.alert),
              child: Text(l10n.removeFromStock),
            ),
          ],
        ],
      ),
    );
  }
}
