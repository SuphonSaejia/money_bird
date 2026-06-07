import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/app_date_utils.dart';
import '../db/database.dart';
import '../models/transaction_type.dart';

/// Thin domain-friendly wrapper around [AppDatabase] for transactions.
class TransactionRepository {
  TransactionRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<Transaction>> watchAll() => _db.watchAll();

  Stream<List<Transaction>> watchRecent({int limit = 8}) =>
      _db.watchRecent(limit);

  Stream<List<Transaction>> watchBetween(DateTime start, DateTime end) =>
      _db.watchBetween(start, end);

  /// All transactions within the calendar month containing [month].
  Stream<List<Transaction>> watchMonth(DateTime month) => _db.watchBetween(
        AppDateUtils.startOfMonth(month),
        AppDateUtils.startOfNextMonth(month),
      );

  Future<List<Transaction>> getBetween(DateTime start, DateTime end) =>
      _db.getBetween(start, end);

  /// Creates a new transaction and returns its generated id.
  Future<String> add({
    required double amount,
    required TransactionType type,
    required String categoryId,
    String? note,
    required DateTime date,
  }) async {
    final id = _uuid.v4();
    await _db.upsertTransaction(
      TransactionsCompanion.insert(
        id: id,
        amount: amount.abs(),
        type: type,
        categoryId: categoryId,
        note: Value(note),
        date: date,
      ),
    );
    return id;
  }

  Future<void> update(Transaction txn) =>
      _db.upsertTransaction(txn.toCompanion(true));

  Future<void> delete(String id) => _db.deleteTransaction(id);
}
