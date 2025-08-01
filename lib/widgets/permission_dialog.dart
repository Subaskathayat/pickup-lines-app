import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import '../services/permission_service.dart';
import '../services/theme_service.dart';
import '../models/app_theme.dart';

/// Dialog to request notification permission with proper context
class NotificationPermissionDialog extends StatelessWidget {
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onPermissionDenied;

  const NotificationPermissionDialog({
    super.key,
    this.onPermissionGranted,
    this.onPermissionDenied,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.notifications_active,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Stay Updated! 💕',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Get daily pickup lines delivered right to your phone!',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.today,
            title: 'Daily Line of the Day',
            description: 'Fresh pickup lines every morning',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            icon: Icons.favorite,
            title: 'Never Miss Out',
            description: 'Stay updated with new content',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            icon: Icons.settings,
            title: 'Full Control',
            description: 'Customize or disable anytime in settings',
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .secondary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'We respect your privacy. Notifications are only for app features.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onPermissionDenied?.call();
          },
          style: TextButton.styleFrom(
            foregroundColor: _getTextButtonColor(context),
          ),
          child: const Text(
            'Not Now',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            final status =
                await PermissionService().requestNotificationPermission();

            if (status == ph.PermissionStatus.granted) {
              onPermissionGranted?.call();
            } else {
              onPermissionDenied?.call();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _getButtonBackgroundColor(context),
            foregroundColor: _getButtonTextColor(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            'Allow Notifications',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFABAB).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFFFABAB),
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A4A4A),
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Get appropriate button background color based on current theme for better visibility
  Color _getButtonBackgroundColor(BuildContext context) {
    final themeService = ThemeService();

    // Special handling for themes with poor contrast
    if (themeService.currentTheme == AppThemeType.luxuryDiamond) {
      // Use secondary color (charcoal) for better visibility against platinum background
      return Theme.of(context).colorScheme.secondary;
    }

    // For other themes, use primary color but ensure it's not too light
    final primaryColor = Theme.of(context).colorScheme.primary;
    final brightness = ThemeData.estimateBrightnessForColor(primaryColor);

    if (brightness == Brightness.light) {
      // If primary is too light, use onSurface for better contrast
      return Theme.of(context).colorScheme.onSurface;
    }

    return primaryColor;
  }

  /// Get appropriate button text color based on current theme and background
  Color _getButtonTextColor(BuildContext context) {
    final themeService = ThemeService();

    // Special handling for themes with poor contrast
    if (themeService.currentTheme == AppThemeType.luxuryDiamond) {
      // Use onSecondary for text on secondary background
      return Theme.of(context).colorScheme.onSecondary;
    }

    // For other themes, determine text color based on background brightness
    final backgroundColor = _getButtonBackgroundColor(context);
    final backgroundBrightness =
        ThemeData.estimateBrightnessForColor(backgroundColor);

    if (backgroundBrightness == Brightness.light) {
      // Dark text on light background
      return Theme.of(context).colorScheme.onSurface;
    } else {
      // Light text on dark background
      return Theme.of(context).colorScheme.onPrimary;
    }
  }

  /// Get appropriate text button color for better visibility
  Color _getTextButtonColor(BuildContext context) {
    final themeService = ThemeService();

    // Special handling for luxury diamond theme
    if (themeService.currentTheme == AppThemeType.luxuryDiamond) {
      // Use secondary color (charcoal) for better visibility
      return Theme.of(context).colorScheme.secondary;
    }

    // For other themes, use primary but ensure visibility
    final primaryColor = Theme.of(context).colorScheme.primary;
    final brightness = ThemeData.estimateBrightnessForColor(primaryColor);

    if (brightness == Brightness.light) {
      // If primary is too light, use onSurface for better contrast
      return Theme.of(context).colorScheme.onSurface;
    }

    return primaryColor;
  }

  /// Show the permission dialog
  static Future<void> show(
    BuildContext context, {
    VoidCallback? onPermissionGranted,
    VoidCallback? onPermissionDenied,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return NotificationPermissionDialog(
          onPermissionGranted: onPermissionGranted,
          onPermissionDenied: onPermissionDenied,
        );
      },
    );
  }
}

/// Dialog to show when permission is permanently denied
class PermissionDeniedDialog extends StatelessWidget {
  const PermissionDeniedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.notifications_off,
              color: Theme.of(context).colorScheme.tertiary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Notifications Disabled',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'To receive daily pickup lines and updates, please enable notifications in your device settings.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF4A4A4A),
              height: 1.4,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Go to: Settings > Apps > Pickup Lines > Notifications',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: _getTextButtonColor(context),
          ),
          child: const Text(
            'Maybe Later',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await PermissionService().openAppSettings();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _getButtonBackgroundColor(context),
            foregroundColor: _getButtonTextColor(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Open Settings',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Get appropriate button background color based on current theme for better visibility
  Color _getButtonBackgroundColor(BuildContext context) {
    final themeService = ThemeService();

    // Special handling for themes with poor contrast
    if (themeService.currentTheme == AppThemeType.luxuryDiamond) {
      // Use secondary color (charcoal) for better visibility against platinum background
      return Theme.of(context).colorScheme.secondary;
    }

    // For other themes, use primary color but ensure it's not too light
    final primaryColor = Theme.of(context).colorScheme.primary;
    final brightness = ThemeData.estimateBrightnessForColor(primaryColor);

    if (brightness == Brightness.light) {
      // If primary is too light, use onSurface for better contrast
      return Theme.of(context).colorScheme.onSurface;
    }

    return primaryColor;
  }

  /// Get appropriate button text color based on current theme and background
  Color _getButtonTextColor(BuildContext context) {
    final themeService = ThemeService();

    // Special handling for themes with poor contrast
    if (themeService.currentTheme == AppThemeType.luxuryDiamond) {
      // Use onSecondary for text on secondary background
      return Theme.of(context).colorScheme.onSecondary;
    }

    // For other themes, determine text color based on background brightness
    final backgroundColor = _getButtonBackgroundColor(context);
    final backgroundBrightness =
        ThemeData.estimateBrightnessForColor(backgroundColor);

    if (backgroundBrightness == Brightness.light) {
      // Dark text on light background
      return Theme.of(context).colorScheme.onSurface;
    } else {
      // Light text on dark background
      return Theme.of(context).colorScheme.onPrimary;
    }
  }

  /// Get appropriate text button color for better visibility
  Color _getTextButtonColor(BuildContext context) {
    final themeService = ThemeService();

    // Special handling for luxury diamond theme
    if (themeService.currentTheme == AppThemeType.luxuryDiamond) {
      // Use secondary color (charcoal) for better visibility
      return Theme.of(context).colorScheme.secondary;
    }

    // For other themes, use primary but ensure visibility
    final primaryColor = Theme.of(context).colorScheme.primary;
    final brightness = ThemeData.estimateBrightnessForColor(primaryColor);

    if (brightness == Brightness.light) {
      // If primary is too light, use onSurface for better contrast
      return Theme.of(context).colorScheme.onSurface;
    }

    return primaryColor;
  }

  /// Show the permission denied dialog
  static Future<void> show(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return const PermissionDeniedDialog();
      },
    );
  }
}
