import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/velvet_colors.dart';

class ContributionHeatmap extends StatelessWidget {
  final Map<DateTime, int> activityCounts;

  const ContributionHeatmap({
    super.key,
    required this.activityCounts,
  });

  Color _getColor(int count) {
    if (count == 0) return VelvetColors.clayTan.withValues(alpha: 0.12);
    if (count == 1) return VelvetColors.mint.withValues(alpha: 0.35);
    if (count <= 3) return VelvetColors.mint.withValues(alpha: 0.65);
    if (count <= 5) return VelvetColors.coralPeach.withValues(alpha: 0.85);
    return VelvetColors.coralPeach;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Build 12 weeks of historical activity
    final weeks = List.generate(12, (w) {
      return List.generate(7, (d) {
        final date = now.subtract(Duration(days: ((11 - w) * 7) + (6 - d)));
        final dateKey = DateTime(date.year, date.month, date.day);
        final count = activityCounts[dateKey] ?? 0;
        return count;
      });
    });

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: VelvetColors.cream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: VelvetColors.clayTan.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.grid_on_rounded, size: 16, color: VelvetColors.coralPeach),
                  const SizedBox(width: 6),
                  Text(
                    'Engineering Activity Heatmap',
                    style: TextStyle(
                      fontFamily: GoogleFonts.outfit().fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: VelvetColors.cocoa,
                    ),
                  ),
                ],
              ),
              Text(
                'Last 90 Days',
                style: TextStyle(
                  fontFamily: GoogleFonts.outfit().fontFamily,
                  fontSize: 10,
                  color: VelvetColors.clayTan,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: weeks.map((week) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Column(
                    children: week.map((count) {
                      return Container(
                        width: 13,
                        height: 13,
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: _getColor(count),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Less ', style: TextStyle(fontSize: 9, color: VelvetColors.cocoa)),
              Container(width: 8, height: 8, color: VelvetColors.clayTan.withValues(alpha: 0.12)),
              const SizedBox(width: 3),
              Container(width: 8, height: 8, color: VelvetColors.mint.withValues(alpha: 0.4)),
              const SizedBox(width: 3),
              Container(width: 8, height: 8, color: VelvetColors.coralPeach),
              const SizedBox(width: 3),
              const Text(' More', style: TextStyle(fontSize: 9, color: VelvetColors.cocoa)),
            ],
          ),
        ],
      ),
    );
  }
}
