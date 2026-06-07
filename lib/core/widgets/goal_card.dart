import 'package:flutter/material.dart';

import '../../domain/goal_plan.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/currency_formatter.dart';
import '../utils/goal_display.dart';
import 'app_card.dart';

/// A card that shows the user's active savings goal: progress toward the
/// target, time remaining and how much to save each month to get there. Works
/// for any goal type (retirement, house, car, …). Used on Home and Profile.
class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.plan, this.onTap});

  final GoalPlan plan;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final accent = plan.onTrack ? AppColors.income : AppColors.primary;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(plan.goalType.icon, size: 20, color: accent),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  l10n.goalSavingFor(plan.title(l10n)),
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (plan.hasTarget)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    plan.isRetirement
                        ? l10n.retirementYearsToGo(plan.yearsToGoal)
                        : l10n.goalYearsToGo(plan.yearsToGoal),
                    style: theme.textTheme.labelSmall,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (!plan.hasTarget)
            Text(
              plan.isRetirement ? l10n.retirementSetupHint : l10n.goalSetupHint,
              style: theme.textTheme.bodyMedium,
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: plan.progress,
                minHeight: 10,
                backgroundColor: AppColors.ringTrack,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${l10n.retirementSaved} ${CurrencyFormatter.compact(plan.currentSavings, locale: locale)}',
                    style: theme.textTheme.labelMedium,
                  ),
                ),
                Text(
                  '${l10n.retirementTarget} ${CurrencyFormatter.compact(plan.targetAmount, locale: locale)}',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.onSurface),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  plan.onTrack
                      ? Icons.check_circle_rounded
                      : Icons.trending_up_rounded,
                  size: 18,
                  color: accent,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    plan.onTrack
                        ? l10n.retirementKeepSaving(
                            CurrencyFormatter.format(plan.plannedMonthly, locale: locale))
                        : l10n.retirementNeedMonthly(
                            CurrencyFormatter.format(plan.requiredMonthly, locale: locale)),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurface),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
