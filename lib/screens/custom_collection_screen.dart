import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../services/custom_lines_service.dart';
import '../services/favorites_service.dart';
import '../utils/snackbar_utils.dart';

class CustomCollectionScreen extends StatefulWidget {
  const CustomCollectionScreen({super.key});

  @override
  State<CustomCollectionScreen> createState() => _CustomCollectionScreenState();
}

class _CustomCollectionScreenState extends State<CustomCollectionScreen> {
  final CustomLinesService _customLinesService = CustomLinesService.instance;
  final FavoritesService _favoritesService = FavoritesService.instance;
  final ScrollController _scrollController = ScrollController();
  List<String> _customLines = [];
  Set<String> _favoriteTexts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _loadCustomLines();
    await _loadFavorites();
  }

  Future<void> _loadCustomLines() async {
    final lines = await _customLinesService.getCustomLines();
    if (mounted) {
      setState(() {
        _customLines = lines;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFavorites() async {
    final favorites = await _favoritesService.getFavorites();
    if (mounted) {
      setState(() {
        _favoriteTexts = favorites.toSet();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Pickup Lines',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showAddLineDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Add Custom Line',
          ),
          if (_customLines.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear_all') {
                  _showClearAllDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Clear All'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _customLines.isEmpty
              ? _buildEmptyState()
              : _buildCustomLinesList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLineDialog,
        backgroundColor: const Color(0xFFFFABAB),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.edit_note,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No Custom Lines Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your own personalized pickup lines',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddLineDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Line'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFABAB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomLinesList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Total ${_customLines.length} Pickup lines',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _customLines.length,
            itemBuilder: (context, index) {
              final line = _customLines[index];
              return ScrollAnimatedItem(
                index: index,
                scrollController: _scrollController,
                child: _buildCustomLineCard(line, index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomLineCard(String line, int index) {
    final isFavorite = _favoriteTexts.contains(line);

    return Card(
      key: ValueKey(
          'custom_line_${index}_${line.hashCode}'), // Unique key for each card
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // Optional: Add tap functionality if needed
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFFD1DC).withValues(alpha: 0.3),
                const Color(0xFFFFABAB).withValues(alpha: 0.1),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.format_quote,
                    color: Color(0xFFFFABAB),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      line,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _copyToClipboard(line),
                        icon: Icon(
                          Icons.copy,
                          color: Colors.grey[600],
                        ),
                        tooltip: 'Copy text',
                      ),
                      IconButton(
                        onPressed: () => _shareText(line),
                        icon: Icon(
                          Icons.share,
                          color: Colors.grey[600],
                        ),
                        tooltip: 'Share text',
                      ),
                      IconButton(
                        onPressed: () => _toggleFavorite(line),
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite
                              ? const Color(0xFFFFABAB)
                              : Colors.grey[600],
                        ),
                        tooltip: isFavorite
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditLineDialog(line, index);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(line, index);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(Icons.more_vert, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddLineDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Pickup Line'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your custom pickup line...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _addCustomLine(controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFABAB),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditLineDialog(String currentLine, int index) {
    final TextEditingController controller =
        TextEditingController(text: currentLine);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Pickup Line'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your pickup line...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _updateCustomLine(currentLine, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFABAB),
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String line, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pickup Line'),
        content: Text(
            'Are you sure you want to delete this pickup line?\n\n"$line"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deleteCustomLine(line),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Custom Lines'),
        content: const Text(
            'Are you sure you want to delete all your custom pickup lines? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _clearAllCustomLines,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Future<void> _addCustomLine(String text) async {
    if (text.trim().isEmpty) {
      Navigator.of(context).pop();
      SnackBarUtils.showWarning(context, 'Please enter a pickup line');
      return;
    }

    final success = await _customLinesService.addCustomLine(text);

    if (mounted) {
      Navigator.of(context).pop();

      if (success) {
        await _loadCustomLines();
        SnackBarUtils.showSuccess(context, 'Custom pickup line added! 💕');
      } else {
        SnackBarUtils.showWarning(context, 'This pickup line already exists');
      }
    }
  }

  Future<void> _updateCustomLine(String oldLine, String newText) async {
    if (newText.trim().isEmpty) {
      Navigator.of(context).pop();
      SnackBarUtils.showWarning(context, 'Please enter a pickup line');
      return;
    }

    if (oldLine == newText.trim()) {
      Navigator.of(context).pop();
      return; // No changes made
    }

    final success =
        await _customLinesService.updateCustomLine(oldLine, newText);

    if (mounted) {
      Navigator.of(context).pop();

      if (success) {
        await _loadCustomLines();
        await _loadFavorites(); // Refresh favorites in case the updated line was favorited
        SnackBarUtils.showSuccess(context, 'Pickup line updated! ✨');
      } else {
        SnackBarUtils.showError(context, 'Failed to update pickup line');
      }
    }
  }

  Future<void> _deleteCustomLine(String line) async {
    final success = await _customLinesService.removeCustomLine(line);

    if (mounted) {
      Navigator.of(context).pop();

      if (success) {
        await _loadCustomLines();
        // Remove from favorites if it was favorited
        if (_favoriteTexts.contains(line)) {
          await _favoritesService.removeFromFavorites(line);
          await _loadFavorites();
        }
        if (mounted) {
          SnackBarUtils.showSnackBar(context, 'Pickup line deleted');
        }
      } else {
        if (mounted) {
          SnackBarUtils.showError(context, 'Failed to delete pickup line');
        }
      }
    }
  }

  Future<void> _clearAllCustomLines() async {
    final success = await _customLinesService.clearAllCustomLines();

    if (mounted) {
      Navigator.of(context).pop();

      if (success) {
        // Remove all custom lines from favorites
        for (final line in _customLines) {
          if (_favoriteTexts.contains(line)) {
            await _favoritesService.removeFromFavorites(line);
          }
        }
        await _loadCustomLines();
        await _loadFavorites();
        if (mounted) {
          SnackBarUtils.showSnackBar(context, 'All custom lines cleared');
        }
      } else {
        if (mounted) {
          SnackBarUtils.showError(context, 'Failed to clear custom lines');
        }
      }
    }
  }

  Future<void> _toggleFavorite(String text) async {
    final isFavorite = _favoriteTexts.contains(text);

    if (isFavorite) {
      await _favoritesService.removeFromFavorites(text);
      if (mounted) {
        SnackBarUtils.showSnackBar(context, 'Removed from favorites');
      }
    } else {
      await _favoritesService.addToFavorites(text);
      if (mounted) {
        SnackBarUtils.showSnackBar(context, 'Added to favorites! ❤️');
      }
    }

    await _loadFavorites();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    SnackBarUtils.showInfo(context, 'Copied to clipboard! 📋');
  }

  void _shareText(String text) {
    Share.share(text);
  }
}

class ScrollAnimatedItem extends StatefulWidget {
  final int index;
  final ScrollController scrollController;
  final Widget child;

  const ScrollAnimatedItem({
    super.key,
    required this.index,
    required this.scrollController,
    required this.child,
  });

  @override
  State<ScrollAnimatedItem> createState() => _ScrollAnimatedItemState();
}

class _ScrollAnimatedItemState extends State<ScrollAnimatedItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 250.0, // Start 250px to the right
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    // Listen to scroll changes
    widget.scrollController.addListener(_onScroll);

    // Check initial visibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _checkVisibility();
  }

  void _checkVisibility() {
    if (_hasAnimated) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;

    // Trigger animation when item is about to enter the screen (with some buffer)
    if (position.dy < screenHeight + 100 &&
        position.dy > -renderBox.size.height) {
      _hasAnimated = true;

      // Add a small delay based on index for subtle staggering
      final delay = Duration(milliseconds: (widget.index % 3) * 50);
      Future.delayed(delay, () {
        if (mounted) {
          _animationController.forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}
