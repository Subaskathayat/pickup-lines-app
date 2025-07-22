import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/category.dart';
import '../services/favorites_service.dart';
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
                    ? const Color(0xFFFFABAB)
                    : Colors.grey[600],
              ),
            ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '${_currentIndex + 1}/${widget.category.texts.length}',
                style: TextStyle(
                  color: Colors.grey[600],
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
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
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
                              colors: [
                                const Color(0xFFFFD1DC)
                                    .withValues(alpha: 0.2), // Light Pink
                                const Color(0xFFB0E0E6)
                                    .withValues(alpha: 0.1), // Powder Blue
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.format_quote,
                                size: 40,
                                color: Color(0xFFFFABAB), // Coral Pink
                              ),
                              const SizedBox(height: 24),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    widget.category.texts[index],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      height: 1.5,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
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
                                    color: const Color(0xFFFFABAB),
                                    onPressed: () => _toggleFavorite(index),
                                  ),
                                  _buildActionButton(
                                    icon: Icons.copy,
                                    label: 'Copy',
                                    color: Colors.blue,
                                    onPressed: () => _copyToClipboard(context),
                                  ),
                                  _buildActionButton(
                                    icon: Icons.share,
                                    label: 'Share',
                                    color: Colors.green,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0,
                40.0), // Increased bottom padding from 24 to 40
            child: Column(
              children: [
                // Swipe hint
                Text(
                  'Swipe left or right for more texts',
                  style: TextStyle(
                    color: Colors.grey[500],
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: color),
            iconSize: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
