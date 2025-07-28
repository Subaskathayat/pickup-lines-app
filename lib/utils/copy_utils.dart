import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/ad_service.dart';
import 'snackbar_utils.dart';

/// Utility class for handling copy operations with rewarded ads
class CopyUtils {
  /// Copy text to clipboard with optional rewarded ad
  static Future<void> copyWithAd(
    BuildContext context,
    String text, {
    String? successMessage,
  }) async {
    // Always copy the text first to ensure functionality works
    Clipboard.setData(ClipboardData(text: text));

    // Show success message
    final message = successMessage ?? 'Copied to clipboard! 💕';
    SnackBarUtils.showInfo(context, message);

    // Strategic ad trigger for copy actions (with frequency capping)
    try {
      await AdService.instance.showRewardedAd(
        onAdClosed: () {
          // Ad closed - no additional action needed
          debugPrint('📋 Rewarded ad closed after copy action');
        },
        onUserEarnedReward: () {
          // User watched the ad - show appreciation
          debugPrint('🎉 User earned reward from copy action ad');
          if (context.mounted) {
            SnackBarUtils.showSuccess(context, 'Thanks for watching! 🎉');
          }
        },
        onAdFailed: () {
          // Ad failed - no impact on copy functionality
          debugPrint('⚠️ Copy action ad failed to show');
        },
      );
    } catch (e) {
      // If ad system fails, don't affect the copy functionality
      debugPrint('❌ Error showing copy action ad: $e');
    }
  }

  /// Simple copy without ads (for cases where ads shouldn't be shown)
  static void copySimple(
    BuildContext context,
    String text, {
    String? successMessage,
  }) {
    Clipboard.setData(ClipboardData(text: text));
    final message = successMessage ?? 'Copied to clipboard! 💕';
    SnackBarUtils.showInfo(context, message);
  }
}
