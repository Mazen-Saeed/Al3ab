import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/preferences_provider.dart';

const _languageKey = 'language';

/// The app's language: Arabic by default. Settings changes it, and the choice is saved
/// on the device, so the app opens in the same language next time.
class AppLanguageNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final saved = ref.watch(sharedPreferencesProvider).getString(_languageKey);
    return Locale(saved == 'en' ? 'en' : 'ar'); // only these two exist; anything else means Arabic
  }

  void set(Locale locale) {
    state = locale;
    unawaited(ref.read(sharedPreferencesProvider).setString(_languageKey, locale.languageCode));
  }
}

final appLanguageProvider = NotifierProvider<AppLanguageNotifier, Locale>(AppLanguageNotifier.new);
