import 'package:al3b_staff/data/unit.dart';
import 'package:al3b_staff/floor/time_text.dart';
import 'package:al3b_staff/l10n/arb/app_localizations_ar.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  group('cost (what the customer pays)', () {
    test('open single: 1 hour at 50 is 50', () {
      final unit = testUnit(status: UnitStatus.running, startedAt: ago(const Duration(hours: 1, seconds: 5)));
      expect(unit.currentCost, 50);
    });

    test('multi uses the multi price', () {
      final unit = testUnit(
        status: UnitStatus.running,
        multi: 70,
        isMulti: true,
        startedAt: ago(const Duration(minutes: 30, seconds: 5)),
      );
      expect(unit.currentCost, 35); // half an hour at 70
    });

    test('rounds down to whole pounds', () {
      final unit = testUnit(status: UnitStatus.running, startedAt: ago(const Duration(minutes: 10, seconds: 1)));
      expect(unit.currentCost, 8); // 8.35 -> 8
    });

    test('a unit that is not running costs nothing', () {
      expect(testUnit().currentCost, 0);
    });
  });

  group('planned time', () {
    test('open time has no countdown', () {
      final unit = testUnit(status: UnitStatus.running, startedAt: ago(const Duration(minutes: 20)));
      expect(unit.remaining, isNull);
      expect(unit.isOvertime, isFalse);
      expect(unit.needsAttention, isFalse);
    });

    test('counts down from the plan', () {
      final unit = testUnit(status: UnitStatus.running, planned: 60, startedAt: ago(const Duration(minutes: 50)));
      expect(unit.remaining!, lessThanOrEqualTo(const Duration(minutes: 10)));
      expect(unit.remaining!, greaterThan(const Duration(minutes: 9, seconds: 50)));
      expect(unit.needsAttention, isFalse);
    });

    test('the last minute needs attention, but is not overtime', () {
      final unit = testUnit(
        status: UnitStatus.running,
        planned: 60,
        startedAt: ago(const Duration(minutes: 59, seconds: 30)),
      );
      expect(unit.isEndingSoon, isTrue);
      expect(unit.isOvertime, isFalse);
      expect(unit.needsAttention, isTrue);
    });

    test('5 minutes left is not "ending soon" yet', () {
      final unit = testUnit(status: UnitStatus.running, planned: 60, startedAt: ago(const Duration(minutes: 55)));
      expect(unit.isEndingSoon, isFalse);
    });

    test('past the plan is overtime', () {
      final unit = testUnit(status: UnitStatus.running, planned: 60, startedAt: ago(const Duration(minutes: 65)));
      expect(unit.isOvertime, isTrue);
      expect(unit.remaining!.isNegative, isTrue);
      expect(unit.needsAttention, isTrue);
    });

    test('adding time extends the planned end', () {
      final unit = testUnit(status: UnitStatus.running, planned: 60, startedAt: ago(const Duration(minutes: 10)));
      expect(unit.plannedMinutesAfterAdding(30), 90);
    });

    test('adding time when already over counts from now', () {
      // 65.5 minutes played -> rounds up to 66, plus 30 more
      final unit = testUnit(
        status: UnitStatus.running,
        planned: 60,
        startedAt: ago(const Duration(minutes: 65, seconds: 30)),
      );
      expect(unit.plannedMinutesAfterAdding(30), 96);
    });

    test('copyWith(makeOpen) removes the plan, other changes keep it', () {
      final unit = testUnit(status: UnitStatus.running, planned: 60, startedAt: ago(const Duration(minutes: 5)));
      expect(unit.copyWith(makeOpen: true).plannedMinutes, isNull);
      expect(unit.copyWith(isMulti: true).plannedMinutes, 60);
    });
  });

  group('timer text', () {
    test('open time shows time played', () {
      expect(timerText(const Duration(hours: 1, minutes: 24, seconds: 10), null), '1:24:10');
    });

    test('planned shows time left', () {
      expect(timerText(const Duration(minutes: 47), const Duration(minutes: 12, seconds: 27)), '0:12:27');
    });

    test('over the plan shows + and the extra time', () {
      expect(timerText(const Duration(hours: 1, minutes: 5), const Duration(minutes: -5, seconds: -16)), '+0:05:16');
    });

    test('exactly zero left is not overtime', () {
      expect(timerText(const Duration(hours: 1), Duration.zero), '0:00:00');
    });

    test('minutes and seconds are padded, hours are not', () {
      expect(formatElapsed(const Duration(seconds: 9)), '0:00:09');
      expect(formatElapsed(const Duration(hours: 12, minutes: 5)), '12:05:00');
    });
  });

  group('friendlyTime (spoken time of day, Arabic)', () {
    final ar = AppLocalizationsAr();
    String say(int hour, [int minute = 0]) => friendlyTime(ar, DateTime(2026, 10, 2, hour, minute));

    test('night', () => expect(say(21), '9 بليل'));
    test('morning with minutes', () => expect(say(10, 30), '10:30 الصبح'));
    test('noon', () => expect(say(12), '12 الظهر'));
    test('afternoon', () => expect(say(16), '4 العصر'));
    test('3:45 pm is still الظهر', () => expect(say(15, 45), '3:45 الظهر'));
    test('5 am is the first morning hour', () => expect(say(5), '5 الصبح'));
    test('4:59 am is still night', () => expect(say(4, 59), '4:59 بليل'));
    test('midnight is 12 at night', () => expect(say(0), '12 بليل'));
  });
}
