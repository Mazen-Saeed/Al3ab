import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/money.dart';
import '../data/unit.dart';
import '../l10n/l10n.dart';
import '../shell/form_surface.dart';

/// "نقل": pick the free unit the running session of [from] moves to. [free] are the free units.
/// Returns the picked unit's id, or null if closed. The time so far keeps the old price; the rest
/// is charged at the new unit's price.
Future<String?> showMoveSession(BuildContext context, Unit from, List<Unit> free) =>
    showFormSurface<String>(context, _MoveSession(from: from, free: free));

class _MoveSession extends StatelessWidget {
  const _MoveSession({required this.from, required this.free});

  final Unit from;
  final List<Unit> free;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsetsDirectional.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormHeader(title: l10n.moveUnit, heading: from.name),
          const SizedBox(height: 8),
          Text(l10n.moveSessionHint, style: AppText.small),
          const SizedBox(height: 16),
          if (free.isEmpty)
            Text(l10n.moveNoFreeUnits, style: AppText.label)
          else
            for (final unit in free) ...[
              Material(
                color: AppColors.raised,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.pop(context, unit.id),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(unit.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                              Text(unit.roomName, style: AppText.small),
                            ],
                          ),
                        ),
                        Text(l10n.pricePerHour(formatMoney(unit.hourlyPrice)), style: AppText.small),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}
