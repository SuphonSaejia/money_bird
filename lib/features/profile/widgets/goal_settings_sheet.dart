import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/goal_display.dart';
import '../../../core/utils/input_formatters.dart';
import '../../../domain/goal_type.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/providers.dart';

/// Opens the savings-goal settings sheet (pick goal type + target).
Future<void> showGoalSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const GoalSettingsSheet(),
  );
}

class GoalSettingsSheet extends ConsumerStatefulWidget {
  const GoalSettingsSheet({super.key});

  @override
  ConsumerState<GoalSettingsSheet> createState() => _GoalSettingsSheetState();
}

class _GoalSettingsSheetState extends ConsumerState<GoalSettingsSheet> {
  late GoalType _type;
  late final TextEditingController _name;
  late final TextEditingController _target;
  late final TextEditingController _year;
  late final TextEditingController _age;
  late final TextEditingController _retireAge;
  late final TextEditingController _monthly;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = ref.read(profileProvider);
    _type = p.goalType;
    _name = TextEditingController(text: p.goalName);
    _target = TextEditingController(text: _money(p.goalTargetAmount));
    final defaultYear = DateTime.now().year + 5;
    _year = TextEditingController(
        text: '${p.goalTargetYear > 0 ? p.goalTargetYear : defaultYear}');
    _age = TextEditingController(text: '${p.age}');
    _retireAge = TextEditingController(text: '${p.retirementAge}');
    _monthly = TextEditingController(text: _money(p.savingsGoal));
  }

  static String _money(double v) {
    if (v <= 0) return '';
    return v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
  }

  double _parseMoney(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '').trim()) ?? 0;

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _year.dispose();
    _age.dispose();
    _retireAge.dispose();
    _monthly.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final current = ref.read(profileProvider);

    var age = current.age;
    var retire = current.retirementAge;
    var targetAmount = current.goalTargetAmount;
    var targetYear = current.goalTargetYear;

    if (_type.isRetirement) {
      age = (int.tryParse(_age.text.trim()) ?? current.age).clamp(15, 85);
      retire = (int.tryParse(_retireAge.text.trim()) ?? current.retirementAge)
          .clamp(40, 90);
      if (retire <= age) retire = age + 1;
    } else {
      targetAmount = _parseMoney(_target);
      targetYear = int.tryParse(_year.text.trim()) ?? 0;
    }

    final updated = current.copyWith(
      goalType: _type,
      goalName: _type == GoalType.custom ? _name.text.trim() : '',
      goalTargetAmount: targetAmount,
      goalTargetYear: targetYear,
      age: age,
      retirementAge: retire,
      savingsGoal: _parseMoney(_monthly),
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
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
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
                      child: Text(l10n.goalSettingsTitle,
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
                const SizedBox(height: AppSpacing.lg),
                Text(l10n.goalChooseType, style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final type in GoalType.values)
                      _TypeChip(
                        type: type,
                        label: type.label(l10n),
                        selected: type == _type,
                        onTap: () => setState(() => _type = type),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                if (_type == GoalType.custom) ...[
                  _LabeledField(
                    label: l10n.goalNameLabel,
                    child: TextField(
                      controller: _name,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(hintText: l10n.goalNameHint),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (_type.isRetirement) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _LabeledField(
                          label: l10n.profileAge,
                          child: _numberField(_age),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _LabeledField(
                          label: l10n.profileRetirementAge,
                          child: _numberField(_retireAge),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  _LabeledField(
                    label: l10n.goalTargetAmount,
                    child: _moneyField(_target),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _LabeledField(
                    label: l10n.goalTargetYear,
                    child: _numberField(_year),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                _LabeledField(
                  label: l10n.goalMonthlySaving,
                  child: _moneyField(_monthly),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed:
                            _saving ? null : () => Navigator.of(context).pop(),
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
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.4, color: AppColors.onPrimary),
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

  Widget _moneyField(TextEditingController c) {
    final theme = Theme.of(context);
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: amountFormatters(),
      decoration: InputDecoration(
        prefixText: '${CurrencyFormatter.symbol} ',
        prefixStyle: theme.textTheme.titleMedium,
        hintText: '0',
      ),
    );
  }

  Widget _numberField(TextEditingController c) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.number,
      inputFormatters: integerFormatters(),
      decoration: const InputDecoration(hintText: '—'),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.type,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final GoalType type;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(type.icon,
                size: 18,
                color: selected ? AppColors.primary : theme.colorScheme.onSurface),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: selected ? AppColors.primary : theme.colorScheme.onSurface,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
