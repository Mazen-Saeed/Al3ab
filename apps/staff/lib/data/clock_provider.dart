import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current time, updated once a second. A screen with running timers watches it, so it
/// redraws every second. The value itself is not used: a unit works out its own elapsed time.
class ClockNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final timer = Timer.periodic(const Duration(seconds: 1), (_) => state = DateTime.now());
    ref.onDispose(timer.cancel); // stops the clock when the app (or a test) closes
    return DateTime.now();
  }
}

final clockProvider = NotifierProvider<ClockNotifier, DateTime>(ClockNotifier.new);
