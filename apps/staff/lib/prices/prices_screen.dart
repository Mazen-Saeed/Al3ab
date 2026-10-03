import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_theme.dart';
import '../data/categories_provider.dart';
import '../data/money.dart';
import '../data/price_category.dart';
import '../data/units_provider.dart';
import '../l10n/l10n.dart';
import '../shell/add_card.dart';
import 'category_form.dart';

/// Manage > Prices: the price lists the owner makes once ("PS5 عادي", "VIP"...) and gives to many
/// devices. Changing one changes every device that uses it (a device with a session keeps its old
/// prices until it is paid).
class PricesScreen extends ConsumerWidget {
  const PricesScreen({super.key, required this.onBack});

  final VoidCallback onBack; // back to the Manage list

  Future<void> _edit(BuildContext context, WidgetRef ref, PriceCategory? category) async {
    final notifier = ref.read(categoriesProvider.notifier); // before the await
    final inUse = category != null && ref.read(unitsProvider).any((u) => u.categoryId == category.id);
    final result = await showCategoryForm(context, category: category, inUse: inUse);
    if (result == null) return;
    if (category == null) {
      notifier.add(
        name: result.name,
        hourlyPrice: result.hourlyPrice,
        multiHourlyPrice: result.multiHourlyPrice,
      );
    } else if (result.delete) {
      notifier.remove(category.id);
    } else {
      notifier.update(
        category.id,
        name: result.name,
        hourlyPrice: result.hourlyPrice,
        multiHourlyPrice: result.multiHourlyPrice,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final categories = ref.watch(categoriesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton.filledTonal(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
            const SizedBox(width: 14),
            Text(l10n.pricesTitle, style: AppText.sectionTitle),
          ],
        ),
        const SizedBox(height: 18),
        Expanded(
          child: SingleChildScrollView(
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AddCard(label: l10n.newPriceCategory, onTap: () => _edit(context, ref, null)),
                    for (final category in categories) ...[
                      const SizedBox(height: 10),
                      _CategoryCard(category: category, onTap: () => _edit(context, ref, category)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final PriceCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final parts = [
      l10n.pricePerHour(formatMoney(category.hourlyPrice)),
      if (category.multiHourlyPrice != null) l10n.pricePerHour(formatMoney(category.multiHourlyPrice!)),
    ];
    return Material(
      color: AppColors.raised,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(parts.join(' · '), style: AppText.small),
            ],
          ),
        ),
      ),
    );
  }
}
