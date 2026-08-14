import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/velvet_colors.dart';

class SkeuoFolderTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const SkeuoFolderTab({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeColor = isDark ? const Color(0xFF21262D) : VelvetColors.clayTan;
    final inactiveColor = isDark 
        ? const Color(0xFF161B22).withValues(alpha: 0.8)
        : VelvetColors.cream.withValues(alpha: 0.8);
    final textColor = isDark ? const Color(0xFFE6EDF3) : VelvetColors.cocoa;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : inactiveColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: isDark ? Colors.black45 : VelvetColors.cocoa.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, -3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: isDark ? Colors.black26 : VelvetColors.cocoa.withValues(alpha: 0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
          border: Border.all(
            color: isSelected 
                ? (isDark ? Colors.white24 : Colors.white.withValues(alpha: 0.5)) 
                : Colors.black.withValues(alpha: 0.08),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected 
                    ? VelvetColors.coralPeach 
                    : textColor.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: GoogleFonts.outfit().fontFamily,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
                color: isSelected 
                    ? (isDark ? const Color(0xFFE6EDF3) : VelvetColors.cocoa) 
                    : textColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
