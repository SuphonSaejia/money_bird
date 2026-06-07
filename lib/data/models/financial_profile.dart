import 'dart:convert';

import '../../domain/goal_type.dart';

/// The user's self-reported financial picture, captured during onboarding and
/// editable later. These are stable monthly figures used as the backbone of
/// the financial-health score; day-to-day transactions adjust the live parts.
class FinancialProfile {
  const FinancialProfile({
    this.monthlyIncome = 0,
    this.fixedExpenses = 0,
    this.currentSavings = 0,
    this.monthlyDebt = 0,
    this.savingsGoal = 0,
    this.age = 30,
    this.retirementAge = 60,
    this.goalType = GoalType.retirement,
    this.goalName = '',
    this.goalTargetAmount = 0,
    this.goalTargetYear = 0,
  });

  /// Take-home pay per month.
  final double monthlyIncome;

  /// Recurring fixed costs per month (rent, bills, subscriptions…).
  final double fixedExpenses;

  /// Total cash / easily-reachable savings on hand right now.
  final double currentSavings;

  /// Monthly payments toward debt (loans, cards, instalments).
  final double monthlyDebt;

  /// Target amount the user wants to save each month.
  final double savingsGoal;

  /// Current age, in years — used to plan retirement savings.
  final int age;

  /// Target age to retire at.
  final int retirementAge;

  /// What the user is saving toward.
  final GoalType goalType;

  /// Custom goal label (used when [goalType] is custom).
  final String goalName;

  /// Target amount for non-retirement goals (retirement is auto-computed).
  final double goalTargetAmount;

  /// Calendar year the user wants to reach the goal (non-retirement).
  final int goalTargetYear;

  static const empty = FinancialProfile();

  bool get isComplete => monthlyIncome > 0;

  FinancialProfile copyWith({
    double? monthlyIncome,
    double? fixedExpenses,
    double? currentSavings,
    double? monthlyDebt,
    double? savingsGoal,
    int? age,
    int? retirementAge,
    GoalType? goalType,
    String? goalName,
    double? goalTargetAmount,
    int? goalTargetYear,
  }) {
    return FinancialProfile(
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      fixedExpenses: fixedExpenses ?? this.fixedExpenses,
      currentSavings: currentSavings ?? this.currentSavings,
      monthlyDebt: monthlyDebt ?? this.monthlyDebt,
      savingsGoal: savingsGoal ?? this.savingsGoal,
      age: age ?? this.age,
      retirementAge: retirementAge ?? this.retirementAge,
      goalType: goalType ?? this.goalType,
      goalName: goalName ?? this.goalName,
      goalTargetAmount: goalTargetAmount ?? this.goalTargetAmount,
      goalTargetYear: goalTargetYear ?? this.goalTargetYear,
    );
  }

  Map<String, dynamic> toMap() => {
        'monthlyIncome': monthlyIncome,
        'fixedExpenses': fixedExpenses,
        'currentSavings': currentSavings,
        'monthlyDebt': monthlyDebt,
        'savingsGoal': savingsGoal,
        'age': age,
        'retirementAge': retirementAge,
        'goalType': goalType.name,
        'goalName': goalName,
        'goalTargetAmount': goalTargetAmount,
        'goalTargetYear': goalTargetYear,
      };

  factory FinancialProfile.fromMap(Map<String, dynamic> map) {
    double d(Object? v) => (v as num?)?.toDouble() ?? 0;
    int i(Object? v, int fallback) => (v as num?)?.toInt() ?? fallback;
    return FinancialProfile(
      monthlyIncome: d(map['monthlyIncome']),
      fixedExpenses: d(map['fixedExpenses']),
      currentSavings: d(map['currentSavings']),
      monthlyDebt: d(map['monthlyDebt']),
      savingsGoal: d(map['savingsGoal']),
      age: i(map['age'], 30),
      retirementAge: i(map['retirementAge'], 60),
      goalType: GoalType.fromName(map['goalType'] as String?),
      goalName: (map['goalName'] as String?) ?? '',
      goalTargetAmount: d(map['goalTargetAmount']),
      goalTargetYear: i(map['goalTargetYear'], 0),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory FinancialProfile.fromJson(String source) =>
      FinancialProfile.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
