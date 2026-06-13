import '../db/database.dart';

/// Thin wrapper around [AppDatabase] for monthly budgets. The overall budget is
/// stored under the [overallBudgetId] sentinel; everything else is keyed by
/// category id. Setting an amount of 0 (or less) clears that budget.
class BudgetRepository {
  BudgetRepository(this._db);

  final AppDatabase _db;

  Stream<List<Budget>> watch() => _db.watchBudgets();

  Future<void> setOverall(double amount) => _set(overallBudgetId, amount);

  Future<void> setCategory(String categoryId, double amount) =>
      _set(categoryId, amount);

  Future<void> _set(String categoryId, double amount) {
    if (amount <= 0) return _db.deleteBudget(categoryId);
    return _db.upsertBudget(categoryId, amount);
  }

  Future<void> remove(String categoryId) => _db.deleteBudget(categoryId);
}
