import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


// FCM background
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp();

  print('Background FCM received');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
}


class NotificationService {
  static final messaging = FirebaseMessaging.instance;
  static final firestore = FirebaseFirestore.instance;
  static final localNotifications =
      FlutterLocalNotificationsPlugin();


  // Initialize
  static Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(
      tz.getLocation('Asia/Karachi'),
    );

    await initializeLocalNotifications();
    await requestNotificationPermission();
    await subscribeToAllUsers();

    listenForForegroundMessages();
  }


  // Local notification initialize
  static Future<void> initializeLocalNotifications() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      ),
    );

    await localNotifications.initialize(settings);
  }


  // FCM permission
  static Future<void> requestNotificationPermission() async {
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final android =
        localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    await android?.requestNotificationsPermission();
  }


  // FCM topic
  static Future<void> subscribeToAllUsers() async {
    await messaging.subscribeToTopic('all_users');
  }


  // FCM foreground
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


  // Show notification
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'bus_reminders',
        'Bus Reminders',
        channelDescription: 'Bus notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    await localNotifications.show(
      DateTime.now()
          .millisecondsSinceEpoch
          .remainder(2147483647),
      title,
      body,
      details,
    );
  }


  // Save FCM token
  static Future<void> saveUserToken() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final token = await messaging.getToken();

    if (token == null) return;

    await firestore
        .collection('users')
        .doc(user.uid)
        .set(
      {'fcmToken': token},
      SetOptions(merge: true),
    );
  }


  // Token refresh
  static void listenForTokenRefresh() {
    messaging.onTokenRefresh.listen(
      (newToken) async {
        final user =
            FirebaseAuth.instance.currentUser;

        if (user == null) return;

        await firestore
            .collection('users')
            .doc(user.uid)
            .set(
          {'fcmToken': newToken},
          SetOptions(merge: true),
        );
      },
    );
  }

  // Schedule reminder
  static Future<void> scheduleReminder({
    required int id,
    required DateTime reminderTime,
    required String busNumber,
    required String route,
  }) async {
    final scheduledDate =
        tz.TZDateTime.from(
      reminderTime,
      tz.local,
    );

    final now = tz.TZDateTime.now(tz.local);

    if (scheduledDate.isBefore(now)) {
      throw Exception(
        'Reminder time has already passed',
      );
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'bus_reminders',
        'Bus Reminders',
        channelDescription:
            'Bus reminder notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    await localNotifications.zonedSchedule(
      id,
      'Bus Reminder 🚌',
      'Bus $busNumber: $route',
      scheduledDate,
      details,
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Cancel one
  static Future<void> cancelReminder(int id) async {
    await localNotifications.cancel(id);
  }

  // Cancel all
  static Future<void> cancelAllNotifications() async {
    await localNotifications.cancelAll();
  }
}