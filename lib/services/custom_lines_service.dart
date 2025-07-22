import 'package:shared_preferences/shared_preferences.dart';

class CustomLinesService {
  static CustomLinesService? _instance;
  static CustomLinesService get instance =>
      _instance ??= CustomLinesService._();

  CustomLinesService._();

  SharedPreferences? _prefs;
  static const String _customLinesKey = 'custom_pickup_lines';

  /// Initialize SharedPreferences
  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get all custom pickup lines
  Future<List<String>> getCustomLines() async {
    await _initPrefs();
    return _prefs!.getStringList(_customLinesKey) ?? [];
  }

  /// Add a new custom pickup line
  Future<bool> addCustomLine(String line) async {
    await _initPrefs();
    List<String> customLines = await getCustomLines();
    
    // Check if line already exists (case-insensitive)
    if (customLines.any((existingLine) => 
        existingLine.toLowerCase().trim() == line.toLowerCase().trim())) {
      return false; // Line already exists
    }
    
    customLines.add(line.trim());
    return await _prefs!.setStringList(_customLinesKey, customLines);
  }

  /// Remove a custom pickup line
  Future<bool> removeCustomLine(String line) async {
    await _initPrefs();
    List<String> customLines = await getCustomLines();
    
    if (customLines.contains(line)) {
      customLines.remove(line);
      return await _prefs!.setStringList(_customLinesKey, customLines);
    }
    return true; // Line doesn't exist, consider it successful
  }

  /// Update a custom pickup line
  Future<bool> updateCustomLine(String oldLine, String newLine) async {
    await _initPrefs();
    List<String> customLines = await getCustomLines();
    
    int index = customLines.indexOf(oldLine);
    if (index != -1) {
      customLines[index] = newLine.trim();
      return await _prefs!.setStringList(_customLinesKey, customLines);
    }
    return false; // Old line not found
  }

  /// Get count of custom lines
  Future<int> getCustomLinesCount() async {
    final lines = await getCustomLines();
    return lines.length;
  }

  /// Clear all custom lines
  Future<bool> clearAllCustomLines() async {
    await _initPrefs();
    return await _prefs!.remove(_customLinesKey);
  }

  /// Check if a line exists
  Future<bool> lineExists(String line) async {
    final customLines = await getCustomLines();
    return customLines.any((existingLine) => 
        existingLine.toLowerCase().trim() == line.toLowerCase().trim());
  }
}
