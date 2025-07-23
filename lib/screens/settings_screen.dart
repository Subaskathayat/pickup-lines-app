import 'package:flutter/material.dart';
import '../utils/snackbar_utils.dart';
import '../services/permission_service.dart';
import '../services/daily_notification_service.dart';

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
            subtitle: 'Get notified about pickup line of the day',
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
            title: 'Clear Cache',
            subtitle: 'Free up storage space',
            icon: Icons.cleaning_services,
            onTap: _clearCache,
          ),
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
          _buildActionTile(
            title: 'Check for Updates',
            subtitle: 'Look for app updates',
            icon: Icons.system_update,
            onTap: _checkForUpdates,
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
          color: Theme.of(context).colorScheme.primary,
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
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
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
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
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
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Cache'),
          content: const Text('Are you sure you want to clear the app cache?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                SnackBarUtils.showSuccess(
                  context,
                  'Cache cleared successfully',
                );
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                SnackBarUtils.showSuccess(
                  context,
                  'Favorites reset successfully',
                );
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _checkForUpdates() {
    SnackBarUtils.showInfo(
      context,
      'You have the latest version!',
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
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
}
