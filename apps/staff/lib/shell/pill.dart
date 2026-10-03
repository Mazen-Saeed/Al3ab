import 'package:flutter/material.dart';

import '../app_theme.dart';

/// A small round choice button ("pill"). Cream when selected, outlined when not.
/// Used for the duration choices and the payment method choices.
class Pill extends StatelessWidget {
  const Pill({super.key, required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.running : Colors.transparent,
      shape: StadiumBorder(
        side: selected ? BorderSide.none : const BorderSide(color: AppColors.raised, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 18, vertical: 12),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.textOnLight : AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}
