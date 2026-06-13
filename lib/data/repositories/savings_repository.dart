import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';

/// Thin wrapper around [AppDatabase] for the savings ledger. Pure persistence —
/// adjusting the running balance (`FinancialProfile.currentSavings`) is
/// orchestrated above this layer (see `SavingsActions`).
class SavingsRepository {
  SavingsRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<SavingsEntry>> watch() => _db.watchSavings();

  /// Inserts a new entry and returns it. [amount] is stored positive.
  Future<void> add({
    required double amount,
    required bool deposit,
    String? note,
    DateTime? date,
  }) {
    return _db.upsertSavingsEntry(
      SavingsEntriesCompanion.insert(
        id: _uuid.v4(),
        amount: amount.abs(),
        deposit: deposit,
        note: Value(note),
        date: date ?? DateTime.now(),
      ),
    );
  }

  Future<void> delete(String id) => _db.deleteSavingsEntry(id);
}
