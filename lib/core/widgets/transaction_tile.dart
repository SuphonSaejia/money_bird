import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/db/database.dart';
import '../../data/models/transaction_type.dart';
import '../../domain/categories.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import 'category_icon.dart';

/// A single transaction row: tinted category icon, category name + note, the
/// signed amount and a relative date. Self-contained — resolves its own
/// category, localisation and currency formatting.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.showDate = true,
  });

  final Transaction transaction;
  final VoidCallback? onTap;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final category = Categories.byId(transaction.categoryId);
    final isIncome = transaction.type == TransactionType.income;
    final title = (transaction.note != null && transaction.note!.isNotEmpty)
        ? transaction.note!
        : category.label(l10n);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            CategoryIcon(icon: category.icon, color: category.color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category.label(l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.formatSigned(
                    transaction.amount,
                    isIncome: isIncome,
                    locale: locale,
                  ),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isIncome ? AppColors.income : theme.colorScheme.onSurface,
                  ),
                ),
                if (showDate) ...[
                  const SizedBox(height: 2),
                  Text(
                    DateFormat.MMMd(locale).format(transaction.date),
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
