import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../app_theme.dart';
import '../data/bill.dart';
import '../data/payment_account.dart';
import '../data/product.dart';
import '../data/unit.dart';
import '../l10n/l10n.dart';
import '../shell/form_surface.dart';
import '../shell/pill.dart';
import 'bill_widgets.dart';
import 'time_text.dart';
import '../data/money.dart';

/// What staff chose in the checkout form.
class CheckoutResult {
  const CheckoutResult({required this.discount, this.discountReason, required this.method});

  final int discount; // piasters, already limited to the subtotal
  final String? discountReason;
  final PaymentMethod method;
}

/// The bill for a unit: play time + orders, an optional discount (with a reason), the payment
/// method, and the amount to collect. [endedAt] is when checkout opened: the play cost is
/// counted until then. [paymentAccounts]: where the venue gets paid, per method; when the chosen
/// method has one, its QR code (and the account written out) is shown for the customer. Returns null if closed without paying.
Future<CheckoutResult?> showCheckout(
  BuildContext context,
  Unit unit,
  List<OrderLine> orders,
  DateTime endedAt, {
  Map<PaymentMethod, PaymentAccount> paymentAccounts = const {},
}) =>
    showFormSurface<CheckoutResult>(
      context,
      _CheckoutForm(unit: unit, orders: orders, endedAt: endedAt, paymentAccounts: paymentAccounts),
      scrolls: false, // the form scrolls its middle part itself, so the pay button stays in view
    );

class _CheckoutForm extends StatefulWidget {
  const _CheckoutForm({required this.unit, required this.orders, required this.endedAt, required this.paymentAccounts});

  final Unit unit;
  final List<OrderLine> orders;
  final DateTime endedAt;
  final Map<PaymentMethod, PaymentAccount> paymentAccounts;

  @override
  State<_CheckoutForm> createState() => _CheckoutFormState();
}

class _CheckoutFormState extends State<_CheckoutForm> {
  final _discountField = TextEditingController();
  final _reasonField = TextEditingController();
  PaymentMethod _method = PaymentMethod.cash; // most customers pay cash

  @override
  void dispose() {
    _discountField.dispose();
    _reasonField.dispose();
    super.dispose();
  }

  late final int _playCost = widget.unit.costAt(widget.endedAt);
  late final int _ordersSum = widget.orders.fold(0, (sum, line) => sum + line.total);
  int get _subtotal => _playCost + _ordersSum;

  /// What was typed, never more than the subtotal (a discount can't make the bill negative).
  int get _discount => math.min(parseMoney(_discountField.text) ?? 0, _subtotal);
  int get _due => _subtotal - _discount;

  /// A discount needs a reason (the owner reads these later).
  bool get _canPay => _discount == 0 || _reasonField.text.trim().isNotEmpty;

  void _pay() {
    final reason = _reasonField.text.trim();
    Navigator.pop(
      context,
      CheckoutResult(
        discount: _discount,
        discountReason: _discount > 0 ? reason : null,
        method: _method,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final methods = [
      (PaymentMethod.cash, l10n.payCash),
      (PaymentMethod.instapay, l10n.payInstapay),
      (PaymentMethod.wallet, l10n.payWallet),
    ];

    return Padding(
      padding: const EdgeInsetsDirectional.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormHeader(title: l10n.checkoutTitle, heading: widget.unit.name),
          const SizedBox(height: 20),

          // Middle part: scrolls when the bill + QR code are taller than the screen
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // The bill, read-only
                  BillRow(
                    label: l10n.playTime,
                    detail: playDetail(
                      l10n,
                      widget.unit.elapsedAt(widget.endedAt),
                      pricePerHour: widget.unit.isMulti ? widget.unit.multiHourlyPrice! : widget.unit.hourlyPrice,
                      isMulti: widget.unit.isMulti,
                    ),
                    value: l10n.amountEgp(formatMoney(_playCost)),
                  ),
                  if (widget.orders.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    BillRow(label: l10n.ordersTitle, value: l10n.amountEgp(formatMoney(_ordersSum)), bold: true),
                    const SizedBox(height: 4),
                    for (final line in widget.orders) OrderRow(line: line),
                  ],
                  const Padding(
                    padding: EdgeInsetsDirectional.symmetric(vertical: 14),
                    child: Divider(height: 1, color: AppColors.raised),
                  ),
                  BillRow(label: l10n.billSubtotal, value: l10n.amountEgp(formatMoney(_subtotal)), bold: true),
                  const SizedBox(height: 20),

                  // Discount (optional). The reason field appears once there is a discount.
                  Text(l10n.discountLabel, style: AppText.label),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _discountField,
                    keyboardType: moneyKeyboard,
                    inputFormatters: moneyInputFormatters,
                    onChanged: (_) => setState(() {}), // redraw: due amount, reason field, button
                    decoration: const InputDecoration(hintText: '0'),
                  ),
                  if (_discount > 0) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: _reasonField,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(hintText: l10n.discountReasonHint),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Payment method
                  Text(l10n.paymentMethodLabel, style: AppText.label),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (method, label) in methods)
                        Pill(label: label, selected: _method == method, onTap: () => setState(() => _method = method)),
                    ],
                  ),

                  // The customer scans this to pay (only for methods that have a link)
                  if (widget.paymentAccounts[_method] case final account?) ...[
                    const SizedBox(height: 16),
                    _PaymentQr(account: account),
                  ],
                ],
              ),
            ),
          ),

          // Pinned at the bottom: the amount to collect and the main button
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: Text(l10n.amountDue, style: const TextStyle(fontWeight: FontWeight.w600))),
              Text(l10n.amountEgp(formatMoney(_due)), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _canPay ? _pay : null,
            style: FilledButton.styleFrom(minimumSize: const Size(0, 60)),
            child: Text(l10n.confirmPayment, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

/// For the customer: a QR code of the payment link on a white card (QR codes need a light
/// background to scan), then, in case the scan fails, the account to type and the link itself.
/// The texts are selectable so a cashier on a PC can copy them.
class _PaymentQr extends StatelessWidget {
  const _PaymentQr({required this.account});

  final PaymentAccount account;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
      child: Column(
        children: [
          QrImageView(data: account.link, size: 200, backgroundColor: Colors.white),
          const SizedBox(height: 14),
          Text(
            context.l10n.payManuallyHint,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.textOnLightMuted),
          ),
          const SizedBox(height: 4),
          for (final text in account.typeable)
            SelectableText(
              text,
              textDirection: TextDirection.ltr, // handles and phone numbers read left to right
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textOnLight),
            ),
          const SizedBox(height: 8),
          SelectableText(
            account.link,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: const TextStyle(fontSize: 12, color: AppColors.textOnLightMuted),
          ),
        ],
      ),
    );
  }
}
