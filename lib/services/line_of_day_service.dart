import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'pickup_lines_service.dart';
import 'daily_notification_service.dart';

class LineOfDayService {
  static const String _currentLineKey = 'current_line_of_day';
  static const String _lastUpdateKey = 'last_line_update';
  static const String _categoryKey = 'current_line_category';

  static LineOfDayService? _instance;
  SharedPreferences? _prefs;
  Timer? _timer;
  final NotificationService _notificationService = NotificationService.instance;

  // Daily notification times (public for testing)
  static const int morningHour = 8;
  static const int morningMinute = 0;
  static const int afternoonHour = 13; // 1:00 PM
  static const int afternoonMinute = 0;
  static const int eveningHour = 19; // 7:00 PM
  static const int eveningMinute = 0;

  // Number of daily notifications to schedule in advance (30 days)
  static const int _daysToSchedule = 30;

  // Number of notifications per day (public for testing)
  static const int notificationsPerDay = 3;

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

    // Shuffle the lines to ensure variety across the scheduling period
    final random = Random();
    final List<int> shuffledIndices = List.generate(allLines.length, (i) => i);
    shuffledIndices.shuffle(random);

    // Calculate the starting date for scheduling
    DateTime now = DateTime.now();
    DateTime startDate = DateTime(now.year, now.month, now.day);

    // If we're past the evening notification time, start from tomorrow
    DateTime eveningToday =
        DateTime(now.year, now.month, now.day, eveningHour, eveningMinute);
    if (now.isAfter(eveningToday)) {
      startDate = startDate.add(const Duration(days: 1));
    }

    int lineIndex = 0;

    // Schedule notifications for the next 30 days
    for (int day = 0; day < _daysToSchedule; day++) {
      DateTime currentDate = startDate.add(Duration(days: day));

      // Schedule morning notification (8:00 AM)
      await _scheduleNotificationForTime(
          currentDate,
          morningHour,
          morningMinute,
          allLines,
          categoryNames,
          shuffledIndices,
          lineIndex,
          day,
          0,
          'Good Morning! Start Your Day Right 🌅');
      lineIndex = (lineIndex + 1) % allLines.length;

      // Schedule afternoon notification (1:00 PM)
      await _scheduleNotificationForTime(
          currentDate,
          afternoonHour,
          afternoonMinute,
          allLines,
          categoryNames,
          shuffledIndices,
          lineIndex,
          day,
          1,
          'Afternoon Pick-Me-Up! 🌞');
      lineIndex = (lineIndex + 1) % allLines.length;

      // Schedule evening notification (7:00 PM)
      await _scheduleNotificationForTime(
          currentDate,
          eveningHour,
          eveningMinute,
          allLines,
          categoryNames,
          shuffledIndices,
          lineIndex,
          day,
          2,
          'Evening Charm Time! 🌙');
      lineIndex = (lineIndex + 1) % allLines.length;
    }
  }

  /// Helper method to schedule a notification for a specific time
  Future<void> _scheduleNotificationForTime(
      DateTime date,
      int hour,
      int minute,
      List<String> allLines,
      List<String> categoryNames,
      List<int> shuffledIndices,
      int lineIndex,
      int day,
      int timeSlot,
      String title) async {
    DateTime scheduledTime =
        DateTime(date.year, date.month, date.day, hour, minute);

    // Skip if the scheduled time is in the past
    if (scheduledTime.isBefore(DateTime.now())) {
      return;
    }

    final shuffledIndex = shuffledIndices[lineIndex];
    final selectedLine = allLines[shuffledIndex];
    final selectedCategory = categoryNames[shuffledIndex];

    // Truncate long pickup lines for notification body
    String body = selectedLine.length > 100
        ? '${selectedLine.substring(0, 97)}...'
        : selectedLine;

    // Generate unique ID: base + (day * 3) + timeSlot
    int notificationId = 1000 + (day * notificationsPerDay) + timeSlot;

    await _notificationService.scheduleNotification(
      id: notificationId,
      title: title,
      body: '$body\n\nCategory: $selectedCategory',
      scheduledDate: scheduledTime,
      payload: 'line_of_day',
    );
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

  /// Get time until next notification (morning, afternoon, or evening)
  Future<Duration?> getTimeUntilNextUpdate() async {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    // Check for next notification today
    List<DateTime> todayNotifications = [
      DateTime(today.year, today.month, today.day, morningHour, morningMinute),
      DateTime(
          today.year, today.month, today.day, afternoonHour, afternoonMinute),
      DateTime(today.year, today.month, today.day, eveningHour, eveningMinute),
    ];

    // Find the next notification time today
    for (DateTime notificationTime in todayNotifications) {
      if (notificationTime.isAfter(now)) {
        return notificationTime.difference(now);
      }
    }

    // If no more notifications today, get tomorrow's morning notification
    DateTime tomorrowMorning = DateTime(
        today.year, today.month, today.day + 1, morningHour, morningMinute);

    return tomorrowMorning.difference(now);
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
