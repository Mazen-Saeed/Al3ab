import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../l10n/l10n.dart';
import 'unit.dart';

/// One tile on the Floor screen. Looks different for each [UnitStatus].
class UnitTile extends StatelessWidget {
  const UnitTile({
    super.key,
    required this.unit,
    this.selected = false,
    this.onTap,
    this.title,
  });

  final Unit unit;
  final bool selected;
  final VoidCallback? onTap;

  /// Text on top of the tile. Defaults to the unit's name;
  /// private rooms pass the room's name instead ("VIP 1").
  final String? title;

  @override
  Widget build(BuildContext context) {
    // 1. Pick the colors for this state.
    final (background, foreground, muted, border) = switch (unit.status) {
      UnitStatus.running => (AppColors.running, AppColors.textOnLight, AppColors.textOnLightMuted, null),
      UnitStatus.free => (AppColors.surface, AppColors.text, AppColors.textMuted, AppColors.raised),
      UnitStatus.waitingPayment => (AppColors.waitingPayment, AppColors.onWaitingPayment, AppColors.onWaitingPayment, null),
      UnitStatus.maintenance => (Colors.transparent, AppColors.maintenance, AppColors.maintenance, AppColors.raised),
    };

    // 2. The tile frame: rounded box, tappable, with a ring when selected.
    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: border == null ? BorderSide.none : BorderSide(color: border, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 150,
          padding: const EdgeInsetsDirectional.all(16),
          foregroundDecoration: selected
              ? BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 3),
                  borderRadius: BorderRadius.circular(24),
                )
              : null,
          // 3. The content: name + icon on top, big value, small line at the bottom.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title ?? unit.name,
                      style: TextStyle(color: foreground, fontSize: 14, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(_iconFor(unit.type), size: 20, color: muted),
                ],
              ),
              const Spacer(),
              _MainLine(unit: unit, color: foreground),
              const Spacer(), // two Spacers share the free space: big line sits in the middle
              _BottomLine(unit: unit, color: muted),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _iconFor(UnitType type) => switch (type) {
        UnitType.playstation => Icons.sports_esports,
        UnitType.pingPong => Icons.sports_tennis,
        UnitType.billiards => Icons.adjust,
      };
}

/// The big line: the timer, the amount due, or the state name.
/// Same size and weight in every state so all tiles line up; only color and text change.
class _MainLine extends StatelessWidget {
  const _MainLine({required this.unit, required this.color});

  final Unit unit;
  final Color color;

  static const _size = 30.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = TextStyle(
      color: color,
      fontSize: _size,
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()], // digits don't jump while ticking
    );

    return switch (unit.status) {
      UnitStatus.running => Text(
          formatElapsed(unit.elapsed),
          textDirection: TextDirection.ltr, // a timer always reads left-to-right
          style: style,
        ),
      UnitStatus.waitingPayment => Text(l10n.amountEgp(unit.amountDue ?? 0), style: style),
      UnitStatus.free => Text(l10n.unitFree, style: style.copyWith(color: AppColors.free)),
      UnitStatus.maintenance => Text(l10n.unitMaintenance, style: style),
    };
  }
}

/// The small line at the bottom: mode + cost, booking, hint, or note.
class _BottomLine extends StatelessWidget {
  const _BottomLine({required this.unit, required this.color});

  final Unit unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reservation = unit.nextReservationAt;

    final String text;
    Color textColor = color;

    switch (unit.status) {
      case UnitStatus.running:
        final cost = l10n.amountEgp(unit.currentCost);
        final mode = unit.hasMultiMode ? (unit.isMulti ? l10n.modeMulti : l10n.modeSingle) : null;
        text = mode == null ? cost : '$mode · $cost';
        if (reservation != null) {
          // A booking is coming on a running unit: warn instead.
          final minutes = reservation.difference(DateTime.now()).inMinutes;
          return _Chip(text: l10n.reservedInMinutes(minutes));
        }
      case UnitStatus.free:
        if (reservation != null) {
          text = l10n.reservedAt(friendlyTime(context, reservation));
          textColor = AppColors.onReserved;
        } else {
          text = l10n.unitTapToStart;
        }
      case UnitStatus.waitingPayment:
        text = l10n.unitWaitingPayment;
      case UnitStatus.maintenance:
        text = unit.note ?? '';
    }

    return Text(
      text,
      style: TextStyle(color: textColor, fontSize: 13),
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Small lavender pill for "booked in 15 min".
class _Chip extends StatelessWidget {
  const _Chip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.reserved,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.onReserved, fontSize: 12)),
    );
  }
}

/// 1:24:10 style. Hours aren't padded; minutes and seconds always have 2 digits.
String formatElapsed(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.inHours}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
}

/// Time the way people say it: "٩ بليل", "٣ الظهر", "١٠:٣٠ الصبح".
/// Simpler to read at a glance than "9:00 م".
String friendlyTime(BuildContext context, DateTime time) {
  final l10n = context.l10n;
  final hour24 = time.hour;
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final hour = time.minute == 0
      ? '$hour12'
      : '$hour12:${time.minute.toString().padLeft(2, '0')}';

  if (hour24 >= 5 && hour24 <= 11) return l10n.timeMorning(hour);
  if (hour24 >= 12 && hour24 <= 15) return l10n.timeNoon(hour);
  if (hour24 >= 16 && hour24 <= 17) return l10n.timeAfternoon(hour);
  return l10n.timeNight(hour); // 18:00 – 04:59
}
