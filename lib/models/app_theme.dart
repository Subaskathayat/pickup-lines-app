import 'package:flutter/material.dart';

/// Enum representing all available themes in the app
enum AppThemeType {
  sweetRomantic('Sweet & Romantic', '🌸', false),
  passionateFire('Passionate Fire', '🔥', true),
  midnightSeduction('Midnight Seduction', '🌙', true),
  playfulRainbow('Playful Rainbow', '🌈', true),
  elegantNoir('Elegant Noir', '🖤', true),
  tropicalParadise('Tropical Paradise', '🌺', true),
  luxuryDiamond('Luxury Diamond', '💎', true),
  cherryBlossom('Cherry Blossom', '🌸', true);

  const AppThemeType(this.displayName, this.emoji, this.isPremium);

  final String displayName;
  final String emoji;
  final bool isPremium;

  /// Get the theme ID for storage
  String get id => name;

  /// Get display name with emoji
  String get displayNameWithEmoji => '$emoji $displayName';
}

/// Model class representing theme-specific properties
class AppThemeData {
  final AppThemeType type;
  final ThemeData themeData;
  final Duration animationDuration;
  final Curve animationCurve;
  final List<Color> gradientColors;
  final String fontFamily;

  const AppThemeData({
    required this.type,
    required this.themeData,
    required this.animationDuration,
    required this.animationCurve,
    required this.gradientColors,
    required this.fontFamily,
  });

  /// Check if this theme is premium
  bool get isPremium => type.isPremium;

  /// Get theme display name
  String get displayName => type.displayName;

  /// Get theme emoji
  String get emoji => type.emoji;

  /// Get theme ID
  String get id => type.id;
}

/// Extension to get theme-specific gradient decorations
extension AppThemeDataExtensions on AppThemeData {
  /// Get a gradient decoration for containers
  BoxDecoration get gradientDecoration => BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );

  /// Get a vertical gradient decoration
  BoxDecoration get verticalGradientDecoration => BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      );

  /// Get a horizontal gradient decoration
  BoxDecoration get horizontalGradientDecoration => BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      );
}
