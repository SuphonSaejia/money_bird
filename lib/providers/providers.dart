import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/db/database.dart';
import '../data/models/app_settings.dart';
import '../data/models/financial_profile.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../domain/financial_health.dart';
import '../domain/goal_plan.dart';
import '../domain/month_summary.dart';

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

/// The composite financial-health snapshot — single source of truth for the
/// home diagram, the widget and the share card.
final financialHealthProvider = Provider<FinancialHealth>((ref) {
  final profile = ref.watch(profileProvider);
  final summary = ref.watch(monthSummaryProvider);
  return FinancialHealth.compute(
    profile: profile,
    spentThisMonth: summary.expense,
    now: DateTime.now(),
  );
});

/// The savings-goal plan derived from the user's profile — works for any goal
/// type (retirement uses the 4% rule; others use a user-set target + year).
final goalPlanProvider = Provider<GoalPlan>((ref) {
  return GoalPlan.from(ref.watch(profileProvider), nowYear: DateTime.now().year);
});
