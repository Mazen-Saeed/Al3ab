import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../shell/form_surface.dart';
import 'duration_picker.dart';
import '../data/unit.dart';

/// What staff chose in the add-time form.
class AddTimeResult {
  const AddTimeResult(this.minutes);

  final int? minutes; // minutes to add; null = switch the session to open time
}

/// Asks how much time to add to a running planned session (or to make it open).
/// Returns null if the form is closed without choosing.
Future<AddTimeResult?> showAddTime(BuildContext context, Unit unit) =>
    showFormSurface<AddTimeResult>(context, _AddTimeForm(unit: unit));

class _AddTimeForm extends StatefulWidget {
  const _AddTimeForm({required this.unit});

  final Unit unit;

  @override
  State<_AddTimeForm> createState() => _AddTimeFormState();
}

class _AddTimeFormState extends State<_AddTimeForm> {
  DurationChoice _choice = const DurationChoice(minutes: 30); // matches initialMinutes below

  bool get _canAdd => _choice.isValid; // "open" (minutes == null) is a valid choice here

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsetsDirectional.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormHeader(title: l10n.addTime, heading: widget.unit.name),
          const SizedBox(height: 18),
          DurationPicker(
            // The "open" pill here means: stop the countdown, let them play without a limit.
            initialMinutes: 30,
            onChanged: (choice) => setState(() => _choice = choice),
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: _canAdd ? () => Navigator.pop(context, AddTimeResult(_choice.minutes)) : null,
            style: FilledButton.styleFrom(minimumSize: const Size(0, 60)),
            child: Text(_choice.minutes == null && _choice.isValid ? l10n.makeOpenConfirm : l10n.addTimeConfirm, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
