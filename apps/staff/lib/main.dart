import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'data/preferences_provider.dart';
import 'l10n/app_language.dart';
import 'l10n/l10n.dart';
import 'shell/app_shell.dart';
import 'shell/notice_overlay.dart';
import 'shell/session_alerts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // a plugin is used before runApp
  final prefs = await SharedPreferences.getInstance(); // the saved settings, read once here
  runApp(
    // ProviderScope holds every provider (units, menu and stock, bills...)
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWith((ref) => prefs)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuilds the whole app when the language changes (Manage > language).
    final locale = ref.watch(appLanguageProvider);
    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: appTheme,
      // builder wraps the whole app, so notices float above every page.
      builder: (context, child) => NoticeOverlay(child: child!),
      home: const SessionAlerts(child: AppShell()),
    );
  }
}
