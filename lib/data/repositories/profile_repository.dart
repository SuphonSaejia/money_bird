import 'package:shared_preferences/shared_preferences.dart';

import '../models/financial_profile.dart';

/// Persists the user's [FinancialProfile] (the onboarding answers) as JSON in
/// [SharedPreferences].
class ProfileRepository {
  ProfileRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _kProfile = 'profile.financial';

  FinancialProfile load() {
    final raw = _prefs.getString(_kProfile);
    if (raw == null || raw.isEmpty) return FinancialProfile.empty;
    try {
      return FinancialProfile.fromJson(raw);
    } catch (_) {
      return FinancialProfile.empty;
    }
  }

  Future<void> save(FinancialProfile profile) =>
      _prefs.setString(_kProfile, profile.toJson());
}
