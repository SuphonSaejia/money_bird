import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/db/database.dart';
import '../data/models/app_settings.dart';
import '../data/models/financial_profile.dart';
import '../data/models/transaction_type.dart';
import '../data/repositories/budget_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/savings_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../domain/budget.dart';
import '../domain/financial_health.dart';
import '../domain/goal_plan.dart';
import '../domain/month_summary.dart';
import '../domain/savings.dart';
import '../services/backup_service.dart';

/// ── Bootstrap ──────────────────────────────────────────────────────────────
/// Overridden in `main()` once async initialisation has completed.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(sharedPreferencesProvider)),
);

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(ref.watch(appDatabaseProvider)),
);

final budgetRepositoryProvider = Provider<BudgetRepository>(
  (ref) => BudgetRepository(ref.watch(appDatabaseProvider)),
);

final savingsRepositoryProvider = Provider<SavingsRepository>(
  (ref) => SavingsRepository(ref.watch(appDatabaseProvider)),
);

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(
    db: ref.watch(appDatabaseProvider),
    profileRepository: ref.watch(profileRepositoryProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
  ),
);

/// ── App settings (theme / locale / onboarding / reminders) ─────────────────
class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(settingsRepositoryProvider).load();

  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  Future<void> setThemeMode(ThemeMode mode) async {
    await _repo.setThemeMode(mode);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setLocaleCode(String code) async {
    await _repo.setLocaleCode(code);
    state = state.copyWith(localeCode: code);
  }

  Future<void> completeOnboarding() async {
    await _repo.setOnboardingComplete(true);
    state = state.copyWith(onboardingComplete: true);
  }

  Future<void> setReminderEnabled(bool value) async {
    await _repo.setReminderEnabled(value);
    state = state.copyWith(reminderEnabled: value);
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    await _repo.setReminderTime(time.hour, time.minute);
    state = state.copyWith(reminderHour: time.hour, reminderMinute: time.minute);
  }
}

final settingsProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

/// ── Financial profile (onboarding answers) ─────────────────────────────────
class ProfileController extends Notifier<FinancialProfile> {
  @override
  FinancialProfile build() => ref.read(profileRepositoryProvider).load();

  Future<void> save(FinancialProfile profile) async {
    await ref.read(profileRepositoryProvider).save(profile);
    state = profile;
  }
}

final profileProvider =
    NotifierProvider<ProfileController, FinancialProfile>(ProfileController.new);

/// ── Transaction streams ────────────────────────────────────────────────────
final recentTransactionsProvider =
    StreamProvider.autoDispose<List<Transaction>>(
  (ref) => ref.watch(transactionRepositoryProvider).watchRecent(limit: 12),
);

final allTransactionsProvider = StreamProvider.autoDispose<List<Transaction>>(
  (ref) => ref.watch(transactionRepositoryProvider).watchAll(),
);

final currentMonthTransactionsProvider =
    StreamProvider.autoDispose<List<Transaction>>(
  (ref) => ref.watch(transactionRepositoryProvider).watchMonth(DateTime.now()),
);

/// ── Derived aggregates ──────────────────────────────────────────────────────
final monthSummaryProvider = Provider<MonthSummary>((ref) {
  final async = ref.watch(currentMonthTransactionsProvider);
  return async.maybeWhen(
    data: MonthSummary.fromTransactions,
    orElse: () => MonthSummary.empty,
  );
});

/// This month's expense total per category id (income is ignored).
final spendByCategoryProvider = Provider<Map<String, double>>((ref) {
  final async = ref.watch(currentMonthTransactionsProvider);
  return async.maybeWhen(
    data: (txns) {
      final byCategory = <String, double>{};
      for (final t in txns) {
        if (t.type == TransactionType.expense) {
          byCategory[t.categoryId] = (byCategory[t.categoryId] ?? 0) + t.amount;
        }
      }
      return byCategory;
    },
    orElse: () => const {},
  );
});

/// ── Budgets ─────────────────────────────────────────────────────────────────
final budgetsProvider = StreamProvider.autoDispose<MonthlyBudgets>(
  (ref) => ref
      .watch(budgetRepositoryProvider)
      .watch()
      .map(MonthlyBudgets.fromRows),
);

/// The overall + per-category budget status for the current month.
final budgetOverviewProvider = Provider<BudgetOverview>((ref) {
  final budgets =
      ref.watch(budgetsProvider).maybeWhen(data: (b) => b, orElse: () => MonthlyBudgets.empty);
  final summary = ref.watch(monthSummaryProvider);
  return BudgetOverview.compute(
    budgets: budgets,
    spentByCategory: ref.watch(spendByCategoryProvider),
    totalSpent: summary.expense,
  );
});

/// The composite financial-health snapshot — single source of truth for the
/// home diagram, the widget and the share card.
final financialHealthProvider = Provider<FinancialHealth>((ref) {
  final profile = ref.watch(profileProvider);
  final summary = ref.watch(monthSummaryProvider);
  final budgets =
      ref.watch(budgetsProvider).maybeWhen(data: (b) => b, orElse: () => MonthlyBudgets.empty);
  return FinancialHealth.compute(
    profile: profile,
    spentThisMonth: summary.expense,
    userBudget: budgets.overall,
    now: DateTime.now(),
  );
});

/// The savings-goal plan derived from the user's profile — works for any goal
/// type (retirement uses the 4% rule; others use a user-set target + year).
final goalPlanProvider = Provider<GoalPlan>((ref) {
  return GoalPlan.from(ref.watch(profileProvider), nowYear: DateTime.now().year);
});

/// ── Savings ledger ───────────────────────────────────────────────────────────
final savingsEntriesProvider = StreamProvider.autoDispose<List<SavingsEntry>>(
  (ref) => ref.watch(savingsRepositoryProvider).watch(),
);

/// Activity figures for the savings screen. The balance is the authoritative
/// `currentSavings` from the profile; the rest is derived from the ledger.
final savingsSummaryProvider = Provider<SavingsSummary>((ref) {
  final balance = ref.watch(profileProvider).currentSavings;
  final entries = ref
      .watch(savingsEntriesProvider)
      .maybeWhen(data: (e) => e, orElse: () => const <SavingsEntry>[]);
  return SavingsSummary.compute(balance: balance, entries: entries);
});

/// Records deposits / withdrawals and keeps the authoritative savings balance
/// (`FinancialProfile.currentSavings`) in step, so the goal, emergency fund and
/// health score all react to logged savings activity.
class SavingsActions {
  SavingsActions(this._ref);

  final Ref _ref;

  SavingsRepository get _repo => _ref.read(savingsRepositoryProvider);

  Future<void> deposit(double amount, {String? note, DateTime? date}) =>
      _record(amount: amount, deposit: true, note: note, date: date);

  Future<void> withdraw(double amount, {String? note, DateTime? date}) =>
      _record(amount: amount, deposit: false, note: note, date: date);

  Future<void> _record({
    required double amount,
    required bool deposit,
    String? note,
    DateTime? date,
  }) async {
    if (amount <= 0) return;
    await _repo.add(amount: amount, deposit: deposit, note: note, date: date);
    await _adjustBalance(deposit ? amount : -amount);
  }

  /// Removes an entry and reverses its effect on the balance.
  Future<void> delete(SavingsEntry entry) async {
    await _adjustBalance(entry.deposit ? -entry.amount : entry.amount);
    await _repo.delete(entry.id);
  }

  Future<void> _adjustBalance(double delta) async {
    final profile = _ref.read(profileProvider);
    final next = profile.currentSavings + delta;
    await _ref
        .read(profileProvider.notifier)
        .save(profile.copyWith(currentSavings: next < 0 ? 0 : next));
  }
}

final savingsActionsProvider =
    Provider<SavingsActions>((ref) => SavingsActions(ref));
