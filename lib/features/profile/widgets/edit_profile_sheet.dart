import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/input_formatters.dart';
import '../../../data/models/financial_profile.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/providers.dart';

/// Opens the edit financial-profile sheet, prefilled from the current profile.
Future<void> showEditProfileSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const EditProfileSheet(),
  );
}

/// A tidy, scrollable bottom sheet with the five numeric profile figures and a
/// save action. Mirrors the calm card aesthetic used across the app.
class EditProfileSheet extends ConsumerStatefulWidget {
  const EditProfileSheet({super.key});

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late final TextEditingController _income;
  late final TextEditingController _expenses;
  late final TextEditingController _savings;
  late final TextEditingController _debt;
  late final TextEditingController _goal;
  late final TextEditingController _age;
  late final TextEditingController _retirementAge;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    _income = TextEditingController(text: _initial(profile.monthlyIncome));
    _expenses = TextEditingController(text: _initial(profile.fixedExpenses));
    _savings = TextEditingController(text: _initial(profile.currentSavings));
    _debt = TextEditingController(text: _initial(profile.monthlyDebt));
    _goal = TextEditingController(text: _initial(profile.savingsGoal));
    _age = TextEditingController(text: '${profile.age}');
    _retirementAge = TextEditingController(text: '${profile.retirementAge}');
  }

  static String _initial(double value) {
    if (value <= 0) return '';
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  }

  static double _parse(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '').trim()) ?? 0;

  @override
  void dispose() {
    _income.dispose();
    _expenses.dispose();
    _savings.dispose();
    _debt.dispose();
    _goal.dispose();
    _age.dispose();
    _retirementAge.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final current = ref.read(profileProvider);
    final age = (int.tryParse(_age.text.trim()) ?? current.age).clamp(15, 85);
    var retire = (int.tryParse(_retirementAge.text.trim()) ?? current.retirementAge).clamp(40, 90);
    if (retire <= age) retire = age + 1;
    final updated = FinancialProfile(
      monthlyIncome: _parse(_income),
      fixedExpenses: _parse(_expenses),
      currentSavings: _parse(_savings),
      monthlyDebt: _parse(_debt),
      savingsGoal: _parse(_goal),
      age: age,
      retirementAge: retire,
    );
    await ref.read(profileProvider.notifier).save(updated);
    if (mounted) Navigator.of(context).pop();
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
                      child: Text(l10n.settingsFinancialProfile,
                          style: theme.textTheme.headlineSmall),
                    ),
                    IconButton(
                      onPressed:
                          _saving ? null : () => Navigator.of(context).maybePop(),
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
                _MoneyField(controller: _income, label: l10n.onbIncomeTitle, autofocus: true),
                const SizedBox(height: AppSpacing.md),
                _MoneyField(controller: _expenses, label: l10n.onbExpensesTitle),
                const SizedBox(height: AppSpacing.md),
                _MoneyField(controller: _savings, label: l10n.onbSavingsTitle),
                const SizedBox(height: AppSpacing.md),
                _MoneyField(controller: _debt, label: l10n.onbDebtTitle),
                const SizedBox(height: AppSpacing.md),
                _MoneyField(controller: _goal, label: l10n.onbGoalTitle),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _MoneyField(controller: _age, label: l10n.profileAge, isCurrency: false),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _MoneyField(
                        controller: _retirementAge,
                        label: l10n.profileRetirementAge,
                        isCurrency: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _saving ? null : () => Navigator.of(context).pop(),
                        child: Text(l10n.commonCancel),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.onPrimary),
                              )
                            : Text(l10n.commonSave),
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

class _MoneyField extends StatelessWidget {
  const _MoneyField({required this.controller, required this.label, this.autofocus = false, this.isCurrency = true});

  final TextEditingController controller;
  final String label;
  final bool autofocus;

  /// When false the field is a plain whole number (no ฿, digits only) — age.
  final bool isCurrency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          autofocus: autofocus,
          keyboardType: isCurrency ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
          inputFormatters: isCurrency ? amountFormatters() : integerFormatters(),
          decoration: InputDecoration(
            prefixText: isCurrency ? '${CurrencyFormatter.symbol} ' : null,
            prefixStyle: theme.textTheme.titleMedium,
            hintText: isCurrency ? '0' : '—',
          ),
        ),
      ],
    );
  }
}
