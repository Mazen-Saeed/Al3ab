import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/shop_store.dart';
import '../data/unit.dart';
import '../l10n/l10n.dart';
import 'add_time.dart';
import 'time_text.dart';

/// Details and actions for the selected unit.
/// On wide screens it sits next to the grid; on smaller screens it opens in a bottom sheet.
/// It reads the unit from the store by id, so it always shows the latest version
/// (even when it stays open in a bottom sheet while the data changes).
class SessionPanel extends StatelessWidget {
  const SessionPanel({super.key, required this.store, required this.unitId, required this.onClose, this.width});

  final ShopStore store;
  final String unitId;
  final double? width; // fixed width next to the grid; null = fill the space (bottom sheet)
  final VoidCallback onClose; // hides the panel (or closes the sheet)

  Future<void> _addTime(BuildContext context, Unit unit) async {
    final result = await showAddTime(context, unit);
    if (result != null) store.addTime(unit.id, result.minutes);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final unit = store.unitById(unitId);
        return Container(
          width: width,
          padding: const EdgeInsetsDirectional.all(22),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
          ),
          child: unit.status == UnitStatus.running
              ? _RunningSession(unit: unit, onAddTime: () => _addTime(context, unit), onClose: onClose)
              : _NotRunning(unit: unit, onClose: onClose),
        );
      },
    );
  }
}

/// Panel content while a session is running.
class _RunningSession extends StatelessWidget {
  const _RunningSession({required this.unit, required this.onAddTime, required this.onClose});

  final Unit unit;
  final VoidCallback onAddTime;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final price = unit.isMulti ? unit.multiHourlyPrice! : unit.hourlyPrice;
    final cost = unit.currentCost;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Name + room
        Row(
          children: [
            Expanded(
              child: Text(unit.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            ),
            Text(unit.roomName, style: AppText.small),
            const SizedBox(width: 12),
            IconButton.filledTonal(onPressed: onClose, icon: const Icon(Icons.close)),
          ],
        ),
        const SizedBox(height: 14),

        // The timer card (cream, like a running tile)
        Container(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.running,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.sessionStarted(friendlyTime(l10n, unit.startedAt!), price),
                style: const TextStyle(fontSize: 13, color: AppColors.textOnLightMuted),
              ),
              Text(
                timerText(unit.elapsed, unit.remaining),
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: unit.needsAttention ? AppColors.alert : AppColors.textOnLight,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (unit.remaining != null)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        unit.isOvertime ? l10n.timeOver : l10n.timeLeft,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: unit.needsAttention ? AppColors.alert : AppColors.textOnLightMuted,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: onAddTime,
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l10n.addTime),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        backgroundColor: AppColors.textOnLight,
                        foregroundColor: AppColors.running,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Bill lines (orders come later, with the database)
        _Line(label: l10n.playTime, value: l10n.amountEgp(cost)),
        const SizedBox(height: 8),
        Text(l10n.noOrdersYet, style: AppText.small),
        const Padding(
          padding: EdgeInsetsDirectional.symmetric(vertical: 14),
          child: Divider(height: 1, color: AppColors.raised),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(child: Text(l10n.total, style: const TextStyle(fontWeight: FontWeight.w600))),
            Text(l10n.amountEgp(cost), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          ],
        ),

        const Spacer(), // pushes the buttons to the bottom of the panel

        // Secondary actions
        Row(
          children: [
            Expanded(child: FilledButton.tonal(onPressed: () {}, child: Text(l10n.addOrder))),
            const SizedBox(width: 8),
            Expanded(child: FilledButton.tonal(onPressed: () {}, child: Text(l10n.moveUnit))),
            if (unit.hasMultiMode) ...[
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () {},
                  child: Text(unit.isMulti ? l10n.switchToSingle : l10n.switchToMulti),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        // Main action
        FilledButton(
          onPressed: () {}, // TODO: open checkout
          style: FilledButton.styleFrom(minimumSize: const Size(0, 60)),
          child: Text(l10n.endAndPay, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

/// Panel content when the selected unit has no running session.
class _NotRunning extends StatelessWidget {
  const _NotRunning({required this.unit, required this.onClose});

  final Unit unit;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = switch (unit.status) {
      UnitStatus.free => l10n.unitFree,
      UnitStatus.waitingPayment => l10n.unitWaitingPayment,
      UnitStatus.maintenance => l10n.unitMaintenance,
      UnitStatus.running => '', // handled by _RunningSession
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(unit.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  Text(unit.roomName, style: AppText.small),
                ],
              ),
            ),
            IconButton.filledTonal(onPressed: onClose, icon: const Icon(Icons.close)),
          ],
        ),
        const SizedBox(height: 24),
        Text(status, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        if (unit.status == UnitStatus.free) ...[
          const SizedBox(height: 6),
          Text(l10n.unitTapToStart, style: const TextStyle(color: AppColors.textMuted)),
        ],
      ],
    );
  }
}

/// A label on one side, an amount on the other.
class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
        Text(value, style: const TextStyle(fontSize: 15)),
      ],
    );
  }
}
