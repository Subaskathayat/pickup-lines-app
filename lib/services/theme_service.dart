import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_theme.dart';
import 'premium_service.dart';

/// Service to manage app themes and theme switching
class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  static const String _selectedThemeKey = 'selected_theme';

  SharedPreferences? _prefs;
  AppThemeType _currentTheme = AppThemeType.sweetRomantic;
  final PremiumService _premiumService = PremiumService();

  /// Get the current theme type
  AppThemeType get currentTheme => _currentTheme;

  /// Get the current theme data
  AppThemeData get currentThemeData => getThemeData(_currentTheme);

  /// Initialize the theme service
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _loadSavedTheme();
  }

  /// Load the saved theme from preferences
  Future<void> _loadSavedTheme() async {
    final savedThemeId = _prefs!.getString(_selectedThemeKey);
    if (savedThemeId != null) {
      try {
        final savedTheme = AppThemeType.values.firstWhere(
          (theme) => theme.id == savedThemeId,
        );

        // Check if user has access to this theme
        if (await _hasAccessToTheme(savedTheme)) {
          _currentTheme = savedTheme;
        } else {
          // Fallback to default theme if no access
          _currentTheme = AppThemeType.sweetRomantic;
          await _saveTheme(_currentTheme);
        }
      } catch (e) {
        // Invalid theme ID, fallback to default
        _currentTheme = AppThemeType.sweetRomantic;
        await _saveTheme(_currentTheme);
      }
    }
  }

  /// Save the current theme to preferences
  Future<void> _saveTheme(AppThemeType theme) async {
    await _prefs!.setString(_selectedThemeKey, theme.id);
  }

  /// Check if user has access to a specific theme
  Future<bool> _hasAccessToTheme(AppThemeType theme) async {
    if (!theme.isPremium) return true;
    return await _premiumService.isPremiumUser();
  }

  /// Switch to a new theme
  Future<bool> switchTheme(AppThemeType newTheme) async {
    // Check if user has access to this theme
    if (!await _hasAccessToTheme(newTheme)) {
      return false;
    }

    _currentTheme = newTheme;
    await _saveTheme(newTheme);
    notifyListeners();
    return true;
  }

  /// Get all available themes for the current user
  Future<List<AppThemeType>> getAvailableThemes() async {
    final isPremium = await _premiumService.isPremiumUser();

    if (isPremium) {
      return AppThemeType.values;
    } else {
      return AppThemeType.values.where((theme) => !theme.isPremium).toList();
    }
  }

  /// Get all premium themes
  List<AppThemeType> getPremiumThemes() {
    return AppThemeType.values.where((theme) => theme.isPremium).toList();
  }

  /// Check if a theme is accessible to the current user
  Future<bool> isThemeAccessible(AppThemeType theme) async {
    return await _hasAccessToTheme(theme);
  }

  /// Reset to default theme
  Future<void> resetToDefault() async {
    await switchTheme(AppThemeType.sweetRomantic);
  }

  /// Get theme data for a specific theme type
  AppThemeData getThemeData(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.sweetRomantic:
        return _getSweetRomanticTheme();
      case AppThemeType.passionateFire:
        return _getPassionateFireTheme();
      case AppThemeType.midnightSeduction:
        return _getMidnightSeductionTheme();
      case AppThemeType.playfulRainbow:
        return _getPlayfulRainbowTheme();
      case AppThemeType.elegantNoir:
        return _getElegantNoirTheme();
      case AppThemeType.tropicalParadise:
        return _getTropicalParadiseTheme();
      case AppThemeType.luxuryDiamond:
        return _getLuxuryDiamondTheme();
      case AppThemeType.cherryBlossom:
        return _getCherryBlossomTheme();
    }
  }

  /// Sweet & Romantic Theme (Default - Free)
  AppThemeData _getSweetRomanticTheme() {
    return AppThemeData(
      type: AppThemeType.sweetRomantic,
      animationDuration: const Duration(milliseconds: 300),
      animationCurve: Curves.easeInOut,
      gradientColors: const [
        Color(0xFFFFABAB), // Coral Pink
        Color(0xFFFFD1DC), // Light Pink
        Color(0xFFFFE4E1), // Misty Rose
      ],
      fontFamily: 'Inter',
      themeData: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFFABAB), // Coral Pink
          secondary: Color(0xFFB0E0E6), // Powder Blue
          tertiary: Color(0xFFFFD1DC), // Light Pink
          surface: Color(0xFFFFF0F5), // Blush White

          onPrimary: Color(0xFF4A4A4A), // Dark Gray
          onSecondary: Color(0xFF4A4A4A), // Dark Gray
          onSurface: Color(0xFF4A4A4A), // Dark Gray
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF0F5),
        useMaterial3: true,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF4A4A4A),
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFABAB),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  /// Passionate Fire Theme (Premium)
  AppThemeData _getPassionateFireTheme() {
    return AppThemeData(
      type: AppThemeType.passionateFire,
      animationDuration: const Duration(milliseconds: 200),
      animationCurve: Curves.easeOutQuart,
      gradientColors: const [
        Color(0xFFE74C3C), // Crimson Red
        Color(0xFFFF6B35), // Flame Orange
        Color(0xFFFFD93D), // Golden Yellow
      ],
      fontFamily: 'Montserrat',
      themeData: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE74C3C), // Crimson Red
          secondary: Color(0xFFFF6B35), // Flame Orange
          tertiary: Color(0xFFFFD93D), // Golden Yellow
          surface: Color(0xFF2C1810), // Dark Brown

          onPrimary: Color(0xFFFFFFFF), // Pure White
          onSecondary: Color(0xFFFFFFFF), // Pure White
          onSurface: Color(0xFFFFF8DC), // Cream
        ),
        scaffoldBackgroundColor: const Color(0xFF1A0F0A),
        useMaterial3: true,
        fontFamily: 'Montserrat',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFFFFF8DC),
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF2C1810),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE74C3C),
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  /// Midnight Seduction Theme (Premium)
  AppThemeData _getMidnightSeductionTheme() {
    return AppThemeData(
      type: AppThemeType.midnightSeduction,
      animationDuration: const Duration(milliseconds: 500),
      animationCurve: Curves.easeInOutCubic,
      gradientColors: const [
        Color(0xFF6C5CE7), // Purple
        Color(0xFF8B5CF6), // Medium Purple
        Color(0xFF2D3436), // Dark Gray
      ],
      fontFamily: 'Playfair Display',
      themeData: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C5CE7), // Purple
          secondary: Color(0xFF00B894), // Mint Green
          tertiary: Color(0xFFE17055), // Coral
          surface: Color(0xFF2D3436), // Dark Gray

          onPrimary: Color(0xFFFFFFFF), // Pure White
          onSecondary: Color(0xFFFFFFFF), // Pure White
          onSurface: Color(0xFFDDD6FE), // Light Purple
        ),
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        useMaterial3: true,
        fontFamily: 'Playfair Display',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFFDDD6FE),
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF2D3436),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C5CE7),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  /// Playful Rainbow Theme (Premium)
  AppThemeData _getPlayfulRainbowTheme() {
    return AppThemeData(
      type: AppThemeType.playfulRainbow,
      animationDuration: const Duration(milliseconds: 400),
      animationCurve: Curves.bounceOut,
      gradientColors: const [
        Color(0xFFFF6B6B), // Coral Red
        Color(0xFFFFE66D), // Sunny Yellow
        Color(0xFF4ECDC4), // Turquoise
        Color(0xFF95E1D3), // Mint
      ],
      fontFamily: 'Nunito',
      themeData: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFF6B6B), // Coral Red
          secondary: Color(0xFF4ECDC4), // Turquoise
          tertiary: Color(0xFFFFE66D), // Sunny Yellow
          surface: Color(0xFFF7F7F7), // Light Gray

          onPrimary: Color(0xFFFFFFFF), // Pure White
          onSecondary: Color(0xFFFFFFFF), // Pure White
          onSurface: Color(0xFF2C3E50), // Dark Blue
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        useMaterial3: true,
        fontFamily: 'Nunito',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF2C3E50),
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFFF7F7F7),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B6B),
            foregroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ),
    );
  }

  /// Elegant Noir Theme (Premium)
  AppThemeData _getElegantNoirTheme() {
    return AppThemeData(
      type: AppThemeType.elegantNoir,
      animationDuration: const Duration(milliseconds: 400),
      animationCurve: Curves.easeInOut,
      gradientColors: const [
        Color(0xFFD4AF37), // Gold
        Color(0xFFC0C0C0), // Silver
        Color(0xFFCD7F32), // Bronze
      ],
      fontFamily: 'Cormorant Garamond',
      themeData: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37), // Gold
          secondary: Color(0xFFC0C0C0), // Silver
          tertiary: Color(0xFFCD7F32), // Bronze
          surface: Color(0xFF1C1C1C), // Charcoal
          onPrimary: Color(0xFF000000), // Black
          onSecondary: Color(0xFF000000), // Black
          onSurface: Color(0xFFFFFFFF), // Pure White
        ),
        scaffoldBackgroundColor: const Color(0xFF000000),
        useMaterial3: true,
        fontFamily: 'Cormorant Garamond',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFFFFFFFF),
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF1C1C1C),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            side: BorderSide(color: Color(0xFFD4AF37), width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: Colors.black,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  /// Tropical Paradise Theme (Premium)
  AppThemeData _getTropicalParadiseTheme() {
    return AppThemeData(
      type: AppThemeType.tropicalParadise,
      animationDuration: const Duration(milliseconds: 600),
      animationCurve: Curves.easeInOutSine,
      gradientColors: const [
        Color(0xFF00D2FF), // Cyan Blue
        Color(0xFF3A7BD5), // Ocean Blue
        Color(0xFF00F260), // Neon Green
      ],
      fontFamily: 'Poppins',
      themeData: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF00D2FF), // Cyan Blue
          secondary: Color(0xFF3A7BD5), // Ocean Blue
          tertiary: Color(0xFF00F260), // Neon Green
          surface: Color(0xFFF0FFFF), // Azure
          onPrimary: Color(0xFFFFFFFF), // Pure White
          onSecondary: Color(0xFFFFFFFF), // Pure White
          onSurface: Color(0xFF006064), // Dark Cyan
        ),
        scaffoldBackgroundColor: const Color(0xFFE0F6FF),
        useMaterial3: true,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF006064),
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFFF0FFFF),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00D2FF),
            foregroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  /// Luxury Diamond Theme (Premium)
  AppThemeData _getLuxuryDiamondTheme() {
    return AppThemeData(
      type: AppThemeType.luxuryDiamond,
      animationDuration: const Duration(milliseconds: 350),
      animationCurve: Curves.easeInOutQuart,
      gradientColors: const [
        Color(0xFFDAA520), // Goldenrod
        Color(0xFFDCDCDC), // Silver
        Color(0xFFE8E8E8), // Platinum
      ],
      fontFamily: 'Lato',
      themeData: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFE8E8E8), // Platinum
          secondary: Color(0xFF4A4A4A), // Charcoal
          tertiary: Color(0xFFB8860B), // Gold Accent
          surface: Color(0xFFF5F5F5), // Light Platinum
          onPrimary: Color(0xFF2C2C2C), // Dark Gray
          onSecondary: Color(0xFFFFFFFF), // Pure White
          onSurface: Color(0xFF2C2C2C), // Dark Gray
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        useMaterial3: true,
        fontFamily: 'Lato',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF2C2C2C),
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFFF5F5F5),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            side: BorderSide(color: Color(0xFFE8E8E8), width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE8E8E8),
            foregroundColor: const Color(0xFF2C2C2C),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ),
    );
  }

  /// Cherry Blossom Theme (Premium)
  AppThemeData _getCherryBlossomTheme() {
    return AppThemeData(
      type: AppThemeType.cherryBlossom,
      animationDuration: const Duration(milliseconds: 800),
      animationCurve: Curves.easeInOutBack,
      gradientColors: const [
        Color(0xFFFFB7C5), // Cherry Blossom Pink
        Color(0xFF98FB98), // Pale Green
        Color(0xFFFFF8DC), // Cornsilk
      ],
      fontFamily: 'Dancing Script',
      themeData: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFFB7C5), // Cherry Blossom Pink
          secondary: Color(0xFF98FB98), // Pale Green
          tertiary: Color(0xFFFFF8DC), // Cornsilk
          surface: Color(0xFFFFFAF0), // Floral White
          onPrimary: Color(0xFF8B4513), // Saddle Brown
          onSecondary: Color(0xFF228B22), // Forest Green
          onSurface: Color(0xFF8B4513), // Saddle Brown
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F8FF),
        useMaterial3: true,
        fontFamily: 'Dancing Script',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF8B4513),
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFFFFFAF0),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFB7C5),
            foregroundColor: const Color(0xFF8B4513),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
