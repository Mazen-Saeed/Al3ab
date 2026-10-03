import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/unit.dart';
import '../l10n/l10n.dart';
import '../shell/form_surface.dart';

/// Asks for an optional reason before a unit goes into maintenance.
/// Returns null if closed; otherwise the record holds the note (null = no reason typed).
Future<({String? note})?> showSetMaintenance(BuildContext context, Unit unit) =>
    showFormSurface<({String? note})>(context, _SetMaintenanceForm(unit: unit));

class _SetMaintenanceForm extends StatefulWidget {
  const _SetMaintenanceForm({required this.unit});

  final Unit unit;

  @override
  State<_SetMaintenanceForm> createState() => _SetMaintenanceFormState();
}

class _SetMaintenanceFormState extends State<_SetMaintenanceForm> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
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
          FormHeader(title: l10n.unitMaintenance, heading: widget.unit.name),
          const SizedBox(height: 18),
          Text(l10n.maintenanceNoteLabel, style: AppText.label),
          const SizedBox(height: 10),
          TextField(
            controller: _note,
            decoration: InputDecoration(hintText: l10n.maintenanceNoteHint),
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: () {
              final text = _note.text.trim();
              Navigator.pop(context, (note: text.isEmpty ? null : text));
            },
            style: FilledButton.styleFrom(minimumSize: const Size(0, 60)),
            child: Text(l10n.maintenanceButton, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
