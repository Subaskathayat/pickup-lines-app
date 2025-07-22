import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/category.dart';

class PickupLinesService {
  static PickupLinesService? _instance;
  static PickupLinesService get instance =>
      _instance ??= PickupLinesService._();

  PickupLinesService._();

  List<Category>? _categories;

  /// Load pickup lines from JSON file
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
      // In production, you might want to use a proper logging solution
      // ignore: avoid_print
      print('Error loading pickup lines: $e');
      return [];
    }
  }

  /// Reload categories from JSON (useful for future updates)
  Future<List<Category>> reloadCategories() async {
    _categories = null;
    return await loadCategories();
  }

  /// Get a specific category by ID
  Future<Category?> getCategoryById(String id) async {
    final categories = await loadCategories();
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all pickup lines from all categories (for line of the day)
  Future<List<String>> getAllPickupLines() async {
    final categories = await loadCategories();
    List<String> allLines = [];

    for (Category category in categories) {
      allLines.addAll(category.texts);
    }

    return allLines;
  }

  /// Get all pickup lines with their category names (for line of the day with category info)
  Future<List<Map<String, String>>> getAllPickupLinesWithCategories() async {
    final categories = await loadCategories();
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

  /// Get total count of pickup lines
  Future<int> getTotalPickupLinesCount() async {
    final categories = await loadCategories();
    int total = 0;

    for (Category category in categories) {
      total += category.texts.length;
    }

    return total;
  }

  /// Get category count
  Future<int> getCategoryCount() async {
    final categories = await loadCategories();
    return categories.length;
  }
}
