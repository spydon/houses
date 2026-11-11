const monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const modelYear = 2026;
const daysInYear = 365;

DateTime dateForDay(int dayOfYear) => DateTime.utc(modelYear, 1, dayOfYear);

int dayOfYearFor(int month, int day) =>
    DateTime.utc(
      modelYear,
      month,
      day,
    ).difference(DateTime.utc(modelYear, 1, 1)).inDays +
    1;

DateTime _lastSundayAtOneUtc(int year, int month) {
  final last = DateTime.utc(year, month + 1, 0);
  return DateTime.utc(year, month, last.day - last.weekday % 7, 1);
}

bool isSummerTime(DateTime utc) {
  final start = _lastSundayAtOneUtc(utc.year, 3);
  final end = _lastSundayAtOneUtc(utc.year, 10);
  return !utc.isBefore(start) && utc.isBefore(end);
}

DateTime utcForLocal(int dayOfYear, int minuteOfDay) {
  final date = dateForDay(dayOfYear);
  final summer = date.add(Duration(minutes: minuteOfDay - 120));
  if (isSummerTime(summer)) {
    return summer;
  }
  return date.add(Duration(minutes: minuteOfDay - 60));
}

({int dayOfYear, int minuteOfDay}) stockholmNow() {
  final utc = DateTime.now().toUtc();
  final local = utc.add(Duration(hours: isSummerTime(utc) ? 2 : 1));
  final day = dayOfYearFor(local.month, local.day).clamp(1, daysInYear);
  return (dayOfYear: day, minuteOfDay: local.hour * 60 + local.minute);
}

String formatClock(int minuteOfDay) {
  final m = minuteOfDay.clamp(0, 1439);
  final hours = (m ~/ 60).toString().padLeft(2, '0');
  final minutes = (m % 60).toString().padLeft(2, '0');
  return '$hours:$minutes';
}

String _plural(int count, String unit) =>
    count == 1 ? '1 $unit' : '$count ${unit}s';

String formatDuration(int minutes) {
  if (minutes <= 0) {
    return 'None';
  }
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  if (hours == 0) {
    return _plural(rest, 'minute');
  }
  if (rest == 0) {
    return _plural(hours, 'hour');
  }
  return '${_plural(hours, 'hour')} ${_plural(rest, 'minute')}';
}

String formatDate(int dayOfYear) {
  final date = dateForDay(dayOfYear);
  return '${date.day} ${monthNames[date.month - 1]}';
}

String partOfMonth(int dayOfYear) {
  final date = dateForDay(dayOfYear);
  final month = monthNames[date.month - 1];
  if (date.day <= 10) {
    return 'early $month';
  }
  if (date.day <= 20) {
    return 'mid $month';
  }
  return 'late $month';
}
