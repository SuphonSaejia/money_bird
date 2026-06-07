import 'package:flutter/material.dart';

/// Immutable snapshot of the user's app-level preferences.
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.localeCode = 'system',
    this.onboardingComplete = false,
    this.reminderEnabled = true,
    this.reminderHour = 20,
    this.reminderMinute = 0,
  });

  final ThemeMode themeMode;

  /// 'system' | 'en' | 'th'.
  final String localeCode;
  final bool onboardingComplete;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;

  /// Null means "follow the device locale".
  Locale? get locale => localeCode == 'system' ? null : Locale(localeCode);

  TimeOfDay get reminderTime =>
      TimeOfDay(hour: reminderHour, minute: reminderMinute);

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? localeCode,
    bool? onboardingComplete,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      localeCode: localeCode ?? this.localeCode,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
    );
  }
}
