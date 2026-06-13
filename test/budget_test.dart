// Pure-Dart tests for the budget model and its effect on the health score.

import 'package:flutter_test/flutter_test.dart';
import 'package:money_bird/data/db/database.dart';
import 'package:money_bird/data/models/financial_profile.dart';
import 'package:money_bird/domain/budget.dart';
import 'package:money_bird/domain/financial_health.dart';

void main() {
  group('MonthlyBudgets.fromRows', () {
    test('splits the overall row from per-category rows', () {
      final budgets = MonthlyBudgets.fromRows([
        Budget(categoryId: overallBudgetId, amount: 20000),
        Budget(categoryId: 'food', amount: 6000),
        Budget(categoryId: 'transport', amount: 2000),
      ]);

      expect(budgets.overall, 20000);
      expect(budgets.perCategory, {'food': 6000, 'transport': 2000});
      expect(budgets.isEmpty, isFalse);
    });

    test('an empty set has no overall and no categories', () {
      final budgets = MonthlyBudgets.fromRows([]);
      expect(budgets.overall, isNull);
      expect(budgets.perCategory, isEmpty);
      expect(budgets.isEmpty, isTrue);
    });
  });

  group('BudgetOverview.compute', () {
    test('computes overall remaining and per-category status, sorted by ratio',
        () {
      final overview = BudgetOverview.compute(
        budgets: const MonthlyBudgets(
          overall: 10000,
          perCategory: {'food': 4000, 'transport': 2000},
        ),
        spentByCategory: {'food': 3000, 'transport': 2500},
        totalSpent: 8000,
      );

      expect(overview.hasOverall, isTrue);
      expect(overview.overallRemaining, 2000);
      expect(overview.isOverallOver, isFalse);
      expect(overview.overallRatio, closeTo(0.8, 1e-9));

      // transport is over (2500/2000 = 1.25) so it sorts before food (0.75).
      expect(overview.categories.first.categoryId, 'transport');
      expect(overview.categories.first.isOver, isTrue);
      expect(overview.categories.last.categoryId, 'food');
      expect(overview.categories.last.isOver, isFalse);
    });

    test('flags an over-budget month', () {
      final overview = BudgetOverview.compute(
        budgets: const MonthlyBudgets(overall: 5000),
        spentByCategory: const {},
        totalSpent: 6200,
      );
      expect(overview.isOverallOver, isTrue);
      expect(overview.overallRemaining, -1200);
    });

    test('with no overall budget set, hasOverall is false', () {
      final overview = BudgetOverview.compute(
        budgets: MonthlyBudgets.empty,
        spentByCategory: const {'food': 100},
        totalSpent: 100,
      );
      expect(overview.hasOverall, isFalse);
      expect(overview.overallRatio, 0);
    });
  });

  group('FinancialHealth with a user budget', () {
    const profile = FinancialProfile(
      monthlyIncome: 50000,
      fixedExpenses: 20000,
      currentSavings: 120000,
      monthlyDebt: 0,
      savingsGoal: 10000,
    );

    // Day 1 of a 30-day month: only ~3% of the month has elapsed, so spending
    // 90% of the budget already should tank the budget-adherence component.
    final earlyMonth = DateTime(2026, 6, 1);

    test('a tight self-set budget lowers the score when overspending early', () {
      final withTightBudget = FinancialHealth.compute(
        profile: profile,
        spentThisMonth: 9000,
        userBudget: 10000,
        now: earlyMonth,
      );
      final withLooseBudget = FinancialHealth.compute(
        profile: profile,
        spentThisMonth: 9000,
        userBudget: 100000,
        now: earlyMonth,
      );
      expect(withTightBudget.budgetScore, lessThan(withLooseBudget.budgetScore));
      expect(withTightBudget.score, lessThan(withLooseBudget.score));
    });

    test('omitting userBudget matches passing null (backward compatible)', () {
      final withoutArg = FinancialHealth.compute(
        profile: profile,
        spentThisMonth: 5000,
        now: earlyMonth,
      );
      final withNull = FinancialHealth.compute(
        profile: profile,
        spentThisMonth: 5000,
        userBudget: null,
        now: earlyMonth,
      );
      expect(withoutArg.score, withNull.score);
      expect(withoutArg.monthlyBudget, withNull.monthlyBudget);
    });
  });
}
