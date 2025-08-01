import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../screens/favorites_screen.dart';
import '../screens/pickup_line_of_day_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/terms_conditions_screen.dart';
import '../screens/subscription_screen.dart';
import '../services/theme_service.dart';
import '../models/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();
    final currentTheme = themeService.currentThemeData;

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: currentTheme.gradientColors.take(2).toList(),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.favorite,
                    size: 48,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pickup Lines',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Find your perfect line',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withValues(alpha: 0.8),
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
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ),
              ),
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
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: _getDrawerIconColor(context),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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

  /// Get appropriate icon color based on current theme for better contrast
  Color _getDrawerIconColor(BuildContext context) {
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
