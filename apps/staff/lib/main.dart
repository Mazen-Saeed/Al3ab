import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'data/sample_data.dart';
import 'data/shop_store.dart';
import 'l10n/app_language.dart';
import 'l10n/l10n.dart';
import 'shell/app_shell.dart';
import 'shell/notice_board.dart';
import 'shell/notice_overlay.dart';
import 'shell/session_alerts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // The one store for the whole app. Sample data for now; local SQLite later.
  final _store = ShopStore(
    buildSampleUnits(),
    products: sampleProducts,
    stockItems: sampleStockItems,
    paymentAccounts: samplePaymentAccounts,
  );
  final _board = NoticeBoard(); // messages to staff, shown at the top of every page

  @override
  void dispose() {
    _store.dispose(); // stops its clock
    _board.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds the whole app when the language changes (Manage > language).
    return ValueListenableBuilder<Locale>(
      valueListenable: appLanguage,
      builder: (context, locale, _) => MaterialApp(
        onGenerateTitle: (context) => context.l10n.appTitle,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: appTheme,
        // builder wraps the whole app, so notices float above every page.
        builder: (context, child) => NoticeOverlay(board: _board, child: child!),
        home: SessionAlerts(
          store: _store,
          board: _board,
          child: AppShell(store: _store),
        ),
      ),
    );
  }
}
