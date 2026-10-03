import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_theme.dart';
import '../data/product.dart';
import '../data/catalog_provider.dart';
import '../l10n/l10n.dart';
import '../shell/add_card.dart';
import '../stock/inventory_section.dart';
import 'product_form.dart';
import 'product_grid.dart';

/// The "Menu and stock" page (Manage), two parts, each with its own buttons:
/// 1. المنيو: what customers buy. "+ منتج للمنيو", then the products. Tap one to change its name or price.
/// 2. المخزون: what is on the shelves (see InventorySection): "+ صنف جديد" and "اشتريت".
/// Changes go through the catalog, so the order form sees them straight away.
class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key, required this.onBack});

  final VoidCallback onBack; // back to the Manage list

  Future<void> _edit(BuildContext context, WidgetRef ref, Product? product) async {
    final catalog = ref.read(catalogProvider.notifier); // before the await: ref is not safe once the page is gone
    final result = await showProductForm(context, product: product);
    if (result == null) return;
    if (product == null) {
      catalog.addProduct(result.name, result.price);
    } else if (result.delete) {
      catalog.deleteProduct(product.id);
    } else {
      catalog.updateProduct(product.id, name: result.name, price: result.price);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final products = ref.watch(catalogProvider).products; // redraws when the menu changes
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton.filledTonal(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
            const SizedBox(width: 14),
            Text(l10n.productsTitle, style: AppText.sectionTitle),
          ],
        ),
        const SizedBox(height: 18),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. The menu: what customers buy. Its own "+" sits right under the heading.
                Text(l10n.menuTitle, style: AppText.sectionTitle),
                const SizedBox(height: 2),
                Text(l10n.menuSubtitle, style: AppText.small),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: AddCard(label: l10n.newProduct, onTap: () => _edit(context, ref, null)),
                ),
                const SizedBox(height: 12),
                ProductGrid(
                  itemCount: products.length,
                  itemBuilder: (context, index, width) =>
                      _ProductCard(width: width, product: products[index], onTap: () => _edit(context, ref, products[index])),
                ),
                const SizedBox(height: 30),
                // 2. Stock: what is on the shelves, with its own buttons.
                const InventorySection(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.width, required this.product, required this.onTap});

  final double width;
  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: AppColors.raised,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(context.l10n.amountEgp(product.price), style: AppText.small),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
