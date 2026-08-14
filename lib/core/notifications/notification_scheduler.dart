import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Schedules daily push reminders for stale projects and ideas.
///
/// Uses flutter_local_notifications with the exact alarm channel.
/// Call [NotificationScheduler.init] once at app start in main.dart.
class NotificationScheduler {
  static final _log = Logger();
  static final _notifications = FlutterLocalNotificationsPlugin();

  static const _channelId = 'pariyojana_reminders';
  static const _channelName = 'Pariyojana Reminders';
  static const _channelDesc = 'Daily focus reminders and stale project alerts.';

  static const int _dailyReminderNotifId = 1001;
  static const int _staleProjectNotifId = 1002;

  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(initSettings);

    // Request exact alarm permission (Android 12+)
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _scheduleDailyReminder();
  }

  static Future<void> _scheduleDailyReminder() async {
    try {
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      );
      const details = NotificationDetails(android: androidDetails);

      // Daily reminder at 9:00 AM local time
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, 9);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        _dailyReminderNotifId,
        '📋 How\'s your Pariyojana today?',
        'Check your ideas vault and active projects.',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      _log.i('[NotificationScheduler] Daily reminder scheduled at 09:00.');
    } catch (e) {
      _log.w('[NotificationScheduler] Failed to schedule reminder: $e');
    }
  }

  /// Show an immediate "stale project" notification.
  /// Call when a project hasn't been updated in 7+ days.
  static Future<void> showStaleProjectAlert(String projectName) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.low,
        priority: Priority.low,
      );
      await _notifications.show(
        _staleProjectNotifId,
        '⏰ Stale Project: $projectName',
        'No updates in 7 days. Tap to review.',
        const NotificationDetails(android: androidDetails),
      );
    } catch (e) {
      _log.w('[NotificationScheduler] showStaleProjectAlert failed: $e');
    }
  }
}
