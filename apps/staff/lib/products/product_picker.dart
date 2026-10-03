import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/product.dart';
import '../l10n/l10n.dart';
import 'product_grid.dart';

/// A grid of products: tap one to add it, use − / + to change how many.
/// Stateless on purpose: the screen that uses it owns the quantities
/// (product id -> how many) and passes them back in. Reused by the order form
/// and, later, by Quick sale.
class ProductPicker extends StatelessWidget {
  const ProductPicker({super.key, required this.products, required this.quantities, required this.onChanged});

  final List<Product> products;
  final Map<String, int> quantities;
  final void Function(String productId, int quantity) onChanged;

  @override
  Widget build(BuildContext context) {
    return ProductGrid(
      itemCount: products.length,
      itemBuilder: (context, index, width) {
        final product = products[index];
        return _ProductCard(
          width: width,
          product: product,
          quantity: quantities[product.id] ?? 0,
          onChanged: (q) => onChanged(product.id, q),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.width, required this.product, required this.quantity, required this.onChanged});

  final double width;
  final Product product;
  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final picked = quantity > 0;
    return SizedBox(
      width: width,
      child: Material(
        color: picked ? AppColors.running : AppColors.raised,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onChanged(quantity + 1),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: picked ? AppColors.textOnLight : AppColors.text,
                  ),
                ),
                Text(
                  context.l10n.amountEgp(product.price),
                  style: TextStyle(color: picked ? AppColors.textOnLightMuted : AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                // Fixed height so the card does not jump when the stepper appears.
                SizedBox(
                  height: 40,
                  child: picked
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton.filled(
                              onPressed: () => onChanged(quantity - 1),
                              icon: const Icon(Icons.remove, size: 18),
                              style: _stepperStyle,
                            ),
                            Text(
                              '$quantity',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textOnLight,
                              ),
                            ),
                            IconButton.filled(
                              onPressed: () => onChanged(quantity + 1),
                              icon: const Icon(Icons.add, size: 18),
                              style: _stepperStyle,
                            ),
                          ],
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small round − / + buttons, sized to fit the narrowest card (phone, 2 per row).
final _stepperStyle = IconButton.styleFrom(
  backgroundColor: AppColors.textOnLight,
  foregroundColor: AppColors.running,
  minimumSize: const Size(36, 36),
  padding: EdgeInsets.zero,
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
);
