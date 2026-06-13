import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

/// Persists app-level preferences in [SharedPreferences].
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _kTheme = 'settings.themeMode';
  static const _kLocale = 'settings.localeCode';
  static const _kOnboarding = 'settings.onboardingComplete';
  static const _kReminderOn = 'settings.reminderEnabled';
  static const _kReminderHour = 'settings.reminderHour';
  static const _kReminderMinute = 'settings.reminderMinute';

  AppSettings load() {
    return AppSettings(
      themeMode: _themeFromString(_prefs.getString(_kTheme)),
      localeCode: _prefs.getString(_kLocale) ?? 'system',
      onboardingComplete: _prefs.getBool(_kOnboarding) ?? false,
      reminderEnabled: _prefs.getBool(_kReminderOn) ?? true,
      reminderHour: _prefs.getInt(_kReminderHour) ?? 20,
      reminderMinute: _prefs.getInt(_kReminderMinute) ?? 0,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(_kTheme, mode.name);

  Future<void> setLocaleCode(String code) => _prefs.setString(_kLocale, code);

  Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool(_kOnboarding, value);

  Future<void> setReminderEnabled(bool value) =>
      _prefs.setBool(_kReminderOn, value);

  Future<void> setReminderTime(int hour, int minute) async {
    await _prefs.setInt(_kReminderHour, hour);
    await _prefs.setInt(_kReminderMinute, minute);
  }

  /// Serialises the user-facing preferences for a backup. [onboardingComplete]
  /// is deliberately excluded — a restore should never re-trigger onboarding.
  Map<String, dynamic> exportMap() {
    final s = load();
    return {
      'themeMode': s.themeMode.name,
      'localeCode': s.localeCode,
      'reminderEnabled': s.reminderEnabled,
      'reminderHour': s.reminderHour,
      'reminderMinute': s.reminderMinute,
    };
  }

  /// Applies preferences from a backup. Missing keys keep their current value.
  Future<void> importMap(Map<String, dynamic> map) async {
    if (map['themeMode'] is String) {
      await setThemeMode(_themeFromString(map['themeMode'] as String));
    }
    if (map['localeCode'] is String) {
      await setLocaleCode(map['localeCode'] as String);
    }
    if (map['reminderEnabled'] is bool) {
      await setReminderEnabled(map['reminderEnabled'] as bool);
    }
    final hour = (map['reminderHour'] as num?)?.toInt();
    final minute = (map['reminderMinute'] as num?)?.toInt();
    if (hour != null && minute != null) {
      await setReminderTime(hour, minute);
    }
  }

  ThemeMode _themeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
