import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/shop_store.dart';
import '../data/stock.dart';
import '../l10n/l10n.dart';
import '../shell/add_card.dart';
import 'stock_action_form.dart';
import 'purchase_form.dart';
import 'stock_item_form.dart';
import 'stock_text.dart';

/// The inventory section (المخزون) of the Products page: what is on the shelves, one row per
/// counted item (menu products, and things used but not sold, like sugar and milk).
/// - Tap a row to fix its number, record an opened tin, or open its settings.
/// - Under the heading: "+ صنف جديد" (add an item) and "اشتريت" (a shopping trip, several items at once).
/// The parent redraws it when the store changes.
class InventorySection extends StatelessWidget {
  const InventorySection({super.key, required this.store});

  final ShopStore store;

  Future<void> _add(BuildContext context) async {
    final result = await showStockItemForm(context, untracked: store.untrackedProducts);
    if (result == null) return;
    final productId = result.productId;
    final name = result.name;
    if (productId != null) {
      store.startTracking(productId, deductsOnSale: result.deductsOnSale, lowStockAt: result.lowStockAt, count: result.count);
    } else if (name != null) {
      store.addInternalItem(name, lowStockAt: result.lowStockAt, count: result.count);
    }
  }

  Future<void> _buy(BuildContext context) async {
    final result = await showPurchaseForm(context, store.stockItems);
    if (result == null) return;
    store.recordPurchase(result.quantities, total: result.total);
  }

  Future<void> _open(BuildContext context, StockItem item) async {
    final result = await showStockAction(context, item);
    if (result == null) return;
    if (result.settings) {
      if (!context.mounted) return; // the page may be gone while the first form was open
      return _settings(context, item);
    }
    switch (result.action) {
      case StockAction.opened:
        store.recordOpened(item.id, result.quantity);
      case StockAction.count:
        store.recordCount(item.id, result.quantity, note: result.note);
    }
  }

  Future<void> _settings(BuildContext context, StockItem item) async {
    final internal = store.isInternal(item);
    final result = await showStockItemForm(context, item: item, itemIsInternal: internal);
    if (result == null) return;
    if (result.delete) {
      store.stopTracking(item.id);
    } else {
      store.updateStockItem(
        item.id,
        name: internal ? result.name : null,
        deductsOnSale: result.deductsOnSale,
        lowStockAt: result.lowStockAt,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = store.stockItems;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.stockTitle, style: AppText.sectionTitle),
        const SizedBox(height: 2),
        Text(l10n.stockSubtitle, style: AppText.small),
        const SizedBox(height: 12),
        // Same height side by side.
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: AddCard(label: l10n.addToStock, onTap: () => _add(context))),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: items.isEmpty ? null : () => _buy(context),
                  icon: const Icon(Icons.shopping_basket_outlined, size: 20),
                  label: Text(l10n.stockBought),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.text,
                    side: const BorderSide(color: AppColors.raised, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        // A list, not a grid: each row is a name and a number, and reads best full width.
        // Capped so it doesn't stretch across a wide PC screen.
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final item in items) ...[
                _StockRow(item: item, onTap: () => _open(context, item)),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StockRow extends StatelessWidget {
  const _StockRow({required this.item, required this.onTap});

  final StockItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = item.isLow ? AppColors.waitingPayment : AppColors.text;
    return Material(
      color: AppColors.raised,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(item.deductsOnSale ? l10n.stockKindAuto : l10n.stockKindManual, style: AppText.small),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    stockLeftText(l10n, item),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color),
                  ),
                  if (item.isLow)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // The icon next to the colour: low stock is not shown by colour alone.
                        const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.waitingPayment),
                        const SizedBox(width: 4),
                        Text(l10n.stockLow, style: const TextStyle(fontSize: 13, color: AppColors.waitingPayment)),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
