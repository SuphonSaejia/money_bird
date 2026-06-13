import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/segmented_tabs.dart';
import '../../core/widgets/soft_icon_button.dart';
import '../../core/widgets/transaction_tile.dart';
import '../../data/db/database.dart';
import '../../data/models/transaction_type.dart';
import '../../domain/categories.dart';
import '../../domain/transaction_filter.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import 'add_transaction_sheet.dart';

/// Opens the searchable, filterable full transaction list.
Future<void> openTransactionsScreen(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const TransactionsScreen()),
  );
}

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchController = TextEditingController();
  TransactionFilter _filter = const TransactionFilter();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setType(int index) {
    setState(() {
      _filter = TransactionFilter(
        query: _filter.query,
        type: switch (index) {
          1 => TransactionType.expense,
          2 => TransactionType.income,
          _ => null,
        },
        // Drop the category filter if it no longer matches the chosen type.
        categoryId: null,
      );
    });
  }

  void _clear() {
    setState(() {
      _filter = const TransactionFilter();
      _searchController.clear();
    });
  }

  int get _typeIndex => switch (_filter.type) {
        TransactionType.expense => 1,
        TransactionType.income => 2,
        null => 0,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(allTransactionsProvider);

    return GradientScaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page, AppSpacing.md, AppSpacing.page, 0),
              child: Row(
                children: [
                  SoftIconButton(
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(l10n.txnAllTitle,
                        style: theme.textTheme.headlineMedium),
                  ),
                  if (_filter.isActive)
                    TextButton(
                      onPressed: _clear,
                      child: Text(l10n.txnFilterClear),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: TextField(
                controller: _searchController,
                onChanged: (v) =>
                    setState(() => _filter = _filter.copyWith(query: v)),
                decoration: InputDecoration(
                  hintText: l10n.txnSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _filter.query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(
                                () => _filter = _filter.copyWith(query: ''));
                          },
                        ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: SegmentedTabs(
                labels: [l10n.txnFilterAll, l10n.txnExpense, l10n.txnIncome],
                selectedIndex: _typeIndex,
                onChanged: _setType,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: async.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
                error: (_, __) => Center(child: Text(l10n.statsNoData)),
                data: (all) => _Results(
                  all: all,
                  filter: _filter,
                  onCategorySelected: (id) => setState(
                    () => _filter = id == null
                        ? _filter.copyWith(clearCategory: true)
                        : _filter.copyWith(categoryId: id),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({
    required this.all,
    required this.filter,
    required this.onCategorySelected,
  });

  final List<Transaction> all;
  final TransactionFilter filter;
  final ValueChanged<String?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Categories present in the data, respecting the active type filter, so the
    // chip row stays short and relevant.
    final typeScoped = filter.type == null
        ? all
        : all.where((t) => t.type == filter.type).toList();
    final presentCategoryIds = <String>{for (final t in typeScoped) t.categoryId};

    final results = filter.apply(all);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.page, 0, AppSpacing.page, 40),
      children: [
        if (presentCategoryIds.length > 1) ...[
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _CategoryFilterChip(
                  label: l10n.txnFilterAll,
                  selected: filter.categoryId == null,
                  onTap: () => onCategorySelected(null),
                ),
                for (final id in presentCategoryIds)
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: _CategoryFilterChip(
                      label: Categories.byId(id).label(l10n),
                      color: Categories.byId(id).color,
                      selected: filter.categoryId == id,
                      onTap: () => onCategorySelected(id),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: AppSpacing.xs),
          child: Text(
            l10n.txnCount(results.length),
            style: theme.textTheme.labelMedium,
          ),
        ),
        if (results.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.huge),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded,
                      size: 40, color: theme.colorScheme.outline),
                  const SizedBox(height: AppSpacing.md),
                  Text(l10n.txnNoResults, style: theme.textTheme.titleSmall),
                ],
              ),
            ),
          )
        else
          AppCard(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
            child: Column(
              children: [
                for (var i = 0; i < results.length; i++) ...[
                  TransactionTile(
                    transaction: results[i],
                    onTap: () =>
                        showAddTransactionSheet(context, existing: results[i]),
                  ),
                  if (i != results.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.border.withValues(alpha: 0.7),
                    ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  const _CategoryFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.14)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? accent : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: selected ? accent : theme.colorScheme.onSurface,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
