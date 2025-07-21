import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/category.dart';
import '../services/favorites_service.dart';

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _favoriteStates[index]
                ? 'Added to favorites ❤️'
                : 'Removed from favorites',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
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
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        width: double.infinity,
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.format_quote,
                              size: 40,
                              color: Color(0xFFFFABAB), // Coral Pink
                            ),
                            const SizedBox(height: 24),
                            Text(
                              widget.category.texts[index],
                              style: const TextStyle(
                                fontSize: 20,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Page indicator dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.category.texts.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Action buttons row
                Row(
                  children: [
                    // Favorite button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _favoriteStates.isNotEmpty
                            ? () => _toggleFavorite(_currentIndex)
                            : null,
                        icon: Icon(
                          _favoriteStates.isNotEmpty &&
                                  _favoriteStates[_currentIndex]
                              ? Icons.favorite
                              : Icons.favorite_border,
                        ),
                        label: Text(
                          _favoriteStates.isNotEmpty &&
                                  _favoriteStates[_currentIndex]
                              ? 'Favorited'
                              : 'Favorite',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _favoriteStates.isNotEmpty &&
                                  _favoriteStates[_currentIndex]
                              ? const Color(0xFFFFABAB)
                              : null,
                          foregroundColor: _favoriteStates.isNotEmpty &&
                                  _favoriteStates[_currentIndex]
                              ? Colors.white
                              : null,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Copy button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _copyToClipboard(context),
                        icon: const Icon(Icons.copy),
                        label: const Text(
                          'Copy',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Text copied to clipboard! 💕'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
