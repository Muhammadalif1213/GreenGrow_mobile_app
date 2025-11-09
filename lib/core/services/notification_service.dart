import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize(BuildContext context) async {
    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _localNotifications.initialize(
      initializationSettings,
      // onSelectNotification sudah deprecated, gunakan onDidReceiveNotificationResponse
      onDidReceiveNotificationResponse:
          (NotificationResponse response) async {},
    );
    // Tambahkan ini:
    getFcmToken();

    // FCM foreground handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'Notifikasi',
              channelDescription: 'Channel notifikasi default',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }

  static Future<String?> getFcmToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $token');
    return token;
  }
}
