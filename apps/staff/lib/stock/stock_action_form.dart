import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../data/stock.dart';
import '../l10n/l10n.dart';
import '../shell/form_surface.dart';
import 'stock_text.dart';

/// What staff can do to one stock item here. (Buying is the "اشتريت" button of the stock section.)
enum StockAction {
  /// "فتحت علبة": a tin/packet was opened (items a sale does not subtract).
  opened,

  /// "تعديل الرقم": staff counted the shelf and typed what is really there.
  count,
}

/// What staff did in the form: record something, or ask for the item's settings.
class StockActionResult {
  const StockActionResult(this.action, this.quantity, {this.note}) : settings = false;

  /// "Item settings" instead of recording.
  const StockActionResult.settings()
      : action = StockAction.count,
        quantity = 0,
        note = null,
        settings = true;

  final StockAction action;
  final int quantity;

  /// Count only: why the number changed. Optional.
  final String? note;
  final bool settings;
}

/// Opens the form for one stock item. Returns null if closed without doing anything.
Future<StockActionResult?> showStockAction(BuildContext context, StockItem item) =>
    showFormSurface<StockActionResult>(context, _StockActionForm(item: item));

class _StockActionForm extends StatefulWidget {
  const _StockActionForm({required this.item});

  final StockItem item;

  @override
  State<_StockActionForm> createState() => _StockActionFormState();
}

class _StockActionFormState extends State<_StockActionForm> {
  // An item a sale subtracts from only ever needs its number fixed, so it opens on the count form.
  // Tea and coffee start on two buttons: "opened" (one tap) and "edit the number".
  late bool _counting = widget.item.deductsOnSale;
  final _quantity = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _quantity.dispose();
    _note.dispose();
    super.dispose();
  }

  int? get _value => int.tryParse(_quantity.text);

  /// "ناقص 4 عن البرنامج" / "زيادة 2 عن البرنامج" / "مطابق": the counted number against the app's.
  String _gapText(AppLocalizations l10n, int counted) {
    final gap = counted - widget.item.onHand;
    if (gap < 0) return l10n.stockDiffShort(-gap);
    if (gap > 0) return l10n.stockDiffExtra(gap);
    return l10n.stockDiffNone;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final item = widget.item;
    final counted = _value;
    return Padding(
      padding: const EdgeInsetsDirectional.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormHeader(title: l10n.stockTitle, heading: item.name),
          const SizedBox(height: 6),
          Text(
            stockLeftText(l10n, item),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: item.isLow ? AppColors.waitingPayment : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 22),
          if (!_counting) ...[
            // One tap: one tin was opened. Opened twice? Tap twice. A real mismatch is "edit the number".
            FilledButton(
              onPressed: () => Navigator.pop(context, const StockActionResult(StockAction.opened, 1)),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 60)),
              child: Text(l10n.stockOpened, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => setState(() => _counting = true),
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 60)),
              child: Text(l10n.stockCount, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
          ] else ...[
            Text(l10n.stockCountedLabel, style: AppText.label),
            const SizedBox(height: 4),
            Text(l10n.stockCountHint, style: AppText.small),
            const SizedBox(height: 10),
            TextField(
              controller: _quantity,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}), // redraw so the gap and the button update
            ),
            if (counted != null) ...[
              const SizedBox(height: 8),
              Text(
                _gapText(l10n, counted),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: counted == item.onHand ? AppColors.textMuted : AppColors.waitingPayment,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Text(l10n.stockNoteLabel, style: AppText.label),
            const SizedBox(height: 10),
            TextField(controller: _note, decoration: InputDecoration(hintText: l10n.stockNoteHint)),
            const SizedBox(height: 22),
            // A count may be 0 (empty shelf).
            FilledButton(
              onPressed: counted == null
                  ? null
                  : () => Navigator.pop(context, StockActionResult(StockAction.count, counted, note: _note.text)),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 60)),
              child: Text(l10n.stockRecord, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
          ],
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context, const StockActionResult.settings()),
            child: Text(l10n.stockEdit),
          ),
        ],
      ),
    );
  }
}
