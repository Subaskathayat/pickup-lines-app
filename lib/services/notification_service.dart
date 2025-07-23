import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'permission_service.dart';

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

  /// Initialize the notification service without requesting permissions
  Future<void> initialize() async {
    // Initialize timezone data
    tz.initializeTimeZones();

    // Android initialization settings - don't request permissions immediately
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // iOS initialization settings - don't request permissions immediately
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // macOS initialization settings - don't request permissions immediately
    const DarwinInitializationSettings initializationSettingsMacOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
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

    // Don't request permissions immediately - let PermissionService handle this gracefully
  }

  /// Request platform-specific permissions when needed
  /// This should only be called after PermissionService has granted permission
  Future<void> requestPlatformPermissions() async {
    // Request permissions for Android (exact alarms, etc.)
    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        // Request exact alarm permission (Android 12+)
        await androidImplementation.requestExactAlarmsPermission();
      }
    }

    // Request permissions for iOS/macOS
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
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
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    // Handle notification tap - could navigate to Line of Day screen
    // For now, we just acknowledge the tap
  }

  /// Check if notifications can be shown (permission granted)
  Future<bool> canShowNotifications() async {
    return await PermissionService().isNotificationPermissionGranted();
  }

  /// Show Line of the Day notification (only if permission is granted)
  Future<bool> showLineOfDayNotification(
      String pickupLine, String category) async {
    // Check if we have permission to show notifications
    if (!await canShowNotifications()) {
      return false;
    }
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'line_of_day_channel',
      'Line of the Day',
      channelDescription: 'Daily pickup line notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
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

    try {
      await _flutterLocalNotificationsPlugin.show(
        _lineOfDayNotificationId,
        title,
        '$body\n\nCategory: $category',
        platformChannelSpecifics,
        payload: 'line_of_day',
      );
      return true;
    } catch (e) {
      debugPrint('Failed to show notification: $e');
      return false;
    }
  }

  /// Show a test notification (for the manual button)
  Future<bool> showTestNotification(String pickupLine, String category) async {
    return await showLineOfDayNotification(pickupLine, category);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Cancel Line of Day notification specifically
  Future<void> cancelLineOfDayNotification() async {
    await _flutterLocalNotificationsPlugin.cancel(_lineOfDayNotificationId);
  }

  /// Schedule a notification for a specific time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'line_of_day_channel',
      'Line of the Day',
      channelDescription: 'Daily pickup line notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
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

    final scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZ,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
      matchDateTimeComponents: null,
    );
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllScheduledNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Cancel a specific scheduled notification
  Future<void> cancelScheduledNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}
