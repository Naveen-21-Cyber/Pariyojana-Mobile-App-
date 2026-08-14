import 'package:flutter/material.dart';
import '../core/theme/velvet_colors.dart';

enum VelvetSnackBarType { success, error, info }

OverlayEntry? _currentVelvetSnackBarEntry;

class VelvetSnackBar {
  VelvetSnackBar._();

  static void showSuccess(BuildContext context, String message, {Duration duration = const Duration(seconds: 3)}) {
    _show(context, message: message, type: VelvetSnackBarType.success, duration: duration);
  }

  static void showError(BuildContext context, String message, {Duration duration = const Duration(seconds: 4)}) {
    _show(context, message: message, type: VelvetSnackBarType.error, duration: duration);
  }

  static void showInfo(BuildContext context, String message, {Duration duration = const Duration(seconds: 3)}) {
    _show(context, message: message, type: VelvetSnackBarType.info, duration: duration);
  }

  static void _show(
    BuildContext context, {
    required String message,
    required VelvetSnackBarType type,
    required Duration duration,
  }) {
    if (!context.mounted) return;

    final Color primaryColor;
    final Color secondaryColor;
    final IconData icon;

    switch (type) {
      case VelvetSnackBarType.success:
        primaryColor = VelvetColors.mint;
        secondaryColor = const Color(0xFF059669);
        icon = Icons.check_circle_rounded;
        break;
      case VelvetSnackBarType.error:
        primaryColor = const Color(0xFFEF4444);
        secondaryColor = const Color(0xFF991B1B);
        icon = Icons.error_outline_rounded;
        break;
      case VelvetSnackBarType.info:
        primaryColor = VelvetColors.coralPeach;
        secondaryColor = VelvetColors.periwinkle;
        icon = Icons.info_outline_rounded;
        break;
    }

    final cardWidget = RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Primary: ScaffoldMessenger (120 FPS Flutter engine hardware-accelerated pipeline)
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      try {
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: cardWidget,
            backgroundColor: Colors.transparent,
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 72, left: 16, right: 16),
            padding: EdgeInsets.zero,
            duration: duration,
          ),
        );
        return;
      } catch (_) {}
    }

    // Fallback: OverlayEntry insertion with isolated RepaintBoundary
    try {
      if (_currentVelvetSnackBarEntry != null) {
        try {
          _currentVelvetSnackBarEntry!.remove();
        } catch (_) {}
        _currentVelvetSnackBarEntry = null;
      }

      final overlay = Overlay.maybeOf(context, rootOverlay: true);
      if (overlay != null) {
        late OverlayEntry entry;
        entry = OverlayEntry(
          builder: (ctx) {
            final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
            final bottomPadding = bottomInset > 0 ? bottomInset + 16 : 80.0;

            return SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottomPadding, left: 16, right: 16),
                  child: Material(
                    color: Colors.transparent,
                    child: RepaintBoundary(
                      child: cardWidget,
                    ),
                  ),
                ),
              ),
            );
          },
        );

        _currentVelvetSnackBarEntry = entry;
        overlay.insert(entry);

        Future.delayed(duration, () {
          if (_currentVelvetSnackBarEntry == entry) {
            try {
              if (entry.mounted) {
                entry.remove();
              }
            } catch (_) {}
            _currentVelvetSnackBarEntry = null;
          }
        });
      }
    } catch (_) {}
  }
}

