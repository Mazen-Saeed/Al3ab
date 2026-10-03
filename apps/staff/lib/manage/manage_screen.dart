import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_theme.dart';
import '../l10n/l10n.dart';
import '../places/places_screen.dart';
import '../prices/prices_screen.dart';
import '../products/products_screen.dart';
import '../settings/settings_screen.dart';

/// The setup areas that open in place of the Manage list.
enum ManageArea { products, places, prices, settings }

/// Which area is open (null = the list). It lives in a provider, not inside the page, so the shell
/// can close it when staff tap the Manage button in the nav.
class ManageAreaNotifier extends Notifier<ManageArea?> {
  @override
  ManageArea? build() => null;

  void open(ManageArea area) => state = area;

  void close() => state = null;
}

final manageAreaProvider = NotifierProvider<ManageAreaNotifier, ManageArea?>(ManageAreaNotifier.new);

/// The Manage page ("الإدارة"): a list of setup areas. Tapping one shows it in place of the
/// list (the nav stays visible); its back button, or the Manage button in the nav, returns here.
/// Products (with its stock), Rooms and devices and Settings are built; staff and reports will be
/// added to this list.
class ManageScreen extends ConsumerWidget {
  const ManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final area = ref.watch(manageAreaProvider);
    final areas = ref.read(manageAreaProvider.notifier);

    switch (area) {
      case ManageArea.products:
        return ProductsScreen(onBack: areas.close);
      case ManageArea.places:
        return PlacesScreen(onBack: areas.close);
      case ManageArea.prices:
        return PricesScreen(onBack: areas.close);
      case ManageArea.settings:
        return SettingsScreen(onBack: areas.close);
      case null:
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.navManage, style: AppText.formTitle),
        const SizedBox(height: 18),
        _ManageEntry(
          icon: Icons.local_drink_outlined,
          title: l10n.productsTitle,
          onTap: () => areas.open(ManageArea.products),
        ),
        const SizedBox(height: 12),
        _ManageEntry(
          icon: Icons.meeting_room_outlined,
          title: l10n.placesTitle,
          onTap: () => areas.open(ManageArea.places),
        ),
        const SizedBox(height: 12),
        _ManageEntry(
          icon: Icons.payments_outlined,
          title: l10n.pricesTitle,
          onTap: () => areas.open(ManageArea.prices),
        ),
        const SizedBox(height: 12),
        _ManageEntry(
          icon: Icons.settings_outlined,
          title: l10n.settingsTitle,
          onTap: () => areas.open(ManageArea.settings),
        ),
      ],
    );
  }
}

/// One row in the Manage list.
class _ManageEntry extends StatelessWidget {
  const _ManageEntry({required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(20),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 14),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
              const Icon(Icons.chevron_right, color: AppColors.textMuted), // Flutter flips it in RTL: points left = forward
            ],
          ),
        ),
      ),
    );
  }
}
