import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The small settings saved on this device (the language, later more). It is opened once in main()
/// before the app starts, and handed in here; tests hand in an in-memory copy.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Give it a value: ProviderScope(overrides: [...]) in main() and in tests'),
);
