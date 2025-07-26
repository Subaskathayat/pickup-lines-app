import 'package:flutter/material.dart';
import '../models/app_theme.dart';
import '../services/theme_service.dart';
import '../services/premium_service.dart';
import '../screens/subscription_screen.dart';
import '../utils/snackbar_utils.dart';

class ThemeSelectionWidget extends StatefulWidget {
  const ThemeSelectionWidget({super.key});

  @override
  State<ThemeSelectionWidget> createState() => _ThemeSelectionWidgetState();
}

class _ThemeSelectionWidgetState extends State<ThemeSelectionWidget> {
  final ThemeService _themeService = ThemeService();
  final PremiumService _premiumService = PremiumService();

  bool _isPremium = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThemes();
  }

  Future<void> _loadThemes() async {
    setState(() => _isLoading = true);

    try {
      // Show all themes regardless of premium status
      final isPremium = await _premiumService.isPremiumUser();

      setState(() {
        _isPremium = isPremium;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectTheme(AppThemeType theme) async {
    if (theme.isPremium && !_isPremium) {
      _showPremiumDialog(theme);
      return;
    }

    final success = await _themeService.switchTheme(theme);
    if (success && mounted) {
      SnackBarUtils.showSuccess(
          context, 'Theme changed to ${theme.displayNameWithEmoji}! ✨');
    } else if (mounted) {
      SnackBarUtils.showError(
          context, 'Failed to change theme. Please try again.');
    }
  }

  void _showPremiumDialog(AppThemeType theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.workspace_premium,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Premium Theme'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${theme.displayNameWithEmoji} is a premium theme.'),
            const SizedBox(height: 8),
            const Text(
                'Upgrade to Premium to unlock all beautiful themes and enjoy an ad-free experience!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ),
              );
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'App Theme',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose your preferred app theme',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            _buildThemeGrid(),
            if (!_isPremium) ...[
              const SizedBox(height: 16),
              _buildPremiumPrompt(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildThemeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: AppThemeType.values.length,
      itemBuilder: (context, index) {
        final theme = AppThemeType.values[index];
        final isSelected = _themeService.currentTheme == theme;
        final isAccessible = !theme.isPremium || _isPremium;

        return _buildThemeCard(theme, isSelected, isAccessible);
      },
    );
  }

  Widget _buildThemeCard(
      AppThemeType theme, bool isSelected, bool isAccessible) {
    final themeData = _themeService.getThemeData(theme);

    return GestureDetector(
      onTap: () => _selectTheme(theme),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          gradient: LinearGradient(
            colors: themeData.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        theme.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          theme.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: themeData.themeData.brightness ==
                                    Brightness.dark
                                ? Colors.white
                                : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isAccessible)
              Positioned(
                top: 4,
                right: 4,
                child: Icon(
                  Icons.lock,
                  size: 16,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            if (isSelected)
              Positioned(
                bottom: 4,
                right: 4,
                child: Icon(
                  Icons.check_circle,
                  size: 16,
                  color: _getIconColor(context),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumPrompt() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.workspace_premium,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Unlock 7 premium themes with Premium subscription!',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ),
              );
            },
            child: const Text(
              'Upgrade',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
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
}
