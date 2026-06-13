import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/goal_card.dart';
import '../../core/widgets/soft_icon_button.dart';
import '../../core/widgets/stat_tile.dart';
import '../../domain/month_summary.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../budget/budget_screen.dart';
import '../share/share_preview_screen.dart';
import '../transactions/transactions_screen.dart';
import 'widgets/health_card.dart';
import 'widgets/recent_activity.dart';

/// The hero screen: a greeting top bar, the financial-health ring card, the
/// monthly overview tiles and the recent-activity list.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final health = ref.watch(financialHealthProvider);
    final summary = ref.watch(monthSummaryProvider);

    return GradientScaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            110,
          ),
          children: [
            _TopBar(locale: locale),
            const SizedBox(height: AppSpacing.xl),
            HealthCard(health: health),
            const SizedBox(height: AppSpacing.xxl),
            SectionHeader(title: l10n.homeOverview),
            const SizedBox(height: AppSpacing.lg),
            _Overview(summary: summary, locale: locale),
            const _BudgetGlance(),
            const SizedBox(height: AppSpacing.xxl),
            GoalCard(plan: ref.watch(goalPlanProvider)),
            const SizedBox(height: AppSpacing.xxl),
            SectionHeader(
              title: l10n.homeRecent,
              actionLabel: l10n.commonSeeAll,
              onAction: () => openTransactionsScreen(context),
            ),
            const SizedBox(height: AppSpacing.lg),
            const RecentActivity(),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? l10n.homeGreetingMorning
        : hour < 18
            ? l10n.homeGreetingAfternoon
            : l10n.homeGreetingEvening;
    final dateLabel = DateFormat.MMMMEEEEd(locale).format(now);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                dateLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        SoftIconButton(
          icon: Icons.ios_share_rounded,
          onPressed: () => openSharePreview(context),
        ),
        const SizedBox(width: AppSpacing.md),
        const SoftIconButton(
          icon: Icons.notifications_none_rounded,
          showDot: true,
        ),
      ],
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({required this.summary, required this.locale});

  final MonthSummary summary;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final tiles = <Widget>[
      StatTile(
        icon: Icons.account_balance_wallet_rounded,
        value: CurrencyFormatter.format(summary.spentToday, locale: locale),
        label: l10n.homeSpentToday,
        tint: AppColors.expense,
      ),
      StatTile(
        icon: Icons.trending_down_rounded,
        value: CurrencyFormatter.format(summary.expense, locale: locale),
        label: l10n.homeMonthFlow,
        tint: AppColors.ringCoral,
      ),
      StatTile(
        icon: Icons.savings_rounded,
        value: CurrencyFormatter.format(summary.net, locale: locale),
        label: l10n.homeSaved,
        tint: AppColors.income,
      ),
      StatTile(
        icon: Icons.local_fire_department_rounded,
        value: '${summary.streak}',
        label: l10n.homeStreak,
        tint: AppColors.ringAmber,
      ),
    ];

    // IntrinsicHeight bounds each row's height to its tallest tile, so the
    // stretch makes both tiles equal-height without forcing infinite height
    // inside the scroll view.
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: tiles[0]),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: tiles[1]),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: tiles[2]),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: tiles[3]),
            ],
          ),
        ),
      ],
    );
  }
}

/// A compact month-budget progress card shown on the home screen, but only once
/// the user has set an overall monthly budget. Tapping opens the budget screen.
class _BudgetGlance extends ConsumerWidget {
  const _BudgetGlance();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final overview = ref.watch(budgetOverviewProvider);

    if (!overview.hasOverall) return const SizedBox.shrink();

    final over = overview.isOverallOver;
    final fill = over ? AppColors.danger : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: l10n.homeBudget,
            actionLabel: l10n.commonSeeAll,
            onAction: () => openBudgetScreen(context),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            onTap: () => openBudgetScreen(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        CurrencyFormatter.format(overview.overallSpent,
                            locale: locale),
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    Text(
                      '/ ${CurrencyFormatter.format(overview.overallLimit!, locale: locale)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: overview.overallRatio.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: AppColors.ringTrack,
                    valueColor: AlwaysStoppedAnimation<Color>(fill),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  over
                      ? l10n.budgetOver(CurrencyFormatter.format(
                          -overview.overallRemaining,
                          locale: locale))
                      : l10n.budgetLeft(CurrencyFormatter.format(
                          overview.overallRemaining,
                          locale: locale)),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: over ? AppColors.danger : AppColors.income,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
