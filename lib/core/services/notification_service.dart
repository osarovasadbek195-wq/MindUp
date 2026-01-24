import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../utils/logger.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      AppLogger.info('Initializing NotificationService...');
      // Timezone ma'lumotlarini yuklash
      tz.initializeTimeZones();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      final bool? initialized = await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          // Bildirishnoma bosilganda
          AppLogger.info('Notification clicked: ${details.payload}');
        },
      );
      
      AppLogger.info('FlutterLocalNotificationsPlugin initialized: $initialized');
      
      // Kanallarni yaratish
      await _createNotificationChannels();
      
      // Android 13+ uchun ruxsat so'rash
      if (Platform.isAndroid) {
        final androidImplementation = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        
        // Android 13+ bildirishnoma ruxsati
        final bool? granted = await androidImplementation?.requestNotificationsPermission();
        AppLogger.info('Android notification permission granted: $granted');
        
        // Android 14+ aniq alarm ruxsati
        if (Platform.isAndroid) {
          final bool? exactAlarmGranted = await androidImplementation?.requestExactAlarmsPermission();
          AppLogger.info('Android exact alarm permission granted: $exactAlarmGranted');
        }
      }
    } catch (e) {
      AppLogger.error('Error initializing NotificationService', error: e);
    }
  }

  Future<void> _createNotificationChannels() async {
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // 1. Study Reminders Channel
      const AndroidNotificationChannel studyChannel = AndroidNotificationChannel(
        'mindup_study_channel',
        'Study Reminders',
        description: 'Reminders for spaced repetition reviews',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      // 2. Daily Reminders Channel
      const AndroidNotificationChannel dailyChannel = AndroidNotificationChannel(
        'mindup_daily_channel',
        'Daily Reminders',
        description: 'Daily study reminders',
        importance: Importance.max,
        playSound: true,
      );

      // 3. Flashcard Reviews Channel
      const AndroidNotificationChannel flashcardChannel = AndroidNotificationChannel(
        'mindup_flashcard_channel',
        'Flashcard Reviews',
        description: 'Individual flashcard review reminders',
        importance: Importance.high,
        playSound: true,
      );

      // 4. General Reminder Channel
      const AndroidNotificationChannel reminderChannel = AndroidNotificationChannel(
        'mindup_reminder_channel',
        'General Reminders',
        description: 'General study reminders for MindUp',
        importance: Importance.max,
        playSound: true,
      );

      await androidImplementation.createNotificationChannel(studyChannel);
      await androidImplementation.createNotificationChannel(dailyChannel);
      await androidImplementation.createNotificationChannel(flashcardChannel);
      await androidImplementation.createNotificationChannel(reminderChannel);
      
      AppLogger.info('Notification channels created successfully');
    }
  }

  Future<void> showInstantNotification(String title, String body) async {
    AppLogger.info('Showing notification: $title - $body');
    
    final Int64List vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 500;
    vibrationPattern[3] = 1000;
    
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'mindup_channel_id',
      'MindUp Notifications',
      channelDescription: 'Study reminders for MindUp',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: vibrationPattern,
    );
    
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
        
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
    
    AppLogger.info('Notification sent!');
  }

  /// Har kuni belgilangan vaqtda eslatma qo'yish
  Future<void> scheduleDailyReminder(int id, String title, String body, TimeOfDay time) async {
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfTime(time),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'mindup_daily_channel',
            'Daily Reminders',
            channelDescription: 'Daily study reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Har kuni shu vaqtda
      );
      AppLogger.info('Daily reminder scheduled for $time');
    } catch (e) {
      AppLogger.error('Error scheduling daily reminder', error: e);
    }
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
  
  /// 3 soatdan keyin notification yuborish
  Future<void> scheduleNotificationIn3Hours(int id, String title, String body) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = now.add(const Duration(hours: 3));
      
      AppLogger.info('Scheduling notification for: $scheduledDate');
      
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'mindup_reminder_channel',
            'Study Reminders',
            channelDescription: 'Study reminders for MindUp',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      
      AppLogger.info('Notification in 3 hours scheduled successfully');
    } catch (e) {
      AppLogger.error('Error scheduling 3 hour notification', error: e);
    }
  }

  /// Aniq bir vaqtda notification rejalashtirish
  Future<void> scheduleNotification(int id, String title, String body, DateTime scheduledTime) async {
    try {
      if (scheduledTime.isBefore(DateTime.now())) {
        AppLogger.warning('Scheduled time $scheduledTime is in the past, scheduling for 1 minute from now');
        scheduledTime = DateTime.now().add(const Duration(minutes: 1));
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'mindup_study_channel',
            'Study Reminders',
            channelDescription: 'Reminders for spaced repetition reviews',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      AppLogger.info('Notification scheduled for $scheduledTime');
    } catch (e) {
      AppLogger.error('Error scheduling notification', error: e);
    }
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Bir nechta flashcard notificationlarini rejalashtirish
  Future<void> scheduleFlashcardNotifications(List<Map<String, dynamic>> flashcards) async {
    AppLogger.info('Scheduling ${flashcards.length} flashcard notifications...');
    
    for (int i = 0; i < flashcards.length; i++) {
      final flashcard = flashcards[i];
      final id = flashcard['id'] as int;
      final title = flashcard['title'] as String;
      final body = flashcard['body'] as String;
      final scheduledTime = flashcard['scheduledTime'] as DateTime;
      
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'mindup_flashcard_channel',
            'Flashcard Reviews',
            channelDescription: 'Individual flashcard review reminders',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(
              '',
              htmlFormatBigText: true,
              contentTitle: '',
              htmlFormatContentTitle: true,
            ),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
    
    AppLogger.info('Flashcard notifications scheduled!');
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }
}
