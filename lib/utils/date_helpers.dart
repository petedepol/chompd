import 'package:intl/intl.dart';

/// Date formatting and calculation helpers.
class DateHelpers {
  DateHelpers._();

  /// Friendly "X days" or "today" or "tomorrow" string.
  static String daysUntil(DateTime date) {
    final now = DateTime.now();
    final diff = DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    if (diff == 0) return 'today';
    if (diff == 1) return 'tomorrow';
    if (diff < 0) return '${-diff} days ago';
    return '$diff days';
  }

  /// Short date format: "14 Mar 2026" (locale-aware when [locale] provided).
  static String shortDate(DateTime date, {String? locale}) {
    return DateFormat('d MMM yyyy', locale).format(date);
  }

  /// Month-year format: "Feb 2026" (locale-aware when [locale] provided).
  static String monthYear(DateTime date, {String? locale}) {
    return DateFormat('MMM yyyy', locale).format(date);
  }
}
