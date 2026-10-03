import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_theme.dart';
import '../data/catalog_provider.dart';
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
/// It watches the catalog, so it redraws itself when the stock changes.
class InventorySection extends ConsumerWidget {
  const InventorySection({super.key});

  // Each action reads what it needs from `ref` BEFORE its first await: after a form closes the
  // page may be gone, and `ref` must not be used then.

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final catalog = ref.read(catalogProvider.notifier);
    final result = await showStockItemForm(context, untracked: ref.read(catalogProvider).untrackedProducts);
    if (result == null) return;
    final productId = result.productId;
    final name = result.name;
    if (productId != null) {
      catalog.startTracking(productId, deductsOnSale: result.deductsOnSale, lowStockAt: result.lowStockAt, count: result.count);
    } else if (name != null) {
      catalog.addInternalItem(name, lowStockAt: result.lowStockAt, count: result.count);
    }
  }

  Future<void> _buy(BuildContext context, WidgetRef ref) async {
    final catalog = ref.read(catalogProvider.notifier);
    final result = await showPurchaseForm(context, ref.read(catalogProvider).stockItems);
    if (result == null) return;
    catalog.recordPurchase(result.lines);
  }

  Future<void> _open(BuildContext context, WidgetRef ref, StockItem item) async {
    final catalog = ref.read(catalogProvider.notifier);
    final result = await showStockAction(context, item);
    if (result == null) return;
    if (result.settings) {
      if (!context.mounted) return; // the page may be gone while the first form was open
      return _settings(context, ref, item);
    }
    switch (result.action) {
      case StockAction.opened:
        catalog.recordOpened(item.id, result.quantity);
      case StockAction.count:
        catalog.recordCount(item.id, result.quantity, note: result.note);
    }
  }

  Future<void> _settings(BuildContext context, WidgetRef ref, StockItem item) async {
    final catalog = ref.read(catalogProvider.notifier);
    final internal = ref.read(catalogProvider).isInternal(item);
    final result = await showStockItemForm(context, item: item, itemIsInternal: internal);
    if (result == null) return;
    if (result.delete) {
      catalog.stopTracking(item.id);
    } else {
      catalog.updateStockItem(
        item.id,
        name: internal ? result.name : null,
        deductsOnSale: result.deductsOnSale,
        lowStockAt: result.lowStockAt,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final items = ref.watch(catalogProvider).stockItems;
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
                Expanded(child: AddCard(label: l10n.addToStock, onTap: () => _add(context, ref))),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: items.isEmpty ? null : () => _buy(context, ref),
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
                _StockRow(item: item, onTap: () => _open(context, ref, item)),
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
