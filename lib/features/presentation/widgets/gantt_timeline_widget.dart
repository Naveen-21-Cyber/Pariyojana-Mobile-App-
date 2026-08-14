import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/theme/velvet_colors.dart';
import '../../../shared_widgets/clay_card.dart';
import '../../../features/project_tracker/presentation/providers/project_provider.dart';
import '../../../features/research_tracker/presentation/providers/research_provider.dart';
import '../../../features/job_tracker/presentation/providers/job_provider.dart';
import '../../../core/database/database.dart';

class GanttTimelineWidget extends ConsumerWidget {
  const GanttTimelineWidget({super.key});

  Future<void> _rescheduleProjectDeadline(BuildContext context, WidgetRef ref, Project project) async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: project.deadline ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (newDate != null) {
      final repo = ref.read(projectRepositoryProvider);
      await repo.updateProject(
        project.copyWith(
          deadline: drift.Value(newDate),
        ),
      );
      ref.invalidate(projectsStreamProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsStreamProvider);
    final papersAsync = ref.watch(researchPapersStreamProvider);
    final jobsAsync = ref.watch(jobApplicationsStreamProvider);

    return ClayCard(
      color: VelvetColors.cream,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timeline_rounded, color: VelvetColors.coralPeach, size: 22),
              SizedBox(width: 8),
              Text(
                'Master Gantt & Sprints Roadmap',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VelvetColors.cocoa),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Projects Gantt Items
          projectsAsync.when(
            data: (projects) {
              if (projects.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PROJECT SPRINTS (TAP TO RESCHEDULE 📅)', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFFC62828), letterSpacing: 1.1)),
                  const SizedBox(height: 6),
                  ...projects.take(4).map((p) {
                    final deadline = p.deadline ?? p.createdAt.add(const Duration(days: 30));
                    final diff = deadline.difference(DateTime.now()).inDays;
                    final progressFraction = (1.0 - (diff / 30).clamp(0.0, 1.0));

                    Color statusFg = const Color(0xFF00796B);
                    if (diff < 0) {
                      statusFg = const Color(0xFFC62828);
                    } else if (diff <= 5) {
                      statusFg = const Color(0xFFE65100);
                    }

                    return InkWell(
                      onTap: () => _rescheduleProjectDeadline(context, ref, p),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    p.name,
                                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: VelvetColors.cocoa),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusFg.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${p.status} • ${diff < 0 ? "Overdue" : "$diff d left"}',
                                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: statusFg),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.edit_calendar_rounded, size: 13, color: Color(0xFFC62828)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progressFraction.clamp(0.05, 1.0),
                                minHeight: 6,
                                backgroundColor: VelvetColors.clayTan.withValues(alpha: 0.35),
                                valueColor: AlwaysStoppedAnimation<Color>(statusFg),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 10),

          // Papers Gantt Items
          papersAsync.when(
            data: (papers) {
              final withDeadlines = papers.where((p) => p.submissionDeadline != null).toList();
              if (withDeadlines.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('RESEARCH SUBMISSION MILESTONES 📚', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF1565C0), letterSpacing: 1.1)),
                  const SizedBox(height: 6),
                  ...withDeadlines.take(3).map((p) {
                    final dateStr = DateFormat('MMM dd, yyyy').format(p.submissionDeadline!);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.0),
                      child: Row(
                        children: [
                          const Icon(Icons.event_note_rounded, size: 14, color: Color(0xFF1565C0)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(p.title, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1A1110)), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1565C0).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(dateStr, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 10),

          // Job Follow-ups Gantt Items
          jobsAsync.when(
            data: (jobs) {
              final withFollowups = jobs.where((j) => j.followUpDate != null).toList();
              if (withFollowups.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('JOB FOLLOW-UP DEADLINES 🔔', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF00796B), letterSpacing: 1.1)),
                  const SizedBox(height: 6),
                  ...withFollowups.take(3).map((j) {
                    final dateStr = DateFormat('MMM dd').format(j.followUpDate!);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.0),
                      child: Row(
                        children: [
                          const Icon(Icons.alarm_rounded, size: 14, color: Color(0xFF00796B)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text('${j.role} at ${j.company}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1A1110)), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00796B).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(dateStr, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF00796B))),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
