import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'pickup_lines_service.dart';
import 'permission_service.dart';
import 'daily_notification_service.dart';

class LineOfDayService {
  static const String _currentLineKey = 'current_line_of_day';
  static const String _lastUpdateKey = 'last_line_update';
  static const String _categoryKey = 'current_line_category';

  static LineOfDayService? _instance;
  SharedPreferences? _prefs;
  Timer? _timer;
  final NotificationService _notificationService = NotificationService.instance;

  // Daily notification at 8:00 AM
  static const int _notificationHour = 8;
  static const int _notificationMinute = 0;

  // Number of daily notifications to schedule in advance (30 days)
  static const int _daysToSchedule = 30;

  LineOfDayService._();

  static LineOfDayService get instance {
    _instance ??= LineOfDayService._();
    return _instance!;
  }

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Initialize the service and schedule notifications
  Future<void> initialize() async {
    await _initPrefs();
    await _notificationService.initialize();

    // Generate initial line if none exists
    String? currentLine = await getCurrentLine();
    if (currentLine == null) {
      await _generateNewLine();
    }

    // Schedule notifications for the future
    await _scheduleNotifications();
  }

  /// Schedule daily notifications for the future (only if permission is granted AND toggle is enabled)
  Future<void> _scheduleNotifications() async {
    // Check if daily notifications should be sent (permission granted AND toggle enabled)
    final shouldSend =
        await DailyNotificationService().shouldSendDailyNotifications();
    if (!shouldSend) {
      // Don't schedule notifications if conditions are not met
      return;
    }

    // Cancel any existing scheduled notifications
    await _notificationService.cancelAllScheduledNotifications();

    // Get all pickup lines from all categories
    final allLinesWithCategories =
        await PickupLinesService.instance.getAllPickupLinesWithCategories();

    List<String> allLines = [];
    List<String> categoryNames = [];

    for (var lineData in allLinesWithCategories) {
      allLines.add(lineData['line']!);
      categoryNames.add(lineData['category']!);
    }

    if (allLines.isEmpty) return;

    final random = Random();

    // Calculate next notification time (next 8:00 AM)
    DateTime now = DateTime.now();
    DateTime nextNotificationTime = DateTime(
      now.year,
      now.month,
      now.day,
      _notificationHour,
      _notificationMinute,
    );

    // If it's already past 8:00 AM today, schedule for tomorrow
    if (nextNotificationTime.isBefore(now)) {
      nextNotificationTime = nextNotificationTime.add(const Duration(days: 1));
    }

    // Schedule daily notifications for the next 30 days
    for (int i = 0; i < _daysToSchedule; i++) {
      // Select a random line
      final index = random.nextInt(allLines.length);
      final selectedLine = allLines[index];
      final selectedCategory = categoryNames[index];

      // Truncate long pickup lines for notification title
      String title = 'Daily Line of the Day! 💕';
      String body = selectedLine.length > 100
          ? '${selectedLine.substring(0, 97)}...'
          : selectedLine;

      await _notificationService.scheduleNotification(
        id: 1000 + i, // Use unique IDs starting from 1000
        title: title,
        body: '$body\n\nCategory: $selectedCategory',
        scheduledDate: nextNotificationTime,
        payload: 'line_of_day',
      );

      // Schedule next notification for next day at same time
      nextNotificationTime = nextNotificationTime.add(const Duration(days: 1));
    }
  }

  /// Stop scheduled notifications
  Future<void> stopNotifications() async {
    await _notificationService.cancelAllScheduledNotifications();
  }

  /// Generate a new random pickup line
  Future<void> _generateNewLine() async {
    await _initPrefs();

    // Get all pickup lines from all categories
    final allLinesWithCategories =
        await PickupLinesService.instance.getAllPickupLinesWithCategories();

    List<String> allLines = [];
    List<String> categoryNames = [];

    for (var lineData in allLinesWithCategories) {
      allLines.add(lineData['line']!);
      categoryNames.add(lineData['category']!);
    }

    if (allLines.isEmpty) return;

    // Select a random line
    final random = Random();
    final index = random.nextInt(allLines.length);
    final selectedLine = allLines[index];
    final selectedCategory = categoryNames[index];

    // Save the new line and update timestamp
    await _prefs!.setString(_currentLineKey, selectedLine);
    await _prefs!.setString(_categoryKey, selectedCategory);
    await _prefs!.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);

    // Show notification
    await _notificationService.showLineOfDayNotification(
      selectedLine,
      selectedCategory,
    );
  }

  /// Get the current line of the day
  Future<String?> getCurrentLine() async {
    await _initPrefs();
    return _prefs!.getString(_currentLineKey);
  }

  /// Get the current line's category
  Future<String?> getCurrentCategory() async {
    await _initPrefs();
    return _prefs!.getString(_categoryKey);
  }

  /// Get the last update timestamp
  Future<DateTime?> getLastUpdate() async {
    await _initPrefs();
    final timestamp = _prefs!.getInt(_lastUpdateKey);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  /// Manually trigger a new line generation
  Future<void> generateNewLineManually() async {
    await _generateNewLine();
    // Reschedule notifications after manual generation
    await _scheduleNotifications();
  }

  /// Get time until next daily update (next 8:00 AM)
  Future<Duration?> getTimeUntilNextUpdate() async {
    DateTime now = DateTime.now();
    DateTime nextUpdate = DateTime(
      now.year,
      now.month,
      now.day,
      _notificationHour,
      _notificationMinute,
    );

    // If it's already past 8:00 AM today, get tomorrow's 8:00 AM
    if (nextUpdate.isBefore(now)) {
      nextUpdate = nextUpdate.add(const Duration(days: 1));
    }

    return nextUpdate.difference(now);
  }

  /// Reschedule notifications when permission is granted
  Future<void> rescheduleNotificationsAfterPermissionGranted() async {
    await _scheduleNotifications();
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllScheduledNotifications() async {
    await _notificationService.cancelAllScheduledNotifications();
  }

  /// Dispose resources
  void dispose() {
    _timer?.cancel();
  }
}
