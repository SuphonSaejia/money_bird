import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import 'stats_models.dart';

/// A single smooth, gradient-filled line that traces spending across the
/// selected range's buckets. Grid is reduced to faint horizontal guides to keep
/// the airy reference aesthetic.
class SpendingTrendChart extends StatelessWidget {
  const SpendingTrendChart({
    super.key,
    required this.spots,
    required this.labels,
    required this.locale,
  });

  final List<TrendPoint> spots;
  final List<String> labels;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final axisStyle = theme.textTheme.labelSmall;

    final maxY = spots.fold<double>(0, (m, p) => p.value > m ? p.value : m);
    // Round the top up to a friendly value and guarantee headroom.
    final niceMax = _niceCeil(maxY);
    final horizontalInterval = niceMax / 4;

    // Show roughly 5–7 x labels regardless of bucket count to avoid clutter.
    final labelStep = (labels.length / 6).ceil().clamp(1, labels.length);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        minY: 0,
        maxY: niceMax,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: horizontalInterval,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: horizontalInterval,
              getTitlesWidget: (value, meta) {
                if (value > niceMax) return const SizedBox.shrink();
                return SideTitleWidget(
                  meta: meta,
                  space: 6,
                  child: Text(
                    CurrencyFormatter.compact(value, locale: locale),
                    style: axisStyle,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final i = value.round();
                if (i < 0 || i >= labels.length) {
                  return const SizedBox.shrink();
                }
                if (i % labelStep != 0 && i != labels.length - 1) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  space: 8,
                  child: Text(labels[i], style: axisStyle),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.navActive,
            tooltipBorderRadius: BorderRadius.circular(10),
            getTooltipItems: (touched) => touched
                .map(
                  (s) => LineTooltipItem(
                    CurrencyFormatter.format(s.y, locale: locale),
                    theme.textTheme.labelSmall!.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (final p in spots) FlSpot(p.x, p.value),
            ],
            isCurved: true,
            curveSmoothness: 0.32,
            preventCurveOverShooting: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.22),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Rounds [value] up to a tidy axis maximum, never returning 0.
  double _niceCeil(double value) {
    if (value <= 0) return 100;
    final magnitude = _pow10((value).floor().toString().length - 1);
    final step = magnitude / 2;
    return (value / step).ceil() * step;
  }

  double _pow10(int exp) {
    var result = 1.0;
    for (var i = 0; i < exp; i++) {
      result *= 10;
    }
    return result;
  }
}
