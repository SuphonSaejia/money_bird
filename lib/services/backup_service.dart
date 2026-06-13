import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/db/database.dart';
import '../data/models/financial_profile.dart';
import '../data/models/transaction_type.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/settings_repository.dart';

/// Why a restore failed, mapped to a localized message by the UI.
enum BackupError { notMoneyBird, unsupportedVersion, corrupt }

class BackupException implements Exception {
  const BackupException(this.error);
  final BackupError error;
}

/// Result of a successful restore — what got brought back.
class RestoreSummary {
  const RestoreSummary({required this.transactions, required this.budgets});
  final int transactions;
  final int budgets;
}

/// Exports and restores all of the user's on-device data as a single JSON
/// document, so they can move devices or recover after a reinstall.
///
/// The payload is versioned ([_backupVersion]) independently of the Drift
/// schema so the format can evolve. Restore is **replace-all**: it wipes the
/// current transactions/budgets and writes the backup's, then overwrites the
/// profile and preferences (onboarding state is left untouched).
class BackupService {
  BackupService({
    required AppDatabase db,
    required ProfileRepository profileRepository,
    required SettingsRepository settingsRepository,
  })  : _db = db,
        _profiles = profileRepository,
        _settings = settingsRepository;

  final AppDatabase _db;
  final ProfileRepository _profiles;
  final SettingsRepository _settings;

  static const int _backupVersion = 1;
  static const String _appTag = 'money_bird';

  /// Builds the full backup document as a pretty-printed JSON string.
  Future<String> buildJson({DateTime? now}) async {
    final txns = await _db.getAllTransactions();
    final budgets = await _db.getAllBudgets();

    final map = <String, dynamic>{
      'app': _appTag,
      'backupVersion': _backupVersion,
      'schemaVersion': _db.schemaVersion,
      'exportedAt': (now ?? DateTime.now()).toIso8601String(),
      'profile': _profiles.load().toMap(),
      'settings': _settings.exportMap(),
      'budgets': [
        for (final b in budgets)
          {'categoryId': b.categoryId, 'amount': b.amount},
      ],
      'transactions': [
        for (final t in txns)
          {
            'id': t.id,
            'amount': t.amount,
            'type': t.type.name,
            'categoryId': t.categoryId,
            'note': t.note,
            'date': t.date.toIso8601String(),
            'createdAt': t.createdAt.toIso8601String(),
          },
      ],
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  /// Writes a backup to a temp file ready to hand to the share sheet. Returns
  /// the file; the name embeds the date, e.g. `money_bird_backup_2026-06-13.json`.
  Future<File> exportToFile({DateTime? now}) async {
    final stamp = now ?? DateTime.now();
    final json = await buildJson(now: stamp);
    final dir = await getTemporaryDirectory();
    final name =
        'money_bird_backup_${stamp.toIso8601String().split('T').first}.json';
    final file = File(p.join(dir.path, name));
    return file.writeAsString(json);
  }

  /// Validates and applies a backup document. Throws [BackupException] on any
  /// problem (the data store is left untouched on failure).
  Future<RestoreSummary> restoreFromJson(String source) async {
    final Map<String, dynamic> map;
    try {
      map = jsonDecode(source) as Map<String, dynamic>;
    } catch (_) {
      throw const BackupException(BackupError.corrupt);
    }

    if (map['app'] != _appTag) {
      throw const BackupException(BackupError.notMoneyBird);
    }
    final version = (map['backupVersion'] as num?)?.toInt();
    if (version == null) throw const BackupException(BackupError.corrupt);
    if (version > _backupVersion) {
      throw const BackupException(BackupError.unsupportedVersion);
    }

    final List<TransactionsCompanion> txns;
    final List<BudgetsCompanion> budgetRows;
    try {
      txns = _parseTransactions(map['transactions']);
      budgetRows = _parseBudgets(map['budgets']);
    } catch (_) {
      throw const BackupException(BackupError.corrupt);
    }

    // Apply: DB first (atomic), then the SharedPreferences-backed stores.
    await _db.replaceAll(txns: txns, budgetRows: budgetRows);

    if (map['profile'] is Map) {
      await _profiles.save(
        FinancialProfile.fromMap(
          (map['profile'] as Map).cast<String, dynamic>(),
        ),
      );
    }
    if (map['settings'] is Map) {
      await _settings.importMap((map['settings'] as Map).cast<String, dynamic>());
    }

    return RestoreSummary(transactions: txns.length, budgets: budgetRows.length);
  }

  List<TransactionsCompanion> _parseTransactions(Object? raw) {
    if (raw == null) return const [];
    final list = raw as List;
    return [
      for (final item in list)
        () {
          final m = (item as Map).cast<String, dynamic>();
          return TransactionsCompanion.insert(
            id: m['id'] as String,
            amount: (m['amount'] as num).toDouble(),
            type: _typeFromName(m['type']),
            categoryId: m['categoryId'] as String,
            note: Value(m['note'] as String?),
            date: DateTime.parse(m['date'] as String),
            createdAt: m['createdAt'] is String
                ? Value(DateTime.parse(m['createdAt'] as String))
                : const Value.absent(),
          );
        }(),
    ];
  }

  List<BudgetsCompanion> _parseBudgets(Object? raw) {
    if (raw == null) return const [];
    final list = raw as List;
    return [
      for (final item in list)
        () {
          final m = (item as Map).cast<String, dynamic>();
          return BudgetsCompanion.insert(
            categoryId: m['categoryId'] as String,
            amount: (m['amount'] as num).toDouble(),
          );
        }(),
    ];
  }

  static TransactionType _typeFromName(Object? name) {
    return TransactionType.values.firstWhere(
      (t) => t.name == name,
      orElse: () => TransactionType.expense,
    );
  }
}
