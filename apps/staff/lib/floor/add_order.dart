import 'package:flutter/material.dart';

import '../data/product.dart';
import '../data/unit.dart';
import '../l10n/l10n.dart';
import '../shell/form_surface.dart';
import '../products/product_picker.dart';

/// Lets staff pick products for a unit's bill.
/// Returns product id -> quantity (only products with quantity > 0), or null if closed.
Future<Map<String, int>?> showAddOrder(BuildContext context, Unit unit, List<Product> products) =>
    showFormSurface<Map<String, int>>(context, _AddOrderForm(unit: unit, products: products));

class _AddOrderForm extends StatefulWidget {
  const _AddOrderForm({required this.unit, required this.products});

  final Unit unit;
  final List<Product> products;

  @override
  State<_AddOrderForm> createState() => _AddOrderFormState();
}

class _AddOrderFormState extends State<_AddOrderForm> {
  final Map<String, int> _quantities = {}; // product id -> how many (0 is removed)

  int get _sum {
    var sum = 0;
    for (final product in widget.products) {
      sum += product.price * (_quantities[product.id] ?? 0);
    }
    return sum;
  }

  void _change(String productId, int quantity) {
    setState(() {
      if (quantity <= 0) {
        _quantities.remove(productId);
      } else {
        _quantities[productId] = quantity;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsetsDirectional.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormHeader(title: l10n.addOrder, heading: widget.unit.name),
          const SizedBox(height: 18),
          // No scroll view here: showFormSurface already scrolls the whole form if it is too tall.
          ProductPicker(products: widget.products, quantities: _quantities, onChanged: _change),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: _quantities.isEmpty ? null : () => Navigator.pop(context, Map.of(_quantities)),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 60)),
            child: Text(
              _quantities.isEmpty ? l10n.addToBill : '${l10n.addToBill} · ${l10n.amountEgp(_sum)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
