import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../services/favorites_service.dart';
import '../services/line_of_day_service.dart';

class PickupLineOfDayScreen extends StatefulWidget {
  const PickupLineOfDayScreen({super.key});

  @override
  State<PickupLineOfDayScreen> createState() => _PickupLineOfDayScreenState();
}

class _PickupLineOfDayScreenState extends State<PickupLineOfDayScreen> {
  String todaysLine = "Loading your daily pickup line...";
  String category = "Loading...";
  bool isFavorite = false;
  bool isLoading = true;
  final FavoritesService _favoritesService = FavoritesService.instance;
  final LineOfDayService _lineOfDayService = LineOfDayService.instance;

  @override
  void initState() {
    super.initState();
    _loadLineOfDay();
  }

  Future<void> _loadLineOfDay() async {
    try {
      // Initialize the service
      await _lineOfDayService.initialize();

      // Get current line and category
      String? currentLine = await _lineOfDayService.getCurrentLine();
      String? currentCategory = await _lineOfDayService.getCurrentCategory();

      if (currentLine != null && currentCategory != null) {
        // Check favorite status
        bool favorite = await _favoritesService.isFavorite(currentLine);

        if (mounted) {
          setState(() {
            todaysLine = currentLine;
            category = currentCategory;
            isFavorite = favorite;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
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
          'Line of the Day',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFFFFABAB),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading your daily pickup line...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and category info
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFABAB).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Color(0xFFFFABAB),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getCurrentDate(),
                          style: const TextStyle(
                            color: Color(0xFFFFABAB),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFABAB),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          category,
                          style: const TextStyle(
                            color: Color(0xFFFFABAB),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Main card with pickup line
                  Expanded(
                    child: Center(
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFFFFD1DC).withValues(alpha: 0.4),
                                const Color(0xFFFFABAB).withValues(alpha: 0.2),
                                Colors.white,
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.format_quote,
                                size: 48,
                                color: Color(0xFFFFABAB),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                todaysLine,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Action buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildActionButton(
                                    icon: isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    label: 'Favorite',
                                    color: const Color(0xFFFFABAB),
                                    onPressed: _toggleFavorite,
                                  ),
                                  _buildActionButton(
                                    icon: Icons.copy,
                                    label: 'Copy',
                                    color: Colors.blue,
                                    onPressed: _copyToClipboard,
                                  ),
                                  _buildActionButton(
                                    icon: Icons.share,
                                    label: 'Share',
                                    color: Colors.green,
                                    onPressed: _shareText,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'A new pickup line is featured every minute for testing. Tap the button below to generate a new line and show notification!',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Test button for generating new line and notification
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _generateNewLineAndNotification,
                      icon: const Icon(Icons.notifications_active),
                      label:
                          const Text('Generate New Line & Show Notification'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFABAB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
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

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[now.month - 1]} ${now.day}';
  }

  Future<void> _toggleFavorite() async {
    bool success = await _favoritesService.toggleFavorite(todaysLine);
    if (success && mounted) {
      setState(() {
        isFavorite = !isFavorite;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite ? 'Added to favorites ❤️' : 'Removed from favorites',
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

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: todaysLine));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareText() {
    SharePlus.instance.share(
      ShareParams(text: todaysLine),
    );
  }

  /// Generate a new line manually and show notification (for testing)
  Future<void> _generateNewLineAndNotification() async {
    try {
      // Show loading state
      setState(() {
        isLoading = true;
      });

      // Generate new line
      await _lineOfDayService.generateNewLineManually();

      // Reload the current line
      await _loadLineOfDay();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New line generated and notification sent! 🎉'),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating new line: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
