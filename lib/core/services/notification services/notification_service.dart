import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FirebaseMessaging messaging =
      FirebaseMessaging.instance;

  static final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  // Initialize FCM
  static Future<void> initialize() async {
    // Ask notification permission
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Subscribe all users to broadcast topic
    if (!kIsWeb) {
      await messaging.subscribeToTopic('all_users');
    }

    // Receive notification while app is open
    FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) {
        print('Notification received');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
      },
    );
  }

  // Save current user's FCM token
  static Future<void> saveUserToken() async {
    final user = FirebaseAuth.instance.currentUser;

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
        .update({
      'fcmToken': token,
    });

    print('FCM token saved');
  }

  // Update token if Firebase changes it
  static void listenForTokenRefresh() {
    messaging.onTokenRefresh.listen(
          (newToken) async {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          return;
        }

        await firestore
            .collection('users')
            .doc(user.uid)
            .update({
          'fcmToken': newToken,
        });

        print('FCM token updated');
      },
    );
  }
}