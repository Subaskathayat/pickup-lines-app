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

    // Ensure daily lines are generated for today and upcoming days
    await ensureDailyLinesGenerated();

    // Check if we need to update from the most recent notification first
    if (await shouldUpdateFromRecentNotification()) {
      await updateFromRecentNotification();
    } else if (await shouldUpdateFromMorningNotification()) {
      await updateFromMorningNotification();
    } else {
      // Update current line based on pre-generated daily lines
      await updateCurrentLineFromDailyLines();
    }

    // Schedule notifications for the future
    await _scheduleNotifications();

    // Clean up old stored morning notification data
    await _cleanupOldMorningNotificationData();

    // Set up daily timer for automatic Line of the Day updates
    _setupDailyUpdateTimer();
  }

  /// Ensure daily lines are generated for today and upcoming days
  Future<void> ensureDailyLinesGenerated() async {
    final today = DateTime.now();

    // Generate lines for today if not already done
    await generateDailyLines(today);

    // Generate lines for the next few days to ensure notifications work
    for (int i = 1; i <= 7; i++) {
      final futureDate = today.add(Duration(days: i));
      await generateDailyLines(futureDate);
    }
  }

  /// Update current line based on pre-generated daily lines
  Future<void> updateCurrentLineFromDailyLines() async {
    final today = DateTime.now();
    final currentTimeSlot = _getCurrentTimeSlot();

    // Try to get the appropriate line for current time slot
    final content = await calculateNotificationForDate(today, currentTimeSlot);

    if (content != null) {
      await _prefs!.setString(_currentLineKey, content['line']!);
      await _prefs!.setString(_categoryKey, content['category']!);
      await _prefs!
          .setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);

      // Store as notification content for tracking
      await storeNotificationContent(
          content['line']!, content['category']!, currentTimeSlot);
    } else {
      // Fallback: generate new daily lines and try again
      await generateDailyLines(today);
      final fallbackContent =
          await calculateNotificationForDate(today, currentTimeSlot);

      if (fallbackContent != null) {
        await _prefs!.setString(_currentLineKey, fallbackContent['line']!);
        await _prefs!.setString(_categoryKey, fallbackContent['category']!);
        await _prefs!
            .setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);

        await storeNotificationContent(fallbackContent['line']!,
            fallbackContent['category']!, currentTimeSlot);
      }
    }
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

    // Calculate the starting date for scheduling
    DateTime now = DateTime.now();
    DateTime startDate = DateTime(now.year, now.month, now.day);

    // If we're past the evening notification time, start from tomorrow
    DateTime eveningToday =
        DateTime(now.year, now.month, now.day, eveningHour, eveningMinute);
    if (now.isAfter(eveningToday)) {
      startDate = startDate.add(const Duration(days: 1));
    }

    // Schedule notifications for the next 30 days
    for (int day = 0; day < _daysToSchedule; day++) {
      DateTime currentDate = startDate.add(Duration(days: day));

      // Ensure daily lines are generated for this date
      await generateDailyLines(currentDate);

      // Schedule morning notification (8:00 AM)
      await _scheduleNotificationForTimeSlot(currentDate, morningHour,
          morningMinute, day, 0, 'Good Morning! Start Your Day Right 🌅');

      // Schedule afternoon notification (1:00 PM)
      await _scheduleNotificationForTimeSlot(currentDate, afternoonHour,
          afternoonMinute, day, 1, 'Afternoon Pick-Me-Up! 🌞');

      // Schedule evening notification (7:00 PM)
      await _scheduleNotificationForTimeSlot(currentDate, eveningHour,
          eveningMinute, day, 2, 'Evening Charm Time! 🌙');
    }
  }

  /// Helper method to schedule a notification for a specific time slot using pre-generated lines
  Future<void> _scheduleNotificationForTimeSlot(DateTime date, int hour,
      int minute, int day, int timeSlot, String title) async {
    DateTime scheduledTime =
        DateTime(date.year, date.month, date.day, hour, minute);

    // Skip if the scheduled time is in the past
    if (scheduledTime.isBefore(DateTime.now())) {
      return;
    }

    // Get the pre-generated line for this date and time slot
    final content = await calculateNotificationForDate(date, timeSlot);

    if (content == null) {
      // This shouldn't happen since we generate lines before scheduling,
      // but handle it gracefully
      return;
    }

    final selectedLine = content['line']!;
    final selectedCategory = content['category']!;

    // If this is today's notification, update the current Line of the Day tracking
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

  /// Generate exactly 3 different pickup lines for a specific date
  Future<void> generateDailyLines(DateTime date) async {
    await _initPrefs();
    final dateString = '${date.year}-${date.month}-${date.day}';

    // Check if lines for this date already exist
    final morningLine = _prefs!.getString('morning_line_$dateString');
    if (morningLine != null) {
      // Lines already generated for this date
      return;
    }

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

    // Create a seeded random generator for consistent daily generation
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final random = Random(seed);

    // Generate 3 different random indices
    Set<int> usedIndices = {};
    List<int> selectedIndices = [];

    while (selectedIndices.length < 3 &&
        selectedIndices.length < allLines.length) {
      int index = random.nextInt(allLines.length);
      if (!usedIndices.contains(index)) {
        usedIndices.add(index);
        selectedIndices.add(index);
      }
    }

    // Store the 3 daily lines
    for (int i = 0; i < selectedIndices.length; i++) {
      final index = selectedIndices[i];
      final line = allLines[index];
      final category = categoryNames[index];

      switch (i) {
        case 0: // Morning (8 AM)
          await _prefs!.setString('morning_line_$dateString', line);
          await _prefs!.setString('morning_category_$dateString', category);
          break;
        case 1: // Afternoon (1 PM)
          await _prefs!.setString('afternoon_line_$dateString', line);
          await _prefs!.setString('afternoon_category_$dateString', category);
          break;
        case 2: // Evening (7 PM)
          await _prefs!.setString('evening_line_$dateString', line);
          await _prefs!.setString('evening_category_$dateString', category);
          break;
      }
    }

    // If this is today, also update the current line tracking
    final today = DateTime.now();
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    if (isToday) {
      // Determine which line should be current based on time
      int currentTimeSlot = _getCurrentTimeSlot();
      if (currentTimeSlot < selectedIndices.length) {
        final currentIndex = selectedIndices[currentTimeSlot];
        final currentLine = allLines[currentIndex];
        final currentCategory = categoryNames[currentIndex];

        await _prefs!.setString(_currentLineKey, currentLine);
        await _prefs!.setString(_categoryKey, currentCategory);
        await _prefs!
            .setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);

        // Store as notification content for the current time slot
        await storeNotificationContent(
            currentLine, currentCategory, currentTimeSlot);
      }
    }
  }

  /// Get current time slot based on time of day
  int _getCurrentTimeSlot() {
    final now = DateTime.now();
    final currentHour = now.hour;

    if (currentHour >= 19) {
      return 2; // Evening (7 PM or later)
    } else if (currentHour >= 13) {
      return 1; // Afternoon (1 PM or later)
    } else {
      return 0; // Morning (before 1 PM)
    }
  }

  /// Generate a new random pickup line (legacy method for manual generation)
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

  /// Get all 3 daily lines for today (morning, afternoon, evening)
  Future<List<Map<String, String?>>> getAllDailyLines() async {
    await _initPrefs();
    final today = DateTime.now();

    // Ensure daily lines are generated for today
    await generateDailyLines(today);

    List<Map<String, String?>> dailyLines = [];

    // Get morning line
    final morningContent = await calculateNotificationForDate(today, 0);
    dailyLines.add({
      'line': morningContent?['line'],
      'category': morningContent?['category'],
      'timeSlot': 'Morning',
      'time': '8:00 AM',
      'icon': '🌅',
      'description': 'Start Your Day Right',
    });

    // Get afternoon line
    final afternoonContent = await calculateNotificationForDate(today, 1);
    dailyLines.add({
      'line': afternoonContent?['line'],
      'category': afternoonContent?['category'],
      'timeSlot': 'Afternoon',
      'time': '1:00 PM',
      'icon': '🌞',
      'description': 'Pick-Me-Up',
    });

    // Get evening line
    final eveningContent = await calculateNotificationForDate(today, 2);
    dailyLines.add({
      'line': eveningContent?['line'],
      'category': eveningContent?['category'],
      'timeSlot': 'Evening',
      'time': '7:00 PM',
      'icon': '🌙',
      'description': 'Charm Time',
    });

    return dailyLines;
  }

  /// Get all 3 daily lines with current time slot highlighted
  Future<Map<String, dynamic>> getAllDailyLinesWithCurrentHighlight() async {
    final allLines = await getAllDailyLines();
    final currentTimeSlot = _getCurrentTimeSlot();

    return {
      'lines': allLines,
      'currentTimeSlot': currentTimeSlot,
      'currentTimeSlotName': _getTimeSlotName(currentTimeSlot),
    };
  }

  /// Get time slot name for display
  String _getTimeSlotName(int timeSlot) {
    switch (timeSlot) {
      case 0:
        return 'Morning';
      case 1:
        return 'Afternoon';
      case 2:
        return 'Evening';
      default:
        return 'Morning';
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

  /// Set up timers to automatically update Line of the Day at notification times
  void _setupDailyUpdateTimer() {
    _timer?.cancel(); // Cancel any existing timer

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Define all notification times for today
    final todayMorning = DateTime(
        today.year, today.month, today.day, morningHour, morningMinute);
    final todayAfternoon = DateTime(
        today.year, today.month, today.day, afternoonHour, afternoonMinute);
    final todayEvening = DateTime(
        today.year, today.month, today.day, eveningHour, eveningMinute);

    // Find the next notification time
    DateTime? nextNotificationTime;

    if (now.isBefore(todayMorning)) {
      nextNotificationTime = todayMorning;
    } else if (now.isBefore(todayAfternoon)) {
      nextNotificationTime = todayAfternoon;
    } else if (now.isBefore(todayEvening)) {
      nextNotificationTime = todayEvening;
    } else {
      // All notifications for today have passed, set for tomorrow's morning
      nextNotificationTime = todayMorning.add(const Duration(days: 1));
    }

    final timeUntilNext = nextNotificationTime.difference(now);

    // Set up a timer to trigger at the next notification time
    _timer = Timer(timeUntilNext, () async {
      await _handleDailyUpdate();
      // Set up the timer for the next notification
      _setupDailyUpdateTimer();
    });
  }

  /// Handle daily update when notification time is reached
  Future<void> _handleDailyUpdate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Ensure daily lines are generated for today
    await generateDailyLines(today);

    // Update current line based on the current time slot
    await updateCurrentLineFromDailyLines();

    // If this is the morning notification, also generate lines for upcoming days
    if (now.hour == morningHour && now.minute == morningMinute) {
      await ensureDailyLinesGenerated();
    }
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
