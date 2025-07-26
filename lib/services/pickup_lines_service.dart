import 'dart:convert';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/services.dart';
import '../models/category.dart';
import 'premium_service.dart';

class PickupLinesService {
  static PickupLinesService? _instance;
  static PickupLinesService get instance =>
      _instance ??= PickupLinesService._();

  PickupLinesService._();

  List<Category>? _categories;
  List<Category>? _premiumCategories;

  /// Load regular pickup lines from JSON file
  Future<List<Category>> loadCategories() async {
    if (_categories != null) {
      return _categories!;
    }

    try {
      // Load JSON file from assets
      final String jsonString =
          await rootBundle.loadString('assets/data/pickup_lines.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      // Convert JSON to Category objects
      _categories = jsonData.map((categoryJson) {
        return Category(
          id: categoryJson['category_id'] as String,
          name: categoryJson['category_name'] as String,
          icon: categoryJson['icon'] as String,
          texts: List<String>.from(categoryJson['messages'] as List),
        );
      }).toList();

      return _categories!;
    } catch (e) {
      // If loading fails, return empty list and log error
      foundation.debugPrint('Error loading pickup lines: $e');
      _categories = [];
      return _categories!;
    }
  }

  /// Load premium pickup lines from JSON file
  Future<List<Category>> loadPremiumCategories() async {
    if (_premiumCategories != null) {
      return _premiumCategories!;
    }

    try {
      // Load premium JSON file from assets
      final String jsonString =
          await rootBundle.loadString('assets/data/premium_lines.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      // Convert JSON to Category objects
      _premiumCategories = jsonData.map((categoryJson) {
        return Category(
          id: categoryJson['category_id'] as String,
          name: categoryJson['category_name'] as String,
          icon: categoryJson['icon'] as String,
          texts: List<String>.from(categoryJson['messages'] as List),
        );
      }).toList();

      return _premiumCategories!;
    } catch (e) {
      // If loading fails, return empty list and log error
      foundation.debugPrint('Error loading premium pickup lines: $e');
      _premiumCategories = [];
      return _premiumCategories!;
    }
  }

  /// Load all categories (regular + premium for premium users)
  Future<List<Category>> loadAllCategories() async {
    final regularCategories = await loadCategories();

    // Check if user has premium access
    final isPremium = await PremiumService().isPremiumUser();
    if (!isPremium) {
      return regularCategories;
    }

    // Load premium categories for premium users
    final premiumCategories = await loadPremiumCategories();

    // Combine regular and premium categories
    return [...regularCategories, ...premiumCategories];
  }

  /// Reload categories from JSON (useful for future updates)
  Future<List<Category>> reloadCategories() async {
    _categories = null;
    _premiumCategories = null;
    return await loadAllCategories();
  }

  /// Get a specific category by ID (searches both regular and premium)
  Future<Category?> getCategoryById(String id) async {
    final categories = await loadAllCategories();
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all pickup lines from all categories (for line of the day)
  /// Includes premium content for premium users
  Future<List<String>> getAllPickupLines() async {
    final categories = await loadAllCategories();
    List<String> allLines = [];

    for (Category category in categories) {
      allLines.addAll(category.texts);
    }

    return allLines;
  }

  /// Get all pickup lines with their category names (for line of the day with category info)
  /// Includes premium content for premium users
  Future<List<Map<String, String>>> getAllPickupLinesWithCategories() async {
    final categories = await loadAllCategories();
    List<Map<String, String>> allLinesWithCategories = [];

    for (Category category in categories) {
      for (String line in category.texts) {
        allLinesWithCategories.add({
          'line': line,
          'category': category.name,
        });
      }
    }

    return allLinesWithCategories;
  }

  /// Get total count of pickup lines (includes premium for premium users)
  Future<int> getTotalPickupLinesCount() async {
    final categories = await loadAllCategories();
    int total = 0;

    for (Category category in categories) {
      total += category.texts.length;
    }

    return total;
  }

  /// Get category count (includes premium for premium users)
  Future<int> getCategoryCount() async {
    final categories = await loadAllCategories();
    return categories.length;
  }

  /// Find category and index for a specific pickup line (searches both regular and premium)
  Future<Map<String, dynamic>?> findCategoryAndIndexForLine(String line) async {
    final categories = await loadAllCategories();

    for (Category category in categories) {
      for (int i = 0; i < category.texts.length; i++) {
        if (category.texts[i] == line) {
          return {
            'category': category,
            'index': i,
          };
        }
      }
    }

    return null; // Line not found in any category
  }

  /// Check if a pickup line is from premium content
  Future<bool> isLineFromPremiumContent(String line) async {
    final premiumCategories = await loadPremiumCategories();

    for (Category category in premiumCategories) {
      if (category.texts.contains(line)) {
        return true;
      }
    }

    return false;
  }

  /// Get premium category by ID (for premium users only)
  Future<Category?> getPremiumCategoryById(String id) async {
    final isPremium = await PremiumService().isPremiumUser();
    if (!isPremium) {
      return null;
    }

    final premiumCategories = await loadPremiumCategories();
    try {
      return premiumCategories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear cached data (for testing purposes)
  void clearCache() {
    _categories = null;
    _premiumCategories = null;
  }
}
