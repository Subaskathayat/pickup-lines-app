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
  List<Map<String, String?>> dailyLines = [];
  int currentTimeSlot = 0;
  String currentTimeSlotName = "Morning";
  bool isLoading = true;
  final FavoritesService _favoritesService = FavoritesService.instance;
  final LineOfDayService _lineOfDayService = LineOfDayService.instance;

  @override
  void initState() {
    super.initState();
    _loadLineOfDay();
  }

  /// Refresh the daily lines data
  Future<void> _refreshDailyLines() async {
    await _loadLineOfDay();
  }

  Future<void> _loadLineOfDay() async {
    try {
      // Initialize the service (this handles daily line generation and synchronization)
      await _lineOfDayService.initialize();

      // Get all 3 daily lines with current time slot highlighted
      final allDailyData =
          await _lineOfDayService.getAllDailyLinesWithCurrentHighlight();
      final lines = allDailyData['lines'] as List<Map<String, String?>>;
      final currentSlot = allDailyData['currentTimeSlot'] as int;
      final currentSlotName = allDailyData['currentTimeSlotName'] as String;

      if (mounted) {
        setState(() {
          dailyLines = lines;
          currentTimeSlot = currentSlot;
          currentTimeSlotName = currentSlotName;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          dailyLines = [
            {
              'line': "Error loading pickup lines. Please try again.",
              'category': "Error",
              'timeSlot': 'Morning',
              'time': '8:00 AM',
              'icon': '🌅',
              'description': 'Start Your Day Right',
            },
            {
              'line': "Error loading pickup lines. Please try again.",
              'category': "Error",
              'timeSlot': 'Afternoon',
              'time': '1:00 PM',
              'icon': '🌞',
              'description': 'Pick-Me-Up',
            },
            {
              'line': "Error loading pickup lines. Please try again.",
              'category': "Error",
              'timeSlot': 'Evening',
              'time': '7:00 PM',
              'icon': '🌙',
              'description': 'Charm Time',
            },
          ];
          currentTimeSlot = 0;
          currentTimeSlotName = "Morning";
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
          'Lines of the Day',
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
                    'Loading your daily pickup lines...',
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
          : Column(
              children: [
                // Date header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
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
                          'Daily Lines',
                          style: const TextStyle(
                            color: Color(0xFFFFABAB),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Scrollable list of all 3 daily lines with pull-to-refresh
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshDailyLines,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: dailyLines.length,
                      itemBuilder: (context, index) {
                        return _buildLineCard(index);
                      },
                    ),
                  ),
                ),

                // Bottom info
                Container(
                  margin: const EdgeInsets.all(16),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily pickup lines synchronized with notifications:',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '8:00 AM • 1:00 PM • 7:00 PM',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Currently: $currentTimeSlotName Edition',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLineCard(int index) {
    final lineData = dailyLines[index];
    final line = lineData['line'] ?? 'No line available';
    final category = lineData['category'] ?? 'Unknown';
    final timeSlot = lineData['timeSlot'] ?? 'Unknown';
    final time = lineData['time'] ?? '';
    final icon = lineData['icon'] ?? '⭐';
    final isCurrentTimeSlot = index == currentTimeSlot;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: isCurrentTimeSlot ? 12 : 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isCurrentTimeSlot
              ? BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : BorderSide.none,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isCurrentTimeSlot
                  ? [
                      Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.3),
                      Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      Theme.of(context).colorScheme.surface,
                    ]
                  : [
                      Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.8),
                      Theme.of(context).colorScheme.surface,
                    ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time slot header
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCurrentTimeSlot
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          icon,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$timeSlot $time',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (isCurrentTimeSlot)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'CURRENT',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Pickup line
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
                child: Column(
                  children: [
                    Icon(
                      Icons.format_quote,
                      size: 32,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      line,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Category: $category',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FutureBuilder<bool>(
                    future: _favoritesService.isFavorite(line),
                    builder: (context, snapshot) {
                      final isFavorite = snapshot.data ?? false;
                      return _buildActionButton(
                        icon:
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                        label: 'Favorite',
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () => _toggleFavorite(line),
                      );
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.copy,
                    label: 'Copy',
                    color: Theme.of(context).colorScheme.secondary,
                    onPressed: () => _copyToClipboard(line),
                  ),
                  _buildActionButton(
                    icon: Icons.share,
                    label: 'Share',
                    color: Theme.of(context).colorScheme.tertiary,
                    onPressed: () => _shareText(line),
                  ),
                ],
              ),
            ],
          ),
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
            iconSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
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

  Future<void> _toggleFavorite(String line) async {
    bool success = await _favoritesService.toggleFavorite(line);
    if (success && mounted) {
      bool isFavorite = await _favoritesService.isFavorite(line);

      // Refresh the UI to update favorite status
      setState(() {
        // The UI will be updated on next build
      });

      if (mounted) {
        SnackBarUtils.showSnackBar(
          context,
          isFavorite ? 'Added to favorites ❤️' : 'Removed from favorites',
        );
      }
    }
  }

  void _copyToClipboard(String line) {
    Clipboard.setData(ClipboardData(text: line));
    SnackBarUtils.showInfo(context, 'Copied to clipboard');
  }

  void _shareText(String line) {
    SharePlus.instance.share(
      ShareParams(text: line),
    );
  }
}
