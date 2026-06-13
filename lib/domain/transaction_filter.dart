import '../data/db/database.dart';
import '../data/models/transaction_type.dart';

/// A set of criteria for narrowing a transaction list. Pure and side-effect
/// free so it can be unit-tested and reused by the search screen.
class TransactionFilter {
  const TransactionFilter({
    this.query = '',
    this.type,
    this.categoryId,
  });

  /// Free-text matched (case-insensitively) against the note.
  final String query;

  /// Restrict to income or expense; null means both.
  final TransactionType? type;

  /// Restrict to a single category id; null means all.
  final String? categoryId;

  bool get isActive =>
      query.trim().isNotEmpty || type != null || categoryId != null;

  TransactionFilter copyWith({
    String? query,
    TransactionType? type,
    String? categoryId,
    bool clearType = false,
    bool clearCategory = false,
  }) {
    return TransactionFilter(
      query: query ?? this.query,
      type: clearType ? null : (type ?? this.type),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
    );
  }

  /// Returns the subset of [txns] matching every active criterion, preserving
  /// the input order.
  List<Transaction> apply(List<Transaction> txns) {
    final q = query.trim().toLowerCase();
    return txns.where((t) {
      if (type != null && t.type != type) return false;
      if (categoryId != null && t.categoryId != categoryId) return false;
      if (q.isNotEmpty) {
        final note = t.note?.toLowerCase() ?? '';
        if (!note.contains(q)) return false;
      }
      return true;
    }).toList();
  }
}
