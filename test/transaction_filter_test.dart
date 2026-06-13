// Pure-Dart tests for the transaction search/filter logic.

import 'package:flutter_test/flutter_test.dart';
import 'package:money_bird/data/db/database.dart';
import 'package:money_bird/data/models/transaction_type.dart';
import 'package:money_bird/domain/transaction_filter.dart';

Transaction _txn({
  required String id,
  required double amount,
  required TransactionType type,
  required String categoryId,
  String? note,
}) {
  return Transaction(
    id: id,
    amount: amount,
    type: type,
    categoryId: categoryId,
    note: note,
    date: DateTime(2026, 6, 10),
    createdAt: DateTime(2026, 6, 10),
  );
}

void main() {
  final sample = [
    _txn(id: '1', amount: 120, type: TransactionType.expense, categoryId: 'food', note: 'Lunch with Bee'),
    _txn(id: '2', amount: 50000, type: TransactionType.income, categoryId: 'salary', note: 'June salary'),
    _txn(id: '3', amount: 300, type: TransactionType.expense, categoryId: 'transport', note: null),
    _txn(id: '4', amount: 800, type: TransactionType.expense, categoryId: 'food', note: 'Dinner'),
  ];

  test('an empty filter is inactive and returns everything', () {
    const filter = TransactionFilter();
    expect(filter.isActive, isFalse);
    expect(filter.apply(sample), hasLength(4));
  });

  test('filters by type', () {
    const filter = TransactionFilter(type: TransactionType.expense);
    final result = filter.apply(sample);
    expect(result.map((t) => t.id), ['1', '3', '4']);
  });

  test('filters by category', () {
    const filter = TransactionFilter(categoryId: 'food');
    expect(filter.apply(sample).map((t) => t.id), ['1', '4']);
  });

  test('searches notes case-insensitively', () {
    const filter = TransactionFilter(query: 'LUNCH');
    expect(filter.apply(sample).single.id, '1');
  });

  test('a null note never matches a text query', () {
    const filter = TransactionFilter(query: 'transport');
    expect(filter.apply(sample), isEmpty);
  });

  test('combines criteria (type + text)', () {
    const filter = TransactionFilter(
      type: TransactionType.expense,
      query: 'dinner',
    );
    expect(filter.apply(sample).single.id, '4');
  });

  test('preserves input order', () {
    const filter = TransactionFilter(type: TransactionType.expense);
    final result = filter.apply(sample);
    expect(result, orderedEquals(result.toList()..sort((a, b) => 0)));
    expect(result.first.id, '1');
    expect(result.last.id, '4');
  });

  test('copyWith can clear type and category', () {
    const filter = TransactionFilter(
      type: TransactionType.income,
      categoryId: 'salary',
    );
    final cleared = filter.copyWith(clearType: true, clearCategory: true);
    expect(cleared.type, isNull);
    expect(cleared.categoryId, isNull);
    expect(cleared.isActive, isFalse);
  });
}
