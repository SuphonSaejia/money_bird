// Tests for the savings ledger: pure summary math, plus the actions that keep
// the authoritative balance (and therefore the goal / emergency fund / health
// score) in step with logged deposits and withdrawals.

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_bird/data/db/database.dart';
import 'package:money_bird/data/models/financial_profile.dart';
import 'package:money_bird/domain/savings.dart';
import 'package:money_bird/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

SavingsEntry _entry({
  required String id,
  required double amount,
  required bool deposit,
  required DateTime date,
}) {
  return SavingsEntry(
    id: id,
    amount: amount,
    deposit: deposit,
    note: null,
    date: date,
    createdAt: date,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Savings (pure)', () {
    test('signed flips withdrawals negative', () {
      expect(
        Savings.signed(
            _entry(id: '1', amount: 100, deposit: true, date: DateTime(2026, 6, 1))),
        100,
      );
      expect(
        Savings.signed(
            _entry(id: '2', amount: 100, deposit: false, date: DateTime(2026, 6, 1))),
        -100,
      );
    });

    test('net sums deposits minus withdrawals', () {
      final net = Savings.net([
        _entry(id: '1', amount: 5000, deposit: true, date: DateTime(2026, 6, 1)),
        _entry(id: '2', amount: 1000, deposit: false, date: DateTime(2026, 6, 2)),
      ]);
      expect(net, 4000);
    });

    test('SavingsSummary.compute scopes deposits/withdrawals to the month', () {
      final summary = SavingsSummary.compute(
        balance: 100000,
        now: DateTime(2026, 6, 13),
        entries: [
          _entry(id: '1', amount: 5000, deposit: true, date: DateTime(2026, 6, 5)),
          _entry(id: '2', amount: 2000, deposit: true, date: DateTime(2026, 6, 9)),
          _entry(id: '3', amount: 1000, deposit: false, date: DateTime(2026, 6, 10)),
          // Previous month — excluded from the monthly figures.
          _entry(id: '4', amount: 9000, deposit: true, date: DateTime(2026, 5, 20)),
        ],
      );
      expect(summary.balance, 100000);
      expect(summary.depositedThisMonth, 7000);
      expect(summary.withdrawnThisMonth, 1000);
      expect(summary.netThisMonth, 6000);
      expect(summary.entryCount, 4);
    });
  });

  group('SavingsActions', () {
    late SharedPreferences prefs;
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWith((ref) {
          final db = AppDatabase(NativeDatabase.memory());
          ref.onDispose(db.close);
          return db;
        }),
      ]);
      addTearDown(container.dispose);
      // Baseline profile: 100k saved, 20k/mo fixed costs.
      await container.read(profileProvider.notifier).save(
            const FinancialProfile(
              monthlyIncome: 50000,
              fixedExpenses: 20000,
              currentSavings: 100000,
            ),
          );
    });

    test('deposit raises the balance, withdraw lowers it', () async {
      final actions = container.read(savingsActionsProvider);

      await actions.deposit(5000);
      expect(container.read(profileProvider).currentSavings, 105000);

      await actions.withdraw(2000);
      expect(container.read(profileProvider).currentSavings, 103000);

      final entries = await container.read(appDatabaseProvider).getAllSavings();
      expect(entries, hasLength(2));
    });

    test('deleting an entry reverses its effect on the balance', () async {
      final actions = container.read(savingsActionsProvider);
      await actions.deposit(8000);
      expect(container.read(profileProvider).currentSavings, 108000);

      final entry =
          (await container.read(appDatabaseProvider).getAllSavings()).single;
      await actions.delete(entry);

      expect(container.read(profileProvider).currentSavings, 100000);
      expect(await container.read(appDatabaseProvider).getAllSavings(), isEmpty);
    });

    test('the balance never goes below zero', () async {
      final actions = container.read(savingsActionsProvider);
      await actions.withdraw(999999);
      expect(container.read(profileProvider).currentSavings, 0);
    });

    test('a deposit lifts the emergency fund and health score', () async {
      final before = container.read(financialHealthProvider);
      // 100k / 20k = 5 months covered. Adding 40k → 7 months → fully covered.
      await container.read(savingsActionsProvider).deposit(40000);
      final after = container.read(financialHealthProvider);

      expect(after.monthsCovered, greaterThan(before.monthsCovered));
      expect(after.score, greaterThanOrEqualTo(before.score));
    });

    test('a deposit advances goal progress', () async {
      final before = container.read(goalPlanProvider);
      await container.read(savingsActionsProvider).deposit(50000);
      final after = container.read(goalPlanProvider);

      expect(after.currentSavings, before.currentSavings + 50000);
      expect(after.progress, greaterThan(before.progress));
    });
  });
}
