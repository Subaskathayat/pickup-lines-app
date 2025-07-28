import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../services/pickup_lines_service.dart';
import '../services/favorites_service.dart';
import '../services/premium_service.dart';
import '../services/premium_content_service.dart';
import '../utils/snackbar_utils.dart';
import '../utils/copy_utils.dart';
import '../services/custom_lines_service.dart';
import '../models/category.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FavoritesService _favoritesService = FavoritesService.instance;
  final PickupLinesService _pickupLinesService = PickupLinesService.instance;
  final CustomLinesService _customLinesService = CustomLinesService.instance;
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  Set<String> _favoriteTexts = {};
  List<Category> _categories = [];
  bool _isPremiumUser = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadCategories();
    _loadPremiumStatus();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final favorites = await _favoritesService.getFavorites();
    if (mounted) {
      setState(() {
        _favoriteTexts = favorites.toSet();
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _pickupLinesService.loadCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
        });
      }
    } catch (e) {
      // Handle error silently or show a message
      if (mounted) {
        setState(() {
          _categories = [];
        });
      }
    }
  }

  Future<void> _loadPremiumStatus() async {
    try {
      final premiumService = PremiumService();
      final isPremium = await premiumService.isPremiumUser();
      if (mounted) {
        setState(() {
          _isPremiumUser = isPremium;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _onSearchChanged() async {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final results = <SearchResult>[];

    // Search through all categories
    for (final category in _categories) {
      for (int i = 0; i < category.texts.length; i++) {
        final text = category.texts[i];
        if (text.toLowerCase().contains(query)) {
          results.add(SearchResult(
            text: text,
            category: category.name,
            categoryIcon: category.icon,
            index: i,
            isCustomCollection: false,
          ));
        }
      }
    }

    // Search through premium content if user is premium
    if (_isPremiumUser) {
      final premiumCategory =
          await PremiumContentService.instance.getTop100FavsCategory();
      if (premiumCategory != null) {
        for (int i = 0; i < premiumCategory.texts.length; i++) {
          final text = premiumCategory.texts[i];
          if (text.toLowerCase().contains(query)) {
            results.add(SearchResult(
              text: text,
              category: premiumCategory.name,
              categoryIcon: premiumCategory.icon,
              index: i,
              isCustomCollection: false,
              isPremiumContent: true,
            ));
          }
        }
      }
    }

    // Search through custom collections
    try {
      final customLines = await _customLinesService.getCustomLines();
      for (int i = 0; i < customLines.length; i++) {
        final text = customLines[i];
        if (text.toLowerCase().contains(query)) {
          results.add(SearchResult(
            text: text,
            category: 'My Collection',
            categoryIcon: '✏️',
            index: i,
            isCustomCollection: true,
          ));
        }
      }
    } catch (e) {
      // Handle error silently - custom lines search is optional
      print('Error searching custom lines: $e');
    }

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  Future<void> _toggleFavorite(String text) async {
    final success = await _favoritesService.toggleFavorite(text);
    if (success && mounted) {
      final isFavorite = await _favoritesService.isFavorite(text);
      setState(() {
        if (isFavorite) {
          _favoriteTexts.add(text);
        } else {
          _favoriteTexts.remove(text);
        }
      });

      if (mounted) {
        SnackBarUtils.showSnackBar(
          context,
          isFavorite ? 'Added to favorites ❤️' : 'Removed from favorites',
        );
      }
    }
  }

  void _copyText(String text) async {
    await CopyUtils.copyWithAd(
      context,
      text,
      successMessage: 'Copied to clipboard! 💕',
    );
  }

  void _shareText(String text) {
    SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Pickup Lines',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search pickup lines...',
                hintStyle: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
                prefixIcon: Icon(Icons.search,
                    color: Theme.of(context).colorScheme.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6)),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary, width: 2),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textInputAction: TextInputAction.search,
            ),
          ),

          // Search Results
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchController.text.trim().isEmpty) {
      return _buildEmptyState(
        icon: Icons.search,
        title: 'Start Searching',
        subtitle: 'Type in the search bar to find pickup lines',
      );
    }

    if (_isSearching) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off,
        title: 'No Results Found',
        subtitle: 'Try different keywords or check your spelling',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return _buildSearchResultCard(result);
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            title,
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
            subtitle,
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

  Widget _buildSearchResultCard(SearchResult result) {
    final isFavorite = _favoriteTexts.contains(result.text);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category info
            Row(
              children: [
                Text(
                  result.categoryIcon,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  result.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (result.isCustomCollection) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .tertiary
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .tertiary
                            .withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'CUSTOM',
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.tertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                if (result.isPremiumContent) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'PREMIUM',
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Pickup line text
            Text(
              result.text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                  label: 'Favorite',
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () => _toggleFavorite(result.text),
                ),
                _buildActionButton(
                  icon: Icons.copy,
                  label: 'Copy',
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: () => _copyText(result.text),
                ),
                _buildActionButton(
                  icon: Icons.share,
                  label: 'Share',
                  color: Theme.of(context).colorScheme.tertiary,
                  onPressed: () => _shareText(result.text),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 16),
          label: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 1,
          ),
        ),
      ),
    );
  }
}

class SearchResult {
  final String text;
  final String category;
  final String categoryIcon;
  final int index;
  final bool isCustomCollection;
  final bool isPremiumContent;

  SearchResult({
    required this.text,
    required this.category,
    required this.categoryIcon,
    required this.index,
    this.isCustomCollection = false,
    this.isPremiumContent = false,
  });
}
