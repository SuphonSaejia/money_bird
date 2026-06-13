import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/transaction_type.dart';

part 'database.g.dart';

/// A single money movement. Amounts are always stored positive; [type] gives
/// the direction. [date] is the day the spending/income happened, while
/// [createdAt] records when the row was logged (used as a tie-breaker).
class Transactions extends Table {
  TextColumn get id => text()();
  RealColumn get amount => real()();
  IntColumn get type => intEnum<TransactionType>()();
  TextColumn get categoryId => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// A monthly spending budget. One row per scope: the special [overallBudgetId]
/// holds the total monthly budget, and each spending category id holds an
/// optional per-category cap. Budgets recur every month (they are not tied to a
/// specific calendar month) to keep the model minimal.
class Budgets extends Table {
  TextColumn get categoryId => text()();
  RealColumn get amount => real()();

  @override
  Set<Column> get primaryKey => {categoryId};
}

/// Sentinel [Budgets.categoryId] for the overall monthly budget.
const String overallBudgetId = 'overall';

@DriftDatabase(tables: [Transactions, Budgets])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'money_bird'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(budgets);
          }
        },
      );

  /// Newest transactions first.
  Stream<List<Transaction>> watchAll() {
    return (select(transactions)
          ..orderBy([
            (t) => OrderingTerm.desc(t.date),
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .watch();
  }

  /// The most recent [limit] transactions (for the home "recent activity" list).
  Stream<List<Transaction>> watchRecent(int limit) {
    return (select(transactions)
          ..orderBy([
            (t) => OrderingTerm.desc(t.date),
            (t) => OrderingTerm.desc(t.createdAt),
          ])
          ..limit(limit))
        .watch();
  }

  /// Transactions whose [date] falls within [start, end).
  Stream<List<Transaction>> watchBetween(DateTime start, DateTime end) {
    return (select(transactions)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(start) & t.date.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<List<Transaction>> getBetween(DateTime start, DateTime end) {
    return (select(transactions)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(start) & t.date.isSmallerThanValue(end)))
        .get();
  }

  Future<void> upsertTransaction(TransactionsCompanion entry) {
    return into(transactions).insertOnConflictUpdate(entry);
  }

  Future<void> deleteTransaction(String id) {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  /// Every transaction, newest first — used by the backup export.
  Future<List<Transaction>> getAllTransactions() {
    return (select(transactions)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  // ── Budgets ────────────────────────────────────────────────────────────────

  /// All budget rows (overall + per-category), as a live stream.
  Stream<List<Budget>> watchBudgets() => select(budgets).watch();

  Future<List<Budget>> getAllBudgets() => select(budgets).get();

  Future<void> upsertBudget(String categoryId, double amount) {
    return into(budgets).insertOnConflictUpdate(
      BudgetsCompanion.insert(categoryId: categoryId, amount: amount),
    );
  }

  Future<void> deleteBudget(String categoryId) {
    return (delete(budgets)..where((b) => b.categoryId.equals(categoryId))).go();
  }

  // ── Backup / restore ─────────────────────────────────────────────────────────

  /// Atomically replaces ALL stored data (transactions + budgets) with the
  /// given rows. Used when restoring a backup.
  Future<void> replaceAll({
    required List<TransactionsCompanion> txns,
    required List<BudgetsCompanion> budgetRows,
  }) {
    return transaction(() async {
      await delete(transactions).go();
      await delete(budgets).go();
      await batch((b) {
        b.insertAll(transactions, txns);
        b.insertAll(budgets, budgetRows);
      });
    });
  }
}
