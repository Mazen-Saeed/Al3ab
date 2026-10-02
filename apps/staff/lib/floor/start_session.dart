import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../l10n/l10n.dart';
import '../shell/form_surface.dart';
import 'duration_picker.dart';
import '../data/unit.dart';
import 'time_text.dart';

/// What staff chose in the form. Returned to the Floor screen when they press start.
class StartSessionResult {
  const StartSessionResult({required this.isMulti, this.plannedMinutes, this.customerText});

  final bool isMulti;
  final int? plannedMinutes; // null = open time
  final String? customerText; // null = walk-in (field left empty)
}

/// Opens the start form. Returns null if staff close it without starting.
Future<StartSessionResult?> showStartSession(BuildContext context, Unit unit) =>
    showFormSurface<StartSessionResult>(context, _StartSessionForm(unit: unit));

class _StartSessionForm extends StatefulWidget {
  const _StartSessionForm({required this.unit});

  final Unit unit;

  @override
  State<_StartSessionForm> createState() => _StartSessionFormState();
}

class _StartSessionFormState extends State<_StartSessionForm> {
  bool _isMulti = false;
  DurationChoice _duration = const DurationChoice(); // open time to begin with
  final _customer = TextEditingController(); // holds what staff typed

  @override
  void dispose() {
    _customer.dispose(); // a controller must be released, like IDisposable
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final unit = widget.unit;
    final reservation = unit.nextReservationAt;

    return Padding(
      padding: const EdgeInsetsDirectional.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min, // as tall as its content, not the whole screen
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormHeader(title: l10n.startSessionTitle, heading: unit.name),
          const SizedBox(height: 18),

          // Booking warning
          if (reservation != null) ...[
            Container(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: AppColors.reserved, borderRadius: BorderRadius.circular(18)),
              child: Row(
                children: [
                  const Icon(Icons.event_outlined, size: 18, color: AppColors.onReserved),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.reservedWarning(friendlyTime(l10n, reservation)),
                      style: const TextStyle(fontSize: 14, color: AppColors.onReserved),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          // Single / multi: only when this unit has a multi price
          if (unit.hasMultiMode) ...[
            Text(l10n.playType, style: AppText.label),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ModeButton(
                    title: l10n.modeSingle,
                    price: unit.hourlyPrice,
                    selected: !_isMulti,
                    onTap: () => setState(() => _isMulti = false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ModeButton(
                    title: l10n.modeMulti,
                    price: unit.multiHourlyPrice!,
                    selected: _isMulti,
                    onTap: () => setState(() => _isMulti = true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
          ],

          // Duration: open time, a preset, or typed minutes
          Text(l10n.durationLabel, style: AppText.label),
          const SizedBox(height: 10),
          DurationPicker(onChanged: (choice) => setState(() => _duration = choice)),
          const SizedBox(height: 18),

          // Customer (optional)
          Text(l10n.customerOptional, style: AppText.label),
          const SizedBox(height: 10),
          TextField(
            controller: _customer,
            decoration: InputDecoration(hintText: l10n.customerHint),
          ),
          const SizedBox(height: 22),

          // Start
          FilledButton(
            onPressed: !_duration.isValid ? null : () { // null = button is disabled
              final text = _customer.text.trim();
              Navigator.pop(
                context,
                StartSessionResult(
                  isMulti: _isMulti,
                  plannedMinutes: _duration.minutes,
                  customerText: text.isEmpty ? null : text,
                ),
              );
            },
            style: FilledButton.styleFrom(minimumSize: const Size(0, 60)),
            child: Text(l10n.startTimer, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

/// One big choice card: "فردي / 50 جنيه في الساعة". Cream when selected.
class _ModeButton extends StatelessWidget {
  const _ModeButton({required this.title, required this.price, required this.selected, required this.onTap});

  final String title;
  final int price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.textOnLight : AppColors.text;
    final muted = selected ? AppColors.textOnLightMuted : AppColors.textMuted;

    return Material(
      color: selected ? AppColors.running : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: selected ? BorderSide.none : const BorderSide(color: AppColors.raised, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: fg)),
              const SizedBox(height: 4),
              Text(context.l10n.pricePerHour(price), style: TextStyle(fontSize: 13, color: muted)),
            ],
          ),
        ),
      ),
    );
  }
}
