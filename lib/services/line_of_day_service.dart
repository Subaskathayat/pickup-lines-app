import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/categories_data.dart';
import '../models/category.dart';
import 'notification_service.dart';

class LineOfDayService {
  static const String _currentLineKey = 'current_line_of_day';
  static const String _lastUpdateKey = 'last_line_update';
  static const String _categoryKey = 'current_line_category';
  
  static LineOfDayService? _instance;
  SharedPreferences? _prefs;
  Timer? _timer;
  final NotificationService _notificationService = NotificationService.instance;
  
  // For testing - 1 minute interval
  static const Duration _updateInterval = Duration(minutes: 1);
  
  LineOfDayService._();
  
  static LineOfDayService get instance {
    _instance ??= LineOfDayService._();
    return _instance!;
  }
  
  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  /// Initialize the service and start the timer
  Future<void> initialize() async {
    await _initPrefs();
    await _notificationService.initialize();
    
    // Generate initial line if none exists
    String? currentLine = await getCurrentLine();
    if (currentLine == null) {
      await _generateNewLine();
    }
    
    // Start the timer for automatic updates
    _startTimer();
  }
  
  /// Start the timer for automatic line updates
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_updateInterval, (timer) {
      _generateNewLine();
    });
  }
  
  /// Stop the timer
  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
  
  /// Generate a new random pickup line
  Future<void> _generateNewLine() async {
    await _initPrefs();
    
    // Get all pickup lines from all categories
    List<String> allLines = [];
    List<String> categoryNames = [];
    
    for (Category category in categories) {
      for (String line in category.texts) {
        allLines.add(line);
        categoryNames.add(category.name);
      }
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
  
  /// Manually trigger a new line generation (for testing button)
  Future<void> generateNewLineManually() async {
    await _generateNewLine();
  }
  
  /// Get time until next update
  Future<Duration?> getTimeUntilNextUpdate() async {
    final lastUpdate = await getLastUpdate();
    if (lastUpdate == null) return null;
    
    final nextUpdate = lastUpdate.add(_updateInterval);
    final now = DateTime.now();
    
    if (nextUpdate.isAfter(now)) {
      return nextUpdate.difference(now);
    }
    
    return Duration.zero;
  }
  
  /// Dispose resources
  void dispose() {
    _timer?.cancel();
  }
}
