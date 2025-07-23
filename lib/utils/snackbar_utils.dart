import 'package:flutter/material.dart';

/// Utility class for managing SnackBars globally to prevent queuing issues
/// All SnackBars use theme-aware colors for visual consistency
class SnackBarUtils {
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
        backgroundColor:
            backgroundColor ?? Theme.of(context).colorScheme.primary,
        duration: duration,
        behavior: behavior,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
        action: action,
      ),
    );
  }

  /// Shows a success SnackBar with theme primary color background
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: Theme.of(context).colorScheme.primary,
      textColor: Theme.of(context).colorScheme.onPrimary,
      duration: duration,
    );
  }

  /// Shows an error SnackBar with error color background
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: Theme.of(context).colorScheme.error,
      textColor: Theme.of(context).colorScheme.onError,
      duration: duration,
    );
  }

  /// Shows a warning SnackBar with theme tertiary color background
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      textColor: Theme.of(context).colorScheme.onSurface,
      duration: duration,
    );
  }

  /// Shows an info SnackBar with theme secondary color background
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      textColor: Theme.of(context).colorScheme.onSecondary,
      duration: duration,
    );
  }

  /// Shows a SnackBar with theme primary color background (maintains backward compatibility)
  /// Note: backgroundColor parameter is ignored to ensure theme consistency
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
      backgroundColor:
          Theme.of(context).colorScheme.primary, // Always use theme primary
      textColor: Theme.of(context).colorScheme.onPrimary,
      duration: duration,
      action: action,
    );
  }
}
