import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/app_date_utils.dart';
import '../../core/utils/input_formatters.dart';
import '../../core/widgets/segmented_tabs.dart';
import '../../data/db/database.dart';
import '../../data/models/transaction_type.dart';
import '../../domain/categories.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';

/// Opens the add / edit transaction sheet. Pass [existing] to edit.
Future<void> showAddTransactionSheet(
  BuildContext context, {
  Transaction? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddTransactionSheet(existing: existing),
  );
}

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key, this.existing});

  final Transaction? existing;

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  late TransactionType _type;
  late String _categoryId;
  late DateTime _date;
  late final TextEditingController _amount;
  late final TextEditingController _note;
  bool _amountError = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.type ?? TransactionType.expense;
    _categoryId = e?.categoryId ?? Categories.forType(_type).first.id;
    _date = e?.date ?? DateTime.now();
    _amount = TextEditingController(
      text: e == null ? '' : (e.amount % 1 == 0
          ? e.amount.toStringAsFixed(0)
          : e.amount.toStringAsFixed(2)),
    );
    _note = TextEditingController(text: e?.note ?? '');
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Color get _accent =>
      _type.isIncome ? AppColors.income : AppColors.primary;

  void _switchType(int index) {
    setState(() {
      _type = index == 0 ? TransactionType.expense : TransactionType.income;
      _categoryId = Categories.forType(_type).first.id;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2018),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final value = double.tryParse(_amount.text.replaceAll(',', '').trim());
    if (value == null || value <= 0) {
      setState(() => _amountError = true);
      return;
    }
    final repo = ref.read(transactionRepositoryProvider);
    final note = _note.text.trim().isEmpty ? null : _note.text.trim();
    final e = widget.existing;
    if (e == null) {
      await repo.add(
        amount: value,
        type: _type,
        categoryId: _categoryId,
        note: note,
        date: _date,
      );
    } else {
      await repo.update(e.copyWith(
        amount: value,
        type: _type,
        categoryId: _categoryId,
        note: Value(note),
        date: _date,
      ));
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final categories = Categories.forType(_type);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isToday = AppDateUtils.isSameDay(_date, DateTime.now());

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xxl)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
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
                      child: Text(
                        widget.existing == null
                            ? l10n.txnNewTitle
                            : l10n.txnEditTitle,
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
                const SizedBox(height: AppSpacing.lg),
                SegmentedTabs(
                  labels: [l10n.txnExpense, l10n.txnIncome],
                  selectedIndex: _type.isExpense ? 0 : 1,
                  onChanged: _switchType,
                ),
                const SizedBox(height: AppSpacing.xl),
                // Amount field
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: TextField(
                      controller: _amount,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: amountFormatters(),
                      style: theme.textTheme.displayMedium
                          ?.copyWith(color: _accent),
                      onChanged: (_) {
                        if (_amountError) setState(() => _amountError = false);
                      },
                      decoration: InputDecoration(
                        filled: false,
                        prefixText: '฿ ',
                        prefixStyle: theme.textTheme.headlineMedium
                            ?.copyWith(color: _accent),
                        hintText: '0',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorText: _amountError ? l10n.txnAmountError : null,
                        errorStyle: const TextStyle(height: 0),
                      ),
                    ),
                  ),
                ),
                if (_amountError)
                  Center(
                    child: Text(l10n.txnAmountError,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.danger)),
                  ),
                const SizedBox(height: AppSpacing.lg),
                Text(l10n.txnCategory, style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final c in categories)
                      _CategoryChip(
                        category: c,
                        selected: c.id == _categoryId,
                        onTap: () => setState(() => _categoryId = c.id),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: _FieldButton(
                        icon: Icons.event_rounded,
                        label: l10n.txnDate,
                        value: isToday
                            ? l10n.commonToday
                            : DateFormat.yMMMd(locale).format(_date),
                        onTap: _pickDate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
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
                  style: FilledButton.styleFrom(backgroundColor: _accent),
                  child: Text(l10n.txnSave),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final AppCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? category.color.withValues(alpha: 0.14)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? category.color : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon, size: 18, color: category.color),
            const SizedBox(width: 8),
            Text(
              category.label(l10n),
              style: theme.textTheme.labelMedium?.copyWith(
                color: selected ? category.color : theme.colorScheme.onSurface,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldButton extends StatelessWidget {
  const _FieldButton({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.input,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: AppRadius.input,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.onSurface),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.labelSmall),
                  Text(value, style: theme.textTheme.titleSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
