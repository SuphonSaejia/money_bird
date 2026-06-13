import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/input_formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/category_icon.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/soft_icon_button.dart';
import '../../domain/budget.dart';
import '../../domain/categories.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';

/// Opens the budget screen.
Future<void> openBudgetScreen(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const BudgetScreen()),
  );
}

/// Lets the user set an overall monthly budget plus optional per-category caps,
/// and shows this month's spending against each.
class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final overview = ref.watch(budgetOverviewProvider);

    return GradientScaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.page, AppSpacing.md, AppSpacing.page, 40),
          children: [
            Row(
              children: [
                SoftIconButton(
                  icon: Icons.arrow_back_rounded,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(l10n.budgetTitle, style: theme.textTheme.headlineMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _OverallCard(overview: overview),
            const SizedBox(height: AppSpacing.xxl),
            SectionHeader(
              title: l10n.budgetByCategory,
              actionLabel: l10n.budgetAddCategory,
              onAction: () => _addCategoryBudget(context, ref, overview),
            ),
            const SizedBox(height: AppSpacing.lg),
            _CategoryBudgetList(overview: overview),
          ],
        ),
      ),
    );
  }

  Future<void> _addCategoryBudget(
    BuildContext context,
    WidgetRef ref,
    BudgetOverview overview,
  ) async {
    final budgeted = overview.categories.map((c) => c.categoryId).toSet();
    final available =
        Categories.expense.where((c) => !budgeted.contains(c.id)).toList();
    final categoryId = await _pickExpenseCategory(context, available);
    if (categoryId == null || !context.mounted) return;
    final amount = await showBudgetAmountSheet(
      context,
      title: Categories.byId(categoryId).label(AppLocalizations.of(context)),
      initial: 0,
    );
    if (amount == null) return;
    await ref.read(budgetRepositoryProvider).setCategory(categoryId, amount);
  }
}

/// ── Overall budget ────────────────────────────────────────────────────────────
class _OverallCard extends ConsumerWidget {
  const _OverallCard({required this.overview});

  final BudgetOverview overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    Future<void> edit() async {
      final amount = await showBudgetAmountSheet(
        context,
        title: l10n.budgetOverall,
        initial: overview.overallLimit ?? 0,
      );
      if (amount == null) return;
      await ref.read(budgetRepositoryProvider).setOverall(amount);
    }

    if (!overview.hasOverall) {
      return AppCard(
        onTap: edit,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.budgetEmptyTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(l10n.budgetEmptyBody, style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: edit,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(l10n.budgetSetCta),
            ),
          ],
        ),
      );
    }

    return AppCard(
      onTap: edit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.budgetOverall, style: theme.textTheme.titleMedium),
              ),
              Icon(Icons.edit_rounded,
                  size: 18, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                CurrencyFormatter.format(overview.overallSpent, locale: locale),
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(width: 6),
              Text(
                '/ ${CurrencyFormatter.format(overview.overallLimit!, locale: locale)}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _BudgetBar(ratio: overview.overallRatio, over: overview.isOverallOver),
          const SizedBox(height: AppSpacing.sm),
          Text(
            overview.isOverallOver
                ? l10n.budgetOver(CurrencyFormatter.format(
                    -overview.overallRemaining,
                    locale: locale))
                : l10n.budgetLeft(CurrencyFormatter.format(
                    overview.overallRemaining,
                    locale: locale)),
            style: theme.textTheme.labelMedium?.copyWith(
              color: overview.isOverallOver ? AppColors.danger : AppColors.income,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// ── Per-category budgets ───────────────────────────────────────────────────────
class _CategoryBudgetList extends ConsumerWidget {
  const _CategoryBudgetList({required this.overview});

  final BudgetOverview overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (overview.categories.isEmpty) {
      return AppCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Text(l10n.budgetNoCategoryBudgets,
                style: theme.textTheme.bodyMedium),
          ),
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
      child: Column(
        children: [
          for (var i = 0; i < overview.categories.length; i++) ...[
            _BudgetRow(status: overview.categories[i]),
            if (i != overview.categories.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.border.withValues(alpha: 0.7),
              ),
          ],
        ],
      ),
    );
  }
}

class _BudgetRow extends ConsumerWidget {
  const _BudgetRow({required this.status});

  final CategoryBudgetStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final category = Categories.byId(status.categoryId);

    Future<void> edit() async {
      final amount = await showBudgetAmountSheet(
        context,
        title: category.label(l10n),
        initial: status.limit,
        allowRemove: true,
      );
      if (amount == null) return;
      await ref.read(budgetRepositoryProvider).setCategory(status.categoryId, amount);
    }

    return InkWell(
      onTap: edit,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            CategoryIcon(icon: category.icon, color: category.color, size: 40, iconSize: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(category.label(l10n),
                            style: theme.textTheme.titleSmall),
                      ),
                      Text(
                        l10n.budgetSpentOf(
                          CurrencyFormatter.format(status.spent, locale: locale),
                          CurrencyFormatter.format(status.limit, locale: locale),
                        ),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: status.isOver
                              ? AppColors.danger
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _BudgetBar(
                    ratio: status.ratio,
                    over: status.isOver,
                    color: category.color,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A slim rounded progress bar. Turns red when over budget.
class _BudgetBar extends StatelessWidget {
  const _BudgetBar({required this.ratio, required this.over, this.color});

  final double ratio;
  final bool over;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fill = over ? AppColors.danger : (color ?? AppColors.primary);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: LinearProgressIndicator(
        value: ratio.clamp(0.0, 1.0),
        minHeight: 8,
        backgroundColor: AppColors.ringTrack,
        valueColor: AlwaysStoppedAnimation<Color>(fill),
      ),
    );
  }
}

/// ── Amount entry sheet ─────────────────────────────────────────────────────────

/// A focused bottom sheet to enter a budget amount. Returns the entered amount
/// (>= 0; 0 clears the budget) or null if dismissed. When [allowRemove] is set
/// a Remove button returns 0.
Future<double?> showBudgetAmountSheet(
  BuildContext context, {
  required String title,
  required double initial,
  bool allowRemove = false,
}) {
  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _BudgetAmountSheet(
      title: title,
      initial: initial,
      allowRemove: allowRemove,
    ),
  );
}

class _BudgetAmountSheet extends StatefulWidget {
  const _BudgetAmountSheet({
    required this.title,
    required this.initial,
    required this.allowRemove,
  });

  final String title;
  final double initial;
  final bool allowRemove;

  @override
  State<_BudgetAmountSheet> createState() => _BudgetAmountSheetState();
}

class _BudgetAmountSheetState extends State<_BudgetAmountSheet> {
  late final TextEditingController _amount;

  @override
  void initState() {
    super.initState();
    final value = widget.initial;
    _amount = TextEditingController(
      text: value <= 0
          ? ''
          : (value % 1 == 0
              ? value.toStringAsFixed(0)
              : value.toStringAsFixed(2)),
    );
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _save() {
    final value = double.tryParse(_amount.text.replaceAll(',', '').trim()) ?? 0;
    Navigator.of(context).pop(value < 0 ? 0.0 : value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: Text(widget.title, style: theme.textTheme.headlineSmall),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      visualDensity: VisualDensity.compact,
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        foregroundColor: theme.colorScheme.onSurface,
                      ),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      tooltip: l10n.commonClose,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                TextField(
                  controller: _amount,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: amountFormatters(),
                  style: theme.textTheme.headlineMedium,
                  decoration: InputDecoration(
                    prefixText: '${CurrencyFormatter.symbol} ',
                    prefixStyle: theme.textTheme.headlineSmall,
                    hintText: '0',
                  ),
                  onSubmitted: (_) => _save(),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    if (widget.allowRemove) ...[
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(0.0),
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.danger),
                          child: Text(l10n.budgetRemoveCategory),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                    ],
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _save,
                        child: Text(l10n.budgetSetLimit),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A compact category picker (expense categories) for adding a budget.
Future<String?> _pickExpenseCategory(
  BuildContext context,
  List<AppCategory> categories,
) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final l10n = AppLocalizations.of(sheetContext);
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(l10n.budgetAddCategory, style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final c in categories)
                      GestureDetector(
                        onTap: () => Navigator.of(sheetContext).pop(c.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(c.icon, size: 18, color: c.color),
                              const SizedBox(width: 8),
                              Text(c.label(l10n),
                                  style: theme.textTheme.labelMedium),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
