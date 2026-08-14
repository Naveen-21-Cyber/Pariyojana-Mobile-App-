import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:drift/drift.dart' as drift;
import 'package:velvet/features/presentation/navigation_shell.dart';
import '../../../../core/database/database.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../core/i18n/app_translation.dart';
import '../../../../shared_widgets/clay_card.dart';
import '../../../../shared_widgets/glass_snackbar.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../providers/project_provider.dart';
import 'package:velvet/features/ai_agents/domain/agents.dart';
import 'package:velvet/features/research_tracker/presentation/providers/research_provider.dart';
import 'package:velvet/features/job_tracker/presentation/providers/job_provider.dart';
import 'package:dio/dio.dart';
import '../../../../core/security/auth_service.dart';
import 'package:velvet/features/presentation/widgets/gantt_timeline_widget.dart';
import '../../../../shared_widgets/dynamic_island.dart';
import '../../../../shared_widgets/ai_sparkle_guide_modal.dart';
import '../../../../shared_widgets/modular_tech_stack_picker.dart';
import '../../../../core/security/credential_scanner.dart';

import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared_widgets/interactive_3d_tilt_card.dart';
import '../../../../core/network/api_rate_limiter.dart';
import 'package:velvet/features/presentation/widgets/ai_smart_digest_card.dart';
import '../widgets/github_repo_import_sheet.dart';
import '../widgets/kanban_board_view.dart';
import '../../../focus_timer/presentation/focus_timer_widget.dart';
import '../../../../shared_widgets/workspace_tab_guide_modal.dart';

final workspaceRecommendationProvider = FutureProvider<String>((ref) async {
  final projects = await ref.watch(projectsStreamProvider.future);
  final papers = await ref.watch(researchPapersStreamProvider.future);
  final jobs = await ref.watch(jobApplicationsStreamProvider.future);

  final activeCount = projects.where((p) => p.status == 'Active').length;
  final paperCount = papers.length;
  final jobCount = jobs.length;

  final summary =
      'Workspace summary: $activeCount active projects, $paperCount total research papers, $jobCount total job applications in the pipeline.';

  final agent = ref.read(recommenderAgentProvider);
  return agent.getWorkspaceRecommendation(summary);
});

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  String _selectedFilter = 'All';
  // ── Scrum Methodology Stages ────────────────────────────────────────────
  final List<String> _filters = [
    'All',
    '💡 Backlog',
    '📋 Sprint Planning',
    '🏃 In Progress',
    '🧪 In Review & QA',
    '🛡️ Security Audit',
    '✅ Done & Deployed',
  ];
  bool _isDashboardExpanded = true;
  bool _isGanttExpanded = false;
  bool _isKanbanView = false;

  void _showAddProjectSheet() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddProjectSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int?>(quickCaptureTriggerProvider, (previous, next) {
      if (next == 1) {
        _showAddProjectSheet();
        ref.read(quickCaptureTriggerProvider.notifier).state = null;
      }
    });

    ref.listen<String?>(quickAddTriggerProvider, (previous, next) {
      if (next == 'project') {
        _showAddProjectSheet();
        ref.read(quickAddTriggerProvider.notifier).state = null;
      }
    });

    final projectsAsync = ref.watch(projectsStreamProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 120.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TranslatedText(
                'Projects',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TranslatedText(
                      'Filesystem-grade engineering asset registry.',
                      style: TextStyle(
                        color: VelvetColors.textSecondary(context),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_circle_rounded, color: VelvetColors.coralPeach, size: 24),
                        tooltip: 'Add New Project 🚀',
                        onPressed: _showAddProjectSheet,
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu_book_rounded, color: VelvetColors.periwinkle),
                        tooltip: 'Projects & Architecture Guide 📖',
                        onPressed: () => WorkspaceTabGuideModal.show(context, initialTab: 'projects'),
                      ),
                      IconButton(
                        icon: Icon(_isKanbanView ? Icons.view_list_rounded : Icons.view_kanban_outlined, color: VelvetColors.coralPeach),
                        tooltip: _isKanbanView ? 'Switch to List View' : 'Switch to Kanban Board',
                        onPressed: () => setState(() => _isKanbanView = !_isKanbanView),
                      ),
                      const SizedBox(width: 4),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: VelvetColors.textPrimary(context),
                          side: BorderSide(color: VelvetColors.border(context)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        onPressed: () => GitHubRepoImportSheet.show(context),
                        icon: const Icon(Icons.download_rounded, size: 14, color: VelvetColors.coralPeach),
                        label: const Text('Import Repos', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const FocusTimerWidget(),
              const SizedBox(height: 16),

              if (_isKanbanView)
                const KanbanBoardView()
              else ...[

              // Stats pills bar — Scrum stage counts
              projectsAsync.when(
                data: (projects) {
                  final active = projects
                      .where((p) =>
                          p.status == 'IN_PROGRESS' ||
                          p.status == 'SPRINT' ||
                          p.status == 'REVIEW')
                      .length;
                  final released =
                      projects.where((p) => p.status == 'DONE').length;
                  final backlog =
                      projects.where((p) => p.status == 'BACKLOG' || p.status == 'IDEA').length;
                  return Row(
                    children: [
                      Expanded(
                        child: _StatPill(
                            label: '🏃 Active',
                            count: active,
                            color: VelvetColors.coralPeach),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatPill(
                            label: '💡 Backlog',
                            count: backlog,
                            color: VelvetColors.periwinkle),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatPill(
                            label: '✅ Done',
                            count: released,
                            color: VelvetColors.mint),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 12),

              // Feature A: Gemini AI Smart Digest Briefing Card
              const AiSmartDigestCard(),
              const SizedBox(height: 12),

              // Workspace Metrics Card — Scrum stage breakdown
              projectsAsync.when(
                data: (projects) {
                  if (projects.isEmpty) return const SizedBox.shrink();

                  // Scrum DB values
                  final ideaCount = projects.where((p) => p.status == 'BACKLOG' || p.status == 'IDEA').length;
                  final developCount = projects.where((p) => p.status == 'SPRINT' || p.status == 'DEVELOP').length;
                  final testCount = projects.where((p) => p.status == 'IN_PROGRESS' || p.status == 'TEST').length;
                  final redevelopCount = projects.where((p) => p.status == 'REVIEW' || p.status == 'REDEVELOP').length;
                  final addSecurityCount = projects.where((p) => p.status == 'SECURITY_AUDIT' || p.status == 'ADD SECURITY').length;
                  final releaseCount = projects.where((p) => p.status == 'DONE' || p.status == 'RELEASE').length;

                  final hasSegments = (ideaCount +
                          developCount +
                          testCount +
                          redevelopCount +
                          addSecurityCount +
                          releaseCount) >
                      0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ClayCard(
                      color: VelvetColors.surface(context),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              setState(() {
                                _isDashboardExpanded = !_isDashboardExpanded;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'WORKSPACE METRICS',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color: VelvetColors.periwinkle,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Icon(
                                  _isDashboardExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: VelvetColors.periwinkle,
                                ),
                              ],
                            ),
                          ),
                          if (_isDashboardExpanded) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                if (hasSegments)
                                  SizedBox(
                                    width: 110,
                                    height: 110,
                                    child: PieChart(
                                      PieChartData(
                                        sectionsSpace: 2,
                                        centerSpaceRadius: 20,
                                        sections: [
                                          if (ideaCount > 0)
                                            PieChartSectionData(
                                              color: VelvetColors.periwinkle,
                                              value: ideaCount.toDouble(),
                                              title: '$ideaCount',
                                              radius: 30,
                                              titleStyle: const TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          if (developCount > 0)
                                            PieChartSectionData(
                                              color: Colors.orangeAccent,
                                              value: developCount.toDouble(),
                                              title: '$developCount',
                                              radius: 30,
                                              titleStyle: const TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          if (testCount > 0)
                                            PieChartSectionData(
                                              color: Colors.amber,
                                              value: testCount.toDouble(),
                                              title: '$testCount',
                                              radius: 30,
                                              titleStyle: const TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          if (redevelopCount > 0)
                                            PieChartSectionData(
                                              color: Colors.redAccent,
                                              value: redevelopCount.toDouble(),
                                              title: '$redevelopCount',
                                              radius: 30,
                                              titleStyle: const TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          if (addSecurityCount > 0)
                                            PieChartSectionData(
                                              color: VelvetColors.coralPeach,
                                              value:
                                                  addSecurityCount.toDouble(),
                                              title: '$addSecurityCount',
                                              radius: 30,
                                              titleStyle: const TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          if (releaseCount > 0)
                                            PieChartSectionData(
                                              color: VelvetColors.mint,
                                              value: releaseCount.toDouble(),
                                              title: '$releaseCount',
                                              radius: 30,
                                              titleStyle: const TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: Wrap(
                                    spacing: 12,
                                    runSpacing: 8,
                                    children: [
                                      _buildLegendItem('IDEA', ideaCount,
                                          VelvetColors.periwinkle),
                                      _buildLegendItem('DEV', developCount,
                                          Colors.orangeAccent),
                                      _buildLegendItem(
                                          'TEST', testCount, Colors.amber),
                                      _buildLegendItem('REDEV', redevelopCount,
                                          Colors.redAccent),
                                      _buildLegendItem('SEC', addSecurityCount,
                                          VelvetColors.coralPeach),
                                      _buildLegendItem('RELEASE', releaseCount,
                                          VelvetColors.mint),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, s) => const SizedBox.shrink(),
              ),

              // Filter Chips
              SingleChildScrollView(
                key: const PageStorageKey('projects_scrum_filters'),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilter = filter),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? VelvetColors.coralPeach
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? VelvetColors.coralPeach
                                  : VelvetColors.border(context),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : VelvetColors.textPrimary(context),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Collapsible Gantt & Roadmap Card
              ClayCard(
                color: VelvetColors.surface(context),
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _isGanttExpanded = !_isGanttExpanded),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.timeline_rounded, color: VelvetColors.coralPeach, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Master Gantt & Sprints Roadmap',
                                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: VelvetColors.coralPeach.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _isGanttExpanded ? 'Collapse ▲' : 'Expand Roadmap ▼',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VelvetColors.coralPeach),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isGanttExpanded) ...[
                      const SizedBox(height: 12),
                      const GanttTimelineWidget(),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              projectsAsync.when(
                data: (projects) {
                  final filtered = projects.where((p) {
                    if (_selectedFilter == 'All') return true;
                    final f = _selectedFilter.toLowerCase();
                    final s = p.status.toLowerCase();
                    // Scrum stage matching
                    if (f.contains('backlog') && (s == 'backlog' || s == 'idea')) return true;
                    if (f.contains('sprint') && (s == 'sprint' || s == 'develop')) return true;
                    if (f.contains('in progress') && (s == 'in_progress' || s == 'test')) return true;
                    if (f.contains('review') && (s == 'review' || s == 'redevelop')) return true;
                    if (f.contains('security') && (s == 'security_audit' || s.contains('security'))) return true;
                    if (f.contains('done') && (s == 'done' || s == 'release')) return true;
                    return p.status == _selectedFilter;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            VelvetColors.coralPeach.withValues(alpha: 0.15),
                            VelvetColors.periwinkle.withValues(alpha: 0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: VelvetColors.coralPeach.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: VelvetColors.coralPeach.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: VelvetColors.coralPeach.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: VelvetColors.coralPeach, width: 1.5),
                            ),
                            child: const Icon(Icons.folder_open_outlined, size: 36, color: VelvetColors.coralPeach),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No $_selectedFilter Projects Found',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: VelvetColors.textPrimary(context)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Track local codebase directories, link GitHub repositories, and log milestone deliverables.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: VelvetColors.textSecondary(context)),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            onPressed: _showAddProjectSheet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: VelvetColors.coralPeach,
                              foregroundColor: Colors.white,
                              elevation: 3,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Add New Project', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: filtered.asMap().entries.map((entry) {
                      final index = entry.key;
                      final project = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Interactive3DTiltCard(
                          child: _ProjectCard(project: project),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: (index * 40).ms)
                            .scale(begin: const Offset(0.92, 0.92), curve: Curves.easeOutBack),
                      );
                    }).toList(),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, _) =>
                    Center(child: Text('Error loading projects: $err')),
              ),
              const SizedBox(height: 40),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 10,
            color: VelvetColors.textPrimary(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatPill(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.45),
          width: 1.0,
        ),
      ),
      child: Text(
        '$label $count',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: VelvetColors.textPrimary(context),
        ),
      ),
    );
  }
}


class _ProjectCard extends ConsumerWidget {
  final Project project;

  const _ProjectCard({required this.project});

  Color _getStatusColor(String status) {
    final s = status.toUpperCase();
    // ── Scrum Methodology stages ─────────────────────────────────────────
    if (s == 'BACKLOG' || s == 'IDEA') return VelvetColors.periwinkle;
    if (s == 'SPRINT' || s == 'DEVELOP') return VelvetColors.coralPeach;
    if (s == 'IN_PROGRESS' || s == 'TEST') return const Color(0xFFFF8C42);
    if (s == 'REVIEW' || s == 'REDEVELOP') return Colors.amber.shade700;
    if (s == 'SECURITY_AUDIT' || s.contains('SECURITY')) return Colors.deepPurple;
    if (s == 'DONE' || s == 'RELEASE') return VelvetColors.mint;
    // Legacy fallback
    if (status.contains('Concept') || status.contains('Spec')) return VelvetColors.periwinkle;
    if (status.contains('Development')) return VelvetColors.coralPeach;
    if (status.contains('QA')) return Colors.amber.shade700;
    if (status.contains('Maintained') || status.contains('Live')) return VelvetColors.mint;
    return VelvetColors.periwinkle;
  }

  Future<void> _publishProjectToGitHub(BuildContext context, WidgetRef ref, Project project) async {
    if (!ApiRateLimiter.checkAndConsume(context, featureName: 'GitHub Publish API')) return;

    final secureStorage = ref.read(secureStorageProvider);
    final pat = await secureStorage.readSetting('velvet_github_pat') ??
        (dotenv.isInitialized ? dotenv.env['GITHUB_PAT'] : null);
    if (!context.mounted) return;
    
    if (pat == null || pat.trim().isEmpty) {
      showGlassSnackBar(
        context,
        message: 'No GitHub PAT configured. Please go to Settings to link your account.',
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.amber,
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VelvetColors.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Publish to GitHub?',
          style: TextStyle(color: VelvetColors.textPrimary(context), fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Do you want to create a private remote GitHub repository for "${project.name}"?',
          style: TextStyle(color: VelvetColors.textPrimary(context)),
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: VelvetColors.textPrimary(context),
              side: const BorderSide(color: VelvetColors.clayTan),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: VelvetColors.coralPeach,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Publish'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (context.mounted) {
      showGlassSnackBar(
        context,
        message: 'Publishing to GitHub...',
        icon: Icons.sync,
        iconColor: VelvetColors.periwinkle,
      );
    }

    try {
      final dio = Dio();
      final slugName = project.name
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9_-]+'), '-')
          .replaceAll(RegExp(r'-+'), '-')
          .replaceAll(RegExp(r'^-+|-+$'), '');

      final response = await dio.post<Map<String, dynamic>>(
        'https://api.github.com/user/repos',
        data: {
          'name': slugName,
          'description': project.description ?? 'Created via Pariyojana App',
          'private': true,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${pat.trim()}',
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
          },
        ),
      );

      final repoUrl = response.data?['html_url'] as String? ?? 'https://github.';
      await Clipboard.setData(ClipboardData(text: repoUrl));

      if (context.mounted) {
        showGlassSnackBar(
          context,
          message: 'Repository created! Link copied to clipboard. 🚀',
          icon: Icons.check_circle_outline,
          iconColor: Colors.green,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showGlassSnackBar(
          context,
          message: 'GitHub publishing failed: $e',
          icon: Icons.error_outline,
          iconColor: Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(projectTasksStreamProvider(project.id));
    final statusColor = _getStatusColor(project.status);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GestureDetector(
        onTap: () => context.go('/projects/${project.id}'),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                statusColor.withValues(alpha: 0.15),
                VelvetColors.cardSurface(context),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.45),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left status strip — vivid & wide
                Container(
                  width: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [statusColor, statusColor.withValues(alpha: 0.7)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                    ),
                  ),
                ),
                // Card content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                project.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: VelvetColors.textPrimary(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.code_rounded, size: 18, color: VelvetColors.iconColor(context)),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: 'Publish to GitHub',
                              onPressed: () => _publishProjectToGitHub(context, ref, project),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                project.status,
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (project.description != null && project.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            project.description!,
                            style: TextStyle(
                              fontSize: 12,
                              color: VelvetColors.textSecondary(context),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            Builder(
                              builder: (_) {
                                Color bg;
                                Color fg;
                                final p = project.priority.toLowerCase();
                                if (p == 'high' || p == 'urgent' || p == 'critical') {
                                  bg = const Color(0xFFFFEBEE);
                                  fg = const Color(0xFFC62828);
                                } else if (p == 'medium') {
                                  bg = const Color(0xFFFFF3E0);
                                  fg = const Color(0xFFE65100);
                                } else {
                                  bg = const Color(0xFFE8F5E9);
                                  fg = const Color(0xFF2E7D32);
                                }
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: bg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: fg.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    '⚡ ${project.priority} Priority',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
                                  ),
                                );
                              },
                            ),
                            if (project.deadline != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: VelvetColors.periwinkle.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '📅 Due: ${project.deadline!.day}/${project.deadline!.month}/${project.deadline!.year}',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                                ),
                              ),
                            if (project.repoUrl != null && project.repoUrl!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.teal.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.link, size: 10, color: Colors.teal),
                                    const SizedBox(width: 3),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 120),
                                      child: Text(
                                        project.repoUrl!,
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        if (project.techStack != null && project.techStack!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 4,
                            runSpacing: 3,
                            children: project.techStack!.split(',').take(5).map((tech) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  tech.trim(),
                                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: statusColor),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        if (project.notes != null && project.notes!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            '📝 Notes: ${project.notes}',
                            style: TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: VelvetColors.textSecondary(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (project.storagePath != null &&
                            project.storagePath!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${project.storageDrive ?? ''}${project.storagePath}',
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
                              color: VelvetColors.textSecondary(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 10),
                        // Progress bar
                        tasksAsync.when(
                          data: (tasks) {
                            if (tasks.isEmpty) {
                              return Text(
                                'No tasks yet',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: VelvetColors.textSecondary(context),
                                ),
                              );
                            }
                            final completed =
                                tasks.where((t) => t.isCompleted).length;
                            final total = tasks.length;
                            final ratio = completed / total;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Tasks: $completed/$total',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: VelvetColors.textSecondary(context),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${(ratio * 100).toInt()}%',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: VelvetColors.coralPeach,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: ratio,
                                    backgroundColor: VelvetColors.chipBg(context),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            VelvetColors.coralPeach),
                                    minHeight: 5,
                                  ),
                                ),
                              ],
                            );
                          },
                          loading: () => const SizedBox(height: 5),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddProjectSheet extends ConsumerStatefulWidget {
  const _AddProjectSheet();

  @override
  ConsumerState<_AddProjectSheet> createState() => _AddProjectSheetState();
}

class _AddProjectSheetState extends ConsumerState<_AddProjectSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _repoUrlController = TextEditingController();
  final _notesController = TextEditingController();

  String _priority = 'Medium';
  String _platformType = 'Cross-Platform Mobile 📱';
  DateTime? _selectedDeadline;
  final List<String> _selectedTechStack = [];
  bool _isAutofilling = false;
  bool _createGitHubRepo = false;
  bool _isSubmitting = false;

  // ── AI Suggestions per dropdown category ─────────────────────────────────
  Map<String, List<String>> _aiSuggestions = {};
  bool _isFetchingSuggestions = false;

  String _slugify(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_-]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  Future<void> _autofill() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showGlassSnackBar(
        context,
        message: 'Please enter a project name first',
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.amber,
      );
      return;
    }

    setState(() => _isAutofilling = true);

    try {
      final agent = ref.read(autofillAgentProvider);
      final result = await agent.autofillProject(name);
      
      if (result.description.isNotEmpty) {
        _descriptionController.text = result.description;
      }
      
      if (result.techStack.isNotEmpty) {
        setState(() {
          for (final tech in result.techStack) {
            final cleaned = tech.trim();
            if (cleaned.isNotEmpty && !_selectedTechStack.contains(cleaned)) {
              _selectedTechStack.add(cleaned);
            }
          }
        });
      }


      if (mounted) {
        showGlassSnackBar(
          context,
          message: 'AI Autofill completed successfully!',
          icon: Icons.auto_awesome,
          iconColor: VelvetColors.coralPeach,
        );
      }
    } catch (e) {
      if (mounted) {
        showGlassSnackBar(
          context,
          message: 'Autofill error: $e',
          icon: Icons.error_outline,
          iconColor: Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAutofilling = false);
      }
    }
  }

  /// Generates per-category AI suggestions based on project name + platform type.
  Future<void> _generateAiSuggestions() async {
    final name = _nameController.text.trim();
    if (name.length < 3) return;
    setState(() => _isFetchingSuggestions = true);
    try {
      final agent = ref.read(autofillAgentProvider);
      // Ask the agent for structured tech recommendations
      final result = await agent.autofillProject('$name (Platform: $_platformType)');
      // Map tech stack items to categories by keyword matching
      final Map<String, List<String>> suggestions = {
        'languages': [],
        'frontend': [],
        'backend': [],
        'database': [],
        'cloud': [],
        'ai': [],
      };
      for (final tech in result.techStack) {
        final t = tech.toLowerCase();
        if (t.contains('dart') || t.contains('typescript') || t.contains('python') ||
            t.contains('rust') || t.contains('go') || t.contains('java') ||
            t.contains('swift') || t.contains('kotlin') || t.contains('c#') || t.contains('c++')) {
          suggestions['languages']!.add(tech);
        }
        if (t.contains('flutter') || t.contains('react') || t.contains('vue') ||
            t.contains('next') || t.contains('swift') || t.contains('kotlin') ||
            t.contains('svelte') || t.contains('angular') || t.contains('html') ||
            t.contains('tailwind') || t.contains('material')) {
          suggestions['frontend']!.add(tech);
        }
        if (t.contains('node') || t.contains('express') || t.contains('fastapi') ||
            t.contains('django') || t.contains('rails') || t.contains('spring') ||
            t.contains('go') || t.contains('rust') || t.contains('php') || t.contains('bun') ||
            t.contains('graphql') || t.contains('grpc')) {
          suggestions['backend']!.add(tech);
        }
        if (t.contains('sql') || t.contains('drift') || t.contains('mongo') || t.contains('postgres') ||
            t.contains('redis') || t.contains('firebase') || t.contains('supabase') ||
            t.contains('sqlite') || t.contains('vector') || t.contains('cipher')) {
          suggestions['database']!.add(tech);
        }
        if (t.contains('aws') || t.contains('gcp') || t.contains('vercel') ||
            t.contains('docker') || t.contains('netlify') || t.contains('kubernetes') ||
            t.contains('azure') || t.contains('fly') || t.contains('railway') || t.contains('actions')) {
          suggestions['cloud']!.add(tech);
        }
        if (t.contains('gpt') || t.contains('gemini') || t.contains('ml') ||
            t.contains('ai') || t.contains('langchain') || t.contains('llm') ||
            t.contains('torch') || t.contains('tensorflow') || t.contains('claude') || t.contains('deepseek')) {
          suggestions['ai']!.add(tech);
        }
      }

      // Default smart picks if empty
      if (suggestions.values.every((l) => l.isEmpty)) {
        suggestions['languages']!.addAll(['Dart', 'TypeScript', 'Python']);
        suggestions['frontend']!.addAll(['Flutter', 'React', 'TailwindCSS']);
        suggestions['backend']!.addAll(['FastAPI', 'Node.js']);
        suggestions['database']!.addAll(['SQLCipher', 'PostgreSQL']);
        suggestions['cloud']!.addAll(['Docker', 'GCP']);
        suggestions['ai']!.addAll(['Gemini 2.0', 'Claude 3.5']);
      }

      if (mounted) {
        setState(() => _aiSuggestions = suggestions);
      }
    } catch (_) {
      // Silently fail — AI suggestions are optional
    } finally {
      if (mounted) setState(() => _isFetchingSuggestions = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _repoUrlController.dispose();
    _notesController.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    // Debounced AI suggestion trigger on name change
    _nameController.addListener(() {
      final name = _nameController.text.trim();
      if (name.length >= 3) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted && _nameController.text.trim() == name) {
            _generateAiSuggestions();
          }
        });
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final repoUrl = _repoUrlController.text.trim();
    final notes = _notesController.text.trim();

    // Security Guardrail: Scan for exposed API keys & credentials
    final hasSecret = CredentialScanner.scanAndAlert(context, '$name $description $notes $repoUrl', fieldName: 'Project Asset');
    if (hasSecret) return;
    final techStack =
        _selectedTechStack.isEmpty ? null : _selectedTechStack.join(',');
    final repo = ref.read(projectRepositoryProvider);

    setState(() => _isSubmitting = true);

    if (_createGitHubRepo) {
      final secureStorage = ref.read(secureStorageProvider);
      final pat = await secureStorage.readSetting('velvet_github_pat') ??
          (dotenv.isInitialized ? dotenv.env['GITHUB_PAT'] : null);
      if (pat == null || pat.trim().isEmpty) {
        if (mounted) {
          showGlassSnackBar(
            context,
            message: 'No GitHub PAT found! Please set it in Settings.',
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.amber,
          );
        }
        setState(() => _isSubmitting = false);
        return;
      }

      try {
        final dio = Dio();
        final slugName = _slugify(name);
        await dio.post<Map<String, dynamic>>(
          'https://api.github.com/user/repos',
          data: {
            'name': slugName,
            'description': description.isEmpty ? 'Created via Pariyojana App' : description,
            'private': true,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer ${pat.trim()}',
              'Accept': 'application/vnd.github+json',
              'X-GitHub-Api-Version': '2022-11-28',
            },
          ),
        );
      } catch (e) {
        if (mounted) {
          showGlassSnackBar(
            context,
            message: 'GitHub creation failed: $e. Project created locally.',
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.amber,
          );
        }
      }
    }

    await repo.insertProject(
      ProjectsCompanion.insert(
        name: name,
        status: 'BACKLOG',
        priority: _priority,
        description: drift.Value(description.isEmpty ? null : description),
        techStack: drift.Value(techStack),
        deadline: drift.Value(_selectedDeadline),
        repoUrl: drift.Value(repoUrl.isEmpty ? null : repoUrl),
        notes: drift.Value(notes.isEmpty ? null : notes),
      ),
    );

    // Physical success haptic vibration
    await ref.read(hapticServiceProvider).successPattern();

    if (mounted) {
      Navigator.of(context).pop();
      showGlassSnackBar(
        context,
        message: _createGitHubRepo ? 'Project and GitHub repository created!' : 'Project created successfully',
      );
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: VelvetColors.textSecondary(context)),
      filled: true,
      fillColor: VelvetColors.inputFill(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: VelvetColors.border(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide:
            BorderSide(color: isDark ? Colors.white12 : VelvetColors.clayTan.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: VelvetColors.coralPeach, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: BoxDecoration(
        color: VelvetColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.50),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: VelvetColors.cocoa.withValues(alpha: 0.10),
            blurRadius: 25,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: VelvetColors.border(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.tune_rounded, color: VelvetColors.coralPeach, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Config Project Asset 🚀',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: VelvetColors.textPrimary(context),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.help_outline_rounded, color: VelvetColors.periwinkle, size: 20),
                      tooltip: 'AI Sparkle Guide ✨',
                      onPressed: () {
                        AiSparkleGuideModal.show(
                          context,
                          featureName: 'AI Smart Project Architect',
                          description: 'Analyzes your project name & description to auto-generate the optimal tech stack, recommend complementary frameworks, and evaluate architecture compatibility.',
                          capabilities: const [
                            {
                              'icon': '🪄',
                              'title': '1-Tap Auto-Architect',
                              'detail': 'Tap the Sparkle icon to auto-generate project descriptions, pick frontend, backend & databases tailored to your build.',
                            },
                            {
                              'icon': '📊',
                              'title': 'Compatibility Matrix',
                              'detail': 'Evaluates frontend & backend synergy with live compatibility scores, conflict detection, and recommended auth protocols.',
                            },
                            {
                              'icon': '🧰',
                              'title': 'Enterprise & Student Stacks',
                              'detail': 'Covers full range: Python Tkinter/PyQt, JavaFX, C# WinForms, HTML/CSS/JS, PHP/LAMP, Flutter, React 19, Next.js 15, Go, Rust & AI models.',
                            },
                          ],
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: VelvetColors.iconColor(context), size: 22),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Close sheet',
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Project Name + Sparkle Auto-fill
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: VelvetColors.textPrimary(context)),
                        decoration: _buildInputDecoration('Project Name *'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please enter project name' : null,
                        onChanged: (val) {
                          final lower = val.toLowerCase();
                          String? detectedPlat;
                          if (lower.contains('tkinter') || lower.contains('gui') || lower.contains('desktop') || lower.contains('pyqt') || lower.contains('javafx')) {
                            detectedPlat = 'Desktop / GUI App 💻';
                          } else if (lower.contains('student') || lower.contains('academic') || lower.contains('college') || lower.contains('lab')) {
                            detectedPlat = 'Student / Academic Project 🎓';
                          } else if (lower.contains('web') || lower.contains('react') || lower.contains('saas') || lower.contains('portal')) {
                            detectedPlat = 'Web Application 🌐';
                          } else if (lower.contains('api') || lower.contains('backend') || lower.contains('microservice')) {
                            detectedPlat = 'Microservice / Backend API ⚙️';
                          } else if (lower.contains('ai') || lower.contains('agent') || lower.contains('llm') || lower.contains('model')) {
                            detectedPlat = 'AI Agent / ML Pipeline 🧠';
                          } else if (lower.contains('security') || lower.contains('vault') || lower.contains('auth')) {
                            detectedPlat = 'Cybersecurity / Zero-Trust 🛡️';
                          }

                          if (detectedPlat != null && detectedPlat != _platformType) {
                            setState(() => _platformType = detectedPlat!);
                          }
                          if (val.trim().length >= 3) {
                            _generateAiSuggestions();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    _isAutofilling
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: VelvetColors.coralPeach),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.auto_awesome, color: VelvetColors.coralPeach),
                            tooltip: 'AI Smart Autofill ✨',
                            onPressed: _autofill,
                          ),
                  ],
                ),
                const SizedBox(height: 12),

                // Platform Type & Priority Level
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _platformType,
                        decoration: _buildInputDecoration('Platform Type'),
                        dropdownColor: VelvetColors.dropdownFill(context),
                        menuMaxHeight: 340,
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(20),
                        items: [
                          DropdownMenuItem(value: 'Cross-Platform Mobile 📱', child: Text('Cross-Platform Mobile 📱', style: TextStyle(fontSize: 12, color: VelvetColors.textPrimary(context)), overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Desktop / GUI App 💻', child: Text('Desktop / GUI App 💻', style: TextStyle(fontSize: 12, color: VelvetColors.textPrimary(context)), overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Student / Academic Project 🎓', child: Text('Student / Academic Project 🎓', style: TextStyle(fontSize: 12, color: VelvetColors.textPrimary(context)), overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Web Application 🌐', child: Text('Web Application 🌐', style: TextStyle(fontSize: 12, color: VelvetColors.textPrimary(context)), overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Microservice / Backend API ⚙️', child: Text('Microservice / Backend API ⚙️', style: TextStyle(fontSize: 12, color: VelvetColors.textPrimary(context)), overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'AI Agent / ML Pipeline 🧠', child: Text('AI Agent / ML Pipeline 🧠', style: TextStyle(fontSize: 12, color: VelvetColors.textPrimary(context)), overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Embedded / IoT / Robotics 🤖', child: Text('Embedded / IoT / Robotics 🤖', style: TextStyle(fontSize: 12, color: VelvetColors.textPrimary(context)), overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Cybersecurity / Zero-Trust 🛡️', child: Text('Cybersecurity / Zero-Trust 🛡️', style: TextStyle(fontSize: 12, color: VelvetColors.textPrimary(context)), overflow: TextOverflow.ellipsis)),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _platformType = val);
                            _generateAiSuggestions();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _priority,
                        decoration: _buildInputDecoration('Priority Level'),
                        dropdownColor: VelvetColors.dropdownFill(context),
                        borderRadius: BorderRadius.circular(20),
                        items: [
                          DropdownMenuItem(value: 'High', child: Text('HIGH 🔴', style: TextStyle(fontSize: 12, color: VelvetColors.textPrimary(context), fontWeight: FontWeight.bold))),
                          DropdownMenuItem(value: 'Medium', child: Text('MEDIUM 🟡', style: TextStyle(fontSize: 12, color: VelvetColors.textPrimary(context), fontWeight: FontWeight.bold))),
                          DropdownMenuItem(value: 'Low', child: Text('LOW 🟢', style: TextStyle(fontSize: 12, color: VelvetColors.textPrimary(context), fontWeight: FontWeight.bold))),
                          DropdownMenuItem(value: 'Critical', child: Text('CRITICAL ⚡', style: TextStyle(fontSize: 12, color: VelvetColors.textPrimary(context), fontWeight: FontWeight.bold))),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _priority = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  style: TextStyle(color: VelvetColors.textPrimary(context)),
                  maxLines: 2,
                  decoration: _buildInputDecoration('Project Description'),
                ),
                const SizedBox(height: 12),

                // ── AI Suggestion Status Banner ─────────────────────────────────
                if (_isFetchingSuggestions)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: VelvetColors.periwinkle.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: VelvetColors.periwinkle.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: VelvetColors.periwinkle)),
                        SizedBox(width: 10),
                        Text('🤖 AI is analysing your project...', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: VelvetColors.periwinkle)),
                      ],
                    ),
                  )
                else if (_aiSuggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: VelvetColors.coralPeach.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.25)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 14, color: VelvetColors.coralPeach),
                        SizedBox(width: 8),
                        Expanded(child: Text('★ AI picks highlighted in each dropdown below', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: VelvetColors.coralPeach))),
                      ],
                    ),
                  ),

                ModularTechStackPicker(
                  selectedTechStack: _selectedTechStack,
                  aiSuggestions: _aiSuggestions,
                  onChanged: (updated) {
                    setState(() {
                      _selectedTechStack.clear();
                      _selectedTechStack.addAll(updated);
                    });
                  },
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _repoUrlController,
                        style: const TextStyle(color: VelvetColors.cocoa),
                        decoration: _buildInputDecoration('Repository URL (GitHub/Git) (Optional)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 14)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                        );
                        if (picked != null) {
                          setState(() => _selectedDeadline = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: VelvetColors.inputFill(context),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: VelvetColors.border(context)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 18, color: VelvetColors.coralPeach),
                            const SizedBox(width: 6),
                            Text(
                              _selectedDeadline == null
                                  ? 'Set Deadline'
                                  : '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => setState(() => _createGitHubRepo = !_createGitHubRepo),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _createGitHubRepo,
                        activeColor: VelvetColors.coralPeach,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _createGitHubRepo = val);
                          }
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'Auto-create remote GitHub repository on Save',
                          style: TextStyle(
                            color: VelvetColors.cocoa,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  style: const TextStyle(color: VelvetColors.cocoa),
                  maxLines: 2,
                  decoration: _buildInputDecoration('Architecture & Project Notes'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VelvetColors.coralPeach,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rocket_launch_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Create & Launch Project Asset',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
