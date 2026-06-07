import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/transaction_tile.dart';
import '../../../data/db/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/providers.dart';
import '../../transactions/add_transaction_sheet.dart';

/// The "Recent activity" list: up to a handful of the latest transactions,
/// each tappable to edit, with a friendly empty/loading/error state.
class RecentActivity extends ConsumerWidget {
  const RecentActivity({super.key});

  static const _maxItems = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final recent = ref.watch(recentTransactionsProvider);

    return recent.when(
      loading: () => const AppCard(
        child: SizedBox(
          height: 120,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ),
        ),
      ),
      error: (_, __) => _Empty(
        icon: Icons.cloud_off_rounded,
        title: l10n.statsNoData,
        body: l10n.homeNoTransactionsBody,
      ),
      data: (txns) {
        if (txns.isEmpty) {
          return _Empty(
            icon: Icons.receipt_long_rounded,
            title: l10n.homeNoTransactions,
            body: l10n.homeNoTransactionsBody,
          );
        }
        final items = txns.take(_maxItems).toList();
        return AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                TransactionTile(
                  transaction: items[i],
                  onTap: () => _edit(context, items[i]),
                ),
                if (i != items.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.border.withValues(alpha: 0.7),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _edit(BuildContext context, Transaction txn) {
    showAddTransactionSheet(context, existing: txn);
  }
}

class _Empty extends StatelessWidget {
  const _Empty({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxxl,
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: AppRadius.input,
            ),
            child: Icon(icon, size: 26, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
