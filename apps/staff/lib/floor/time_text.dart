import '../l10n/l10n.dart';

/// 1:24:10 style. Hours aren't padded; minutes and seconds always have 2 digits.
String formatElapsed(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.inHours}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
}

/// What the big number shows for a running unit:
/// open time -> time played; planned -> time left; over the plan -> "+5:12" (time over).
String timerText(Duration elapsed, Duration? remaining) {
  if (remaining == null) return formatElapsed(elapsed);
  if (remaining.isNegative) return '+${formatElapsed(-remaining)}';
  return formatElapsed(remaining);
}

/// Time the way people say it: "9 بليل", "3 الظهر", "10:30 الصبح".
/// Simpler to read at a glance than "9:00 م".
String friendlyTime(AppLocalizations l10n, DateTime time) {
  final hour24 = time.hour;
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final hour = time.minute == 0
      ? '$hour12'
      : '$hour12:${time.minute.toString().padLeft(2, '0')}';

  if (hour24 >= 5 && hour24 <= 11) return l10n.timeMorning(hour);
  if (hour24 >= 12 && hour24 <= 15) return l10n.timeNoon(hour);
  if (hour24 >= 16 && hour24 <= 17) return l10n.timeAfternoon(hour);
  return l10n.timeNight(hour); // 18:00 - 04:59
}

/// Time played, the way people say it: "ساعة و20 دقيقة", "ساعتين", "5 دقايق".
/// The wording changes with the number in Arabic (1, 2, 3-10, 11+), so it is chosen here
/// (ARB plural syntax can turn the digits into Arabic-Indic ones, and we want 1 2 3).
String playedText(AppLocalizations l10n, Duration played) {
  final hours = played.inHours;
  final minutes = played.inMinutes % 60;

  final hoursText = switch (hours) {
    0 => '',
    1 => l10n.hoursOne,
    2 => l10n.hoursTwo,
    >= 3 && <= 10 => l10n.hoursFew(hours),
    _ => l10n.hoursMany(hours),
  };
  final minutesText = switch (minutes) {
    0 => '',
    1 => l10n.minutesOne,
    2 => l10n.minutesTwo,
    >= 3 && <= 10 => l10n.minutesFew(minutes),
    _ => l10n.minutesMany(minutes),
  };

  if (hours == 0 && minutes == 0) return l10n.lessThanMinute;
  if (hours == 0) return minutesText;
  if (minutes == 0) return hoursText;
  return l10n.hoursAndMinutes(hoursText, minutesText);
}

/// The line under "وقت اللعب" on a bill: "ساعة و20 دقيقة · زوجي · 50 جنيه في الساعة".
String playDetail(AppLocalizations l10n, Duration played, {required int pricePerHour, required bool isMulti}) {
  return [
    playedText(l10n, played),
    if (isMulti) l10n.modeMulti,
    l10n.pricePerHour(pricePerHour),
  ].join(' · ');
}
