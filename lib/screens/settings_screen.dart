import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool dailyLineNotification = true;
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  String selectedTheme = 'Light';
  String selectedLanguage = 'English';

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
          _buildSwitchTile(
            title: 'Enable Notifications',
            subtitle: 'Receive app notifications',
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),
          _buildSwitchTile(
            title: 'Daily Line Notification',
            subtitle: 'Get notified about pickup line of the day',
            value: dailyLineNotification,
            onChanged: notificationsEnabled
                ? (value) {
                    setState(() {
                      dailyLineNotification = value;
                    });
                  }
                : null,
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Sound & Vibration'),
          _buildSwitchTile(
            title: 'Sound Effects',
            subtitle: 'Play sounds for interactions',
            value: soundEnabled,
            onChanged: (value) {
              setState(() {
                soundEnabled = value;
              });
            },
          ),
          _buildSwitchTile(
            title: 'Vibration',
            subtitle: 'Vibrate on interactions',
            value: vibrationEnabled,
            onChanged: (value) {
              setState(() {
                vibrationEnabled = value;
              });
            },
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Appearance'),
          _buildDropdownTile(
            title: 'Theme',
            subtitle: 'Choose app theme',
            value: selectedTheme,
            items: ['Light', 'Dark', 'System'],
            onChanged: (value) {
              setState(() {
                selectedTheme = value!;
              });
            },
          ),
          
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
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFABAB),
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
        activeColor: const Color(0xFFFFABAB),
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
        leading: Icon(icon, color: const Color(0xFFFFABAB)),
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
        leading: Icon(icon, color: const Color(0xFFFFABAB)),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared successfully')),
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
          content: const Text('Are you sure you want to remove all favorite pickup lines?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Favorites reset successfully')),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You have the latest version!')),
    );
  }
}
