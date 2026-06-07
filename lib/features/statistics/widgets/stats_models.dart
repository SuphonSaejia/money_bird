import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/app_date_utils.dart';
import '../../../l10n/app_localizations.dart';

/// The three time windows the statistics screen can aggregate over.
enum StatsRange {
  weekly,
  monthly,
  yearly;

  /// Half-open `[start, end)` window relative to [now].
  (DateTime, DateTime) bounds(DateTime now) {
    switch (this) {
      case StatsRange.weekly:
        final start = AppDateUtils.startOfWeek(now);
        return (start, start.add(const Duration(days: 7)));
      case StatsRange.monthly:
        return (
          AppDateUtils.startOfMonth(now),
          AppDateUtils.startOfNextMonth(now),
        );
      case StatsRange.yearly:
        return (
          AppDateUtils.startOfYear(now),
          DateTime(now.year + 1, 1, 1),
        );
    }
  }

  /// Number of trend buckets (points on the line chart).
  int bucketCount(DateTime now) {
    switch (this) {
      case StatsRange.weekly:
        return 7; // Mon..Sun
      case StatsRange.monthly:
        return AppDateUtils.daysInMonth(now);
      case StatsRange.yearly:
        return 12; // Jan..Dec
    }
  }

  /// Maps a transaction date to its trend bucket index, or -1 if out of range.
  int bucketIndex(DateTime date, DateTime now) {
    switch (this) {
      case StatsRange.weekly:
        return date.weekday - DateTime.monday; // 0..6
      case StatsRange.monthly:
        return date.day - 1; // 0..daysInMonth-1
      case StatsRange.yearly:
        return date.month - 1; // 0..11
    }
  }

  /// Denominator for the "average per day" tile.
  int dayCount(DateTime now) {
    switch (this) {
      case StatsRange.weekly:
        return 7;
      case StatsRange.monthly:
        return AppDateUtils.daysInMonth(now);
      case StatsRange.yearly:
        // Days elapsed so far this year keeps the average meaningful mid-year.
        final start = AppDateUtils.startOfYear(now);
        return now.difference(start).inDays + 1;
    }
  }

  /// X-axis labels aligned to bucket indices.
  List<String> bucketLabels(DateTime now, AppLocalizations l10n) {
    final locale = l10n.localeName;
    switch (this) {
      case StatsRange.weekly:
        final fmt = DateFormat.E(locale);
        final monday = AppDateUtils.startOfWeek(now);
        return List<String>.generate(
          7,
          (i) => fmt.format(monday.add(Duration(days: i))),
        );
      case StatsRange.monthly:
        final days = AppDateUtils.daysInMonth(now);
        return List<String>.generate(days, (i) => '${i + 1}');
      case StatsRange.yearly:
        final fmt = DateFormat.MMM(locale);
        return List<String>.generate(
          12,
          (i) => fmt.format(DateTime(now.year, i + 1, 1)),
        );
    }
  }
}

/// A single point on the spending trend line.
class TrendPoint {
  const TrendPoint(this.x, this.value);

  final double x;
  final double value;
}

/// One expense category's share of the total, for the donut + legend.
class CategorySlice {
  const CategorySlice({
    required this.categoryId,
    required this.amount,
    required this.color,
  });

  final String categoryId;
  final double amount;
  final Color color;
}
