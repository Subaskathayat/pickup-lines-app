import 'package:flutter/material.dart';
import '../services/pickup_lines_service.dart';
import '../services/custom_lines_service.dart';
import '../models/category.dart';
import '../widgets/app_drawer.dart';
import '../widgets/age_verification_dialog.dart';
import '../utils/snackbar_utils.dart';
import 'category_list_screen.dart';
import 'favorites_screen.dart';
import 'subscription_screen.dart';
import 'search_screen.dart';
import 'custom_collection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Category> categories = [];
  bool isLoading = true;
  int customLinesCount = 0;
  final CustomLinesService _customLinesService = CustomLinesService.instance;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadCustomLinesCount();
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ),
              );
            },
            icon: const Icon(Icons.workspace_premium),
            tooltip: 'Premium',
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
            icon: const Icon(Icons.favorite_outline),
            tooltip: 'Favorites',
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
                  color: Colors.grey[600]!,
                  onPressed: () => _navigateToSearch(context),
                ),
                _buildQuickActionButton(
                  icon: Icons.edit,
                  label: 'Your Lines',
                  color: Colors.grey[600]!,
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
                color: Colors.grey[600],
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
                                  const Color(0xFFE1D5E7)
                                      .withValues(alpha: 0.4), // Light Lavender
                                  const Color(0xFFD1C4E9)
                                      .withValues(alpha: 0.2), // Soft Purple
                                ],
                              );
                            } else if (index == 1) {
                              // Top 100 Lines Card
                              final top100Category = categories.firstWhere(
                                (cat) => cat.id == 'top100',
                                orElse: () => Category(
                                  id: 'top100',
                                  name: 'Top 100 Lines',
                                  icon: '🏆',
                                  texts: [],
                                ),
                              );
                              return FeatureCard(
                                title: 'Top 100 Lines',
                                subtitle: 'Most favorited by all users',
                                icon: '🏆',
                                count: top100Category.texts.length,
                                onTap: () =>
                                    _navigateToCategory(top100Category),
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

  void _navigateToSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchScreen(),
      ),
    );
  }

  void _showCreateCustomDialog(BuildContext context) {
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
              backgroundColor: const Color(0xFFFFABAB),
              foregroundColor: Colors.white,
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
    // Check if age verification is needed for mature content
    await AgeVerificationUtils.checkAndShow(
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
              colors: [
                const Color(0xFFFFD1DC).withValues(alpha: 0.3), // Light Pink
                const Color(0xFFFFABAB).withValues(alpha: 0.1), // Coral Pink
              ],
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${category.texts.length} lines',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
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

  const FeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.count,
    required this.onTap,
    this.gradientColors,
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
                  [
                    const Color(0xFFFFD1DC)
                        .withValues(alpha: 0.4), // Light Pink
                    const Color(0xFFFFABAB)
                        .withValues(alpha: 0.2), // Coral Pink
                  ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600], // Same as CategoryCard
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                count > 0 ? '$count lines' : 'Get started',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[
                      600], // Changed from red to grey to match CategoryCard
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
