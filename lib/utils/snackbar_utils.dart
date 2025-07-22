import 'package:flutter/material.dart';

/// Utility class for managing SnackBars globally to prevent queuing issues
/// All SnackBars use the app's coral pink theme for visual consistency
class SnackBarUtils {
  /// App's primary coral pink color for consistent SnackBar styling
  static const Color _primarySnackBarColor = Color(0xFFFFABAB);

  /// Shows a SnackBar and clears any existing ones to prevent queuing
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 2),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    BorderRadius? borderRadius,
    SnackBarAction? action,
  }) {
    // Clear any existing SnackBars first
    ScaffoldMessenger.of(context).clearSnackBars();

    // Show the new SnackBar with consistent styling
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: backgroundColor ?? _primarySnackBarColor,
        duration: duration,
        behavior: behavior,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
        action: action,
      ),
    );
  }

  /// Shows a success SnackBar with coral pink background
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: _primarySnackBarColor,
      textColor: Colors.white,
      duration: duration,
    );
  }

  /// Shows an error SnackBar with coral pink background
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: _primarySnackBarColor,
      textColor: Colors.white,
      duration: duration,
    );
  }

  /// Shows a warning SnackBar with coral pink background
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: _primarySnackBarColor,
      textColor: Colors.white,
      duration: duration,
    );
  }

  /// Shows an info SnackBar with coral pink background
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: _primarySnackBarColor,
      textColor: Colors.white,
      duration: duration,
    );
  }

  /// Shows a SnackBar with coral pink background (maintains backward compatibility)
  /// Note: backgroundColor parameter is ignored to ensure consistency
  static void showCustom(
    BuildContext context,
    String message,
    Color backgroundColor, {
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: _primarySnackBarColor, // Always use coral pink
      textColor: Colors.white,
      duration: duration,
      action: action,
    );
  }
}
