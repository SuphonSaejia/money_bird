import 'dart:math' as math;

import '../core/utils/app_date_utils.dart';
import '../data/models/financial_profile.dart';

/// Qualitative band a score falls into.
enum HealthBand { needsWork, fair, good, excellent }

/// One component of the composite score, expressed as a 0..1 ring value plus a
/// human-readable headline figure. Used to drive the home diagram.
class HealthMetric {
  const HealthMetric({
    required this.key,
    required this.value,
    required this.detail,
  });

  /// Stable key the UI maps to an l10n label + ring colour.
  final HealthMetricKey key;

  /// 0..1 — how "full" this ring is.
  final double value;

  /// Pre-formatted percent/figure for the legend, e.g. "18%" or "4.2 mo".
  final String detail;
}

enum HealthMetricKey { savingsRate, budget, emergency, debt }

/// The composite financial-health snapshot shown across the app and shared.
///
/// Score weighting (sums to 1.0):
///   • Savings rate     0.35  — surplus vs income (target ≥ 20%)
///   • Emergency fund   0.30  — months of expenses saved (target ≥ 6)
///   • Budget adherence 0.20  — actual spend vs prorated monthly budget
///   • Debt ratio       0.15  — debt payments vs income (target ≤ 0%, cap 36%)
class FinancialHealth {
  const FinancialHealth({
    required this.score,
    required this.band,
    required this.savingsRate,
    required this.savingsScore,
    required this.emergencyScore,
    required this.monthsCovered,
    required this.budgetScore,
    required this.debtScore,
    required this.debtRatio,
    required this.monthlyBudget,
    required this.spentThisMonth,
    required this.monthlySurplus,
  });

  final int score; // 0..100
  final HealthBand band;

  final double savingsRate; // signed ratio for display (e.g. -0.05)
  final double savingsScore; // 0..1 ring
  final double emergencyScore; // 0..1 ring
  final double monthsCovered; // months of expenses in savings
  final double budgetScore; // 0..1 ring
  final double debtScore; // 0..1
  final double debtRatio; // 0..1+

  final double monthlyBudget; // intended spendable per month
  final double spentThisMonth; // logged expenses this month
  final double monthlySurplus; // income − fixed − debt

  /// Ordered metrics for the three home rings + the debt breakdown row.
  List<HealthMetric> get metrics => [
        HealthMetric(
          key: HealthMetricKey.savingsRate,
          value: savingsScore,
          detail: '${(savingsRate * 100).round()}%',
        ),
        HealthMetric(
          key: HealthMetricKey.budget,
          value: budgetScore,
          detail: '${(budgetScore * 100).round()}%',
        ),
        HealthMetric(
          key: HealthMetricKey.emergency,
          value: emergencyScore,
          detail: '${monthsCovered.toStringAsFixed(1)} mo',
        ),
        HealthMetric(
          key: HealthMetricKey.debt,
          value: debtScore,
          detail: '${(debtRatio * 100).round()}%',
        ),
      ];

  /// The three rings rendered on the home diagram (outer → inner).
  List<HealthMetric> get rings =>
      metrics.where((m) => m.key != HealthMetricKey.debt).toList();

  static double _clamp01(double v) => v.clamp(0.0, 1.0);

  static HealthBand bandFor(int score) {
    if (score >= 80) return HealthBand.excellent;
    if (score >= 60) return HealthBand.good;
    if (score >= 40) return HealthBand.fair;
    return HealthBand.needsWork;
  }

  /// Computes the snapshot from the stable [profile] plus live month figures.
  ///
  /// When the user has set their own monthly [userBudget] it drives the
  /// budget-adherence component; otherwise it falls back to the implied
  /// `income − goal − debt` figure so existing users score unchanged.
  factory FinancialHealth.compute({
    required FinancialProfile profile,
    required double spentThisMonth,
    double? userBudget,
    DateTime? now,
  }) {
    final today = now ?? _fallbackNow();
    final income = profile.monthlyIncome;
    final fixed = profile.fixedExpenses;
    final debt = profile.monthlyDebt;
    final goal = profile.savingsGoal;
    final savings = profile.currentSavings;

    // Without an income there is no financial picture to score yet.
    if (income <= 0) {
      return FinancialHealth(
        score: 0,
        band: HealthBand.needsWork,
        savingsRate: 0,
        savingsScore: 0,
        emergencyScore: 0,
        monthsCovered: 0,
        budgetScore: 0,
        debtScore: 0,
        debtRatio: 0,
        monthlyBudget: 0,
        spentThisMonth: spentThisMonth,
        monthlySurplus: 0,
      );
    }

    // --- Savings rate (0.35) ---
    final surplus = income - fixed - debt;
    final savingsRate = income > 0 ? surplus / income : 0.0;
    final savingsScore = _clamp01(savingsRate / 0.20); // 20% surplus = full

    // --- Emergency fund (0.30) ---
    final committed = fixed + debt;
    final monthsCovered = committed > 0
        ? savings / committed
        : (savings > 0 ? 6.0 : 0.0);
    final emergencyScore = _clamp01(monthsCovered / 6.0); // 6 months = full

    // --- Debt ratio (0.15) ---
    final debtRatio = income > 0 ? debt / income : (debt > 0 ? 1.0 : 0.0);
    final debtScore = _clamp01(1 - debtRatio / 0.36); // 36% DTI = zero

    // --- Budget adherence (0.20) ---
    double monthlyBudget;
    if (userBudget != null && userBudget > 0) {
      monthlyBudget = userBudget;
    } else {
      monthlyBudget = income - goal - debt;
      if (monthlyBudget <= 0) monthlyBudget = fixed > 0 ? fixed : income;
    }
    double budgetScore;
    if (monthlyBudget <= 0) {
      budgetScore = 1.0;
    } else {
      final utilization = spentThisMonth / monthlyBudget;
      final expected = AppDateUtils.monthProgress(today);
      if (utilization <= expected) {
        budgetScore = 1.0;
      } else {
        budgetScore =
            _clamp01(1 - (utilization - expected) / math.max(1 - expected, 0.0001));
      }
    }

    final raw = 0.35 * savingsScore +
        0.30 * emergencyScore +
        0.20 * budgetScore +
        0.15 * debtScore;
    final score = (raw * 100).round().clamp(0, 100);

    return FinancialHealth(
      score: score,
      band: bandFor(score),
      savingsRate: savingsRate,
      savingsScore: savingsScore,
      emergencyScore: emergencyScore,
      monthsCovered: monthsCovered,
      budgetScore: budgetScore,
      debtScore: debtScore,
      debtRatio: debtRatio,
      monthlyBudget: monthlyBudget,
      spentThisMonth: spentThisMonth,
      monthlySurplus: surplus,
    );
  }

  static DateTime _fallbackNow() => DateTime.now();
}
