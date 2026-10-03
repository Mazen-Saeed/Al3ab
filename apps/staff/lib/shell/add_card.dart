import 'package:flutter/material.dart';

import '../app_theme.dart';

/// The outlined "+ new ..." card that sits first in a list or grid (new product, new stock item).
/// The caller sets its width (a grid cell, or the full width of a list).
class AddCard extends StatelessWidget {
  const AddCard({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.raised, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(14),
          child: Row(
            children: [
              const Icon(Icons.add, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
