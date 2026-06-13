import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/input_formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/soft_icon_button.dart';
import '../../data/db/database.dart';
import '../../domain/savings.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';

/// Opens the savings ledger screen.
Future<void> openSavingsScreen(BuildContext context) {
  return Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SavingsScreen()));
}

/// Lets the user log money moved into / out of savings. Each entry adjusts the
/// running balance that drives the goal, emergency fund and health score.
class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final summary = ref.watch(savingsSummaryProvider);
    final entriesAsync = ref.watch(savingsEntriesProvider);

    return GradientScaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.md, AppSpacing.page, 40),
          children: [
            Row(
              children: [
                SoftIconButton(icon: Icons.arrow_back_rounded, onPressed: () => Navigator.of(context).maybePop()),
                const SizedBox(width: AppSpacing.md),
                Text(l10n.savingsTitle, style: theme.textTheme.headlineMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _BalanceCard(summary: summary, locale: locale),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _add(context, ref, deposit: true),
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: Text(l10n.savingsDeposit),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.income,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _add(context, ref, deposit: false),
                    icon: const Icon(Icons.remove_rounded, size: 20),
                    label: Text(l10n.savingsWithdraw),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.expense,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            SectionHeader(title: l10n.savingsHistory),
            const SizedBox(height: AppSpacing.lg),
            entriesAsync.when(
              loading: () => const AppCard(
                child: SizedBox(height: 80, child: Center(child: CircularProgressIndicator(strokeWidth: 2.4))),
              ),
              error: (_, __) => AppCard(child: Text(l10n.statsNoData, style: theme.textTheme.bodyMedium)),
              data: (entries) => entries.isEmpty ? _Empty(l10n: l10n) : _Ledger(entries: entries),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref, {required bool deposit}) async {
    final result = await showSavingsEntrySheet(context, deposit: deposit);
    if (result == null) return;
    final actions = ref.read(savingsActionsProvider);
    if (deposit) {
      await actions.deposit(result.$1, note: result.$2);
    } else {
      await actions.withdraw(result.$1, note: result.$2);
    }
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.summary, required this.locale});

  final SavingsSummary summary;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.savingsBalance, style: theme.textTheme.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            CurrencyFormatter.format(summary.balance, locale: locale),
            style: AppTextStyles.money(34, color: theme.colorScheme.onSurface),
          ),
          if (summary.depositedThisMonth > 0 || summary.withdrawnThisMonth > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.xs,
              children: [
                if (summary.depositedThisMonth > 0)
                  _Delta(
                    label: l10n.savingsInThisMonth,
                    amount: summary.depositedThisMonth,
                    locale: locale,
                    positive: true,
                  ),
                if (summary.withdrawnThisMonth > 0)
                  _Delta(
                    label: l10n.savingsOutThisMonth,
                    amount: summary.withdrawnThisMonth,
                    locale: locale,
                    positive: false,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Delta extends StatelessWidget {
  const _Delta({required this.label, required this.amount, required this.locale, required this.positive});

  final String label;
  final double amount;
  final String locale;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = positive ? AppColors.income : AppColors.expense;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(positive ? Icons.south_west_rounded : Icons.north_east_rounded, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          '$label ${CurrencyFormatter.format(amount, locale: locale)}',
          style: theme.textTheme.labelMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _Ledger extends ConsumerWidget {
  const _Ledger({required this.entries});

  final List<SavingsEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            _LedgerRow(entry: entries[i]),
            if (i != entries.length - 1)
              Divider(height: 1, thickness: 1, color: AppColors.border.withValues(alpha: 0.7)),
          ],
        ],
      ),
    );
  }
}

class _LedgerRow extends ConsumerWidget {
  const _LedgerRow({required this.entry});

  final SavingsEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final color = entry.deposit ? AppColors.income : AppColors.expense;
    final title = (entry.note != null && entry.note!.isNotEmpty)
        ? entry.note!
        : (entry.deposit ? l10n.savingsDeposit : l10n.savingsWithdraw);

    return InkWell(
      onTap: () => _confirmDelete(context, ref, l10n),
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                entry.deposit ? Icons.savings_rounded : Icons.account_balance_wallet_rounded,
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(DateFormat.MMMd(locale).format(entry.date), style: theme.textTheme.labelSmall),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '${entry.deposit ? '+' : '−'}${CurrencyFormatter.format(entry.amount, locale: locale)}',
              style: theme.textTheme.titleSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.savingsDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(savingsActionsProvider).delete(entry);
    }
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xxxl),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: AppColors.incomeSoft, borderRadius: AppRadius.input),
            child: const Icon(Icons.savings_rounded, size: 26, color: AppColors.income),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.savingsEmptyTitle, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.savingsEmptyBody, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// A focused sheet to enter a deposit / withdrawal amount and optional note.
/// Returns `(amount, note)` or null if dismissed.
Future<(double, String?)?> showSavingsEntrySheet(BuildContext context, {required bool deposit}) {
  return showModalBottomSheet<(double, String?)>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SavingsEntrySheet(deposit: deposit),
  );
}

class _SavingsEntrySheet extends StatefulWidget {
  const _SavingsEntrySheet({required this.deposit});

  final bool deposit;

  @override
  State<_SavingsEntrySheet> createState() => _SavingsEntrySheetState();
}

class _SavingsEntrySheetState extends State<_SavingsEntrySheet> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  bool _error = false;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    final value = double.tryParse(_amount.text.replaceAll(',', '').trim());
    if (value == null || value <= 0) {
      setState(() => _error = true);
      return;
    }
    final note = _note.text.trim().isEmpty ? null : _note.text.trim();
    Navigator.of(context).pop((value, note));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final accent = widget.deposit ? AppColors.income : AppColors.primary;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl),
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
                      child: Text(
                        widget.deposit ? l10n.savingsDepositTitle : l10n.savingsWithdrawTitle,
                        style: theme.textTheme.headlineSmall,
                      ),
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
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: TextField(
                      controller: _amount,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: amountFormatters(),
                      style: theme.textTheme.displayMedium?.copyWith(color: accent),
                      onChanged: (_) {
                        if (_error) setState(() => _error = false);
                      },
                      decoration: InputDecoration(
                        filled: false,
                        prefixText: '${CurrencyFormatter.symbol} ',
                        prefixStyle: theme.textTheme.headlineMedium?.copyWith(color: accent),
                        hintText: '0',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorText: _error ? l10n.txnAmountError : null,
                        errorStyle: const TextStyle(height: 0),
                      ),
                    ),
                  ),
                ),
                if (_error)
                  Center(
                    child: Text(
                      l10n.txnAmountError,
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.danger),
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _note,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: l10n.txnNoteHint,
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(backgroundColor: accent),
                  child: Text(widget.deposit ? l10n.savingsDeposit : l10n.savingsWithdraw),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
