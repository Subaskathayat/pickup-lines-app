import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:shared_preferences/shared_preferences.dart';

/// Service to handle app permissions gracefully with user-friendly timing
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  static const String _notificationPermissionAskedKey =
      'notification_permission_asked';
  static const String _notificationPermissionDeniedKey =
      'notification_permission_denied';
  static const String _userInteractionCountKey = 'user_interaction_count';
  static const String _firstLaunchKey = 'first_launch_completed';

  /// Check if notification permission has been granted
  Future<bool> isNotificationPermissionGranted() async {
    final status = await ph.Permission.notification.status;
    return status == ph.PermissionStatus.granted;
  }

  /// Check if this is the first launch of the app
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_firstLaunchKey) ?? false);
  }

  /// Mark first launch as completed
  Future<void> markFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, true);
  }

  /// Check if we should ask for notification permission
  /// Returns true if:
  /// 1. Permission is not granted
  /// 2. It's the first launch OR user has interacted enough with the app
  /// 3. User hasn't permanently denied the permission
  Future<bool> shouldRequestNotificationPermission() async {
    // If already granted, no need to ask
    if (await isNotificationPermissionGranted()) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();

    // Check if user has permanently denied
    final permanentlyDenied =
        prefs.getBool(_notificationPermissionDeniedKey) ?? false;
    if (permanentlyDenied) {
      return false;
    }

    // Check if this is the first launch
    if (await isFirstLaunch()) {
      return true;
    }

    // Check if we've asked before
    final hasAskedBefore =
        prefs.getBool(_notificationPermissionAskedKey) ?? false;

    // If we haven't asked before, check user interaction count
    if (!hasAskedBefore) {
      final interactionCount = prefs.getInt(_userInteractionCountKey) ?? 0;
      // Ask after user has interacted with the app at least 3 times
      return interactionCount >= 3;
    }

    // If we've asked before and it's not permanently denied,
    // we can ask again (but should be done carefully)
    return false;
  }

  /// Request notification permission with proper handling
  Future<ph.PermissionStatus> requestNotificationPermission() async {
    final prefs = await SharedPreferences.getInstance();

    // Mark that we've asked for permission
    await prefs.setBool(_notificationPermissionAskedKey, true);

    final status = await ph.Permission.notification.request();

    // If permanently denied, mark it
    if (status == ph.PermissionStatus.permanentlyDenied) {
      await prefs.setBool(_notificationPermissionDeniedKey, true);
    }

    return status;
  }

  /// Increment user interaction count
  Future<void> incrementUserInteraction() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_userInteractionCountKey) ?? 0;
    await prefs.setInt(_userInteractionCountKey, currentCount + 1);
  }

  /// Get current user interaction count
  Future<int> getUserInteractionCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userInteractionCountKey) ?? 0;
  }

  /// Check if user has permanently denied notification permission
  Future<bool> isNotificationPermissionPermanentlyDenied() async {
    final status = await ph.Permission.notification.status;
    return status == ph.PermissionStatus.permanentlyDenied;
  }

  /// Reset permission tracking (useful for testing or settings reset)
  Future<void> resetPermissionTracking() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationPermissionAskedKey);
    await prefs.remove(_notificationPermissionDeniedKey);
    await prefs.remove(_userInteractionCountKey);
  }

  /// Open app settings for manual permission management
  Future<bool> openAppSettings() async {
    return await ph.openAppSettings();
  }

  /// Get permission status as a user-friendly string
  Future<String> getNotificationPermissionStatusText() async {
    final status = await ph.Permission.notification.status;
    switch (status) {
      case ph.PermissionStatus.granted:
        return 'Granted';
      case ph.PermissionStatus.denied:
        return 'Denied';
      case ph.PermissionStatus.restricted:
        return 'Restricted';
      case ph.PermissionStatus.limited:
        return 'Limited';
      case ph.PermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case ph.PermissionStatus.provisional:
        return 'Provisional';
      default:
        return 'Unknown';
    }
  }

  /// Check if we can show rationale for notification permission
  Future<bool> shouldShowNotificationRationale() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await ph.Permission.notification.shouldShowRequestRationale;
    }
    return false;
  }
}
