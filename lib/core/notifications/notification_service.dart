import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

import 'package:audioplayers/audioplayers.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  service.initialize();
  return service;
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();

  NotificationService();

  /// Plays category-specific Pariyojana audio chimes
  Future<void> _playToneDirect([String toneAsset = 'sounds/tone_daily_digest.wav']) async {
    try {
      await _audioPlayer.setAudioContext(AudioContext(
        android: const AudioContextAndroid(
          usageType: AndroidUsageType.alarm,
          contentType: AndroidContentType.music,
          audioFocus: AndroidAudioFocus.gainTransient,
        ),
      ));
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(toneAsset));
    } catch (_) {
      try {
        await _audioPlayer.play(AssetSource('sounds/notification.wav'));
      } catch (_) {}
    }
  }

  Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName =
          tzInfo.identifier.isNotEmpty ? tzInfo.identifier : 'Asia/Kolkata';
      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
      }
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap / deep-link
      },
    );
  }

  Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _localNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String toneAsset = 'sounds/tone_daily_digest.wav',
  }) async {
    // Play custom audio chime
    unawaited(_playToneDirect(toneAsset));

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'pariyojana_alerts_v5',
      'Pariyojana High Priority Alerts',
      channelDescription: 'Workspace status updates, follow-up nudges, and stale item alerts',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification_tone'),
      audioAttributesUsage: AudioAttributesUsage.alarm,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      actions: [
        const AndroidNotificationAction('action_open', '🚀 Open App', showsUserInterface: true),
        const AndroidNotificationAction('action_bookmark', '🔖 Bookmark', showsUserInterface: false),
      ],
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _localNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }


  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pariyojana_scheduled_v4',
      'Pariyojana Scheduled Alerts',
      channelDescription: 'Daily scheduled projects, research paper, and job application nudges',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification_tone'),
      audioAttributesUsage: AudioAttributesUsage.alarm,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
    );

    await _localNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> refreshDailySchedules({
    required String username,
    required List<String> activeProjectNames,
    List<String> recentIdeaTitles = const [],
    List<String> researchPaperTitles = const [],
    List<String> jobTargetTitles = const [],
    required bool hasUnpublishedPapers,
    required bool hasActiveJobs,
    int startHour = 9,
    int endHour = 22,
    int dailyFrequency = 3,
    int exactMinute = 0,
    dynamic agentGateway,
  }) async {
    // Cancel previous legacy notification IDs
    for (int i = 1001; i <= 1006; i++) {
      try { await _localNotificationsPlugin.cancel(i); } catch (_) {}
    }
    for (int i = 2001; i <= 2024; i++) {
      try { await _localNotificationsPlugin.cancel(i); } catch (_) {}
    }
    for (int h = 0; h < 24; h++) {
      try { await _localNotificationsPlugin.cancel(3000 + h); } catch (_) {}
    }

    final activeProjStr = activeProjectNames.isNotEmpty ? activeProjectNames.first : 'your active project';
    final activeIdeaStr = recentIdeaTitles.isNotEmpty ? recentIdeaTitles.first : 'your recent idea';
    final activePaperStr = researchPaperTitles.isNotEmpty ? researchPaperTitles.first : 'your research paper';
    final activeJobStr = jobTargetTitles.isNotEmpty ? jobTargetTitles.first : 'your job application';

    // Compute distributed target hours based on dailyFrequency (1 to 12)
    final List<int> targetHours = _computeDistributedHours(
      count: dailyFrequency,
      startHour: startHour,
      endHour: endHour,
    );

    List<Map<String, String>> hourlyMessages = [];

    // Attempt to use AI via agentGateway if configured
    if (agentGateway != null) {
      try {
        final prompt = 'You are a productivity assistant for the Pariyojana workspace app. '
            'Generate exactly 16 notification title and body pairs. '
            'RULES: Every message MUST reference specific item names from this workspace: '
            'Project: "$activeProjStr", Idea: "$activeIdeaStr", Research: "$activePaperStr", Job: "$activeJobStr". '
            'Keep the tone professional, motivational, and focused on productivity. '
            'Do NOT use any fictional characters, brand names, or copyrighted references. '
            'Return ONLY a JSON array of 16 objects: [{"title": "Title", "body": "Body"}]';

        final responseStr = await agentGateway.dispatchPrompt(prompt);
        final jsonStart = responseStr.indexOf('[');
        final jsonEnd = responseStr.lastIndexOf(']');
        if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
          final jsonSub = responseStr.substring(jsonStart, jsonEnd + 1);
          final parsed = (jsonDecode(jsonSub) as List<dynamic>);
          for (final item in parsed) {
            if (item is Map<String, dynamic> && item.containsKey('title') && item.containsKey('body')) {
              hourlyMessages.add({
                'title': item['title'].toString(),
                'body': item['body'].toString(),
              });
            }
          }
        }
      } catch (_) {}
    }

    // ── Fallback: original productivity nudges (no copyrighted characters) ──
    final Map<int, Map<String, String>> timeMatchedPool = {
      9:  {'title': '🌅 Morning Focus — 9:00 AM', 'body': 'Good morning, $username! Start strong — "$activeProjStr" is waiting for your focus today.'},
      10: {'title': '💡 Idea Check — 10:00 AM', 'body': 'Hey $username! Don\'t let great ideas slip away — review "$activeIdeaStr" in the Vault.'},
      11: {'title': '🔬 Research Spotlight — 11:00 AM', 'body': 'Mid-morning check: How\'s "$activePaperStr" progressing? Add your latest notes now.'},
      12: {'title': '🎯 Midday Sync — 12:00 PM', 'body': 'Halfway through the day! "$activeJobStr" follow-up status — have you reached out yet?'},
      13: {'title': '⚡ Afternoon Push — 1:00 PM', 'body': '$username, keep the momentum going on "$activeProjStr". Small steps build big things.'},
      14: {'title': '🔁 Idea Refresh — 2:00 PM', 'body': 'Two PM check-in: Any updates to "$activeIdeaStr"? Capture your thoughts before they fade.'},
      15: {'title': '📄 Research Review — 3:00 PM', 'body': 'Time to review "$activePaperStr". Stay ahead of your research milestones.'},
      16: {'title': '📋 Career Pulse — 4:00 PM', 'body': '$username, check your outreach status for "$activeJobStr". Consistent follow-up wins.'},
      17: {'title': '🏁 Evening Sprint — 5:00 PM', 'body': 'Final push on "$activeProjStr" before end of day. What can you complete in the next hour?'},
      18: {'title': '🧠 Knowledge Capture — 6:00 PM', 'body': 'Evening debrief: Log any insights from today into "$activeIdeaStr" or the Vault.'},
      19: {'title': '📊 Progress Log — 7:00 PM', 'body': 'Update your research log for "$activePaperStr". Consistent progress beats bursts.'},
      20: {'title': '💼 Job Tracker Update — 8:00 PM', 'body': 'Review your pipeline for "$activeJobStr". Is your follow-up scheduled?'},
      21: {'title': '🌙 Night Review — 9:00 PM', 'body': 'Great work today, $username! Log any last updates on "$activeProjStr" before you wind down.'},
      22: {'title': '🔒 Vault Secure — 10:00 PM', 'body': 'Your ideas are encrypted and safe. Review "$activeIdeaStr" one last time tonight.'},
      23: {'title': '📝 Day-End Notes — 11:00 PM', 'body': 'Before you sleep — add a quick note to "$activePaperStr". Tomorrow\'s you will thank you.'},
      0:  {'title': '🌌 Midnight Checkpoint — 12:00 AM', 'body': 'Late night, $username. "$activeJobStr" is in your pipeline. Rest up and tackle it fresh tomorrow.'},
    };

    for (final h in targetHours) {
      if (timeMatchedPool.containsKey(h)) {
        hourlyMessages.add(timeMatchedPool[h]!);
      }
    }

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pariyojana_hourly_v4',
      'Pariyojana Hourly Nudges',
      channelDescription: 'Smart productivity nudges based on your selected frequency',
      importance: Importance.max,
      priority: Priority.max,
      tag: 'pariyojana_daily_nudge',
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification_tone'),
      audioAttributesUsage: AudioAttributesUsage.alarm,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 400, 150, 400]),
    );

    // Schedule hourly notifications using device local timezone
    tz.Location scheduleLocation;
    try {
      scheduleLocation = tz.local;
    } catch (_) {
      scheduleLocation = tz.UTC;
    }

    for (int i = 0; i < targetHours.length && i < hourlyMessages.length; i++) {
      final hour = targetHours[i];
      final msg = hourlyMessages[i];
      final minute = (dailyFrequency == 1 && i == 0) ? exactMinute : 0;

      final tz.TZDateTime nowLocal = tz.TZDateTime.now(scheduleLocation);
      var scheduledDate = tz.TZDateTime(scheduleLocation, nowLocal.year, nowLocal.month, nowLocal.day, hour, minute);
      if (scheduledDate.isBefore(nowLocal)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final int notifId = 3000 + hour;

      try {
        await _localNotificationsPlugin.zonedSchedule(
          notifId,
          msg['title']!,
          msg['body']!,
          scheduledDate,
          NotificationDetails(android: androidDetails),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } catch (_) {}
    }
  }

  static List<int> _computeDistributedHours({
    required int count,
    int startHour = 9,
    int endHour = 22,
  }) {
    final clamped = count.clamp(1, 12);
    if (clamped == 1) return [9];
    if (clamped == 2) return [9, 20];
    if (clamped == 3) return [9, 14, 20];
    if (clamped == 4) return [9, 13, 17, 21];

    final int span = (endHour >= startHour) ? (endHour - startHour) : (24 - startHour + endHour);
    final double step = (clamped > 1) ? span / (clamped - 1) : span.toDouble();
    final List<int> result = [];
    for (int i = 0; i < clamped; i++) {
      final int h = ((startHour + (i * step).round()) % 24);
      if (!result.contains(h)) {
        result.add(h);
      }
    }
    return result;
  }

  /// Schedule a custom scheduled local notification for a specific idea in Idea Vault.
  Future<void> scheduleIdeaReminder({
    required int ideaId,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    bool isRecurring = false,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pariyojana_idea_reminders_v1',
      'Pariyojana Idea Vault Reminders',
      channelDescription: 'Custom scheduled notifications and reminders for your captured ideas',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification_tone'),
      audioAttributesUsage: AudioAttributesUsage.alarm,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
    );

    tz.Location scheduleLocation;
    try {
      scheduleLocation = tz.local;
    } catch (_) {
      scheduleLocation = tz.UTC;
    }

    final tz.TZDateTime tzScheduled = tz.TZDateTime.from(scheduledDateTime, scheduleLocation);
    final int notifId = 50000 + (ideaId % 10000);

    try {
      await _localNotificationsPlugin.zonedSchedule(
        notifId,
        title,
        body,
        tzScheduled,
        NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: isRecurring ? DateTimeComponents.time : null,
      );
    } catch (e) {
      // Fallback: Immediate alert if exact alarm fails
      await showNotification(
        id: notifId,
        title: title,
        body: body,
      );
    }
  }

  /// Cancel a scheduled idea reminder.
  Future<void> cancelIdeaReminder(int ideaId) async {
    final int notifId = 50000 + (ideaId % 10000);
    await _localNotificationsPlugin.cancel(notifId);
  }
}
