import 'package:shared_preferences/shared_preferences.dart';
import 'permission_service.dart';
import 'line_of_day_service.dart';

/// Service to manage daily notification toggle state and functionality
class DailyNotificationService {
  static final DailyNotificationService _instance = DailyNotificationService._internal();
  factory DailyNotificationService() => _instance;
  DailyNotificationService._internal();

  static const String _dailyNotificationEnabledKey = 'daily_notification_enabled';

  /// Check if daily notifications are enabled by user
  Future<bool> isDailyNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dailyNotificationEnabledKey) ?? true; // Default to true
  }

  /// Set daily notification enabled state
  Future<void> setDailyNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailyNotificationEnabledKey, enabled);
    
    // Update notification scheduling based on the new state
    await _updateNotificationScheduling();
  }

  /// Check if daily notifications should be active (both permission granted AND toggle enabled)
  Future<bool> shouldSendDailyNotifications() async {
    final hasPermission = await PermissionService().isNotificationPermissionGranted();
    final isEnabled = await isDailyNotificationEnabled();
    return hasPermission && isEnabled;
  }

  /// Update notification scheduling based on current state
  Future<void> _updateNotificationScheduling() async {
    if (await shouldSendDailyNotifications()) {
      // Enable notifications - reschedule them
      await LineOfDayService.instance.rescheduleNotificationsAfterPermissionGranted();
    } else {
      // Disable notifications - cancel all scheduled notifications
      await LineOfDayService.instance.cancelAllScheduledNotifications();
    }
  }

  /// Initialize daily notifications when permission is granted
  /// This should be called when permission is first granted
  Future<void> initializeAfterPermissionGranted() async {
    // Auto-enable daily notifications when permission is granted for the first time
    final isEnabled = await isDailyNotificationEnabled();
    if (!isEnabled) {
      await setDailyNotificationEnabled(true);
    } else {
      // Just update scheduling if already enabled
      await _updateNotificationScheduling();
    }
  }

  /// Get the effective state for UI display
  /// Returns true only if both permission is granted AND toggle is enabled
  Future<bool> getEffectiveToggleState() async {
    final hasPermission = await PermissionService().isNotificationPermissionGranted();
    final isEnabled = await isDailyNotificationEnabled();
    return hasPermission && isEnabled;
  }

  /// Check if toggle should be interactive (permission is granted)
  Future<bool> isToggleInteractive() async {
    return await PermissionService().isNotificationPermissionGranted();
  }
}
