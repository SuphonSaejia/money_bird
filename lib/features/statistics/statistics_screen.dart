import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/app_date_utils.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/segmented_tabs.dart';
import '../../core/widgets/stat_tile.dart';
import '../../data/db/database.dart';
import '../../domain/categories.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import 'widgets/category_breakdown.dart';
import 'widgets/income_expense_bars.dart';
import 'widgets/spending_trend_chart.dart';
import 'widgets/stats_models.dart';

/// The Statistics tab: a calm, chart-led overview of where the money went.
///
/// The user picks a range (Weekly / Monthly / Yearly) and the screen aggregates
/// the transaction stream into overview tiles, a gradient spending-trend line,
/// a donut category breakdown and an income-vs-expense comparison.
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  int _rangeIndex = 1; // default to Monthly

  StatsRange get _range => StatsRange.values[_rangeIndex];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final transactionsAsync = ref.watch(allTransactionsProvider);
    final now = DateTime.now();

    return GradientScaffold(
      body: SafeArea(
        bottom: false,
        child: transactionsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 120),
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          ),
          error: (_, __) => Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 120),
              child: Text(
                l10n.statsNoData,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
          data: (transactions) {
            final aggregate = StatsAggregate.build(
              transactions: transactions,
              range: _range,
              now: now,
              l10n: l10n,
            );
            return _StatsBody(
              aggregate: aggregate,
              range: _range,
              rangeIndex: _rangeIndex,
              now: now,
              locale: locale,
              onRangeChanged: (i) => setState(() => _rangeIndex = i),
            );
          },
        ),
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({
    required this.aggregate,
    required this.range,
    required this.rangeIndex,
    required this.now,
    required this.locale,
    required this.onRangeChanged,
  });

  final StatsAggregate aggregate;
  final StatsRange range;
  final int rangeIndex;
  final DateTime now;
  final String locale;
  final ValueChanged<int> onRangeChanged;

  String _periodLabel(AppLocalizations l10n) {
    switch (range) {
      case StatsRange.weekly:
        final start = AppDateUtils.startOfWeek(now);
        final fmt = DateFormat.MMMd(locale);
        return '${fmt.format(start)} – ${fmt.format(now)}';
      case StatsRange.monthly:
        return DateFormat.yMMMM(locale).format(now);
      case StatsRange.yearly:
        return DateFormat.y(locale).format(now);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final topCategoryLabel = aggregate.topCategoryId == null
        ? '—'
        : Categories.byId(aggregate.topCategoryId!).label(l10n);
    final topCategoryTint = aggregate.topCategoryId == null
        ? AppColors.textSecondary
        : Categories.byId(aggregate.topCategoryId!).color;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.lg,
        AppSpacing.page,
        110,
      ),
      children: [
        // ── Header ───────────────────────────────────────────────────────
        Text(l10n.statsTitle, style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(_periodLabel(l10n), style: theme.textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xl),

        // ── Range selector ───────────────────────────────────────────────
        SegmentedTabs(
          labels: [
            l10n.statsRangeWeek,
            l10n.statsRangeMonth,
            l10n.statsRangeYear,
          ],
          selectedIndex: rangeIndex,
          onChanged: onRangeChanged,
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── Overview tiles ───────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: StatTile(
                icon: Icons.south_west_rounded,
                value: CurrencyFormatter.format(
                  aggregate.totalExpense,
                  locale: locale,
                ),
                label: l10n.statsTotalSpent,
                tint: AppColors.expense,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatTile(
                icon: Icons.north_east_rounded,
                value: CurrencyFormatter.format(
                  aggregate.totalIncome,
                  locale: locale,
                ),
                label: l10n.statsTotalIncome,
                tint: AppColors.income,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: StatTile(
                icon: Icons.calendar_today_rounded,
                value: CurrencyFormatter.format(
                  aggregate.avgPerDay,
                  locale: locale,
                ),
                label: l10n.statsAvgPerDay,
                tint: AppColors.ringBlue,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatTile(
                icon: Icons.pie_chart_rounded,
                value: topCategoryLabel,
                label: l10n.statsTopCategory,
                tint: topCategoryTint,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── Spending trend ───────────────────────────────────────────────
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: l10n.statsTrend),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 200,
                child: aggregate.hasTrendData
                    ? SpendingTrendChart(
                        spots: aggregate.trend,
                        labels: aggregate.trendLabels,
                        locale: locale,
                      )
                    : _EmptyChart(message: l10n.statsNoData),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Category breakdown ───────────────────────────────────────────
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: l10n.statsSpendingByCategory),
              const SizedBox(height: AppSpacing.lg),
              if (aggregate.categories.isEmpty)
                _EmptyChart(message: l10n.statsNoData)
              else
                CategoryBreakdown(
                  slices: aggregate.categories,
                  total: aggregate.totalExpense,
                  locale: locale,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Income vs expense ────────────────────────────────────────────
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: l10n.statsIncomeVsExpense),
              const SizedBox(height: AppSpacing.lg),
              if (aggregate.totalIncome == 0 && aggregate.totalExpense == 0)
                _EmptyChart(message: l10n.statsNoData)
              else
                IncomeExpenseBars(
                  income: aggregate.totalIncome,
                  expense: aggregate.totalExpense,
                  locale: locale,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A calm placeholder shown inside chart cards when there isn't enough data.
class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 140,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insights_rounded,
              size: 36,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Aggregation result for the selected range. Lives here (rather than in the
/// stateful widget) so the chart widgets stay dumb and reusable.
class StatsAggregate {
  const StatsAggregate({
    required this.totalIncome,
    required this.totalExpense,
    required this.avgPerDay,
    required this.topCategoryId,
    required this.trend,
    required this.trendLabels,
    required this.categories,
  });

  final double totalIncome;
  final double totalExpense;
  final double avgPerDay;
  final String? topCategoryId;

  /// Trend buckets as (x, y) spending points.
  final List<TrendPoint> trend;

  /// X-axis labels aligned to [trend] indices.
  final List<String> trendLabels;

  /// Expense slices, sorted descending by amount.
  final List<CategorySlice> categories;

  bool get hasTrendData => trend.any((p) => p.value > 0);

  static StatsAggregate build({
    required List<Transaction> transactions,
    required StatsRange range,
    required DateTime now,
    required AppLocalizations l10n,
  }) {
    final (start, end) = range.bounds(now);

    final inRange = transactions.where((t) {
      return !t.date.isBefore(start) && t.date.isBefore(end);
    }).toList();

    double totalIncome = 0;
    double totalExpense = 0;
    final byCategory = <String, double>{};

    // Trend buckets sized to the range.
    final bucketCount = range.bucketCount(now);
    final buckets = List<double>.filled(bucketCount, 0);

    for (final t in inRange) {
      if (t.type.isIncome) {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
        byCategory.update(
          t.categoryId,
          (v) => v + t.amount,
          ifAbsent: () => t.amount,
        );
        final bucket = range.bucketIndex(t.date, now);
        if (bucket >= 0 && bucket < bucketCount) {
          buckets[bucket] += t.amount;
        }
      }
    }

    final dayCount = range.dayCount(now);
    final avgPerDay = dayCount > 0 ? totalExpense / dayCount : 0.0;

    String? topCategoryId;
    double topAmount = 0;
    byCategory.forEach((id, amount) {
      if (amount > topAmount) {
        topAmount = amount;
        topCategoryId = id;
      }
    });

    final categories = byCategory.entries
        .map((e) => CategorySlice(
              categoryId: e.key,
              amount: e.value,
              color: Categories.byId(e.key).color,
            ))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final trend = List<TrendPoint>.generate(
      bucketCount,
      (i) => TrendPoint(i.toDouble(), buckets[i]),
    );

    return StatsAggregate(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      avgPerDay: avgPerDay,
      topCategoryId: topCategoryId,
      trend: trend,
      trendLabels: range.bucketLabels(now, l10n),
      categories: categories,
    );
  }
}
