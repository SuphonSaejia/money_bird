import '../core/utils/app_date_utils.dart';
import '../data/db/database.dart';
import '../data/models/transaction_type.dart';

/// Aggregated figures for the current calendar month, derived from the live
/// transaction stream. Drives the home overview cards.
class MonthSummary {
  const MonthSummary({
    this.income = 0,
    this.expense = 0,
    this.spentToday = 0,
    this.count = 0,
    this.streak = 0,
  });

  final double income; // logged income this month
  final double expense; // logged expenses this month
  final double spentToday; // expenses dated today
  final int count; // number of transactions this month
  final int streak; // consecutive days up to today with ≥1 transaction

  double get net => income - expense;

  static const empty = MonthSummary();

  factory MonthSummary.fromTransactions(
    List<Transaction> txns, {
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    double income = 0;
    double expense = 0;
    double spentToday = 0;
    final daysWithActivity = <DateTime>{};

    for (final t in txns) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
        if (AppDateUtils.isSameDay(t.date, today)) spentToday += t.amount;
      }
      daysWithActivity.add(AppDateUtils.startOfDay(t.date));
    }

    // Count back from today while each day has activity.
    var streak = 0;
    var cursor = AppDateUtils.startOfDay(today);
    while (daysWithActivity.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return MonthSummary(
      income: income,
      expense: expense,
      spentToday: spentToday,
      count: txns.length,
      streak: streak,
    );
  }
}
