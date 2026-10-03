import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bill.dart';
import 'payment_account.dart';
import 'sample_data.dart';

/// Where customers pay, per method (venue settings, later). Checkout shows a QR for these.
/// A method without an entry (cash) shows nothing extra.
final paymentAccountsProvider = Provider<Map<PaymentMethod, PaymentAccount>>((ref) => samplePaymentAccounts);
