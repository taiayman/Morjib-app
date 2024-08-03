import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static bool _isRequestingPermission = false;

  Future<void> init() async {
    if (_isRequestingPermission) return;
    _isRequestingPermission = true;

    try {
      // Request permission for iOS devices
      await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Configure FCM
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Initialize local notifications
      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
      final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    } catch (e) {
      print('Failed to request permission: $e');
    } finally {
      _isRequestingPermission = false;
    }
  }

  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print("Handling a foreground message: ${message.messageId}");
    _showNotification(message);
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    print("Handling a background message: ${message.messageId}");
    // Handle background message, e.g., navigate to a specific screen
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'order_updates_channel',
      'Order Updates',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      platformChannelSpecifics,
      payload: message.data['order_id'],
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  // Handle background message, e.g., update local storage
}
