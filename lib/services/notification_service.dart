import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static NotificationService? _instance;
  static const int _lineOfDayNotificationId = 1;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._();

  static NotificationService get instance {
    _instance ??= NotificationService._();
    return _instance!;
  }

  /// Initialize the notification service
  Future<void> initialize() async {
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // macOS initialization settings
    const DarwinInitializationSettings initializationSettingsMacOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for iOS
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      await _requestIOSPermissions();
    }
  }

  /// Request iOS/macOS permissions
  Future<void> _requestIOSPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    // Handle notification tap - could navigate to Line of Day screen
    debugPrint('Notification tapped: ${notificationResponse.payload}');
  }

  /// Show Line of the Day notification
  Future<void> showLineOfDayNotification(
      String pickupLine, String category) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'line_of_day_channel',
      'Line of the Day',
      channelDescription: 'Daily pickup line notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFFABAB), // Coral pink
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      macOS: iOSPlatformChannelSpecifics,
    );

    // Truncate long pickup lines for notification title
    String title = 'New Line of the Day! 💕';
    String body = pickupLine.length > 100
        ? '${pickupLine.substring(0, 97)}...'
        : pickupLine;

    await _flutterLocalNotificationsPlugin.show(
      _lineOfDayNotificationId,
      title,
      '$body\n\nCategory: $category',
      platformChannelSpecifics,
      payload: 'line_of_day',
    );
  }

  /// Show a test notification (for the manual button)
  Future<void> showTestNotification(String pickupLine, String category) async {
    await showLineOfDayNotification(pickupLine, category);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Cancel Line of Day notification specifically
  Future<void> cancelLineOfDayNotification() async {
    await _flutterLocalNotificationsPlugin.cancel(_lineOfDayNotificationId);
  }
}
