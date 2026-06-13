import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../core/constants/app_constants.dart';

/// Wraps `flutter_local_notifications` for the daily "log your spending"
/// reminder. Localised copy is passed in by the caller (which has access to
/// the current locale), so the notification text matches the app language.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: darwin),
    );
    _ready = true;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  /// Asks the OS for notification permission. Returns true if granted. Also
  /// makes sure exact alarms are allowed so the reminder fires on time (on
  /// Android 12/14 this may open the system "Alarms & reminders" screen).
  Future<bool> requestPermissions() async {
    await init();
    final android = _android;
    final androidGranted = await android?.requestNotificationsPermission();
    if (android != null) {
      final canExact = await android.canScheduleExactNotifications();
      if (canExact == false) {
        await android.requestExactAlarmsPermission();
      }
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    return (androidGranted ?? true) && (iosGranted ?? true);
  }

  NotificationDetails _details(String channelName, String channelDesc,
      {Importance importance = Importance.high}) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        AppConstants.reminderChannelId,
        channelName,
        channelDescription: channelDesc,
        importance: importance,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  /// Schedules (or replaces) the recurring daily reminder at [hour]:[minute].
  ///
  /// Prefers an exact alarm so it fires on time; if exact alarms aren't
  /// permitted it falls back to an inexact one (which Android may delay) rather
  /// than failing, so the user still gets reminders.
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String channelName,
    required String channelDesc,
  }) async {
    await init();
    await _plugin.cancel(id: AppConstants.reminderNotificationId);

    final canExact = await _android?.canScheduleExactNotifications() ?? true;
    final mode = canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    Future<void> schedule(AndroidScheduleMode scheduleMode) {
      return _plugin.zonedSchedule(
        id: AppConstants.reminderNotificationId,
        title: title,
        body: body,
        scheduledDate: _nextInstanceOf(hour, minute),
        notificationDetails: _details(channelName, channelDesc),
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    try {
      await schedule(mode);
    } on Exception {
      // "exact_alarms_not_permitted" (revoked between the check and the call) —
      // retry inexact so reminders still work.
      if (mode == AndroidScheduleMode.exactAllowWhileIdle) {
        await schedule(AndroidScheduleMode.inexactAllowWhileIdle);
      } else {
        rethrow;
      }
    }
  }

  Future<void> cancelReminder() async {
    await init();
    await _plugin.cancel(id: AppConstants.reminderNotificationId);
  }

  /// Fires an immediate "today's spending wrap-up" notification.
  Future<void> showDailySummary({
    required String title,
    required String body,
    required String channelName,
    required String channelDesc,
  }) async {
    await init();
    await _plugin.show(
      id: AppConstants.summaryNotificationId,
      title: title,
      body: body,
      notificationDetails:
          _details(channelName, channelDesc, importance: Importance.defaultImportance),
    );
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
