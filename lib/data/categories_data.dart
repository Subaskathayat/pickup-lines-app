import '../models/category.dart';
import '../services/pickup_lines_service.dart';

/// Legacy function for backward compatibility
/// This will be loaded dynamically from JSON
Future<List<Category>> getCategories() async {
  return await PickupLinesService.instance.loadCategories();
}

/// Deprecated: Use PickupLinesService.instance.loadCategories() instead
/// This is kept for backward compatibility with existing code
List<Category> categories = [];
