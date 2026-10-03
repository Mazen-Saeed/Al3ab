import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_theme.dart';
import '../data/bills_provider.dart';
import '../data/catalog_provider.dart';
import '../data/clock_provider.dart';
import '../data/orders_provider.dart';
import '../data/payment_accounts_provider.dart';
import '../data/product.dart';
import '../data/unit.dart';
import '../data/units_provider.dart';
import '../l10n/l10n.dart';
import 'add_order.dart';
import 'add_time.dart';
import 'bill_widgets.dart';
import 'checkout.dart';
import 'time_text.dart';

/// Details and actions for the selected unit.
/// On wide screens it sits next to the grid; on smaller screens it opens in a bottom sheet.
/// It reads the unit from the units by id, so it always shows the latest version
/// (even when it stays open in a bottom sheet while the data changes).
class SessionPanel extends ConsumerWidget {
  const SessionPanel({super.key, required this.unitId, required this.onClose, this.width});

  final String unitId;
  final double? width; // fixed width next to the grid; null = fill the space (bottom sheet)
  final VoidCallback onClose; // hides the panel (or closes the sheet)

  // Each action reads what it needs from `ref` BEFORE its first await: after the form closes the
  // panel may be gone, and `ref` must not be used then.

  Future<void> _addTime(BuildContext context, WidgetRef ref, Unit unit) async {
    final units = ref.read(unitsProvider.notifier);
    final result = await showAddTime(context, unit);
    if (result != null) units.addTime(unit.id, result.minutes);
  }

  Future<void> _addOrder(BuildContext context, WidgetRef ref, Unit unit) async {
    final orders = ref.read(ordersProvider.notifier);
    final quantities = await showAddOrder(context, unit, ref.read(catalogProvider).products);
    if (quantities != null) orders.addOrder(unit.id, quantities);
  }

  Future<void> _checkout(BuildContext context, WidgetRef ref, Unit unit) async {
    // Freeze the clock now: the form shows, and the bill saves, the amount at this moment.
    final endedAt = DateTime.now();
    final bills = ref.read(billsProvider.notifier);
    final result = await showCheckout(
      context,
      unit,
      ref.read(ordersProvider).forUnit(unit.id),
      endedAt,
      paymentAccounts: ref.read(paymentAccountsProvider),
    );
    if (result == null) return;
    bills.endAndPay(
      unit.id,
      endedAt: endedAt,
      discount: result.discount,
      discountReason: result.discountReason,
      method: result.method,
    );
    onClose(); // the unit is free now, nothing left to show in the panel
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(clockProvider); // redraws every second, so the time and the amount move
    final unit = ref.watch(unitsProvider).byId(unitId);
    final orders = ref.watch(ordersProvider).forUnit(unit.id);
    return Container(
      width: width,
      padding: const EdgeInsetsDirectional.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: unit.status == UnitStatus.running
          ? _RunningSession(
              unit: unit,
              orders: orders,
              onAddTime: () => _addTime(context, ref, unit),
              onAddOrder: () => _addOrder(context, ref, unit),
              onCheckout: () => _checkout(context, ref, unit),
              onRemoveOrder: (productId) => ref.read(ordersProvider.notifier).removeOrderLine(unit.id, productId),
              onClose: onClose,
            )
          : _NotRunning(
              unit: unit,
              onClose: onClose,
              onBackToWork: () {
                ref.read(unitsProvider.notifier).clearMaintenance(unit.id);
                onClose(); // a free unit has nothing to show here
              },
            ),
    );
  }
}

/// Panel content while a session is running.
class _RunningSession extends StatelessWidget {
  const _RunningSession({
    required this.unit,
    required this.orders,
    required this.onAddTime,
    required this.onAddOrder,
    required this.onCheckout,
    required this.onRemoveOrder,
    required this.onClose,
  });

  final Unit unit;
  final List<OrderLine> orders;
  final VoidCallback onAddTime;
  final VoidCallback onAddOrder;
  final VoidCallback onCheckout;
  final void Function(String productId) onRemoveOrder;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final price = unit.isMulti ? unit.multiHourlyPrice! : unit.hourlyPrice;
    final playCost = unit.currentCost;
    final ordersSum = orders.fold(0, (sum, line) => sum + line.total);
    final cost = playCost + ordersSum; // the bill: time played + products

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

        // Everything between the header and the total scrolls (timer, bill lines), so a short
        // window never overflows. The total and the buttons below stay pinned.
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                BillRow(
                  label: l10n.playTime,
                  detail: playDetail(l10n, unit.elapsed, pricePerHour: price, isMulti: unit.isMulti),
                  value: l10n.amountEgp(playCost),
                ),
                const SizedBox(height: 18), // clear gap between the two sections
                if (orders.isEmpty)
                  Text(l10n.noOrdersYet, style: AppText.small)
                else ...[
                  BillRow(label: l10n.ordersTitle, value: l10n.amountEgp(ordersSum), bold: true),
                  const SizedBox(height: 4),
                  for (final line in orders)
                    OrderRow(line: line, onRemove: () => onRemoveOrder(line.productId)),
                ],
              ],
            ),
          ),
        ),
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

        const SizedBox(height: 20), // space between the total and the buttons

        // Secondary actions: two per row, the mode switch gets its own full-width row
        Row(
          children: [
            Expanded(child: FilledButton.tonal(onPressed: onAddOrder, child: Text(l10n.addOrder))),
            const SizedBox(width: 8),
            Expanded(child: FilledButton.tonal(onPressed: () {}, child: Text(l10n.moveUnit))),
          ],
        ),
        if (unit.hasMultiMode) ...[
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () {},
            child: Text(unit.isMulti ? l10n.switchToSingle : l10n.switchToMulti),
          ),
        ],
        const SizedBox(height: 10),
        // Main action
        FilledButton(
          onPressed: onCheckout,
          style: FilledButton.styleFrom(minimumSize: const Size(0, 60)),
          child: Text(l10n.endAndPay, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

/// Panel content when the selected unit has no running session.
class _NotRunning extends StatelessWidget {
  const _NotRunning({required this.unit, required this.onClose, required this.onBackToWork});

  final Unit unit;
  final VoidCallback onClose;
  final VoidCallback onBackToWork; // maintenance -> free

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
        if (unit.status == UnitStatus.maintenance) ...[
          if (unit.note != null) ...[
            const SizedBox(height: 6),
            Text(unit.note!, style: const TextStyle(color: AppColors.textMuted)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onBackToWork,
            style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 60)),
            child: Text(l10n.backToWork, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
        ],
      ],
    );
  }
}
