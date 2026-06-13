import '../data/db/database.dart';

/// The user's monthly budgets, split into the overall cap and optional
/// per-category caps. Budgets recur every month.
class MonthlyBudgets {
  const MonthlyBudgets({this.overall, this.perCategory = const {}});

  /// Total spendable per month, or null when the user hasn't set one.
  final double? overall;

  /// categoryId → monthly cap, for categories the user has budgeted.
  final Map<String, double> perCategory;

  static const empty = MonthlyBudgets();

  bool get isEmpty => overall == null && perCategory.isEmpty;

  /// Builds from raw [Budget] rows, splitting out the [overallBudgetId] row.
  factory MonthlyBudgets.fromRows(List<Budget> rows) {
    double? overall;
    final perCategory = <String, double>{};
    for (final row in rows) {
      if (row.categoryId == overallBudgetId) {
        overall = row.amount;
      } else {
        perCategory[row.categoryId] = row.amount;
      }
    }
    return MonthlyBudgets(overall: overall, perCategory: perCategory);
  }
}

/// One category's budget vs. what's been spent against it this month.
class CategoryBudgetStatus {
  const CategoryBudgetStatus({
    required this.categoryId,
    required this.limit,
    required this.spent,
  });

  final String categoryId;
  final double limit;
  final double spent;

  /// 0..1+ (can exceed 1 when over budget); 0 when there's no limit.
  double get ratio => limit <= 0 ? 0 : spent / limit;

  double get remaining => limit - spent;

  bool get isOver => limit > 0 && spent > limit;
}

/// The overall monthly budget vs. total spending, plus per-category breakdown.
class BudgetOverview {
  const BudgetOverview({
    required this.overallLimit,
    required this.overallSpent,
    required this.categories,
  });

  final double? overallLimit;
  final double overallSpent;
  final List<CategoryBudgetStatus> categories;

  bool get hasOverall => overallLimit != null && overallLimit! > 0;

  double get overallRatio =>
      hasOverall ? overallSpent / overallLimit! : 0;

  double get overallRemaining =>
      hasOverall ? overallLimit! - overallSpent : 0;

  bool get isOverallOver => hasOverall && overallSpent > overallLimit!;

  /// Builds the overview from budgets + this month's spend-by-category.
  factory BudgetOverview.compute({
    required MonthlyBudgets budgets,
    required Map<String, double> spentByCategory,
    required double totalSpent,
  }) {
    final categories = <CategoryBudgetStatus>[
      for (final entry in budgets.perCategory.entries)
        CategoryBudgetStatus(
          categoryId: entry.key,
          limit: entry.value,
          spent: spentByCategory[entry.key] ?? 0,
        ),
    ]..sort((a, b) => b.ratio.compareTo(a.ratio));

    return BudgetOverview(
      overallLimit: budgets.overall,
      overallSpent: totalSpent,
      categories: categories,
    );
  }
}
