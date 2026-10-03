import 'package:al3b_staff/data/preferences_provider.dart';
import 'package:al3b_staff/l10n/app_language.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  /// A fresh app start reading the given saved settings.
  ProviderContainer appStart(SharedPreferences prefs) {
    final container = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWith((ref) => prefs)]);
    addTearDown(container.dispose);
    return container;
  }

  test('the app opens in Arabic, and a language that was changed is saved for the next start', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final first = appStart(prefs);
    expect(first.read(appLanguageProvider), const Locale('ar'));

    first.read(appLanguageProvider.notifier).set(const Locale('en'));
    expect(first.read(appLanguageProvider), const Locale('en'));

    final nextStart = appStart(prefs); // like closing and opening the app
    expect(nextStart.read(appLanguageProvider), const Locale('en'));
  });

  test('an unknown saved language falls back to Arabic', () async {
    SharedPreferences.setMockInitialValues({'language': 'fr'});
    final prefs = await SharedPreferences.getInstance();
    expect(appStart(prefs).read(appLanguageProvider), const Locale('ar'));
  });
}
