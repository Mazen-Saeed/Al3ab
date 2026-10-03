import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/unit.dart';
import '../l10n/l10n.dart';
import '../shell/form_surface.dart';
import 'duration_picker.dart';

/// Asks for time on a running session: more time on a fixed session, or a time limit (counted from
/// now) on an open one. Returns the minutes, or null if the form is closed without choosing.
/// (Turning a fixed session into an open one is its own button in the panel.)
Future<int?> showAddTime(BuildContext context, Unit unit) =>
    showFormSurface<int>(context, _AddTimeForm(unit: unit));

class _AddTimeForm extends StatefulWidget {
  const _AddTimeForm({required this.unit});

  final Unit unit;

  @override
  State<_AddTimeForm> createState() => _AddTimeFormState();
}

class _AddTimeFormState extends State<_AddTimeForm> {
  DurationChoice _choice = const DurationChoice(minutes: 30); // matches initialMinutes below

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isOpen = widget.unit.plannedMinutes == null; // open session: this sets a limit
    return Padding(
      padding: const EdgeInsetsDirectional.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormHeader(title: isOpen ? l10n.setTime : l10n.addTime, heading: widget.unit.name),
          const SizedBox(height: 18),
          DurationPicker(
            showOpen: false,
            initialMinutes: 30,
            onChanged: (choice) => setState(() => _choice = choice),
          ),
          if (isOpen) ...[
            const SizedBox(height: 10),
            Text(l10n.fromNowNote, style: AppText.small), // the limit starts counting now, not at the start
          ],
          const SizedBox(height: 22),
          FilledButton(
            onPressed: _choice.isValid && _choice.minutes != null ? () => Navigator.pop(context, _choice.minutes) : null,
            style: FilledButton.styleFrom(minimumSize: const Size(0, 60)),
            child: Text(
              isOpen ? l10n.setTimeConfirm : l10n.addTimeConfirm,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
