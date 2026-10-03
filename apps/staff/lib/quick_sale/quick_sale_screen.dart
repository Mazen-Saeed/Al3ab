import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_theme.dart';
import '../data/bill.dart';
import '../data/bills_provider.dart';
import '../data/catalog_provider.dart';
import '../data/money.dart';
import '../data/payment_accounts_provider.dart';
import '../floor/checkout.dart';
import '../l10n/l10n.dart';
import '../products/product_picker.dart';
import '../shell/pill.dart';

/// Quick sale ("بيع سريع"): drinks and snacks for someone who is not playing. Tap products, pick
/// how they pay, press "بيع". It saves a paid bill with no unit and takes the stock off the shelf.
class QuickSaleScreen extends ConsumerStatefulWidget {
  const QuickSaleScreen({super.key});

  @override
  ConsumerState<QuickSaleScreen> createState() => _QuickSaleScreenState();
}

class _QuickSaleScreenState extends ConsumerState<QuickSaleScreen> {
  final Map<String, int> _quantities = {}; // product id -> how many
  PaymentMethod _method = PaymentMethod.cash;

  void _change(String productId, int quantity) {
    setState(() {
      if (quantity <= 0) {
        _quantities.remove(productId);
      } else {
        _quantities[productId] = quantity;
      }
    });
  }

  void _sell() {
    final bill = ref.read(billsProvider.notifier).quickSale(_quantities, method: _method);
    if (bill == null) return;
    final l10n = context.l10n;
    setState(() {
      _quantities.clear();
      _method = PaymentMethod.cash;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('${l10n.quickSaleDone} · ${l10n.amountEgp(formatMoney(bill.total))}')));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final products = ref.watch(catalogProvider).products;
    final accounts = ref.watch(paymentAccountsProvider);
    var sum = 0;
    for (final product in products) {
      sum += product.price * (_quantities[product.id] ?? 0);
    }
    final methods = [
      (PaymentMethod.cash, l10n.payCash),
      (PaymentMethod.instapay, l10n.payInstapay),
      (PaymentMethod.wallet, l10n.payWallet),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.navQuickSale, style: AppText.formTitle),
        const SizedBox(height: 18),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProductPicker(products: products, quantities: _quantities, onChanged: _change),
                if (_quantities.isNotEmpty && accounts[_method] != null) ...[
                  const SizedBox(height: 16),
                  PaymentQr(account: accounts[_method]!), // the customer scans it to pay
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Pinned at the bottom: how they pay, the total and the button.
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (method, label) in methods)
              Pill(label: label, selected: _method == method, onTap: () => setState(() => _method = method)),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _quantities.isEmpty ? null : _sell,
          style: FilledButton.styleFrom(minimumSize: const Size(0, 60)),
          child: Text(
            _quantities.isEmpty ? l10n.quickSaleSell : '${l10n.quickSaleSell} · ${l10n.amountEgp(formatMoney(sum))}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
