import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'layout.dart';

/// Shows a small form: a centered dialog on bigger screens, a bottom sheet on phones.
/// Returns whatever the form passes to `Navigator.pop(context, value)` (null if closed).
/// [scrolls]: by default the whole form scrolls if it is taller than the screen. A form that
/// keeps its main button pinned (Checkout) passes false and scrolls its own middle part.
Future<T?> showFormSurface<T>(BuildContext context, Widget form, {bool scrolls = true}) {
  final body = scrolls ? SingleChildScrollView(child: form) : form;
  if (screenSizeOf(context) != ScreenSize.phone) {
    return showDialog<T>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520), // never wider than 520
          child: body,
        ),
      ),
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent, // the box below draws its own background
    builder: (context) => Padding(
      // viewInsets.bottom = height of the keyboard. Lifts the sheet above it.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(32),
          ),
          child: body,
        ),
      ),
    ),
  );
}

/// Top of every small form: a small grey line, the big name, and a close button.
class FormHeader extends StatelessWidget {
  const FormHeader({super.key, required this.title, required this.heading});

  final String title; // small grey line: "بدء جلسة"
  final String heading; // big line: the unit's name

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.label),
              Text(heading, style: AppText.formTitle),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: () => Navigator.pop(context), // pop with no value = null result
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}
