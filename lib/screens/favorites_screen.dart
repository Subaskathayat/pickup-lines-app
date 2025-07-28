import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../services/favorites_service.dart';
import '../services/pickup_lines_service.dart';
import '../services/theme_service.dart';
import '../models/app_theme.dart';
import '../widgets/age_verification_dialog.dart';
import '../utils/snackbar_utils.dart';
import '../utils/copy_utils.dart';
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

  // Multi-select functionality
  bool isSelectionMode = false;
  Set<int> selectedIndices = {};
  bool isSelectAll = false;

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
        title: Text(
          isSelectionMode ? '${selectedIndices.length} selected' : 'Favorites',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelectionMode,
              )
            : null,
        actions: isSelectionMode
            ? [
                IconButton(
                  icon: Icon(isSelectAll ? Icons.deselect : Icons.select_all),
                  onPressed: _toggleSelectAll,
                  tooltip: isSelectAll ? 'Deselect All' : 'Select All',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed:
                      selectedIndices.isNotEmpty ? _deleteSelected : null,
                  tooltip: 'Delete Selected',
                ),
              ]
            : null,
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
    final isSelected = selectedIndices.contains(index);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(
                color: _getIconColor(context),
                width: 2,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          if (isSelectionMode) {
            _toggleSelection(index);
          } else {
            _navigateToTextDetail(text);
          }
        },
        onLongPress: () {
          if (!isSelectionMode) {
            _enterSelectionMode(index);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: ThemeService()
                  .currentThemeData
                  .gradientColors
                  .map((color) => color.withValues(alpha: 0.2))
                  .toList(),
            ),
          ),
          child: Row(
            children: [
              // Selection indicator
              if (isSelectionMode)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isSelected
                        ? _getIconColor(context)
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.4),
                    size: 24,
                  ),
                ),
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
              // Action buttons (hidden in selection mode)
              if (!isSelectionMode)
                Column(
                  children: [
                    IconButton(
                      onPressed: () => _removeFavorite(index),
                      icon: Icon(
                        Icons.favorite,
                        color: _getIconColor(context),
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

  void _copyText(String text) async {
    await CopyUtils.copyWithAd(
      context,
      text,
      successMessage: 'Copied to clipboard! 💕',
    );
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

  /// Enter selection mode and select the first item
  void _enterSelectionMode(int index) {
    setState(() {
      isSelectionMode = true;
      selectedIndices.clear();
      selectedIndices.add(index);
      isSelectAll = false;
    });
  }

  /// Exit selection mode
  void _exitSelectionMode() {
    setState(() {
      isSelectionMode = false;
      selectedIndices.clear();
      isSelectAll = false;
    });
  }

  /// Toggle selection of an item
  void _toggleSelection(int index) {
    setState(() {
      if (selectedIndices.contains(index)) {
        selectedIndices.remove(index);
      } else {
        selectedIndices.add(index);
      }

      // Update select all state
      isSelectAll = selectedIndices.length == favorites.length;
    });
  }

  /// Toggle select all/deselect all
  void _toggleSelectAll() {
    setState(() {
      if (isSelectAll) {
        selectedIndices.clear();
        isSelectAll = false;
      } else {
        selectedIndices.clear();
        selectedIndices
            .addAll(List.generate(favorites.length, (index) => index));
        isSelectAll = true;
      }
    });
  }

  /// Delete selected items
  void _deleteSelected() {
    if (selectedIndices.isEmpty) return;

    final selectedCount = selectedIndices.length;
    final selectedTexts =
        selectedIndices.map((index) => favorites[index]).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Selected'),
          content: Text(
            'Are you sure you want to remove $selectedCount favorite${selectedCount > 1 ? 's' : ''}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final currentContext = context;
                Navigator.of(currentContext).pop();

                try {
                  // Remove selected items from favorites
                  bool allSuccess = true;
                  for (final text in selectedTexts) {
                    final success =
                        await _favoritesService.removeFromFavorites(text);
                    if (!success) allSuccess = false;
                  }

                  if (allSuccess && mounted) {
                    // Reload favorites and exit selection mode
                    await _loadFavorites();
                    _exitSelectionMode();

                    SnackBarUtils.showSnackBar(
                      currentContext,
                      'Removed $selectedCount favorite${selectedCount > 1 ? 's' : ''}',
                      action: SnackBarAction(
                        label: 'Undo',
                        textColor:
                            Theme.of(currentContext).colorScheme.onPrimary,
                        onPressed: () async {
                          // Re-add all removed items
                          for (final text in selectedTexts) {
                            await _favoritesService.addToFavorites(text);
                          }
                          _loadFavorites();
                        },
                      ),
                    );
                  } else if (mounted) {
                    SnackBarUtils.showError(
                      currentContext,
                      'Failed to remove some favorites',
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    SnackBarUtils.showError(
                      currentContext,
                      'Error removing favorites: $e',
                    );
                  }
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
