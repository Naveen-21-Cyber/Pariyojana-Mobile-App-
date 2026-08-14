import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/velvet_colors.dart';
import '../../../shared_widgets/clay_card.dart';
import '../../project_tracker/presentation/providers/project_provider.dart';
import '../../job_tracker/presentation/providers/job_provider.dart';

class DailyBriefCard extends ConsumerStatefulWidget {
  const DailyBriefCard({super.key});

  @override
  ConsumerState<DailyBriefCard> createState() => _DailyBriefCardState();
}

class _DailyBriefCardState extends ConsumerState<DailyBriefCard> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    // Only display morning card until 11:00 AM device time
    final currentHour = DateTime.now().hour;
    if (currentHour >= 11) {
      return const SizedBox.shrink();
    }

    final projects = ref.watch(projectsStreamProvider).valueOrNull ?? [];
    final jobs = ref.watch(jobApplicationsStreamProvider).valueOrNull ?? [];

    final activeProjects = projects.where((p) => p.status != 'Done').take(2).toList();
    final pendingJobs = jobs.where((j) => j.status == 'Applied' || j.status == 'Shortlisted' || j.status == 'Interview' || j.status == 'Interviewing').take(2).toList();

    return ClayCard(
      color: VelvetColors.surface(context),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined, color: VelvetColors.coralPeach, size: 22),
              const SizedBox(width: 8),
              Text(
                'Daily Command Brief 🌅',
                style: TextStyle(fontFamily: GoogleFonts.outfit().fontFamily, fontSize: 15, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(_isCollapsed ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded, color: VelvetColors.coralPeach),
                onPressed: () => setState(() => _isCollapsed = !_isCollapsed),
                tooltip: _isCollapsed ? 'Expand Morning Brief' : 'Collapse Morning Brief',
              ),
            ],
          ),

          if (!_isCollapsed) ...[
            const SizedBox(height: 10),
            // Gita Verse Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: VelvetColors.coralPeach.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Text('📜', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('योगः कर्मसु कौशलम्', style: TextStyle(fontFamily: GoogleFonts.notoSans().fontFamily, fontWeight: FontWeight.bold, fontSize: 13, color: VelvetColors.textPrimary(context))),
                        const SizedBox(height: 2),
                        Text('Excellence in work is true Yoga. — BG 2.50', style: TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: VelvetColors.textSecondary(context))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // AI Action Priorities
            Text('Key Priorities Today:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
            const SizedBox(height: 6),

            if (activeProjects.isNotEmpty)
              ...activeProjects.map((p) => _buildPriorityRow(context, Icons.folder_open_outlined, 'Project: ', VelvetColors.mint)),

            if (pendingJobs.isNotEmpty)
              ...pendingJobs.map((j) => _buildPriorityRow(context, Icons.work_outline_outlined, 'Followup:  ()', VelvetColors.periwinkle)),

            if (activeProjects.isEmpty && pendingJobs.isEmpty)
              _buildPriorityRow(context, Icons.check_circle_outline, 'All active projects & jobs on track! Capture a new idea.', VelvetColors.coralPeach),
          ],
        ],
      ),
    );
  }

  Widget _buildPriorityRow(BuildContext context, IconData icon, String title, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 11.5, color: VelvetColors.textPrimary(context)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
