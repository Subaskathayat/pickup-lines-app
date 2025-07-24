import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/category.dart';
import '../models/app_theme.dart';
import '../services/favorites_service.dart';
import '../services/theme_service.dart';
import '../utils/snackbar_utils.dart';

class TextDetailScreen extends StatefulWidget {
  final Category category;
  final int initialIndex;

  const TextDetailScreen({
    super.key,
    required this.category,
    required this.initialIndex,
  });

  @override
  State<TextDetailScreen> createState() => _TextDetailScreenState();
}

class _TextDetailScreenState extends State<TextDetailScreen> {
  late PageController _pageController;
  late int _currentIndex;
  final FavoritesService _favoritesService = FavoritesService.instance;
  List<bool> _favoriteStates = [];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _initializeFavoriteStates();
  }

  Future<void> _initializeFavoriteStates() async {
    _favoriteStates = List.filled(widget.category.texts.length, false);
    for (int i = 0; i < widget.category.texts.length; i++) {
      bool isFavorite =
          await _favoritesService.isFavorite(widget.category.texts[i]);
      if (mounted) {
        setState(() {
          _favoriteStates[i] = isFavorite;
        });
      }
    }
  }

  Future<void> _toggleFavorite(int index) async {
    String pickupLine = widget.category.texts[index];
    bool success = await _favoritesService.toggleFavorite(pickupLine);

    if (success && mounted) {
      setState(() {
        _favoriteStates[index] = !_favoriteStates[index];
      });

      SnackBarUtils.showSnackBar(
        context,
        _favoriteStates[index]
            ? 'Added to favorites ❤️'
            : 'Removed from favorites',
      );
    }
  }

  // Enhanced animation methods for smoother transitions
  void _animateToNextPage() {
    if (_currentIndex < widget.category.texts.length - 1) {
      _pageController.animateToPage(
        _currentIndex + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _animateToPreviousPage() {
    if (_currentIndex > 0) {
      _pageController.animateToPage(
        _currentIndex - 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Favorite button
          if (_favoriteStates.isNotEmpty)
            IconButton(
              onPressed: () => _toggleFavorite(_currentIndex),
              icon: Icon(
                _favoriteStates[_currentIndex]
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: _favoriteStates[_currentIndex]
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
              ),
            ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '${_currentIndex + 1}/${widget.category.texts.length}',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Add subtle haptic feedback on tap
                HapticFeedback.lightImpact();
              },
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                pageSnapping: true,
                onPageChanged: (index) {
                  // Add haptic feedback on page change
                  HapticFeedback.selectionClick();
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: widget.category.texts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1.0, // 1:1 aspect ratio for square format
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: ThemeService()
                                    .currentThemeData
                                    .gradientColors
                                    .map(
                                        (color) => color.withValues(alpha: 0.2))
                                    .toList(),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.format_quote,
                                  size: 40,
                                  color: _getIconColor(
                                      Theme.of(context).colorScheme.primary),
                                ),
                                const SizedBox(height: 24),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      widget.category.texts[index],
                                      style: TextStyle(
                                        fontSize: 20,
                                        height: 1.5,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Action buttons inside the card (matching pickup line of day layout)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildActionButton(
                                      icon: _favoriteStates.isNotEmpty &&
                                              _favoriteStates[index]
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      label: 'Favorite',
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      onPressed: () => _toggleFavorite(index),
                                    ),
                                    _buildActionButton(
                                      icon: Icons.copy,
                                      label: 'Copy',
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      onPressed: () =>
                                          _copyToClipboard(context),
                                    ),
                                    _buildActionButton(
                                      icon: Icons.share,
                                      label: 'Share',
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                      onPressed: () => _shareText(context),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0,
                40.0), // Increased bottom padding from 24 to 40
            child: Column(
              children: [
                // Swipe hint
                Text(
                  'Swipe left or right for more texts',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(
        ClipboardData(text: widget.category.texts[_currentIndex]));
    SnackBarUtils.showSuccess(context, 'Text copied to clipboard! 💕');
  }

  void _shareText(BuildContext context) {
    SharePlus.instance.share(
      ShareParams(text: widget.category.texts[_currentIndex]),
    );
  }

  /// Get appropriate icon color based on current theme
  Color _getIconColor(Color defaultColor) {
    final themeService = ThemeService();

    // Special handling for Luxury Diamond theme
    if (themeService.currentTheme == AppThemeType.luxuryDiamond) {
      // Use a darker color that contrasts well with the platinum background
      return const Color(0xFF4A4A4A); // Charcoal gray for better visibility
    }

    // For all other themes, use the default theme color
    return defaultColor;
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final iconColor = _getIconColor(color);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: iconColor),
            iconSize: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: iconColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
