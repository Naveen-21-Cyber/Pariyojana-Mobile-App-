import 'package:flutter/material.dart';
import '../../../../core/database/database.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../shared_widgets/clay_card.dart';

class JobAnalyticsFunnel extends StatelessWidget {
  final List<JobApplication> jobs;

  const JobAnalyticsFunnel({
    super.key,
    required this.jobs,
  });

  @override
  Widget build(BuildContext context) {
    final total = jobs.length;
    final saved = jobs.where((j) => j.status == 'Saved').length;
    final applied = jobs.where((j) => j.status == 'Applied' || j.status == 'Outreach Sent').length;
    final shortlisted = jobs.where((j) => j.status == 'Shortlisted' || j.status == 'Response').length;
    final interview = jobs.where((j) => j.status == 'Interview' || j.status == 'Interviewing').length;
    final offer = jobs.where((j) => j.status == 'Offer' || j.status == 'Offered').length;

    // Calculate response rate
    final activeApplications = applied + shortlisted + interview + offer;
    final totalResponses = shortlisted + interview + offer;
    final responseRate = activeApplications == 0 ? 0 : ((totalResponses / activeApplications) * 100).toInt();

    return ClayCard(
      color: VelvetColors.cardSurface(context),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.filter_alt_outlined, color: VelvetColors.coralPeach, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Job Application Pipeline Funnel',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: VelvetColors.mint.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Response: $responseRate%',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Funnel visual bars (5 Core Stages)
          _buildFunnelRow(context, '1. Saved', saved, total, const Color(0xFF64748B)),
          _buildFunnelRow(context, '2. Applied', applied, total, const Color(0xFF3B82F6)),
          _buildFunnelRow(context, '3. Shortlisted', shortlisted, total, const Color(0xFF8B5CF6)),
          _buildFunnelRow(context, '4. Interview', interview, total, const Color(0xFFF97316)),
          _buildFunnelRow(context, '5. Offer 🎯', offer, total, const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildFunnelRow(BuildContext context, String label, int count, int total, Color color) {
    final fraction = total == 0 ? 0.0 : (count / total).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: VelvetColors.textPrimary(context)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: fraction == 0 ? 0.02 : fraction,
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 24,
            child: Text(
              '$count',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
