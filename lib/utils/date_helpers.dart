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

  /// Short date format: "14 Mar 2026"
  static String shortDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Month-year format: "Feb 2026"
  static String monthYear(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
