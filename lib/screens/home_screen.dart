import 'package:flutter/material.dart';
import '../services/pickup_lines_service.dart';
import '../services/custom_lines_service.dart';
import '../services/permission_flow_service.dart';
import '../services/theme_service.dart';
import '../services/premium_service.dart';
import '../services/premium_content_service.dart';
import '../services/ad_service.dart';
import '../models/category.dart';
import '../widgets/app_drawer.dart';
import '../widgets/age_verification_dialog.dart';
import '../utils/snackbar_utils.dart';
import 'category_list_screen.dart';
import 'favorites_screen.dart';
import 'subscription_screen.dart';
import 'search_screen.dart';
import 'custom_collection_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Category> categories = [];
  bool isLoading = true;
  int customLinesCount = 0;
  bool isPremiumUser = false;
  Category? premiumCategory;
  final CustomLinesService _customLinesService = CustomLinesService.instance;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadCustomLinesCount();
    _loadPremiumStatus();
    _loadPremiumCategory();
    _checkFirstLaunchPermission();
  }

  /// Check and request permission on first launch
  Future<void> _checkFirstLaunchPermission() async {
    // Add a small delay to ensure the UI is fully loaded
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      await PermissionFlowService()
          .checkAndRequestPermissionOnFirstLaunch(context);
    }
  }

  Future<void> _loadCategories() async {
    try {
      final loadedCategories =
          await PickupLinesService.instance.loadCategories();
      setState(() {
        categories = loadedCategories;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Show error message
      if (mounted) {
        SnackBarUtils.showError(
          context,
          'Error loading categories: $e',
        );
      }
    }
  }

  Future<void> _loadCustomLinesCount() async {
    try {
      final count = await CustomLinesService.instance.getCustomLinesCount();
      if (mounted) {
        setState(() {
          customLinesCount = count;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadPremiumStatus() async {
    try {
      final premiumService = PremiumService();
      final isPremium = await premiumService.isPremiumUser();
      if (mounted) {
        setState(() {
          isPremiumUser = isPremium;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadPremiumCategory() async {
    try {
      final category =
          await PremiumContentService.instance.getTop100FavsCategory();
      if (mounted) {
        setState(() {
          premiumCategory = category;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pickup Lines',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ),
              );
              // Reload premium status when returning from subscription screen
              _loadPremiumStatus();
              _loadPremiumCategory();
            },
            icon: Icon(
              isPremiumUser ? Icons.diamond : Icons.workspace_premium,
              color: isPremiumUser
                  ? const Color(0xFFDAA520) // Golden color for premium users
                  : null, // Default color for non-premium users
            ),
            tooltip: isPremiumUser ? 'Premium Active' : 'Get Premium',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
            icon: const Icon(Icons.favorite),
            tooltip: 'Favorites',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionButton(
                  icon: Icons.search,
                  label: 'Search',
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                  onPressed: () => _navigateToSearch(context),
                ),
                _buildQuickActionButton(
                  icon: Icons.edit,
                  label: 'Your Lines',
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                  onPressed: () => _showCreateCustomDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Pick a category to find the perfect pickup line',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : categories.isEmpty
                      ? const Center(
                          child: Text(
                            'No categories available',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio:
                                1.0, // Changed from 1.2 to 1.0 for more height
                          ),
                          itemCount:
                              categories.length + 2, // +2 for feature cards
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              // Custom Collection Card
                              return FeatureCard(
                                title: 'My Collection',
                                subtitle: 'Your personal pickup lines',
                                icon: '✏️',
                                count: customLinesCount,
                                onTap: () => _navigateToCustomCollection(),
                                gradientColors: [
                                  Theme.of(context)
                                      .colorScheme
                                      .tertiary
                                      .withValues(alpha: 0.4),
                                  Theme.of(context)
                                      .colorScheme
                                      .tertiary
                                      .withValues(alpha: 0.2),
                                ],
                              );
                            } else if (index == 1) {
                              // Top Secret Card (Premium)
                              return FeatureCard(
                                title: 'Top Secret',
                                subtitle: 'Exclusive premium content',
                                icon: '💎',
                                count: premiumCategory?.texts.length ?? 0,
                                isPremium: true,
                                onTap: () {
                                  if (premiumCategory != null) {
                                    _navigateToTop100Lines(premiumCategory!);
                                  }
                                },
                              );
                            } else {
                              // Regular category cards
                              final categoryIndex = index - 2;
                              final regularCategories = categories
                                  .where((cat) => cat.id != 'top100')
                                  .toList();
                              if (categoryIndex < regularCategories.length) {
                                return CategoryCard(
                                    category: regularCategories[categoryIndex]);
                              }
                              return const SizedBox.shrink();
                            }
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
            backgroundColor: color.withValues(alpha: 0.05),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  void _navigateToSearch(BuildContext context) async {
    // Check permission flow on user interaction
    await PermissionFlowService().checkAndRequestPermissionIfNeeded(context);

    if (!mounted) return;

    Navigator.push(
      this.context,
      MaterialPageRoute(
        builder: (context) => const SearchScreen(),
      ),
    );
  }

  void _showCreateCustomDialog(BuildContext context) async {
    // Check permission flow on user interaction
    await PermissionFlowService().checkAndRequestPermissionIfNeeded(context);

    if (!mounted) return;

    _showAddLineDialog();
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
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Add'),
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
        SnackBarUtils.showSuccess(context, 'Custom pickup line added! 💕');
        // Navigate to custom collection screen after successful addition
        _navigateToCustomCollection();
      } else {
        SnackBarUtils.showWarning(context, 'This pickup line already exists');
      }
    }
  }

  void _navigateToCustomCollection() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CustomCollectionScreen(),
      ),
    );
    // Refresh custom lines count when returning
    _loadCustomLinesCount();
  }

  Future<void> _navigateToCategory(Category category) async {
    // Check permission flow on user interaction
    await PermissionFlowService().checkAndRequestPermissionIfNeeded(context);

    // Check if widget is still mounted after async operation
    if (!mounted) return;

    // Strategic ad trigger for category navigation (with frequency capping)
    try {
      await AdService.instance.showRewardedAd(
        onAdClosed: () {
          // Navigate to category after ad (or immediately if no ad shown)
          if (mounted) {
            _performCategoryNavigation(category);
          }
        },
        onAdFailed: () {
          // Navigate immediately if ad fails
          if (mounted) {
            _performCategoryNavigation(category);
          }
        },
      );
    } catch (e) {
      debugPrint('❌ Error showing category navigation ad: $e');
      // Navigate immediately if ad system fails
      if (mounted) {
        _performCategoryNavigation(category);
      }
    }
  }

  /// Perform the actual category navigation with age verification
  void _performCategoryNavigation(Category category) {
    // Check if age verification is needed for mature content
    AgeVerificationUtils.checkAndShow(
      context,
      category.name,
      () {
        // Navigate to category after age verification (if needed)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryListScreen(category: category),
          ),
        );
      },
    );
  }

  /// Navigate to Top Secret Lines with subscription check
  Future<void> _navigateToTop100Lines(Category category) async {
    // Check subscription status first
    final premiumService = PremiumService();
    final isPremium = await premiumService.isPremiumUser();

    if (!isPremium) {
      // Show subscription prompt if not premium
      _showPremiumPrompt();
      return;
    }

    // If premium, proceed with normal navigation
    await _navigateToCategory(category);
  }

  /// Show premium prompt for Top Secret Lines access
  void _showPremiumPrompt() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.star,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text('Premium Feature'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top Secret is a premium feature!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Get access to:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text('• Exclusive premium pickup lines'),
              Text('• Carefully curated content'),
              Text('• Updated regularly'),
              Text('• Ad-free experience'),
              Text('• All premium themes'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Maybe Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to subscription screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text('Get Premium'),
            ),
          ],
        );
      },
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () async {
          // Use age verification dialog for mature content
          await AgeVerificationUtils.checkAndShow(
            context,
            category.name,
            () {
              // Navigate directly to category list screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryListScreen(category: category),
                ),
              );
            },
          );
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
                  .map((color) => color.withValues(alpha: 0.4))
                  .toList(),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category.icon,
                style: const TextStyle(fontSize: 36),
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${category.texts.length} lines',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final int count;
  final VoidCallback onTap;
  final List<Color>? gradientColors;
  final bool isPremium;

  const FeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.count,
    required this.onTap,
    this.gradientColors,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors ??
                  ThemeService()
                      .currentThemeData
                      .gradientColors
                      .map((color) => color.withValues(alpha: 0.4))
                      .toList(),
            ),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (isPremium) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPremium ? 'Premium Content' : subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: isPremium
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                      height: 1.2,
                      fontWeight:
                          isPremium ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    count > 0 ? '$count lines' : 'Get started',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              // Premium lock icon in top-right corner
              if (isPremium)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock,
                      size: 10,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
