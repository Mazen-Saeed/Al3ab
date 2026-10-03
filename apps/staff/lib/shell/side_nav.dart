import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../l10n/l10n.dart';

/// The app's side navigation (shared by all screens).
/// On the start side: right in Arabic, left in English.
class SideNav extends StatelessWidget {
  const SideNav({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    this.hasNewReservation = false,
  });

  final int selectedIndex; // which item is highlighted
  final ValueChanged<int> onSelect; // called with the tapped item's index
  final bool hasNewReservation; // shows a dot on the reservations icon

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // The items, in order. Index 0 is the Floor screen.
    final items = [
      (Icons.grid_view_rounded, l10n.homeTitle),
      (Icons.local_drink_outlined, l10n.navQuickSale),
      (Icons.event_outlined, l10n.navReservations),
      (Icons.payments_outlined, l10n.navShift),
    ];

    return Container(
      width: 88,
      padding: const EdgeInsetsDirectional.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          // App mark: first letter of the name on a cream square.
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.running,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              l10n.appTitle.characters.first,
              style: const TextStyle(color: AppColors.textOnLight, fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 14),
          for (final (index, (icon, label)) in items.indexed)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 6),
              child: _NavButton(
                icon: icon,
                label: label,
                selected: index == selectedIndex,
                showDot: index == 2 && hasNewReservation,
                onTap: () => onSelect(index),
              ),
            ),
          const Spacer(),
          // Management (staff, units & prices, products, reports, settings).
          // TODO: show only to owners and managers once login exists.
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 12),
            child: _NavButton(
              icon: Icons.tune_rounded,
              label: l10n.navManage,
              selected: selectedIndex == items.length,
              onTap: () => onSelect(items.length),
            ),
          ),
          // Who is working now. Tapping it will open "Switch staff" (PIN).
          Tooltip(
            message: l10n.switchStaff,
            child: InkWell(
              onTap: () {}, // TODO: open the switch-staff screen
              customBorder: const CircleBorder(),
              child: Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.raised, width: 2),
                ),
                child: const Text('أ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One icon button in the side nav, with a tooltip and an optional red dot.
class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.showDot = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label, // shown on hover/long-press; also read by screen readers
      child: Material(
        color: selected ? AppColors.raised : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            width: 56,
            height: 56,
            // Stack = widgets on top of each other: the icon, plus the dot in a corner.
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, color: selected ? AppColors.text : AppColors.textMuted),
                if (showDot)
                  PositionedDirectional(
                    top: 12,
                    end: 12,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(color: AppColors.waitingPayment, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
