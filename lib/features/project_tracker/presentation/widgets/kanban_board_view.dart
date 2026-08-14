import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../shared_widgets/clay_card.dart';
import '../providers/project_provider.dart';

class KanbanBoardView extends ConsumerWidget {
  const KanbanBoardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsStreamProvider);

    return projectsAsync.when(
      data: (projects) {
        // Map all DB scrum status values to the right columns
        final todo = projects.where((p) =>
          p.status == 'BACKLOG' || p.status == 'IDEA' ||
          p.status == 'Planning' || p.status == 'Todo' ||
          p.status == 'SPRINT_PLANNING').toList();
        final inProgress = projects.where((p) =>
          p.status == 'IN_PROGRESS' || p.status == 'SPRINT' ||
          p.status == 'DEVELOP' || p.status == 'TEST' ||
          p.status == 'In Progress' || p.status == 'Building' ||
          p.status == 'REVIEW' || p.status == 'REDEVELOP' ||
          p.status == 'SECURITY_AUDIT').toList();
        final done = projects.where((p) =>
          p.status == 'DONE' || p.status == 'Done' ||
          p.status == 'Completed' || p.status == 'RELEASE').toList();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildKanbanColumn(context, ref, '📌 Planning / Todo', todo, VelvetColors.periwinkle),
              const SizedBox(width: 14),
              _buildKanbanColumn(context, ref, '⚡ In Progress', inProgress, VelvetColors.coralPeach),
              const SizedBox(width: 14),
              _buildKanbanColumn(context, ref, '✅ Done / Shipped', done, VelvetColors.mint),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: VelvetColors.coralPeach)),
      error: (e, _) => Center(child: Text('Error loading Kanban board: $e')),
    );
  }

  Widget _buildKanbanColumn(BuildContext context, WidgetRef ref, String title, List<dynamic> items, Color accent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 270,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? VelvetColors.darkSurface : VelvetColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: GoogleFonts.outfit().fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: VelvetColors.textPrimary(context),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${items.length}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: accent)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Container(
              height: 85,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.withValues(alpha: 0.12),
                    VelvetColors.surface(context),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accent.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 18, color: accent.withValues(alpha: 0.7)),
                  const SizedBox(width: 6),
                  Text('No $title Projects', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: VelvetColors.textSecondary(context))),
                ],
              ),
            )
          else
            Column(
              children: items.map((p) => _buildKanbanCard(context, ref, p, accent)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildKanbanCard(BuildContext context, WidgetRef ref, dynamic p, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: () => context.push('/projects/${p.id}'),
        borderRadius: BorderRadius.circular(14),
        child: ClayCard(
          color: VelvetColors.surface(context),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      p.name,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 12, color: VelvetColors.textSecondary(context)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                p.description.isNotEmpty ? p.description : 'No description provided.',
                style: TextStyle(fontSize: 10.5, color: VelvetColors.textSecondary(context)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    label: Text(p.techStack.isNotEmpty ? p.techStack.first : 'Flutter', style: const TextStyle(fontSize: 8.5)),
                    backgroundColor: accent.withValues(alpha: 0.15),
                  ),
                  Text(
                    p.scrumPhase ?? 'Phase 1',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: accent),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
