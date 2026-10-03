import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/money.dart';
import '../data/price_category.dart';
import '../l10n/l10n.dart';
import '../shell/form_surface.dart';

/// What the owner did in the price form.
class CategoryFormResult {
  const CategoryFormResult({required this.name, required this.hourlyPrice, this.multiHourlyPrice}) : delete = false;

  /// "Delete this price" instead of saving.
  const CategoryFormResult.delete()
      : name = '',
        hourlyPrice = 0,
        multiHourlyPrice = null,
        delete = true;

  final String name;
  final int hourlyPrice; // piasters
  final int? multiHourlyPrice; // piasters, null = none
  final bool delete;
}

/// New price ([category] null) or change one. [inUse]: devices use it, so it cannot be deleted.
/// Returns null if closed without saving.
Future<CategoryFormResult?> showCategoryForm(BuildContext context, {PriceCategory? category, bool inUse = false}) =>
    showFormSurface<CategoryFormResult>(context, _CategoryForm(category: category, inUse: inUse));

class _CategoryForm extends StatefulWidget {
  const _CategoryForm({this.category, required this.inUse});

  final PriceCategory? category;
  final bool inUse;

  @override
  State<_CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<_CategoryForm> {
  late final _name = TextEditingController(text: widget.category?.name);
  late final _price =
      TextEditingController(text: widget.category == null ? null : formatMoney(widget.category!.hourlyPrice));
  late final _multi = TextEditingController(
    text: widget.category?.multiHourlyPrice == null ? null : formatMoney(widget.category!.multiHourlyPrice!),
  );

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _multi.dispose();
    super.dispose();
  }

  int get _priceValue => parseMoney(_price.text) ?? 0;
  int? get _multiValue => parseMoney(_multi.text);

  /// Empty is fine (no such price); something typed must be a real number.
  bool _optionalOk(TextEditingController c, int? value) => c.text.trim().isEmpty || value != null;

  bool get _canSave => _name.text.trim().isNotEmpty && _priceValue > 0 && _optionalOk(_multi, _multiValue);

  Widget _moneyField(String label, TextEditingController controller, Key key) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 18),
          Text(label, style: AppText.label),
          const SizedBox(height: 10),
          TextField(
            key: key,
            controller: controller,
            keyboardType: moneyKeyboard,
            inputFormatters: moneyInputFormatters,
            onChanged: (_) => setState(() {}),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final category = widget.category;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormHeader(title: l10n.pricesTitle, heading: category?.name ?? l10n.newPriceCategory),
            const SizedBox(height: 18),
            Text(l10n.priceNameLabel, style: AppText.label),
            const SizedBox(height: 10),
            TextField(
              key: const ValueKey('price-name'),
              controller: _name,
              decoration: InputDecoration(hintText: l10n.priceNameHint),
              onChanged: (_) => setState(() {}),
            ),
            _moneyField(l10n.singlePriceLabel, _price, const ValueKey('price-hourly')),
            _moneyField(l10n.multiPriceLabel, _multi, const ValueKey('price-multi')),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: _canSave
                  ? () => Navigator.pop(
                        context,
                        CategoryFormResult(
                          name: _name.text.trim(),
                          hourlyPrice: _priceValue,
                          multiHourlyPrice: _multiValue,
                        ),
                      )
                  : null,
              style: FilledButton.styleFrom(minimumSize: const Size(0, 60)),
              child: Text(l10n.save, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            if (category != null && !widget.inUse) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context, const CategoryFormResult.delete()),
                style: TextButton.styleFrom(foregroundColor: AppColors.alert),
                child: Text(l10n.deletePriceCategory),
              ),
            ],
            if (category != null && widget.inUse) ...[
              const SizedBox(height: 12),
              Text(l10n.priceCategoryInUse, style: AppText.small),
            ],
          ],
        ),
      ),
    );
  }
}
