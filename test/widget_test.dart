// Domain tests for the financial-health scoring model.
//
// These are pure-Dart unit tests (no Flutter binding / database), so they run
// fast and deterministically.

import 'package:flutter_test/flutter_test.dart';
import 'package:money_bird/data/models/financial_profile.dart';
import 'package:money_bird/domain/financial_health.dart';
import 'package:money_bird/domain/goal_plan.dart';
import 'package:money_bird/domain/goal_type.dart';

void main() {
  group('FinancialHealth.compute', () {
    test('an empty profile scores zero and needs work', () {
      final health = FinancialHealth.compute(
        profile: FinancialProfile.empty,
        spentThisMonth: 0,
      );
      expect(health.score, 0);
      expect(health.band, HealthBand.needsWork);
      expect(health.rings, hasLength(3));
    });

    test('a healthy profile scores well', () {
      const profile = FinancialProfile(
        monthlyIncome: 50000,
        fixedExpenses: 20000,
        currentSavings: 300000, // ~15 months of expenses
        monthlyDebt: 0,
        savingsGoal: 10000,
      );
      final health = FinancialHealth.compute(
        profile: profile,
        spentThisMonth: 5000,
        now: DateTime(2026, 6, 15),
      );
      expect(health.score, greaterThanOrEqualTo(80));
      expect(health.band, HealthBand.excellent);
      expect(health.savingsRate, greaterThan(0));
    });

    test('high debt and overspending drags the score down', () {
      const profile = FinancialProfile(
        monthlyIncome: 30000,
        fixedExpenses: 25000,
        currentSavings: 2000,
        monthlyDebt: 9000,
        savingsGoal: 5000,
      );
      final health = FinancialHealth.compute(
        profile: profile,
        spentThisMonth: 28000,
        now: DateTime(2026, 6, 10),
      );
      expect(health.score, lessThan(40));
      expect(health.band, HealthBand.needsWork);
      expect(health.debtRatio, greaterThan(0.2));
    });

    test('scores are always clamped to 0..100', () {
      const profile = FinancialProfile(
        monthlyIncome: 1000000,
        fixedExpenses: 0,
        currentSavings: 100000000,
        monthlyDebt: 0,
        savingsGoal: 0,
      );
      final health = FinancialHealth.compute(
        profile: profile,
        spentThisMonth: 0,
      );
      expect(health.score, inInclusiveRange(0, 100));
      expect(health.savingsScore, inInclusiveRange(0.0, 1.0));
    });
  });

  group('GoalPlan.from (retirement)', () {
    test('no expenses means no retirement target', () {
      final plan = GoalPlan.from(
        const FinancialProfile(monthlyIncome: 50000),
        nowYear: 2026,
      );
      expect(plan.isRetirement, isTrue);
      expect(plan.hasTarget, isFalse);
      expect(plan.targetAmount, 0);
    });

    test('target follows the 4% rule (25x annual expenses)', () {
      final plan = GoalPlan.from(
        const FinancialProfile(
          monthlyIncome: 50000,
          fixedExpenses: 20000,
          age: 30,
          retirementAge: 60,
        ),
        nowYear: 2026,
      );
      expect(plan.targetAmount, closeTo(20000 * 12 * 25, 0.001)); // 6,000,000
      expect(plan.yearsToGoal, 30);
      expect(plan.requiredMonthly, greaterThan(0));
      expect(plan.onTrack, isFalse);
    });

    test('saving enough each month puts you on track', () {
      final plan = GoalPlan.from(
        const FinancialProfile(
          monthlyIncome: 80000,
          fixedExpenses: 20000,
          age: 30,
          retirementAge: 60,
          savingsGoal: 50000,
        ),
        nowYear: 2026,
      );
      expect(plan.onTrack, isTrue);
      expect(plan.projectedAmount, greaterThanOrEqualTo(plan.targetAmount));
    });

    test('at/after retirement age needs the shortfall now', () {
      final plan = GoalPlan.from(
        const FinancialProfile(
          fixedExpenses: 10000,
          age: 65,
          retirementAge: 60,
          currentSavings: 1000000,
        ),
        nowYear: 2026,
      );
      expect(plan.yearsToGoal, 0);
      // target 3,000,000 − 1,000,000 saved = 2,000,000 shortfall.
      expect(plan.requiredMonthly, closeTo(2000000, 0.001));
    });

    test('all derived values stay finite and progress is 0..1', () {
      final plan = GoalPlan.from(
        const FinancialProfile(
          monthlyIncome: 1,
          fixedExpenses: 1,
          age: 60,
          retirementAge: 60,
        ),
        nowYear: 2026,
      );
      expect(plan.requiredMonthly.isFinite, isTrue);
      expect(plan.projectedAmount.isFinite, isTrue);
      expect(plan.progress, inInclusiveRange(0.0, 1.0));
      expect(plan.projectedProgress, inInclusiveRange(0.0, 1.0));
    });
  });

  group('GoalPlan.from (custom goal: buy a house)', () {
    test('uses the user-set target amount and target year', () {
      final plan = GoalPlan.from(
        const FinancialProfile(
          monthlyIncome: 60000,
          goalType: GoalType.house,
          goalTargetAmount: 1200000,
          goalTargetYear: 2036,
          currentSavings: 200000,
        ),
        nowYear: 2026,
      );
      expect(plan.isRetirement, isFalse);
      expect(plan.targetAmount, 1200000);
      expect(plan.yearsToGoal, 10); // 2036 − 2026
      expect(plan.hasTarget, isTrue);
      expect(plan.requiredMonthly, greaterThan(0));
      expect(plan.progress, closeTo(200000 / 1200000, 0.0001));
    });

    test('no target amount means setup is incomplete', () {
      final plan = GoalPlan.from(
        const FinancialProfile(goalType: GoalType.car, goalTargetYear: 2030),
        nowYear: 2026,
      );
      expect(plan.hasTarget, isFalse);
    });
  });
}
