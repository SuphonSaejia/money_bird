import 'package:flutter/material.dart';

import '../../domain/financial_health.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// Presentation mapping for the health domain → localized labels + ring colours.
/// Keeps every screen (home, onboarding result, share card) perfectly in sync.
extension HealthBandDisplay on HealthBand {
  String label(AppLocalizations l) {
    switch (this) {
      case HealthBand.excellent:
        return l.healthExcellent;
      case HealthBand.good:
        return l.healthGood;
      case HealthBand.fair:
        return l.healthFair;
      case HealthBand.needsWork:
        return l.healthNeedsWork;
    }
  }

  String tip(AppLocalizations l) {
    switch (this) {
      case HealthBand.excellent:
        return l.healthExcellentTip;
      case HealthBand.good:
        return l.healthGoodTip;
      case HealthBand.fair:
        return l.healthFairTip;
      case HealthBand.needsWork:
        return l.healthNeedsWorkTip;
    }
  }

  Color get color {
    switch (this) {
      case HealthBand.excellent:
        return AppColors.income;
      case HealthBand.good:
        return AppColors.primary;
      case HealthBand.fair:
        return AppColors.warning;
      case HealthBand.needsWork:
        return AppColors.expense;
    }
  }
}

extension HealthMetricDisplay on HealthMetricKey {
  String label(AppLocalizations l) {
    switch (this) {
      case HealthMetricKey.savingsRate:
        return l.metricSavingsRate;
      case HealthMetricKey.budget:
        return l.metricBudget;
      case HealthMetricKey.emergency:
        return l.metricEmergency;
      case HealthMetricKey.debt:
        return l.metricDebtRatio;
    }
  }

  Color get color {
    switch (this) {
      case HealthMetricKey.savingsRate:
        return AppColors.ringBlue;
      case HealthMetricKey.budget:
        return AppColors.ringCoral;
      case HealthMetricKey.emergency:
        return AppColors.ringAmber;
      case HealthMetricKey.debt:
        return AppColors.textSecondary;
    }
  }
}
