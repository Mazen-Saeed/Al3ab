import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n.dart';
import '../shell/pill.dart';

/// What the picker holds right now.
class DurationChoice {
  const DurationChoice({this.minutes, this.isValid = true});

  final int? minutes; // null = open time
  final bool isValid; // false while "other" is chosen but the field is empty or 0
}

/// Pills: [open] 30 min · 1 hour · 2 hours · other (type hours, like 2.5).
/// Used by the start form and the add-time sheet (where "open" means: remove the limit).
class DurationPicker extends StatefulWidget {
  const DurationPicker({
    super.key,
    required this.onChanged,
    this.initialMinutes,
  });

  final ValueChanged<DurationChoice> onChanged; // called on every change
  final int? initialMinutes;

  @override
  State<DurationPicker> createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {
  late int? _minutes = widget.initialMinutes; // chosen preset; null = open time
  bool _custom = false; // "other" chosen: use what's typed in the field
  final _hours = TextEditingController();

  @override
  void dispose() {
    _hours.dispose();
    super.dispose();
  }

  /// Typed hours (2.5 -> 150 minutes) or the preset. Staff think in hours, the database in minutes.
  int? get _current {
    if (!_custom) return _minutes;
    final hours = double.tryParse(_hours.text.replaceAll(',', '.')); // "2,5" works too
    return hours == null ? null : (hours * 60).round();
  }

  void _emit() {
    final isValid = !_custom || (_current ?? 0) > 0;
    widget.onChanged(DurationChoice(minutes: _current, isValid: isValid));
  }

  void _choose(int? minutes) {
    setState(() {
      _custom = false;
      _minutes = minutes;
    });
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8, // like Row spacing, but moves to the next line when full
          runSpacing: 8,
          children: [
            Pill(label: l10n.durationOpen, selected: !_custom && _minutes == null, onTap: () => _choose(null)),
            Pill(label: l10n.duration30, selected: !_custom && _minutes == 30, onTap: () => _choose(30)),
            Pill(label: l10n.duration60, selected: !_custom && _minutes == 60, onTap: () => _choose(60)),
            Pill(label: l10n.duration120, selected: !_custom && _minutes == 120, onTap: () => _choose(120)),
            Pill(
              label: l10n.durationCustom,
              selected: _custom,
              onTap: () {
                setState(() => _custom = true);
                _emit();
              },
            ),
          ],
        ),
        if (_custom) ...[
          const SizedBox(height: 10),
          TextField(
            controller: _hours,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))], // digits and a separator
            onChanged: (_) {
              setState(() {});
              _emit();
            },
            decoration: InputDecoration(hintText: l10n.customHoursHint),
          ),
        ],
      ],
    );
  }
}
