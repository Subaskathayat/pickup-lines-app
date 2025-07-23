import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Utility class for age verification
class AgeVerificationUtils {
  static const String _storageKey = 'age_verification_accepted';

  /// Check if age verification has been previously accepted
  static Future<bool> isAgeVerificationAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_storageKey) ?? false;
  }

  /// Store age verification acceptance
  static Future<void> setAgeVerificationAccepted(bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_storageKey, accepted);
  }

  /// Check if a category contains mature content
  static bool isMatureCategory(String categoryName) {
    final matureCategories = ['spicy', 'seductive', 'dirty'];
    return matureCategories.contains(categoryName.toLowerCase());
  }

  /// Show age verification dialog if needed
  static Future<bool> checkAndShow(
    BuildContext context,
    String categoryName,
    VoidCallback onContinue,
  ) async {
    // Check if category is mature content
    if (!isMatureCategory(categoryName)) {
      onContinue();
      return true;
    }

    // Check if user has already accepted age verification
    final isAccepted = await isAgeVerificationAccepted();
    if (isAccepted) {
      onContinue();
      return true;
    }

    // Show dialog - check if context is still mounted
    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AgeVerificationDialog(
        categoryName: categoryName,
        onContinue: onContinue,
      ),
    );

    return result ?? false;
  }
}

class AgeVerificationDialog extends StatefulWidget {
  final String categoryName;
  final VoidCallback onContinue;
  final VoidCallback? onCancel;

  const AgeVerificationDialog({
    super.key,
    required this.categoryName,
    required this.onContinue,
    this.onCancel,
  });

  @override
  State<AgeVerificationDialog> createState() => _AgeVerificationDialogState();
}

class _AgeVerificationDialogState extends State<AgeVerificationDialog> {
  bool _dontAskAgain = false;

  void _handleCancel() {
    Navigator.of(context).pop(false);
    if (widget.onCancel != null) {
      widget.onCancel!();
    }
  }

  Future<void> _handleContinue() async {
    if (_dontAskAgain) {
      await AgeVerificationUtils.setAgeVerificationAccepted(true);
    }

    if (mounted) {
      Navigator.of(context).pop(true);
      widget.onContinue();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.warning,
              color: Theme.of(context).colorScheme.tertiary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Age Verification',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The "${widget.categoryName}" category contains adult content with mature language.',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You must be 18+ years old to view this content.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _dontAskAgain,
                onChanged: (value) {
                  setState(() {
                    _dontAskAgain = value ?? false;
                  });
                },
                activeColor: const Color(0xFFFFABAB),
              ),
              Expanded(
                child: Text(
                  "Don't ask me again",
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _handleCancel,
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _handleContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "I'm 18+ Continue",
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
