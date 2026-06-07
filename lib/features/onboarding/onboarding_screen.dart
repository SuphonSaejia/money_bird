import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/health_display.dart';
import '../../core/utils/input_formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/brand_logo.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/health_ring_chart.dart';
import '../../data/models/financial_profile.dart';
import '../../domain/financial_health.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';

/// Number of question pages (income, fixed, savings, debt, goal, age).
const int _questionCount = 6;

/// Total pages: welcome (0) + questions (1..N) + result.
const int _totalPages = _questionCount + 2;

/// Which profile figure a question step edits.
enum _Field { income, fixed, savings, debt, goal, age }

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();

  /// The profile assembled across the question steps.
  FinancialProfile _profile = FinancialProfile.empty;

  /// Index of the current page (0 = welcome, 6 = result).
  int _page = 0;

  /// Set true once the result CTA is tapped, to disable it while persisting.
  bool _finishing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    // Keep the keyboard up when moving between question steps (the next step
    // re-focuses its field); dismiss it for the welcome / result pages.
    final goingToInputPage = page > 0 && page < _totalPages - 1;
    if (!goingToInputPage) FocusScope.of(context).unfocus();
    _controller.animateToPage(page, duration: const Duration(milliseconds: 360), curve: Curves.easeInOutCubic);
  }

  void _next() => _goTo((_page + 1).clamp(0, _totalPages - 1));

  void _back() => _goTo((_page - 1).clamp(0, _totalPages - 1));

  /// Persists a step's parsed value into the in-memory profile.
  void _setValue(_Field field, double value) {
    setState(() {
      switch (field) {
        case _Field.income:
          _profile = _profile.copyWith(monthlyIncome: value);
        case _Field.fixed:
          _profile = _profile.copyWith(fixedExpenses: value);
        case _Field.savings:
          _profile = _profile.copyWith(currentSavings: value);
        case _Field.debt:
          _profile = _profile.copyWith(monthlyDebt: value);
        case _Field.goal:
          _profile = _profile.copyWith(savingsGoal: value);
        case _Field.age:
          _profile = _profile.copyWith(age: value.round().clamp(15, 90));
      }
    });
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    // The app root listens to onboardingComplete and swaps to the main app,
    // so there's no manual navigation here.
    await ref.read(profileProvider.notifier).save(_profile);
    await ref.read(settingsProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GradientScaffold(
      body: SafeArea(
        child: PageView(
          controller: _controller,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (i) => setState(() => _page = i),
          children: [
            _WelcomePage(onStart: _next),
            _QuestionPage(
              step: 1,
              field: _Field.income,
              title: l10n.onbIncomeTitle,
              body: l10n.onbIncomeBody,
              initial: _profile.monthlyIncome,
              allowZero: false,
              isActive: _page == 1,
              onCommit: (v) => _setValue(_Field.income, v),
              onBack: _back,
              onNext: _next,
            ),
            _QuestionPage(
              step: 2,
              field: _Field.fixed,
              title: l10n.onbExpensesTitle,
              body: l10n.onbExpensesBody,
              initial: _profile.fixedExpenses,
              allowZero: false,
              isActive: _page == 2,
              onCommit: (v) => _setValue(_Field.fixed, v),
              onBack: _back,
              onNext: _next,
            ),
            _QuestionPage(
              step: 3,
              field: _Field.savings,
              title: l10n.onbSavingsTitle,
              body: l10n.onbSavingsBody,
              initial: _profile.currentSavings,
              allowZero: false,
              isActive: _page == 3,
              onCommit: (v) => _setValue(_Field.savings, v),
              onBack: _back,
              onNext: _next,
            ),
            _QuestionPage(
              step: 4,
              field: _Field.debt,
              title: l10n.onbDebtTitle,
              body: l10n.onbDebtBody,
              initial: _profile.monthlyDebt,
              allowZero: true,
              isActive: _page == 4,
              onCommit: (v) => _setValue(_Field.debt, v),
              onBack: _back,
              onNext: _next,
            ),
            _QuestionPage(
              step: 5,
              field: _Field.goal,
              title: l10n.onbGoalTitle,
              body: l10n.onbGoalBody,
              initial: _profile.savingsGoal,
              allowZero: false,
              isActive: _page == 5,
              onCommit: (v) => _setValue(_Field.goal, v),
              onBack: _back,
              onNext: _next,
            ),
            _QuestionPage(
              step: 6,
              field: _Field.age,
              title: l10n.onbAgeTitle,
              body: l10n.onbAgeBody,
              initial: _profile.age.toDouble(),
              allowZero: false,
              isCurrency: false,
              isActive: _page == 6,
              onCommit: (v) => _setValue(_Field.age, v),
              onBack: _back,
              onNext: _next,
            ),
            _ResultPage(profile: _profile, finishing: _finishing, onFinish: _finish),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Welcome
// ---------------------------------------------------------------------------

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.xxl, AppSpacing.page, AppSpacing.xxl),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surface,
              boxShadow: AppShadows.floating,
            ),
            alignment: Alignment.center,
            child: const BrandLogo(size: 86),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(l10n.onbWelcomeTitle, textAlign: TextAlign.center, style: theme.textTheme.displaySmall),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.onbWelcomeBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.textTheme.bodyMedium?.color),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: onStart, child: Text(l10n.onbGetStarted)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Question step
// ---------------------------------------------------------------------------

class _QuestionPage extends StatefulWidget {
  const _QuestionPage({
    required this.step,
    required this.field,
    required this.title,
    required this.body,
    required this.initial,
    required this.allowZero,
    required this.isActive,
    this.isCurrency = true,
    required this.onCommit,
    required this.onBack,
    required this.onNext,
  });

  final int step;
  final _Field field;
  final String title;
  final String body;
  final double initial;
  final bool allowZero;

  /// Whether this is the page currently shown (drives auto-focus).
  final bool isActive;

  /// When true the input shows a ฿ prefix + decimals; when false it's a plain
  /// whole-number field (used for the age step).
  final bool isCurrency;
  final ValueChanged<double> onCommit;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  State<_QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<_QuestionPage> {
  late final TextEditingController _amount;
  final FocusNode _focusNode = FocusNode();
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(text: _format(widget.initial));
    if (widget.isActive) _focusSoon();
  }

  @override
  void didUpdateWidget(_QuestionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-focus the amount field when this step becomes the active page.
    if (widget.isActive && !oldWidget.isActive) _focusSoon();
  }

  void _focusSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.isActive) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _amount.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  static String _format(double v) {
    if (v <= 0) return '';
    return v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
  }

  /// Parsed value, or null if blank/unparseable.
  double? get _parsed => double.tryParse(_amount.text.replaceAll(',', '').trim());

  bool get _canAdvance {
    final value = _parsed;
    if (widget.allowZero) return true;
    return value != null && value > 0;
  }

  void _handleNext() {
    final raw = _amount.text.replaceAll(',', '').trim();
    final value = _parsed;
    if (widget.allowZero) {
      // Treat blank as zero for the debt step.
      if (raw.isEmpty) {
        widget.onCommit(0);
        widget.onNext();
        return;
      }
      if (value == null) {
        setState(() => _error = true);
        return;
      }
      widget.onCommit(value);
      widget.onNext();
      return;
    }
    if (value == null || value <= 0) {
      setState(() => _error = true);
      return;
    }
    widget.onCommit(value);
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final progress = widget.step / _questionCount;

    return LayoutBuilder(
      builder: (context, constraints) => ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress bar + step counter.
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 16,
                      backgroundColor: AppColors.ringTrack,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.onbStepOf(widget.step, _questionCount),
                  style: theme.textTheme.labelMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(widget.title, style: theme.textTheme.headlineLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(widget.body, style: theme.textTheme.bodyLarge?.copyWith(color: theme.textTheme.bodyMedium?.color)),
                const Spacer(),
                // Centered large amount input.
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: TextField(
                      controller: _amount,
                      focusNode: _focusNode,
                      textAlign: TextAlign.center,
                      keyboardType: widget.isCurrency
                          ? const TextInputType.numberWithOptions(decimal: true)
                          : TextInputType.number,
                      inputFormatters:
                          widget.isCurrency ? amountFormatters() : integerFormatters(),
                      style: theme.textTheme.displayMedium?.copyWith(color: AppColors.primary),
                      onChanged: (_) {
                        if (_error) setState(() => _error = false);
                        setState(() {});
                      },
                      onSubmitted: (_) {
                        if (_canAdvance) _handleNext();
                      },
                      decoration: InputDecoration(
                        filled: false,
                        prefixText: widget.isCurrency ? '฿ ' : null,
                        prefixStyle: theme.textTheme.headlineMedium?.copyWith(color: AppColors.primary),
                        hintText: '0',
                        hintStyle: theme.textTheme.displayMedium?.copyWith(color: theme.textTheme.bodyMedium?.color),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorStyle: const TextStyle(height: 0),
                      ),
                    ),
                  ),
                ),
                if (_error)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        l10n.txnAmountError,
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.danger),
                      ),
                    ),
                  ),
                const Spacer(),
                // Back + Next controls.
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(onPressed: widget.onBack, child: Text(l10n.commonBack)),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: FilledButton(onPressed: _canAdvance ? _handleNext : null, child: Text(l10n.commonNext)),
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

// ---------------------------------------------------------------------------
// Result
// ---------------------------------------------------------------------------

class _ResultPage extends StatelessWidget {
  const _ResultPage({required this.profile, required this.finishing, required this.onFinish});

  final FinancialProfile profile;
  final bool finishing;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final health = FinancialHealth.compute(profile: profile, spentThisMonth: 0);
    final bandColor = health.band.color;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.xxl, AppSpacing.page, AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.onbResultTitle, textAlign: TextAlign.center, style: theme.textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.xxl),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              children: [
                HealthRingChart(
                  size: 190,
                  rings: [for (final m in health.rings) RingData(value: m.value, color: m.key.color)],
                  center: Text(
                    '${health.score}%',
                    style: theme.textTheme.displayMedium?.copyWith(color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Band pill.
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: bandColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(health.band.label(l10n), style: theme.textTheme.titleSmall?.copyWith(color: bandColor)),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(health.band.tip(l10n), textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Legend of the three rings.
          AppCard(
            child: Column(
              children: [
                for (var i = 0; i < health.rings.length; i++) ...[
                  if (i > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Divider(height: 1, color: AppColors.border),
                    ),
                  _LegendRow(metric: health.rings[i]),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.onbResultBody, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: finishing ? null : onFinish,
            child: finishing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                  )
                : Text(l10n.onbResultCta),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.metric});

  final HealthMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final color = metric.key.color;

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(metric.key.label(l10n), style: theme.textTheme.titleSmall)),
        Text(metric.detail, style: theme.textTheme.titleSmall?.copyWith(color: color)),
      ],
    );
  }
}
