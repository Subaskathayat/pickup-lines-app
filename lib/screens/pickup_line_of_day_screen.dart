import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../services/favorites_service.dart';
import '../services/line_of_day_service.dart';
import '../utils/snackbar_utils.dart';

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

      // Check if we need to update from the most recent notification first
      if (await _lineOfDayService.shouldUpdateFromRecentNotification()) {
        await _lineOfDayService.updateFromRecentNotification();
      } else if (await _lineOfDayService
          .shouldUpdateFromMorningNotification()) {
        await _lineOfDayService.updateFromMorningNotification();
      }

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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your daily pickup line...',
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
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
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
                                Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.4),
                                Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.2),
                                Theme.of(context).colorScheme.surface,
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.format_quote,
                                size: 48,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                todaysLine,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
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
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    onPressed: _toggleFavorite,
                                  ),
                                  _buildActionButton(
                                    icon: Icons.copy,
                                    label: 'Copy',
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    onPressed: _copyToClipboard,
                                  ),
                                  _buildActionButton(
                                    icon: Icons.share,
                                    label: 'Share',
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
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
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'A new pickup line is featured daily at 8:00 AM',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
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

      SnackBarUtils.showSnackBar(
        context,
        isFavorite ? 'Added to favorites ❤️' : 'Removed from favorites',
      );
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: todaysLine));
    SnackBarUtils.showInfo(context, 'Copied to clipboard');
  }

  void _shareText() {
    SharePlus.instance.share(
      ShareParams(text: todaysLine),
    );
  }
}
