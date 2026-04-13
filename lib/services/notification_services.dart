import 'package:chakri_info/notifications/notification_model.dart'; // Ensure correct path
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // 1. Request Notification Permission for Android 13+ and iOS
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    }

    // 2. Subscribe user to "all_users" topic by default
    // This allows sending a single message to everyone from Firebase Console
    await _messaging.subscribeToTopic("all_users");

    // 3. Local Notification Setup (Foreground Pop-up)
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle click action when app is in foreground
        debugPrint("Foreground Notification clicked: ${details.payload}");
      },
    );

    // 4. Foreground Message Listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint(
        "Message received in foreground: ${message.notification?.title}",
      );

      // Save notification to Hive Database
      await _saveNotificationToHive(message);

      // Show the popup
      _showLocalNotification(message);
    });

    // 5. Background/Terminated Click Listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("App opened from background notification: ${message.data}");
      // Here you can add logic to navigate to a specific screen based on message.data['type']
    });
  }

  // Helper function to save notification to Hive
  static Future<void> _saveNotificationToHive(RemoteMessage message) async {
    try {
      final box = Hive.box<NotificationModel>('notifications');

      final newNotification = NotificationModel(
        title: message.notification?.title ?? "New Update",
        body: message.notification?.body ?? "",
        dateTime: DateTime.now(),
        category: message.data['category'] ?? 'general', // govt, bank, bcs etc.
        type: message.data['type'] ?? 'single', // single or list
        jobId: message.data['jobId'], // For direct navigation
        isRead: false,
      );

      await box.add(newNotification);
      debugPrint("Notification saved to Hive successfully");
    } catch (e) {
      debugPrint("Error saving notification to Hive: $e");
    }
  }

  // Get Device Token for testing or specific user targeting
  static Future<String?> getDeviceToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint("Error getting token: $e");
      return null;
    }
  }

  // Show Local Pop-up with High Importance
  static void _showLocalNotification(RemoteMessage message) async {
    // Styling for expanded text (Full Update Support)
    final BigTextStyleInformation bigTextStyle = BigTextStyleInformation(
      message.notification?.body ?? '',
      contentTitle: message.notification?.title,
      summaryText: message.data['category'] ?? 'Job Update',
    );

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'job_alert_channel', // Channel ID
      'Job Alerts', // Channel Name
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: bigTextStyle, // Enables long text support
      showWhen: true,
    );

    NotificationDetails details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      details,
      payload: message.data.toString(),
    );
  }

  // Function to Subscribe/Unsubscribe from specific topics (Settings Screen)
  static Future<void> updateSubscription(String topic, bool subscribe) async {
    if (subscribe) {
      await _messaging.subscribeToTopic(topic);
    } else {
      await _messaging.unsubscribeFromTopic(topic);
    }
  }
}
