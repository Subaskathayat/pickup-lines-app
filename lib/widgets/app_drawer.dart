import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../screens/favorites_screen.dart';
import '../screens/pickup_line_of_day_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/terms_conditions_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFABAB)
                  .withValues(alpha: 0.1), // Light Coral Pink
              const Color(0xFFFFF0F5), // Blush White
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFABAB), // Coral Pink
                    Color(0xFFFFD1DC), // Light Pink
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.favorite,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pickup Lines',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Find your perfect line',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.remove_circle_outline,
              title: 'Remove Ads',
              subtitle: 'Enjoy ad-free experience',
              onTap: () => _showRemoveAdsDialog(context),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.favorite_outline,
              title: 'Favorites',
              subtitle: 'Your saved pickup lines',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const FavoritesScreen()),
              ),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.today,
              title: 'Pickup Line of the Day',
              subtitle: 'Daily featured line',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PickupLineOfDayScreen()),
              ),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.settings,
              title: 'Settings',
              subtitle: 'App preferences',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ),
            ),
            const Divider(height: 32),
            _buildDrawerItem(
              context,
              icon: Icons.support_agent,
              title: 'Customer Support',
              subtitle: 'Get help and support',
              onTap: () => _launchEmail(),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'How we protect your data',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen()),
              ),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.description_outlined,
              title: 'Terms & Conditions',
              subtitle: 'App usage terms',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TermsConditionsScreen()),
              ),
            ),
            const Divider(height: 32),
            _buildDrawerItem(
              context,
              icon: Icons.star_outline,
              title: 'Rate App',
              subtitle: 'Rate us on app store',
              onTap: () => _rateApp(),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.share,
              title: 'Share App',
              subtitle: 'Share with friends',
              onTap: () => _shareApp(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFABAB).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFFFFABAB),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showRemoveAdsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Ads'),
          content: const Text(
            'Upgrade to premium to enjoy an ad-free experience and unlock additional features!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Maybe Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement premium upgrade logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Premium upgrade coming soon!'),
                  ),
                );
              },
              child: const Text('Upgrade Now'),
            ),
          ],
        );
      },
    );
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@pickuplines.app',
      query: 'subject=Pickup Lines App Support',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _rateApp() async {
    // TODO: Replace with actual app store URLs and implement platform detection
    // const String appStoreUrl = 'https://apps.apple.com/app/your-app-id';
    // const String playStoreUrl = 'https://play.google.com/store/apps/details?id=your.package.name';

    // For now, just show a message
    // In a real app, you would detect the platform and open the appropriate store
  }

  void _shareApp() {
    SharePlus.instance.share(
      ShareParams(
        text:
            'Check out this amazing Pickup Lines app! Download it now and find the perfect line for any situation.',
        subject: 'Pickup Lines App',
      ),
    );
  }
}
