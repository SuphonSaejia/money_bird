import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/categories.dart';
import '../../../l10n/app_localizations.dart';
import 'stats_models.dart';

/// A donut of expense-per-category beside a legend (dot + name + amount + %).
class CategoryBreakdown extends StatelessWidget {
  const CategoryBreakdown({
    super.key,
    required this.slices,
    required this.total,
    required this.locale,
  });

  final List<CategorySlice> slices;
  final double total;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final safeTotal = total <= 0 ? 1.0 : total;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 132,
          height: 132,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              startDegreeOffset: -90,
              sections: [
                for (final s in slices)
                  PieChartSectionData(
                    value: s.amount,
                    color: s.color,
                    radius: 22,
                    showTitle: false,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xl),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final s in slices.take(5))
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _LegendRow(
                    color: s.color,
                    label: Categories.byId(s.categoryId).label(l10n),
                    amount: CurrencyFormatter.format(s.amount, locale: locale),
                    percent: s.amount / safeTotal,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.amount,
    required this.percent,
  });

  final Color color;
  final String label;
  final String amount;
  final double percent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentText = '${(percent * 100).round()}%';

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.titleMedium?.color,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          amount,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.textTheme.titleMedium?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 38,
          child: Text(
            percentText,
            textAlign: TextAlign.right,
            style: theme.textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}
