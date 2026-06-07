import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';

/// Two rounded, proportional bars comparing total income against total expense
/// for the selected range. Calmer than a full bar chart and easy to read.
class IncomeExpenseBars extends StatelessWidget {
  const IncomeExpenseBars({
    super.key,
    required this.income,
    required this.expense,
    required this.locale,
  });

  final double income;
  final double expense;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final maxValue = (income > expense ? income : expense);
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;

    return Column(
      children: [
        _Bar(
          label: l10n.homeIncome,
          value: income,
          fraction: income / safeMax,
          color: AppColors.income,
          locale: locale,
        ),
        const SizedBox(height: AppSpacing.lg),
        _Bar(
          label: l10n.homeExpense,
          value: expense,
          fraction: expense / safeMax,
          color: AppColors.expense,
          locale: locale,
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.label,
    required this.value,
    required this.fraction,
    required this.color,
    required this.locale,
  });

  final String label;
  final double value;
  final double fraction;
  final Color color;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
            ),
            Text(
              CurrencyFormatter.format(value, locale: locale),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.textTheme.titleMedium?.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            final width =
                (constraints.maxWidth * fraction.clamp(0.0, 1.0)).clamp(
              value > 0 ? 6.0 : 0.0,
              constraints.maxWidth,
            );
            return Stack(
              children: [
                Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.ringTrack,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOut,
                  height: 14,
                  width: width,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
