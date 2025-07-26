import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/app_theme.dart';
import '../services/favorites_service.dart';
import '../services/theme_service.dart';
import '../utils/snackbar_utils.dart';
import 'text_detail_screen.dart';

class CategoryListScreen extends StatefulWidget {
  final Category category;

  const CategoryListScreen({super.key, required this.category});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final GlobalKey<SliverAnimatedListState> _listKey =
      GlobalKey<SliverAnimatedListState>();
  late List<String> _texts;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _texts = List.from(widget.category.texts);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Header section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    widget.category.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_texts.length} pickup lines',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 8),
          ),
          // Animated list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return ScrollAnimatedItem(
                    index: index,
                    scrollController: _scrollController,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextCard(
                        text: _texts[index],
                        index: index,
                        category: widget.category,
                      ),
                    ),
                  );
                },
                childCount: _texts.length,
              ),
            ),
          ),
          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
      ),
    );
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
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 200.0, // Reduced from 250px for faster entry
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic, // More responsive curve
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8,
          curve: Curves.easeOutCubic), // Faster fade-in
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
      final delay = Duration(
          milliseconds:
              (widget.index % 3) * 25); // Reduced delay for faster response
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

class TextCard extends StatefulWidget {
  final String text;
  final int index;
  final Category category;

  const TextCard({
    super.key,
    required this.text,
    required this.index,
    required this.category,
  });

  @override
  State<TextCard> createState() => _TextCardState();
}

class _TextCardState extends State<TextCard> {
  bool isFavorite = false;
  final FavoritesService _favoritesService = FavoritesService.instance;

  /// Get appropriate text color based on current theme
  Color _getTextColor(Color defaultColor) {
    final themeService = ThemeService();

    // Special handling for Luxury Diamond theme
    if (themeService.currentTheme == AppThemeType.luxuryDiamond) {
      // Use a darker color that contrasts well with the platinum background
      return const Color(0xFF4A4A4A); // Charcoal gray for better visibility
    }

    // Special handling for Passionate Fire and Midnight Seduction themes
    if (themeService.currentTheme == AppThemeType.passionateFire ||
        themeService.currentTheme == AppThemeType.midnightSeduction) {
      // Use black for better contrast against these themes' gradient backgrounds
      return Colors.black;
    }

    // For all other themes, use the default color
    return defaultColor;
  }

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    bool favorite = await _favoritesService.isFavorite(widget.text);
    if (mounted) {
      setState(() {
        isFavorite = favorite;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    bool success = await _favoritesService.toggleFavorite(widget.text);
    if (success && mounted) {
      setState(() {
        isFavorite = !isFavorite;
      });

      SnackBarUtils.showSnackBar(
        context,
        isFavorite ? 'Added to favorites ❤️' : 'Removed from favorites',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TextDetailScreen(
                category: widget.category,
                initialIndex: widget.index,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 130, // Increased height by 10px
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: ThemeService()
                  .currentThemeData
                  .gradientColors
                  .map((color) => color.withValues(alpha: 0.4))
                  .toList(),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD1DC)
                      .withValues(alpha: 0.3), // Light Pink
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '${widget.index + 1}',
                    style: TextStyle(
                      color:
                          _getTextColor(Theme.of(context).colorScheme.primary),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.4,
                  ),
                  maxLines: 3, // Reverted back to 3 lines
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              // Vertical arrangement of icons
              SizedBox(
                width: 48,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Favorite button
                    IconButton(
                      onPressed: _toggleFavorite,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite
                            ? _getIconColor(context)
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                        size: 22,
                      ),
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Open/Arrow icon
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
