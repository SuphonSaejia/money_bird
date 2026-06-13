import '../core/utils/app_date_utils.dart';
import '../data/db/database.dart';

/// Pure helpers over the savings ledger. The authoritative balance lives in
/// `FinancialProfile.currentSavings`; these derive activity figures for display.
class Savings {
  Savings._();

  /// A single entry's signed effect on the balance: +deposit, −withdrawal.
  static double signed(SavingsEntry e) => e.deposit ? e.amount : -e.amount;

  /// Net change recorded by [entries] (deposits − withdrawals).
  static double net(Iterable<SavingsEntry> entries) =>
      entries.fold(0.0, (sum, e) => sum + signed(e));
}

/// Activity figures for the savings screen, for the calendar month of [now].
class SavingsSummary {
  const SavingsSummary({
    required this.balance,
    required this.depositedThisMonth,
    required this.withdrawnThisMonth,
    required this.entryCount,
  });

  /// The current savings balance (from the profile).
  final double balance;
  final double depositedThisMonth;
  final double withdrawnThisMonth;
  final int entryCount;

  double get netThisMonth => depositedThisMonth - withdrawnThisMonth;

  static const empty = SavingsSummary(
    balance: 0,
    depositedThisMonth: 0,
    withdrawnThisMonth: 0,
    entryCount: 0,
  );

  factory SavingsSummary.compute({
    required double balance,
    required List<SavingsEntry> entries,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final start = AppDateUtils.startOfMonth(today);
    final end = AppDateUtils.startOfNextMonth(today);

    double deposited = 0;
    double withdrawn = 0;
    for (final e in entries) {
      final inMonth = !e.date.isBefore(start) && e.date.isBefore(end);
      if (!inMonth) continue;
      if (e.deposit) {
        deposited += e.amount;
      } else {
        withdrawn += e.amount;
      }
    }

    return SavingsSummary(
      balance: balance,
      depositedThisMonth: deposited,
      withdrawnThisMonth: withdrawn,
      entryCount: entries.length,
    );
  }
}
