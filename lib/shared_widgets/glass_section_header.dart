import 'package:flutter/material.dart';
import '../core/theme/velvet_colors.dart';

/// A frosted-glass section header pill used to label groups in lists/screens.
/// Part of the glass visual language (nav/modals/dividers).
/// Optimized for 120 FPS high-refresh rate scrolling with RepaintBoundary.
class GlassSectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final double blurSigma;

  const GlassSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.blurSigma = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white.withValues(alpha: 0.90) : VelvetColors.cocoa.withValues(alpha: 0.85);
    final bgColor = isDark ? const Color(0xFF1E232B).withValues(alpha: 0.92) : VelvetColors.cream.withValues(alpha: 0.90);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.16) : VelvetColors.border(context);

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.25) : VelvetColors.cocoa.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: VelvetColors.coralPeach),
              const SizedBox(width: 6),
            ],
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 1.2,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
