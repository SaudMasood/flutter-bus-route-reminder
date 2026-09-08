import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FirebaseMessaging messaging =
      FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Ask notification permission
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (!kIsWeb) {
      await FirebaseMessaging.instance.subscribeToTopic('all_users');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notification received');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
    });
  }
}