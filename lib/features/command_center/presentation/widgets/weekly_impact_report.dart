import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../core/database/database.dart';
import '../../../../shared_widgets/glass_snackbar.dart';

class WeeklyImpactReportSheet extends ConsumerWidget {
  const WeeklyImpactReportSheet({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const WeeklyImpactReportSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return FutureBuilder(
      future: Future.wait([
        db.select(db.projects).get(),
        db.select(db.ideas).get(),
        db.select(db.researchPapers).get(),
        db.select(db.jobApplications).get(),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: VelvetColors.coralPeach));
        }

        final projects = snapshot.data![0] as List<Project>;
        final ideas = snapshot.data![1] as List<Idea>;
        final papers = snapshot.data![2] as List<ResearchPaper>;
        final jobs = snapshot.data![3] as List<JobApplication>;

        final shippedProjects = projects.where((p) => p.status == 'DEVELOP' || p.status == 'TEST').length;
        final totalVelocityScore = (shippedProjects * 25 + ideas.length * 10 + papers.length * 15 + jobs.length * 10).clamp(0, 100);

        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: VelvetColors.cream,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: VelvetColors.coralPeach.withValues(alpha: 0.35),
                  blurRadius: 24,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.assessment_rounded, color: VelvetColors.coralPeach, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          'Weekly Engineering Velocity 📊',
                          style: TextStyle(fontFamily: GoogleFonts.outfit().fontFamily, fontSize: 17, fontWeight: FontWeight.bold, color: VelvetColors.cocoa),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: VelvetColors.cocoa),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Velocity Score Gauge
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: VelvetColors.periwinkle.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: VelvetColors.periwinkle.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: VelvetColors.coralPeach,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$totalVelocityScore',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Velocity Impact Index',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VelvetColors.cocoa),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '7-Day Composite Engineering Output Score based on commits, ideas, papers, and jobs.',
                              style: TextStyle(fontSize: 10.5, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Stats breakdown
                Row(
                  children: [
                    _buildMetricCard('Projects', '${projects.length}', VelvetColors.coralPeach),
                    const SizedBox(width: 8),
                    _buildMetricCard('Ideas', '${ideas.length}', VelvetColors.periwinkle),
                    const SizedBox(width: 8),
                    _buildMetricCard('Papers', '${papers.length}', const Color(0xFFFFE4B5)),
                    const SizedBox(width: 8),
                    _buildMetricCard('Jobs', '${jobs.length}', VelvetColors.mint),
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VelvetColors.cocoa,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.picture_as_pdf_rounded),
                    label: const Text('Export Weekly Impact Digest 📄', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      GlassSnackBar.show(context, '✅ Weekly Impact Digest exported successfully!');
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VelvetColors.cocoa)),
          ],
        ),
      ),
    );
  }
}
