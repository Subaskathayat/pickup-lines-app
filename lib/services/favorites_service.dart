import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_pickup_lines';
  static FavoritesService? _instance;
  SharedPreferences? _prefs;

  FavoritesService._();

  static FavoritesService get instance {
    _instance ??= FavoritesService._();
    return _instance!;
  }

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get all favorite pickup lines
  Future<List<String>> getFavorites() async {
    await _initPrefs();
    return _prefs!.getStringList(_favoritesKey) ?? [];
  }

  /// Add a pickup line to favorites
  Future<bool> addToFavorites(String pickupLine) async {
    await _initPrefs();
    List<String> favorites = await getFavorites();
    
    if (!favorites.contains(pickupLine)) {
      favorites.add(pickupLine);
      return await _prefs!.setStringList(_favoritesKey, favorites);
    }
    return true; // Already exists, consider it successful
  }

  /// Remove a pickup line from favorites
  Future<bool> removeFromFavorites(String pickupLine) async {
    await _initPrefs();
    List<String> favorites = await getFavorites();
    
    if (favorites.contains(pickupLine)) {
      favorites.remove(pickupLine);
      return await _prefs!.setStringList(_favoritesKey, favorites);
    }
    return true; // Doesn't exist, consider it successful
  }

  /// Check if a pickup line is in favorites
  Future<bool> isFavorite(String pickupLine) async {
    await _initPrefs();
    List<String> favorites = await getFavorites();
    return favorites.contains(pickupLine);
  }

  /// Toggle favorite status of a pickup line
  Future<bool> toggleFavorite(String pickupLine) async {
    bool isCurrentlyFavorite = await isFavorite(pickupLine);
    
    if (isCurrentlyFavorite) {
      return await removeFromFavorites(pickupLine);
    } else {
      return await addToFavorites(pickupLine);
    }
  }

  /// Clear all favorites
  Future<bool> clearAllFavorites() async {
    await _initPrefs();
    return await _prefs!.remove(_favoritesKey);
  }

  /// Get the count of favorite pickup lines
  Future<int> getFavoritesCount() async {
    List<String> favorites = await getFavorites();
    return favorites.length;
  }
}
