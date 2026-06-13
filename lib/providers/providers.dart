import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/db/database.dart';
import '../data/models/app_settings.dart';
import '../data/models/financial_profile.dart';
import '../data/models/transaction_type.dart';
import '../data/repositories/budget_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../domain/budget.dart';
import '../domain/financial_health.dart';
import '../domain/goal_plan.dart';
import '../domain/month_summary.dart';
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
