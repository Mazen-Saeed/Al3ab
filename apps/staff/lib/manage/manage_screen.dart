import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_theme.dart';
import '../l10n/app_language.dart';
import '../l10n/l10n.dart';
import '../products/products_screen.dart';

/// The Manage page ("الإدارة"): a list of setup areas. Tapping one shows it in place of the
/// list (the nav stays visible); its back button returns here. Products (with its stock) is the
/// first area; places & devices, staff, reports and settings will be added to this list as they
/// are built.
class ManageScreen extends ConsumerStatefulWidget {
  const ManageScreen({super.key});

  @override
  ConsumerState<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends ConsumerState<ManageScreen> {
  bool _showProducts = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_showProducts) {
      return ProductsScreen(onBack: () => setState(() => _showProducts = false));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.navManage, style: AppText.formTitle),
        const SizedBox(height: 18),
        _ManageEntry(
          icon: Icons.local_drink_outlined,
          title: l10n.productsTitle,
          onTap: () => setState(() => _showProducts = true),
        ),
        const SizedBox(height: 12),
        // Shows the OTHER language's own name: tap it to switch. (Temporary home until Settings exists.)
        _ManageEntry(
          icon: Icons.language,
          title: l10n.localeName == 'ar' ? 'English' : 'العربية',
          onTap: () => ref.read(appLanguageProvider.notifier).set(Locale(l10n.localeName == 'ar' ? 'en' : 'ar')),
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
