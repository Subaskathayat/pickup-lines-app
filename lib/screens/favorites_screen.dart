import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../services/favorites_service.dart';
import '../services/pickup_lines_service.dart';
import '../widgets/age_verification_dialog.dart';
import '../utils/snackbar_utils.dart';
import 'text_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService.instance;
  final PickupLinesService _pickupLinesService = PickupLinesService.instance;
  List<String> favorites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      List<String> loadedFavorites = await _favoritesService.getFavorites();
      if (mounted) {
        setState(() {
          favorites = loadedFavorites;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favorites.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    return _buildFavoriteCard(favorites[index], index);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding pickup lines to your favorites\nby tapping the heart icon',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(String text, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () =>
            _navigateToTextDetail(text), // Navigate to text detail screen
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              ],
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  IconButton(
                    onPressed: () => _removeFavorite(index),
                    icon: Icon(
                      Icons.favorite,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    tooltip: 'Remove from favorites',
                  ),
                  IconButton(
                    onPressed: () => _copyText(text),
                    icon: Icon(
                      Icons.copy,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                    tooltip: 'Copy text',
                  ),
                  IconButton(
                    onPressed: () => _shareText(text),
                    icon: Icon(
                      Icons.share,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                    tooltip: 'Share text',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removeFavorite(int index) async {
    String pickupLine = favorites[index];
    bool success = await _favoritesService.removeFromFavorites(pickupLine);

    if (success && mounted) {
      setState(() {
        favorites.removeAt(index);
      });

      SnackBarUtils.showSnackBar(
        context,
        'Removed from favorites',
        action: SnackBarAction(
          label: 'Undo',
          textColor: Theme.of(context).colorScheme.onPrimary,
          onPressed: () async {
            await _favoritesService.addToFavorites(pickupLine);
            _loadFavorites(); // Reload to show the restored item
          },
        ),
      );
    }
  }

  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    SnackBarUtils.showInfo(context, 'Copied to clipboard! 💕');
  }

  void _shareText(String text) {
    SharePlus.instance.share(
      ShareParams(text: text),
    );
  }

  Future<void> _navigateToTextDetail(String favoriteText) async {
    try {
      // Find the category and index for this favorite line
      final result =
          await _pickupLinesService.findCategoryAndIndexForLine(favoriteText);

      if (result != null && mounted) {
        final category = result['category'];
        // Check age verification for mature content before navigating
        await AgeVerificationUtils.checkAndShow(
          context,
          category.name,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TextDetailScreen(
                  category: category,
                  initialIndex: result['index'],
                ),
              ),
            );
          },
        );
      } else if (mounted) {
        // Show error if line not found in categories
        SnackBarUtils.showError(
          context,
          'Unable to find this line in categories',
        );
      }
    } catch (e) {
      // Handle any errors
      if (mounted) {
        SnackBarUtils.showError(
          context,
          'Error opening text detail: $e',
        );
      }
    }
  }
}
