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

  // Keys for tracking all daily notification sync (morning, afternoon, evening)
  static const String _morningNotificationLineKey = 'morning_notification_line';
  static const String _morningNotificationCategoryKey =
      'morning_notification_category';
  static const String _afternoonNotificationLineKey =
      'afternoon_notification_line';
  static const String _afternoonNotificationCategoryKey =
      'afternoon_notification_category';
  static const String _eveningNotificationLineKey = 'evening_notification_line';
  static const String _eveningNotificationCategoryKey =
      'evening_notification_category';
  static const String _lastNotificationDateKey = 'last_notification_date';
  static const String _lastNotificationTimeSlotKey =
      'last_notification_time_slot'; // 0=morning, 1=afternoon, 2=evening

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

    // Check if we need to update from the most recent notification first
    if (await shouldUpdateFromRecentNotification()) {
      await updateFromRecentNotification();
    } else if (await shouldUpdateFromMorningNotification()) {
      await updateFromMorningNotification();
    } else {
      // Generate initial line if none exists
      String? currentLine = await getCurrentLine();
      if (currentLine == null) {
        await _generateNewLine();
      }
    }

    // Schedule notifications for the future
    await _scheduleNotifications();

    // Clean up old stored morning notification data
    await _cleanupOldMorningNotificationData();

    // Set up daily timer for automatic Line of the Day updates
    _setupDailyUpdateTimer();
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

    // Store notification content for Line of the Day sync for all time slots
    final dateString = '${date.year}-${date.month}-${date.day}';

    // Store content for the specific time slot
    if (hour == morningHour && minute == morningMinute) {
      // Morning notification (8 AM)
      await _prefs!.setString('morning_line_$dateString', selectedLine);
      await _prefs!.setString('morning_category_$dateString', selectedCategory);
    } else if (hour == afternoonHour && minute == afternoonMinute) {
      // Afternoon notification (1 PM)
      await _prefs!.setString('afternoon_line_$dateString', selectedLine);
      await _prefs!
          .setString('afternoon_category_$dateString', selectedCategory);
    } else if (hour == eveningHour && minute == eveningMinute) {
      // Evening notification (7 PM)
      await _prefs!.setString('evening_line_$dateString', selectedLine);
      await _prefs!.setString('evening_category_$dateString', selectedCategory);
    }

    // If this is today's notification, update the current Line of the Day
    final today = DateTime.now();
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    if (isToday) {
      await storeNotificationContent(selectedLine, selectedCategory, timeSlot);
    }

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

  /// Get the most appropriate content based on current time and recent notifications
  Future<Map<String, String?>> getMostRelevantContent() async {
    await _initPrefs();
    final now = DateTime.now();
    final todayDateString = '${now.year}-${now.month}-${now.day}';
    final lastNotificationDate = _prefs!.getString(_lastNotificationDateKey);

    // If we have a notification from today, use the most recent one
    if (lastNotificationDate == todayDateString) {
      final lastTimeSlot = _prefs!.getInt(_lastNotificationTimeSlotKey) ?? -1;
      if (lastTimeSlot != -1) {
        final content = await getNotificationContent(lastTimeSlot);
        if (content['line'] != null && content['category'] != null) {
          return content;
        }
      }
    }

    // Otherwise, determine based on current time
    final currentHour = now.hour;
    int timeSlot;

    if (currentHour >= 19) {
      // 7 PM or later
      timeSlot = 2; // Evening
    } else if (currentHour >= 13) {
      // 1 PM or later
      timeSlot = 1; // Afternoon
    } else {
      // Before 1 PM
      timeSlot = 0; // Morning
    }

    // Try to get content for the appropriate time slot
    final content = await getNotificationContent(timeSlot);
    if (content['line'] != null && content['category'] != null) {
      return content;
    }

    // Fallback to current stored line
    return {
      'line': _prefs!.getString(_currentLineKey),
      'category': _prefs!.getString(_categoryKey),
    };
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

  /// Get the morning notification content for a given date from stored data
  Future<Map<String, String>?> calculateMorningNotificationForDate(
      DateTime date) async {
    await _initPrefs();
    final dateString = '${date.year}-${date.month}-${date.day}';

    final line = _prefs!.getString('morning_line_$dateString');
    final category = _prefs!.getString('morning_category_$dateString');

    if (line != null && category != null) {
      return {
        'line': line,
        'category': category,
      };
    }

    return null;
  }

  /// Get the afternoon notification content for a given date from stored data
  Future<Map<String, String>?> calculateAfternoonNotificationForDate(
      DateTime date) async {
    await _initPrefs();
    final dateString = '${date.year}-${date.month}-${date.day}';

    final line = _prefs!.getString('afternoon_line_$dateString');
    final category = _prefs!.getString('afternoon_category_$dateString');

    if (line != null && category != null) {
      return {
        'line': line,
        'category': category,
      };
    }

    return null;
  }

  /// Get the evening notification content for a given date from stored data
  Future<Map<String, String>?> calculateEveningNotificationForDate(
      DateTime date) async {
    await _initPrefs();
    final dateString = '${date.year}-${date.month}-${date.day}';

    final line = _prefs!.getString('evening_line_$dateString');
    final category = _prefs!.getString('evening_category_$dateString');

    if (line != null && category != null) {
      return {
        'line': line,
        'category': category,
      };
    }

    return null;
  }

  /// Get notification content for any time slot for a given date
  Future<Map<String, String>?> calculateNotificationForDate(
      DateTime date, int timeSlot) async {
    switch (timeSlot) {
      case 0:
        return await calculateMorningNotificationForDate(date);
      case 1:
        return await calculateAfternoonNotificationForDate(date);
      case 2:
        return await calculateEveningNotificationForDate(date);
      default:
        return null;
    }
  }

  /// Clean up old stored notification data for all time slots (keep only last 7 days)
  Future<void> _cleanupOldMorningNotificationData() async {
    await _initPrefs();
    final keys = _prefs!.getKeys();
    final today = DateTime.now();

    for (final key in keys) {
      if (key.startsWith('morning_line_') ||
          key.startsWith('morning_category_') ||
          key.startsWith('afternoon_line_') ||
          key.startsWith('afternoon_category_') ||
          key.startsWith('evening_line_') ||
          key.startsWith('evening_category_')) {
        // Extract date from key (format: morning_line_2024-1-15 or afternoon_category_2024-1-15)
        final parts = key.split('_');
        if (parts.length >= 3) {
          final dateString = parts[2];
          final dateParts = dateString.split('-');
          if (dateParts.length == 3) {
            try {
              final year = int.parse(dateParts[0]);
              final month = int.parse(dateParts[1]);
              final day = int.parse(dateParts[2]);
              final keyDate = DateTime(year, month, day);

              // Remove data older than 7 days
              if (today.difference(keyDate).inDays > 7) {
                await _prefs!.remove(key);
              }
            } catch (e) {
              // If parsing fails, remove the key to clean up invalid data
              await _prefs!.remove(key);
            }
          }
        }
      }
    }
  }

  /// Store notification content for Line of the Day sync (supports all time slots)
  Future<void> storeNotificationContent(
      String line, String category, int timeSlot) async {
    await _initPrefs();
    final today = DateTime.now();
    final todayDateString = '${today.year}-${today.month}-${today.day}';

    // Store content based on time slot
    switch (timeSlot) {
      case 0: // Morning (8 AM)
        await _prefs!.setString(_morningNotificationLineKey, line);
        await _prefs!.setString(_morningNotificationCategoryKey, category);
        break;
      case 1: // Afternoon (1 PM)
        await _prefs!.setString(_afternoonNotificationLineKey, line);
        await _prefs!.setString(_afternoonNotificationCategoryKey, category);
        break;
      case 2: // Evening (7 PM)
        await _prefs!.setString(_eveningNotificationLineKey, line);
        await _prefs!.setString(_eveningNotificationCategoryKey, category);
        break;
    }

    // Track the most recent notification
    await _prefs!.setString(_lastNotificationDateKey, todayDateString);
    await _prefs!.setInt(_lastNotificationTimeSlotKey, timeSlot);

    // Update the current Line of the Day to match the most recent notification
    await _prefs!.setString(_currentLineKey, line);
    await _prefs!.setString(_categoryKey, category);
    await _prefs!.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Store morning notification content for Line of the Day sync (backward compatibility)
  Future<void> storeMorningNotificationContent(
      String line, String category) async {
    await storeNotificationContent(line, category, 0);
  }

  /// Get stored notification content for a specific time slot
  Future<Map<String, String?>> getNotificationContent(int timeSlot) async {
    await _initPrefs();
    switch (timeSlot) {
      case 0: // Morning
        return {
          'line': _prefs!.getString(_morningNotificationLineKey),
          'category': _prefs!.getString(_morningNotificationCategoryKey),
        };
      case 1: // Afternoon
        return {
          'line': _prefs!.getString(_afternoonNotificationLineKey),
          'category': _prefs!.getString(_afternoonNotificationCategoryKey),
        };
      case 2: // Evening
        return {
          'line': _prefs!.getString(_eveningNotificationLineKey),
          'category': _prefs!.getString(_eveningNotificationCategoryKey),
        };
      default:
        return {'line': null, 'category': null};
    }
  }

  /// Get the stored morning notification content (backward compatibility)
  Future<Map<String, String?>> getMorningNotificationContent() async {
    await _initPrefs();
    final content = await getNotificationContent(0);
    final lastDate = _prefs!.getString(_lastNotificationDateKey);
    return {
      'line': content['line'],
      'category': content['category'],
      'date': lastDate,
    };
  }

  /// Check if Line of the Day needs to be updated based on morning notification
  Future<bool> shouldUpdateFromMorningNotification() async {
    await _initPrefs();
    final today = DateTime.now();
    final todayDateString = '${today.year}-${today.month}-${today.day}';
    final lastUpdateDate = _prefs!.getString(_lastNotificationDateKey);

    // Check if we've already updated for today
    if (lastUpdateDate == todayDateString) {
      return false; // Already updated today
    }

    // Calculate what today's morning notification should be
    final todayMorningContent =
        await calculateMorningNotificationForDate(today);
    if (todayMorningContent == null) return false;

    final currentLine = _prefs!.getString(_currentLineKey);

    // Update if the current line doesn't match today's calculated morning notification
    return todayMorningContent['line'] != currentLine;
  }

  /// Check if Line of the Day needs to be updated based on the most recent notification
  Future<bool> shouldUpdateFromRecentNotification() async {
    await _initPrefs();
    final today = DateTime.now();
    final todayDateString = '${today.year}-${today.month}-${today.day}';
    final lastUpdateDate = _prefs!.getString(_lastNotificationDateKey);

    // If no notification was sent today, no update needed
    if (lastUpdateDate != todayDateString) {
      return false;
    }

    // Get the most recent notification time slot
    final lastTimeSlot = _prefs!.getInt(_lastNotificationTimeSlotKey) ?? -1;
    if (lastTimeSlot == -1) {
      return false;
    }

    // Check if we have content for the most recent notification
    final recentContent = await getNotificationContent(lastTimeSlot);
    final line = recentContent['line'];
    final category = recentContent['category'];

    if (line == null || category == null) {
      return false;
    }

    // Check if the current line matches the most recent notification
    final currentLine = _prefs!.getString(_currentLineKey);
    return line != currentLine;
  }

  /// Update Line of the Day from calculated morning notification content
  Future<void> updateFromMorningNotification() async {
    await _initPrefs();
    final today = DateTime.now();
    final todayMorningContent =
        await calculateMorningNotificationForDate(today);

    if (todayMorningContent != null) {
      final line = todayMorningContent['line']!;
      final category = todayMorningContent['category']!;

      // Update the current Line of the Day
      await _prefs!.setString(_currentLineKey, line);
      await _prefs!.setString(_categoryKey, category);
      await _prefs!
          .setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);

      // Store as morning notification content to track that we've updated today
      await storeMorningNotificationContent(line, category);
    }
  }

  /// Update Line of the Day from the most recent notification content
  Future<void> updateFromRecentNotification() async {
    await _initPrefs();
    final today = DateTime.now();
    final todayDateString = '${today.year}-${today.month}-${today.day}';
    final lastUpdateDate = _prefs!.getString(_lastNotificationDateKey);

    // Only update if we have notification content from today
    if (lastUpdateDate != todayDateString) {
      return;
    }

    // Get the most recent notification time slot
    final lastTimeSlot = _prefs!.getInt(_lastNotificationTimeSlotKey) ?? -1;
    if (lastTimeSlot == -1) {
      return;
    }

    // Get the content for the most recent notification
    final recentContent = await getNotificationContent(lastTimeSlot);
    final line = recentContent['line'];
    final category = recentContent['category'];

    if (line != null && category != null) {
      // Update the current Line of the Day
      await _prefs!.setString(_currentLineKey, line);
      await _prefs!.setString(_categoryKey, category);
      await _prefs!
          .setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
    }
  }

  /// Set up a daily timer to automatically update Line of the Day at 8:00 AM
  void _setupDailyUpdateTimer() {
    _timer?.cancel(); // Cancel any existing timer

    final now = DateTime.now();
    final today8AM =
        DateTime(now.year, now.month, now.day, morningHour, morningMinute);

    // Calculate when the next 8:00 AM will be
    DateTime next8AM;
    if (now.isBefore(today8AM)) {
      // If it's before 8:00 AM today, schedule for today
      next8AM = today8AM;
    } else {
      // If it's after 8:00 AM today, schedule for tomorrow
      next8AM = today8AM.add(const Duration(days: 1));
    }

    final timeUntilNext8AM = next8AM.difference(now);

    // Set up a timer to trigger at the next 8:00 AM
    _timer = Timer(timeUntilNext8AM, () async {
      // Update Line of the Day from morning notification if available
      if (await shouldUpdateFromMorningNotification()) {
        await updateFromMorningNotification();
      }

      // Set up the timer for the next day
      _setupDailyUpdateTimer();
    });
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
