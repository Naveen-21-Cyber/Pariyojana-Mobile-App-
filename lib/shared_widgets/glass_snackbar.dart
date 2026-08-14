import 'package:flutter/material.dart';
import 'velvet_snack_bar.dart';

/// Premium VelvetSnackBar redirection wrapper.
/// Ensures 100% of snackbars across the entire app render floating VelvetSnackBar gradient popups.

void showGlassSnackBar(
  BuildContext context, {
  required String message,
  IconData icon = Icons.check_circle_rounded,
  Color iconColor = const Color(0xFF4CAF50),
  Duration duration = const Duration(seconds: 3),
  Color? accentColor,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  if (!context.mounted) return;
  VelvetSnackBar.showSuccess(context, message, duration: duration);
}

/// Error variant.
void showGlassErrorSnackBar(BuildContext context, {required String message}) {
  VelvetSnackBar.showError(context, message);
}

/// Warning variant.
void showGlassWarningSnackBar(BuildContext context, {required String message}) {
  VelvetSnackBar.showError(context, message);
}

/// Info variant.
void showGlassInfoSnackBar(BuildContext context, {required String message}) {
  VelvetSnackBar.showInfo(context, message);
}

class GlassSnackBar {
  static void show(
    BuildContext context,
    String message, {
    IconData icon = Icons.check_circle_rounded,
    Color iconColor = const Color(0xFF4CAF50),
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    VelvetSnackBar.showSuccess(context, message, duration: duration);
  }
}
