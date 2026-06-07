/// Small date helpers used by the stats + health calculations. All ranges are
/// half-open `[start, end)` to keep aggregation queries unambiguous.
class AppDateUtils {
  AppDateUtils._();

  static DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime startOfMonth(DateTime d) => DateTime(d.year, d.month, 1);

  static DateTime startOfNextMonth(DateTime d) =>
      DateTime(d.year, d.month + 1, 1);

  static DateTime startOfYear(DateTime d) => DateTime(d.year, 1, 1);

  /// Monday as the first day of the week (matches the reference design).
  static DateTime startOfWeek(DateTime d) {
    final day = startOfDay(d);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  static int daysInMonth(DateTime d) =>
      DateTime(d.year, d.month + 1, 0).day;

  /// How far through the current month we are, as a 0..1 fraction.
  static double monthProgress(DateTime now) {
    return now.day / daysInMonth(now);
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
