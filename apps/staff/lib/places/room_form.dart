import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../l10n/l10n.dart';
import '../shell/form_surface.dart';

/// New room ([name] null) or rename one. Returns the name, or null if closed without saving.
Future<String?> showRoomForm(BuildContext context, {String? name}) =>
    showFormSurface<String>(context, _RoomForm(name: name));

class _RoomForm extends StatefulWidget {
  const _RoomForm({this.name});

  final String? name;

  @override
  State<_RoomForm> createState() => _RoomFormState();
}

class _RoomFormState extends State<_RoomForm> {
  late final _name = TextEditingController(text: widget.name);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _canSave => _name.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsetsDirectional.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormHeader(title: l10n.placesTitle, heading: widget.name ?? l10n.newPlace),
          const SizedBox(height: 18),
          Text(l10n.placeNameLabel, style: AppText.label),
          const SizedBox(height: 10),
          TextField(
            controller: _name,
            decoration: InputDecoration(hintText: l10n.placeNameHint),
            onChanged: (_) => setState(() {}), // redraw so the save button can enable
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: _canSave ? () => Navigator.pop(context, _name.text.trim()) : null,
            style: FilledButton.styleFrom(minimumSize: const Size(0, 60)),
            child: Text(l10n.save, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
