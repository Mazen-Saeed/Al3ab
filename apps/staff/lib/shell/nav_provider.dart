import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The pages of the nav, in nav order. The index is the page's place in the nav bar.
class NavPage {
  static const floor = 0;
  static const quickSale = 1;
  static const reservations = 2;
  static const shift = 3;
  static const manage = 4;
}

/// Which page is showing. It lives in a provider, not inside the shell, so a button on one page
/// (the Floor's "+ بيع سريع") can open another page.
class NavNotifier extends Notifier<int> {
  @override
  int build() => NavPage.floor;

  void open(int page) => state = page;
}

final navProvider = NotifierProvider<NavNotifier, int>(NavNotifier.new);
