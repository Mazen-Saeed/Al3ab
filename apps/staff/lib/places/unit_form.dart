import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/money.dart';
import '../data/price_category.dart';
import '../data/unit.dart';
import '../floor/floor_sections.dart';
import '../l10n/l10n.dart';
import '../shell/form_surface.dart';
import '../shell/pill.dart';

/// What staff did in the unit form: the new values, or "delete this unit".
class UnitFormResult {
  const UnitFormResult({
    required this.name,
    required this.type,
    required this.hourlyPrice,
    this.multiHourlyPrice,
    this.categoryId,
  }) : delete = false;

  /// "Delete this unit" instead of saving.
  const UnitFormResult.delete()
      : name = '',
        type = UnitType.playstation,
        hourlyPrice = 0,
        multiHourlyPrice = null,
        categoryId = null,
        delete = true;

  final String name;
  final UnitType type;
  final int hourlyPrice; // piasters
  final int? multiHourlyPrice; // piasters, null = no multi mode
  final String? categoryId; // the price category chosen
  final bool delete;
}

/// New unit ([unit] null) or change one. [heading] is the big line (the room for a new unit, the
/// unit's name for an edit). Returns null if closed without saving.
/// [categories] are the price categories the owner can pick from.
Future<UnitFormResult?> showUnitForm(
  BuildContext context, {
  required String heading,
  required List<PriceCategory> categories,
  Unit? unit,
}) =>
    showFormSurface<UnitFormResult>(context, _UnitForm(heading: heading, categories: categories, unit: unit));

class _UnitForm extends StatefulWidget {
  const _UnitForm({required this.heading, required this.categories, this.unit});

  final String heading;
  final List<PriceCategory> categories;
  final Unit? unit;

  @override
  State<_UnitForm> createState() => _UnitFormState();
}

class _UnitFormState extends State<_UnitForm> {
  late final _name = TextEditingController(text: widget.unit?.name);
  /// The chosen price category: the unit's own, else none yet (staff must pick one).
  late String? _categoryId = widget.categories.any((c) => c.id == widget.unit?.categoryId) ? widget.unit!.categoryId : null;
  late UnitType _type = widget.unit?.type ?? UnitType.playstation;

  /// A unit with a session keeps its type and prices until it is paid.
  bool get _busy => widget.unit?.hasSession ?? false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  PriceCategory? get _category => widget.categories.where((c) => c.id == _categoryId).firstOrNull;

  bool get _canSave => _name.text.trim().isNotEmpty && (_busy || _category != null);

  /// The unit's prices from the chosen category: pair price only for the kinds that can have one.
  UnitFormResult _result() {
    final category = _category;
    if (category == null) {
      // Busy unit: only the name changes, the units provider keeps the rest.
      final unit = widget.unit!;
      return UnitFormResult(name: _name.text.trim(), type: unit.type, hourlyPrice: unit.hourlyPrice);
    }
    return UnitFormResult(
      name: _name.text.trim(),
      type: _type,
      hourlyPrice: category.hourlyPrice,
      multiHourlyPrice: _type.hasPairPrice ? category.multiHourlyPrice : null,
      categoryId: category.id,
    );
  }

  /// "50 جنيه في الساعة · 70 جنيه في الساعة", only what this kind of unit uses.
  String _priceSummary(AppLocalizations l10n, PriceCategory category) => [
        l10n.pricePerHour(formatMoney(category.hourlyPrice)),
        if (_type.hasPairPrice && category.multiHourlyPrice != null) l10n.pricePerHour(formatMoney(category.multiHourlyPrice!)),
      ].join(' · ');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final unit = widget.unit;
    return Padding(
      padding: const EdgeInsetsDirectional.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormHeader(title: unit == null ? l10n.newDevice : l10n.editDevice, heading: widget.heading),
          const SizedBox(height: 18),
          Text(l10n.deviceNameLabel, style: AppText.label),
          const SizedBox(height: 10),
          TextField(
            controller: _name,
            decoration: InputDecoration(hintText: l10n.deviceNameHint),
            onChanged: (_) => setState(() {}), // redraw so the save button can enable
          ),
          // A unit with a session keeps its type and prices (the bill depends on them): don't show them.
          if (!_busy) ...[
            const SizedBox(height: 18),
            Text(l10n.deviceTypeLabel, style: AppText.label),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final type in UnitType.values)
                  Pill(
                    label: unitTypeName(type, l10n),
                    selected: _type == type,
                    onTap: () => setState(() => _type = type),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Text(l10n.priceCategoryLabel, style: AppText.label),
            const SizedBox(height: 10),
            if (widget.categories.isEmpty)
              Text(l10n.noPriceCategoryHint, style: AppText.small)
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in widget.categories)
                    Pill(
                      label: category.name,
                      selected: _categoryId == category.id,
                      onTap: () => setState(() => _categoryId = category.id),
                    ),
                ],
              ),
            if (_category != null) ...[
              const SizedBox(height: 8),
              Text(_priceSummary(l10n, _category!), style: AppText.small),
            ],
          ],
          if (_busy) ...[
            const SizedBox(height: 12),
            Text(l10n.deviceBusyHint, style: AppText.small),
          ],
          const SizedBox(height: 22),
          FilledButton(
            onPressed: _canSave
                ? () => Navigator.pop(
                      context,
                      _result(),
                    )
                : null,
            style: FilledButton.styleFrom(minimumSize: const Size(0, 60)),
            child: Text(l10n.save, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          if (unit != null && !_busy) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context, const UnitFormResult.delete()),
              style: TextButton.styleFrom(foregroundColor: AppColors.alert),
              child: Text(l10n.deleteDevice),
            ),
          ],
        ],
      ),
    );
  }
}
