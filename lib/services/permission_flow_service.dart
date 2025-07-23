import 'package:flutter/material.dart';
import 'permission_service.dart';
import 'line_of_day_service.dart';
import 'notification_service.dart';
import 'daily_notification_service.dart';
import '../widgets/permission_dialog.dart';
import '../utils/snackbar_utils.dart';

/// Service to manage the permission request flow throughout the app
class PermissionFlowService {
  static final PermissionFlowService _instance =
      PermissionFlowService._internal();
  factory PermissionFlowService() => _instance;
  PermissionFlowService._internal();

  final PermissionService _permissionService = PermissionService();

  /// Check and potentially request notification permission based on user interaction
  Future<void> checkAndRequestPermissionIfNeeded(BuildContext context) async {
    // Increment user interaction count (only if not first launch)
    if (!await _permissionService.isFirstLaunch()) {
      await _permissionService.incrementUserInteraction();
    }

    // Check if we should request permission
    final shouldRequest =
        await _permissionService.shouldRequestNotificationPermission();

    if (shouldRequest && context.mounted) {
      await _showPermissionDialog(context);
    }
  }

  /// Check and request permission on first launch (for home screen)
  Future<void> checkAndRequestPermissionOnFirstLaunch(
      BuildContext context) async {
    // Check if this is the first launch and we should request permission
    if (await _permissionService.isFirstLaunch()) {
      final shouldRequest =
          await _permissionService.shouldRequestNotificationPermission();

      if (shouldRequest && context.mounted) {
        await _showPermissionDialog(context);
        // Mark first launch as completed after showing dialog
        await _permissionService.markFirstLaunchCompleted();
      }
    }
  }

  /// Show permission dialog with proper context
  Future<void> _showPermissionDialog(BuildContext context) async {
    await NotificationPermissionDialog.show(
      context,
      onPermissionGranted: () async {
        // Request platform-specific permissions and initialize daily notifications
        await NotificationService.instance.requestPlatformPermissions();
        await DailyNotificationService().initializeAfterPermissionGranted();

        if (context.mounted) {
          SnackBarUtils.showSuccess(
              context, 'Great! You\'ll now receive daily pickup lines 💕');
        }
      },
      onPermissionDenied: () {
        if (context.mounted) {
          SnackBarUtils.showInfo(
              context, 'You can enable notifications later in Settings');
        }
      },
    );
  }

  /// Request permission immediately (for settings or explicit user action)
  Future<bool> requestPermissionNow(BuildContext context) async {
    final isPermanentlyDenied =
        await _permissionService.isNotificationPermissionPermanentlyDenied();

    if (isPermanentlyDenied) {
      if (context.mounted) {
        await PermissionDeniedDialog.show(context);
      }
      return false;
    }

    if (context.mounted) {
      bool granted = false;
      await NotificationPermissionDialog.show(
        context,
        onPermissionGranted: () async {
          granted = true;
          // Request platform-specific permissions and initialize daily notifications
          await NotificationService.instance.requestPlatformPermissions();
          await DailyNotificationService().initializeAfterPermissionGranted();

          if (context.mounted) {
            SnackBarUtils.showSuccess(context, 'Notifications enabled! 🎉');
          }
        },
        onPermissionDenied: () {
          granted = false;
          if (context.mounted) {
            SnackBarUtils.showWarning(context, 'Notifications remain disabled');
          }
        },
      );
      return granted;
    }

    return false;
  }

  /// Check if permission is granted
  Future<bool> isPermissionGranted() async {
    return await _permissionService.isNotificationPermissionGranted();
  }

  /// Get user interaction count (for debugging/analytics)
  Future<int> getUserInteractionCount() async {
    return await _permissionService.getUserInteractionCount();
  }

  /// Reset permission tracking (for testing)
  Future<void> resetPermissionTracking() async {
    await _permissionService.resetPermissionTracking();
  }
}
