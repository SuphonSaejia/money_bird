/// App-wide constants, including the native identifiers shared with the
/// home-screen widget and notification plumbing.
class AppConstants {
  AppConstants._();

  // Native identifiers (must match android/ + ios/ native config).
  static const String iosAppGroupId = 'group.com.example.moneyBird';
  static const String androidWidgetProvider =
      'com.example.money_bird.MoneyBirdWidgetProvider';
  static const String iosWidgetKind = 'MoneyBirdWidget';

  // Keys for data shared with the home-screen widget.
  static const String wkScore = 'mb_score';
  static const String wkBand = 'mb_band';
  static const String wkSpentToday = 'mb_spent_today';
  static const String wkTitle = 'mb_title';
  static const String wkSpentLabel = 'mb_spent_label';
  static const String wkTapHint = 'mb_tap_hint';

  // Notifications.
  static const String reminderChannelId = 'daily_reminders';
  static const int reminderNotificationId = 1001;
  static const int summaryNotificationId = 1002;
}
