import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FirebaseMessaging messaging =
      FirebaseMessaging.instance;

  static final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  static final FlutterLocalNotificationsPlugin localNotifications =
  FlutterLocalNotificationsPlugin();

  // =========================
  // NOTIFICATION CHANNELS
  // =========================

  static const AndroidNotificationChannel notificationChannel =
  AndroidNotificationChannel(
    'bus_notifications',
    'Bus Notifications',
    description: 'Notifications for new bus routes',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel reminderChannel =
  AndroidNotificationChannel(
    'bus_reminders',
    'Bus Reminders',
    description: 'Bus reminder notifications',
    importance: Importance.high,
  );

  // =========================
  // INITIALIZE
  // =========================

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    tz.setLocalLocation(
      tz.getLocation('Asia/Karachi'),
    );

    await initializeLocalNotifications();

    await requestNotificationPermission();

    await requestExactAlarmPermission();

    await createNotificationChannels();

    await subscribeToAllUsers();

    listenForForegroundMessages();
  }

  // =========================
  // LOCAL NOTIFICATION INIT
  // =========================

  static Future<void> initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await localNotifications.initialize(
      settings,
    );
  }

  // =========================
  // NOTIFICATION PERMISSION
  // =========================

  static Future<void> requestNotificationPermission() async {
    if (kIsWeb) {
      return;
    }

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final androidPlugin =
    localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
  }

  // =========================
  // EXACT ALARM PERMISSION
  // =========================

  static Future<void> requestExactAlarmPermission() async {
    if (kIsWeb) {
      return;
    }

    final androidPlugin =
    localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestExactAlarmsPermission();
  }

  // =========================
  // CREATE CHANNELS
  // =========================

  static Future<void> createNotificationChannels() async {
    if (kIsWeb) {
      return;
    }

    final androidPlugin =
    localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      notificationChannel,
    );

    await androidPlugin?.createNotificationChannel(
      reminderChannel,
    );
  }

  // =========================
  // SUBSCRIBE ALL USERS
  // =========================

  static Future<void> subscribeToAllUsers() async {
    if (kIsWeb) {
      return;
    }

    await messaging.subscribeToTopic(
      'all_users',
    );
  }

  // =========================
  // FOREGROUND FCM
  // =========================

  static void listenForForegroundMessages() {
    FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) async {
        final title =
            message.notification?.title ?? 'Notification';

        final body =
            message.notification?.body ?? '';

        await showNotification(
          title: title,
          body: body,
        );
      },
    );
  }

  // =========================
  // SHOW FCM NOTIFICATION
  // =========================

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'bus_notifications',
      'Bus Notifications',
      channelDescription:
      'Notifications for new bus routes',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  // SAVE FCM TOKEN

  static Future<void> saveUserToken() async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final token = await messaging.getToken();

    if (token == null) {
      return;
    }

    await firestore
        .collection('users')
        .doc(user.uid)
        .set(
      {
        'fcmToken': token,
      },
      SetOptions(merge: true),
    );
  }


  // TOKEN REFRESH

  static void listenForTokenRefresh() {
    messaging.onTokenRefresh.listen(
          (newToken) async {
        final user =
            FirebaseAuth.instance.currentUser;

        if (user == null) {
          return;
        }

        await firestore
            .collection('users')
            .doc(user.uid)
            .set(
          {
            'fcmToken': newToken,
          },
          SetOptions(merge: true),
        );
      },
    );
  }

  // SCHEDULE BUS REMINDER


  static Future<void> scheduleReminder({
    required int id,
    required DateTime reminderTime,
    required String busNumber,
    required String route,
  }) async {
    final scheduledDate = tz.TZDateTime.from(
      reminderTime,
      tz.local,
    );

    final now = tz.TZDateTime.now(
      tz.local,
    );

    if (scheduledDate.isBefore(now)) {
      throw Exception(
        'Reminder time has already passed',
      );
    }

    const androidDetails =
    AndroidNotificationDetails(
      'bus_reminders',
      'Bus Reminders',
      channelDescription:
      'Bus reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const notificationDetails =
    NotificationDetails(
      android: androidDetails,
    );

    await localNotifications.zonedSchedule(
      id,
      'Bus Reminder 🚌',
      'Bus $busNumber: $route',
      scheduledDate,
      notificationDetails,
      androidScheduleMode:
      AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // CANCEL ONE REMINDER


  static Future<void> cancelReminder(
      int id,
      ) async {
    await localNotifications.cancel(id);
  }

  // CANCEL ALL

  static Future<void> cancelAllNotifications() async {
    await localNotifications.cancelAll();
  }
}