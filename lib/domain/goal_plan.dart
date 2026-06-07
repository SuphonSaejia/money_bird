import 'dart:math' as math;

import '../data/models/financial_profile.dart';
import 'goal_type.dart';

/// A savings-goal plan derived from the user's profile. Works for any goal:
///
///  • **Retirement** — target is auto-computed with the 4% rule (25× annual
///    expenses) and the horizon comes from age → retirement age.
///  • **Other goals** (house, car, …) — the user sets the target amount and the
///    year they want it.
///
/// The required monthly contribution is solved from the future-value-of-annuity
/// formula assuming a modest real return.
class GoalPlan {
  const GoalPlan({
    required this.goalType,
    required this.goalName,
    required this.yearsToGoal,
    required this.targetAmount,
    required this.currentSavings,
    required this.plannedMonthly,
    required this.requiredMonthly,
    required this.projectedAmount,
    required this.progress,
    required this.projectedProgress,
    required this.onTrack,
  });

  final GoalType goalType;

  /// Custom label when [goalType] is custom (empty otherwise).
  final String goalName;
  final int yearsToGoal;

  /// Total amount needed to reach the goal.
  final double targetAmount;
  final double currentSavings;

  /// What the user currently plans to save each month (their savings goal).
  final double plannedMonthly;

  /// Monthly contribution needed to reach [targetAmount] in time.
  final double requiredMonthly;

  /// Projected amount at the goal date if they keep saving [plannedMonthly].
  final double projectedAmount;

  /// 0..1 — how much of the target is already saved.
  final double progress;

  /// 0..1 — projected coverage of the target at the planned saving rate.
  final double projectedProgress;

  /// Whether the projected amount meets the target.
  final bool onTrack;

  bool get isRetirement => goalType.isRetirement;
  bool get hasTarget => targetAmount > 0;

  factory GoalPlan.from(
    FinancialProfile profile, {
    required int nowYear,
    double annualReturn = 0.05,
  }) {
    final int years;
    final double target;
    if (profile.goalType.isRetirement) {
      years = math.max(0, profile.retirementAge - profile.age);
      target = profile.fixedExpenses * 12 * 25; // 4% rule
    } else {
      years = math.max(0, profile.goalTargetYear - nowYear);
      target = profile.goalTargetAmount;
    }

    final savings = profile.currentSavings;
    final planned = profile.savingsGoal;

    final i = annualReturn / 12;
    final n = years * 12;

    double fvCurrent;
    double annuityFactor; // future value of 1/month over n months
    if (n == 0) {
      fvCurrent = savings;
      annuityFactor = 0;
    } else {
      final growth = math.pow(1 + i, n).toDouble();
      fvCurrent = savings * growth;
      annuityFactor = (growth - 1) / i;
    }

    double required;
    if (target <= 0) {
      required = 0;
    } else if (n == 0) {
      required = math.max(0.0, target - savings);
    } else {
      final remaining = math.max(0.0, target - fvCurrent);
      required = remaining / annuityFactor;
    }

    final projected = n == 0 ? savings : fvCurrent + planned * annuityFactor;

    double clamp01(double v) {
      if (v.isNaN || v.isInfinite || v < 0) return 0;
      return v > 1 ? 1 : v;
    }

    double finite(double v, double fallback) =>
        (v.isNaN || v.isInfinite) ? fallback : v;

    return GoalPlan(
      goalType: profile.goalType,
      goalName: profile.goalName,
      yearsToGoal: years,
      targetAmount: target,
      currentSavings: savings,
      plannedMonthly: planned,
      requiredMonthly: finite(required, 0),
      projectedAmount: finite(projected, savings),
      progress: target <= 0 ? 0 : clamp01(savings / target),
      projectedProgress: target <= 0 ? 0 : clamp01(projected / target),
      onTrack: target > 0 && projected >= target,
    );
  }
}
