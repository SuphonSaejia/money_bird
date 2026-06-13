// Round-trip + validation tests for the backup/restore service, using an
// in-memory Drift database and mocked SharedPreferences.

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:money_bird/data/db/database.dart';
import 'package:money_bird/data/models/financial_profile.dart';
import 'package:money_bird/data/models/transaction_type.dart';
import 'package:money_bird/data/repositories/profile_repository.dart';
import 'package:money_bird/data/repositories/settings_repository.dart';
import 'package:money_bird/domain/budget.dart';
import 'package:money_bird/services/backup_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SharedPreferences prefs;
  late ProfileRepository profiles;
  late SettingsRepository settings;
  late BackupService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    db = AppDatabase(NativeDatabase.memory());
    profiles = ProfileRepository(prefs);
    settings = SettingsRepository(prefs);
    service = BackupService(
      db: db,
      profileRepository: profiles,
      settingsRepository: settings,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('export then restore round-trips all data', () async {
    await db.upsertTransaction(TransactionsCompanion.insert(
      id: 'a',
      amount: 120,
      type: TransactionType.expense,
      categoryId: 'food',
      note: const Value('Lunch'),
      date: DateTime(2026, 6, 10),
    ));
    await db.upsertBudget(overallBudgetId, 20000);
    await db.upsertBudget('food', 6000);
    await profiles.save(
        const FinancialProfile(monthlyIncome: 50000, fixedExpenses: 20000));
    await settings.setThemeMode(ThemeMode.dark);
    await settings.setLocaleCode('th');

    final json = await service.buildJson(now: DateTime(2026, 6, 13));

    // Simulate a fresh install: wipe the stores before restoring.
    await db.replaceAll(txns: [], budgetRows: []);
    await profiles.save(FinancialProfile.empty);
    await settings.setThemeMode(ThemeMode.light);
    await settings.setLocaleCode('en');

    final summary = await service.restoreFromJson(json);

    expect(summary.transactions, 1);
    expect(summary.budgets, 2);

    final txns = await db.getAllTransactions();
    expect(txns, hasLength(1));
    expect(txns.single.note, 'Lunch');
    expect(txns.single.amount, 120);
    expect(txns.single.type, TransactionType.expense);

    final budgets = MonthlyBudgets.fromRows(await db.getAllBudgets());
    expect(budgets.overall, 20000);
    expect(budgets.perCategory['food'], 6000);

    expect(profiles.load().monthlyIncome, 50000);
    expect(settings.load().themeMode, ThemeMode.dark);
    expect(settings.load().localeCode, 'th');
  });

  test('rejects malformed JSON', () {
    expect(
      () => service.restoreFromJson('{ not json'),
      throwsA(isA<BackupException>()
          .having((e) => e.error, 'error', BackupError.corrupt)),
    );
  });

  test('rejects a file from another app', () {
    expect(
      () => service.restoreFromJson('{"app":"other","backupVersion":1}'),
      throwsA(isA<BackupException>()
          .having((e) => e.error, 'error', BackupError.notMoneyBird)),
    );
  });

  test('rejects a backup from a newer app version', () {
    expect(
      () => service.restoreFromJson('{"app":"money_bird","backupVersion":999}'),
      throwsA(isA<BackupException>()
          .having((e) => e.error, 'error', BackupError.unsupportedVersion)),
    );
  });

  test('restore leaves data untouched when the payload is corrupt', () async {
    await db.upsertTransaction(TransactionsCompanion.insert(
      id: 'keep',
      amount: 99,
      type: TransactionType.expense,
      categoryId: 'food',
      date: DateTime(2026, 6, 10),
    ));

    await expectLater(
      service.restoreFromJson('{"app":"money_bird","backupVersion":1,'
          '"transactions":"not-a-list"}'),
      throwsA(isA<BackupException>()),
    );

    // The pre-existing row must still be there.
    final txns = await db.getAllTransactions();
    expect(txns.single.id, 'keep');
  });
}
