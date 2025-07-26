import 'package:flutter/material.dart';
import '../utils/snackbar_utils.dart';
import '../services/permission_service.dart';
import '../services/daily_notification_service.dart';
import '../services/theme_service.dart';
import '../services/favorites_service.dart';
import '../models/app_theme.dart';

import '../widgets/permission_dialog.dart';
import '../widgets/theme_selection_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool dailyLineNotification = true;
  String selectedLanguage = 'English';
  String notificationPermissionStatus = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadPermissionStatus();
  }

  Future<void> _loadPermissionStatus() async {
    final status =
        await PermissionService().getNotificationPermissionStatusText();
    final isGranted =
        await PermissionService().isNotificationPermissionGranted();
    final dailyEnabled =
        await DailyNotificationService().getEffectiveToggleState();

    setState(() {
      notificationPermissionStatus = status;
      notificationsEnabled = isGranted;
      dailyLineNotification = dailyEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Notifications'),
          if (!notificationsEnabled) _buildPermissionStatusTile(),
          if (!notificationsEnabled) const SizedBox(height: 8),
          _buildSwitchTile(
            title: 'Daily Line Notification',
            subtitle: 'Get pickup lines 3 times daily (8 AM, 1 PM, 7 PM)',
            value: dailyLineNotification,
            onChanged: notificationsEnabled
                ? (value) async {
                    // Capture context before async operation
                    final currentContext = context;

                    setState(() {
                      dailyLineNotification = value;
                    });

                    // Update the daily notification service
                    await DailyNotificationService()
                        .setDailyNotificationEnabled(value);

                    // Show feedback to user
                    if (mounted) {
                      if (value) {
                        SnackBarUtils.showSuccess(
                            currentContext, 'Daily notifications enabled! 💕');
                      } else {
                        SnackBarUtils.showInfo(
                            currentContext, 'Daily notifications disabled');
                      }
                    }
                  }
                : null,
          ),
          if (!notificationsEnabled) _buildPermissionActionTile(),
          const SizedBox(height: 24),
          _buildSectionHeader('Appearance'),
          const ThemeSelectionWidget(),
          const SizedBox(height: 24),
          _buildSectionHeader('Language'),
          _buildDropdownTile(
            title: 'Language',
            subtitle: 'Choose app language',
            value: selectedLanguage,
            items: ['English', 'Spanish', 'French', 'German'],
            onChanged: (value) {
              setState(() {
                selectedLanguage = value!;
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Data'),
          _buildActionTile(
            title: 'Reset Favorites',
            subtitle: 'Remove all favorite pickup lines',
            icon: Icons.refresh,
            onTap: _resetFavorites,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('About'),
          _buildInfoTile(
            title: 'Version',
            subtitle: '1.0.0',
            icon: Icons.info_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _getIconColor(context),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: _getSwitchActiveColor(context),
        activeTrackColor: _getSwitchActiveColor(context).withValues(alpha: 0.3),
        inactiveThumbColor:
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        inactiveTrackColor:
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
      ),
    );
  }

  /// Get appropriate switch active color based on current theme for better visibility
  Color _getSwitchActiveColor(BuildContext context) {
    final themeService = ThemeService();

    // Special handling for themes with poor contrast
    if (themeService.currentTheme == AppThemeType.luxuryDiamond) {
      // Use secondary color (charcoal) for better visibility against platinum background
      return Theme.of(context).colorScheme.secondary;
    }

    // For other themes, check if primary color provides good contrast
    final primaryColor = Theme.of(context).colorScheme.primary;
    final brightness = ThemeData.estimateBrightnessForColor(primaryColor);
    final surfaceBrightness = ThemeData.estimateBrightnessForColor(
        Theme.of(context).colorScheme.surface);

    // If both primary and surface are light, use a darker color
    if (brightness == Brightness.light &&
        surfaceBrightness == Brightness.light) {
      return Theme.of(context).colorScheme.onSurface;
    }

    // If both are dark, use a lighter color
    if (brightness == Brightness.dark && surfaceBrightness == Brightness.dark) {
      return Theme.of(context).colorScheme.onPrimary;
    }

    return primaryColor;
  }

  /// Get appropriate icon color based on current theme for better contrast
  Color _getIconColor(BuildContext context) {
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

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: _getIconColor(context)),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: _getIconColor(context)),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  void _resetFavorites() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Favorites'),
          content: const Text(
              'Are you sure you want to remove all favorite pickup lines?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: _getTextButtonColor(context),
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Capture context before async operation
                final currentContext = context;
                Navigator.of(currentContext).pop();

                try {
                  // Clear all favorites using the service
                  final success =
                      await FavoritesService.instance.clearAllFavorites();

                  if (success && mounted) {
                    SnackBarUtils.showSuccess(
                      currentContext,
                      'All favorites cleared successfully',
                    );
                  } else if (mounted) {
                    SnackBarUtils.showError(
                      currentContext,
                      'Failed to clear favorites',
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    SnackBarUtils.showError(
                      currentContext,
                      'Error clearing favorites: $e',
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _getButtonBackgroundColor(context),
                foregroundColor: _getButtonTextColor(context),
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPermissionStatusTile() {
    Color statusColor;
    IconData statusIcon;
    String userFriendlyMessage;

    switch (notificationPermissionStatus.toLowerCase()) {
      case 'granted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        userFriendlyMessage = 'Notifications are enabled! 🎉';
        break;
      case 'denied':
        statusColor = const Color(0xFFFFABAB); // Use app's coral pink
        statusIcon = Icons.notifications_off;
        userFriendlyMessage = 'Please grant notification permission';
        break;
      case 'permanently denied':
        statusColor = Colors.orange;
        statusIcon = Icons.settings;
        userFriendlyMessage = 'Please enable notifications in device settings';
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        userFriendlyMessage = 'Please grant notification permission';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                Text(
                  userFriendlyMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: statusColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          if (notificationPermissionStatus.toLowerCase() != 'granted')
            IconButton(
              onPressed: _refreshPermissionStatus,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh Status',
            ),
        ],
      ),
    );
  }

  Widget _buildPermissionActionTile() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Card(
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFABAB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.notifications_active,
              color: Color(0xFFFFABAB),
              size: 20,
            ),
          ),
          title: const Text(
            'Enable Notifications',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: const Text(
            'Allow notifications to receive daily pickup lines',
            style: TextStyle(fontSize: 12),
          ),
          trailing: ElevatedButton(
            onPressed: _requestNotificationPermission,
            style: ElevatedButton.styleFrom(
              backgroundColor: _getButtonBackgroundColor(context),
              foregroundColor: _getButtonTextColor(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Allow',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshPermissionStatus() async {
    await _loadPermissionStatus();
  }

  Future<void> _requestNotificationPermission() async {
    final shouldRequest =
        await PermissionService().shouldRequestNotificationPermission();
    final isPermanentlyDenied =
        await PermissionService().isNotificationPermissionPermanentlyDenied();

    if (isPermanentlyDenied) {
      // Show dialog to go to settings
      if (mounted) {
        await PermissionDeniedDialog.show(context);
      }
    } else if (shouldRequest ||
        !await PermissionService().isNotificationPermissionGranted()) {
      // Show permission request dialog
      if (mounted) {
        await NotificationPermissionDialog.show(
          context,
          onPermissionGranted: () {
            _loadPermissionStatus();
            SnackBarUtils.showSuccess(context, 'Notifications enabled! 🎉');
          },
          onPermissionDenied: () {
            _loadPermissionStatus();
            SnackBarUtils.showWarning(context, 'Notifications remain disabled');
          },
        );
      }
    } else {
      // Already granted, just refresh status
      await _loadPermissionStatus();
    }
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
}
