import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../data/product.dart';
import '../l10n/l10n.dart';
import '../shell/form_surface.dart';

/// What staff did in the product form.
class ProductFormResult {
  const ProductFormResult({required this.name, required this.price}) : delete = false;

  /// "Delete this product" instead of saving.
  const ProductFormResult.delete()
      : name = '',
        price = 0,
        delete = true;

  final String name;
  final int price;
  final bool delete;
}

/// Add a product ([product] null) or edit one. Returns null if closed without saving.
Future<ProductFormResult?> showProductForm(BuildContext context, {Product? product}) =>
    showFormSurface<ProductFormResult>(context, _ProductForm(product: product));

class _ProductForm extends StatefulWidget {
  const _ProductForm({this.product});

  final Product? product;

  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  late final _name = TextEditingController(text: widget.product?.name);
  late final _price = TextEditingController(text: widget.product?.price.toString());

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  int get _priceValue => int.tryParse(_price.text) ?? 0;
  bool get _canSave => _name.text.trim().isNotEmpty && _priceValue > 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final product = widget.product;
    return Padding(
      padding: const EdgeInsetsDirectional.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormHeader(title: l10n.menuTitle, heading: product?.name ?? l10n.newProduct),
          const SizedBox(height: 18),
          Text(l10n.productNameLabel, style: AppText.label),
          const SizedBox(height: 10),
          TextField(
            controller: _name,
            onChanged: (_) => setState(() {}), // redraw so the save button can enable
          ),
          const SizedBox(height: 18),
          Text(l10n.productPriceLabel, style: AppText.label),
          const SizedBox(height: 10),
          TextField(
            controller: _price,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: _canSave
                ? () => Navigator.pop(context, ProductFormResult(name: _name.text.trim(), price: _priceValue))
                : null,
            style: FilledButton.styleFrom(minimumSize: const Size(0, 60)),
            child: Text(l10n.saveProduct, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          if (product != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context, const ProductFormResult.delete()),
              style: TextButton.styleFrom(foregroundColor: AppColors.alert),
              child: Text(l10n.deleteProduct),
            ),
          ],
        ],
      ),
    );
  }
}
