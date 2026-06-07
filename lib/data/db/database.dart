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

@DriftDatabase(tables: [Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'money_bird'));

  @override
  int get schemaVersion => 1;

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
}
