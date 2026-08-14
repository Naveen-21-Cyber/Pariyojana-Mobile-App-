import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:collection/collection.dart';
import '../../../../core/database/database.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../shared_widgets/clay_card.dart';
import '../../../../shared_widgets/glass_snackbar.dart';
import '../../../../shared_widgets/velvet_snack_bar.dart';
import '../../../../shared_widgets/modular_tech_stack_picker.dart';
import '../../../../shared_widgets/particle_explosion.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../research_tracker/presentation/providers/research_provider.dart';
import '../../../job_tracker/presentation/providers/job_provider.dart';
import '../providers/project_provider.dart';
import '../widgets/folder_tree_widget.dart';
import '../widgets/security_hardening_scanner.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/security/auth_service.dart';
import '../../../../core/profile/user_profile_provider.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final int projectId;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  final TextEditingController _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    final title = _taskController.text.trim();
    if (title.isEmpty) return;

    final companion = ProjectTasksCompanion.insert(
      projectId: widget.projectId,
      title: title,
    );

    await ref.read(projectRepositoryProvider).insertProjectTask(companion);
    _taskController.clear();
  }

  Future<void> _toggleTask(ProjectTask task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await ref.read(projectRepositoryProvider).updateProjectTask(updated);
    if (updated.isCompleted && mounted) {
      final size = MediaQuery.of(context).size;
      ParticleExplosion.show(
        context,
        Offset(size.width / 2, size.height * 0.45),
        color: VelvetColors.coralPeach,
      );
    }
  }

  Future<void> _deleteTask(int id) async {
    await ref.read(projectRepositoryProvider).deleteProjectTask(id);
  }

  Future<void> _updateStatus(Project project, String newStatus) async {
    final updated = project.copyWith(status: newStatus);
    final success = await ref.read(projectRepositoryProvider).updateProject(updated);
    
    // Medium haptic response for milestone update
    await ref.read(hapticServiceProvider).mediumImpact();

    if (success && mounted) {
      showGlassSnackBar(
        context,
        message: 'Project milestone updated to $newStatus',
      );
    }
  }

  void _showEditPathDialog(Project project) {
    final osController = TextEditingController(text: project.storageOs);
    final driveController = TextEditingController(text: project.storageDrive);
    final pathController = TextEditingController(text: project.storagePath);
    final backupController = TextEditingController(text: project.backupPath);
    final subfoldersController = TextEditingController(
      text: project.storageSubfoldersJson != null
          ? (jsonDecode(project.storageSubfoldersJson!) as List).join(', ')
          : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VelvetColors.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Modify FileSystem Path',
          style: TextStyle(color: VelvetColors.textPrimary(context), fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: osController,
                style: TextStyle(color: VelvetColors.textPrimary(context)),
                decoration: const InputDecoration(
                  labelText: 'Target OS',
                  hintText: 'e.g. Windows, Linux, macOS',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: driveController,
                style: TextStyle(color: VelvetColors.textPrimary(context)),
                decoration: const InputDecoration(
                  labelText: 'Drive / Mount Point',
                  hintText: 'e.g. E:, /mnt',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: pathController,
                style: TextStyle(color: VelvetColors.textPrimary(context)),
                decoration: const InputDecoration(
                  labelText: 'Manual Path / Estimated Path',
                  hintText: 'e.g. \\Projects\\Pariyojana\\',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: backupController,
                style: TextStyle(color: VelvetColors.textPrimary(context)),
                decoration: const InputDecoration(
                  labelText: 'Backup Path',
                  hintText: 'e.g. E:\\Backups\\',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: subfoldersController,
                style: TextStyle(color: VelvetColors.textPrimary(context)),
                decoration: const InputDecoration(
                  labelText: 'Subfolders (comma-separated)',
                  hintText: 'e.g. src, tests, docs',
                ),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: VelvetColors.textPrimary(context),
              side: BorderSide(color: VelvetColors.border(context)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: VelvetColors.coralPeach,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              List<String>? subfolders;
              if (subfoldersController.text.trim().isNotEmpty) {
                subfolders = subfoldersController.text
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList();
              }
              final updated = project.copyWith(
                storageOs: drift.Value(osController.text.trim().isEmpty ? null : osController.text.trim()),
                storageDrive: drift.Value(driveController.text.trim().isEmpty ? null : driveController.text.trim()),
                storagePath: drift.Value(pathController.text.trim().isEmpty ? null : pathController.text.trim()),
                backupPath: drift.Value(backupController.text.trim().isEmpty ? null : backupController.text.trim()),
                storageSubfoldersJson: drift.Value(subfolders != null ? jsonEncode(subfolders) : null),
              );
              await ref.read(projectRepositoryProvider).updateProject(updated);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showSecondConfirmationDialog(Project project) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VelvetColors.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            Text(
              'Final Confirmation',
              style: TextStyle(color: VelvetColors.textPrimary(context), fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          'Are you absolutely certain? This will delete project "${project.name}" and purge all its associated checklist subtasks from the local encrypted database. There is no undo.',
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: VelvetColors.textSecondary(context),
              side: BorderSide(color: VelvetColors.border(context)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, Purge Everything'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _deleteProject(Project project) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VelvetColors.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Project', style: TextStyle(color: VelvetColors.textPrimary(context), fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to permanently delete project "${project.name}"? This action cannot be undone.'),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: VelvetColors.textSecondary(context),
              side: BorderSide(color: VelvetColors.border(context)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final secondConfirm = await _showSecondConfirmationDialog(project);
      if (secondConfirm == true) {
        try {
          final success = await ref.read(projectRepositoryProvider).deleteProject(project.id);
          
          // Heavy warning vibration for project deletion
          await ref.read(hapticServiceProvider).warningPulse();

          if (success && mounted) {
            showGlassSnackBar(
              context,
              message: 'Project deleted successfully',
            );
            context.pop(); // Go back to projects list
          } else {
            if (mounted) {
              showGlassErrorSnackBar(
                context,
                message: 'Failed to delete project: No rows affected',
              );
            }
          }
        } catch (e) {
          if (mounted) {
            showGlassErrorSnackBar(
              context,
              message: 'Error deleting project: $e',
            );
          }
        }
      }
    }
  }

  void _showEditProjectSheet(Project project) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditProjectSheet(project: project),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsStreamProvider);
    final tasksAsync = ref.watch(projectTasksStreamProvider(widget.projectId));
    final papersAsync = ref.watch(researchPapersStreamProvider);
    final jobsAsync = ref.watch(jobApplicationsStreamProvider);

    return Scaffold(
      backgroundColor: VelvetColors.surface(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: VelvetColors.iconColor(context)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Project Details',
          style: TextStyle(color: VelvetColors.textPrimary(context), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: projectsAsync.when(
          data: (projects) {
            final project = projects.firstWhereOrNull((p) => p.id == widget.projectId);
            if (project == null) return [];
            return [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: VelvetColors.periwinkle),
                tooltip: 'Edit Project Details',
                onPressed: () => _showEditProjectSheet(project),
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                tooltip: 'Delete Project',
                onPressed: () => _deleteProject(project),
              ),
            ];
          },
          loading: () => [],
          error: (_, __) => [],
        ),
      ),
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! > 12) {
            context.pop();
          }
        },
        child: projectsAsync.when(
        data: (projects) {
          final project = projects.firstWhereOrNull(
            (p) => p.id == widget.projectId,
          );

          if (project == null) {
            return const Center(child: Text('Project not found'));
          }

          return tasksAsync.when(
            data: (tasks) {
              final completedCount = tasks.where((t) => t.isCompleted).length;
              final totalCount = tasks.length;
              final percent = totalCount == 0 ? 0.0 : completedCount / totalCount;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 100.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Overview clay card with progress circle
                    ClayCard(
                      color: VelvetColors.surface(context),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Text(
                                    project.name,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          color: VelvetColors.textPrimary(context),
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Created: ${DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(project.createdAt)}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
                                      color: VelvetColors.textSecondary(context),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      _buildBadge(project.status, VelvetColors.periwinkle),
                                      _buildBadge('${project.priority} Priority', VelvetColors.coralPeach),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          CircularPercentIndicator(
                            radius: 40.0,
                            lineWidth: 8.0,
                            percent: percent,
                            center: Text(
                              '${(percent * 100).toInt()}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: VelvetColors.textPrimary(context),
                              ),
                            ),
                            circularStrokeCap: CircularStrokeCap.round,
                            backgroundColor: VelvetColors.clayTan.withValues(alpha: 0.3),
                            progressColor: VelvetColors.coralPeach,
                          ),
                        ],
                      ),
                    ),

                    if (project.description != null || project.techStack != null) ...[
                      const SizedBox(height: 16),
                      ClayCard(
                        color: VelvetColors.surface(context),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (project.description != null) ...[
                              const Text(
                                'PROJECT BRIEF / METADATA',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VelvetColors.coralPeach, letterSpacing: 1.1),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                project.description!,
                                style: TextStyle(fontSize: 13, color: VelvetColors.textPrimary(context), height: 1.4),
                              ),
                            ],
                            if (project.deadline != null) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 14, color: VelvetColors.coralPeach),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Target Deadline: ${project.deadline!.day}/${project.deadline!.month}/${project.deadline!.year}',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                                  ),
                                ],
                              ),
                            ],
                            if (project.repoUrl != null && project.repoUrl!.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.link_rounded, size: 16, color: Colors.teal),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Repository: ${project.repoUrl!}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (project.notes != null && project.notes!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                'ARCHITECTURE & PROJECT NOTES',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context), letterSpacing: 1.1),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                project.notes!,
                                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: VelvetColors.textSecondary(context)),
                              ),
                            ],
                            if (project.description != null && project.techStack != null) const SizedBox(height: 16),
                            if (project.techStack != null) ...[
                              const Text(
                                'PROVISIONED TECH STACK',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VelvetColors.periwinkle, letterSpacing: 1.1),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 4.0,
                                children: project.techStack!.split(',').map((tech) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: VelvetColors.periwinkle.withValues(alpha: 0.15),
                                      border: Border.all(color: VelvetColors.periwinkle.withValues(alpha: 0.25)),
                                    ),
                                    child: Text(
                                      tech,
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                

                    const SizedBox(height: 16),
                    _GitHubSyncCard(
                      projectName: project.name,
                      repoUrl: project.repoUrl,
                    ),
                    const SizedBox(height: 16),
                    SecurityHardeningScanner(project: project),
                    const SizedBox(height: 16),
                    // Milestone Pipeline Stepper Card
                    ClayCard(
                      color: VelvetColors.surface(context),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MILESTONE PIPELINE & AUDIT STAGES',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VelvetColors.cocoa, letterSpacing: 1.1),
                          ),
                          const SizedBox(height: 16),
                          ...[
                            'BACKLOG',
                            'SPRINT',
                            'IN_PROGRESS',
                            'REVIEW',
                            'SECURITY_AUDIT',
                            'DONE',
                          ].mapIndexed((idx, stageDb) {
                            final stageLabels = [
                              '💡 Product Backlog',
                              '📋 Sprint Planning',
                              '🏃 In Progress',
                              '🧪 In Review & QA',
                              '🛡️ Security Audit',
                              '✅ Done & Deployed',
                            ];
                            final stageDescriptions = [
                              'Captured in Product Backlog',
                              'Selected for current Sprint',
                              'Actively being developed',
                              'Under code review & QA testing',
                              'Zero-trust security hardening',
                              'Shipped to production',
                            ];
                            final currentStatus = project.status;
                            final scrumStages = [
                              'BACKLOG', 'SPRINT', 'IN_PROGRESS',
                              'REVIEW', 'SECURITY_AUDIT', 'DONE',
                            ];
                            // Legacy value mapping
                            String normalised = currentStatus;
                            if (currentStatus == 'IDEA') normalised = 'BACKLOG';
                            if (currentStatus == 'DEVELOP') normalised = 'SPRINT';
                            if (currentStatus == 'TEST') normalised = 'IN_PROGRESS';
                            if (currentStatus == 'REDEVELOP') normalised = 'REVIEW';
                            if (currentStatus.contains('SECURITY') || currentStatus == 'ADD SECURITY') normalised = 'SECURITY_AUDIT';
                            if (currentStatus == 'RELEASE') normalised = 'DONE';

                            int currentIdx = scrumStages.indexOf(normalised);
                            if (currentIdx == -1) currentIdx = 0;

                            final isDone = idx < currentIdx;
                            final isActive = idx == currentIdx;
                            final showLine = idx < 5;
                            final displayStageName = stageLabels[idx];
                            final stageDesc = stageDescriptions[idx];

                            return InkWell(
                              onTap: () async {
                                await HapticFeedback.mediumImpact();
                                await ref.read(projectRepositoryProvider).updateProject(project.copyWith(status: stageDb));
                                if (context.mounted) {
                                  GlassSnackBar.show(context, 'Project moved to $displayStageName! 🚀');
                                }
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Icon(
                                          isDone
                                              ? Icons.check_circle
                                              : (isActive ? Icons.play_circle : Icons.radio_button_unchecked),
                                          color: isDone
                                              ? VelvetColors.mint
                                              : (isActive ? VelvetColors.coralPeach : VelvetColors.clayTan),
                                          size: 20,
                                        ),
                                        if (showLine)
                                          Container(
                                            width: 2,
                                            height: 24,
                                            color: isDone ? VelvetColors.mint : VelvetColors.clayTan.withValues(alpha: 0.5),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            displayStageName,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: isActive ? VelvetColors.coralPeach : VelvetColors.textPrimary(context),
                                              decoration: isDone ? TextDecoration.lineThrough : null,
                                            ),
                                          ),
                                          Text(
                                            isActive ? '▶ Active Sprint Phase (Tap to set)' : (isDone ? '✔ Completed (Tap to revert)' : '○ Tap to advance to this stage'),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDone
                                                  ? VelvetColors.mint
                                                  : (isActive ? VelvetColors.coralPeach : VelvetColors.textSecondary(context)),
                                            ),
                                          ),
                                          if (isActive)
                                            Text(
                                              stageDesc,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: VelvetColors.textSecondary(context),
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const Divider(height: 24, color: VelvetColors.clayTan),
                          
                          // Set Stage dropdown — Scrum stages
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Set Scrum Stage:',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                decoration: BoxDecoration(
                                  color: VelvetColors.clayTan.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: VelvetColors.clayTan.withValues(alpha: 0.3)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: () {
                                      final s = project.status;
                                      const valid = [
                                        'BACKLOG', 'SPRINT', 'IN_PROGRESS',
                                        'REVIEW', 'SECURITY_AUDIT', 'DONE',
                                      ];
                                      if (valid.contains(s)) return s;
                                      // Legacy mapping
                                      if (s == 'IDEA') return 'BACKLOG';
                                      if (s == 'DEVELOP') return 'SPRINT';
                                      if (s == 'TEST') return 'IN_PROGRESS';
                                      if (s == 'REDEVELOP') return 'REVIEW';
                                      if (s.contains('SECURITY') || s == 'ADD SECURITY') return 'SECURITY_AUDIT';
                                      if (s == 'RELEASE') return 'DONE';
                                      return 'BACKLOG';
                                    }(),
                                    dropdownColor: VelvetColors.dropdownFill(context),
                                    borderRadius: BorderRadius.circular(14),
                                    items: [
                                      DropdownMenuItem(value: 'BACKLOG', child: Text('💡 Product Backlog', style: TextStyle(fontSize: 12, color: VelvetColors.textPrimary(context), fontWeight: FontWeight.bold))),
                                      DropdownMenuItem(value: 'SPRINT', child: Text('📋 Sprint Planning', style: TextStyle(fontSize: 12, color: VelvetColors.textPrimary(context), fontWeight: FontWeight.bold))),
                                      DropdownMenuItem(value: 'IN_PROGRESS', child: Text('🏃 In Progress', style: TextStyle(fontSize: 12, color: VelvetColors.textPrimary(context), fontWeight: FontWeight.bold))),
                                      DropdownMenuItem(value: 'REVIEW', child: Text('🧪 In Review & QA', style: TextStyle(fontSize: 12, color: VelvetColors.textPrimary(context), fontWeight: FontWeight.bold))),
                                      DropdownMenuItem(value: 'SECURITY_AUDIT', child: Text('🛡️ Security Audit', style: TextStyle(fontSize: 12, color: VelvetColors.textPrimary(context), fontWeight: FontWeight.bold))),
                                      DropdownMenuItem(value: 'DONE', child: Text('✅ Done & Deployed', style: TextStyle(fontSize: 12, color: VelvetColors.textPrimary(context), fontWeight: FontWeight.bold))),
                                    ],
                                    onChanged: (newStage) {
                                      if (newStage != null) {
                                        _updateStatus(project, newStage);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    // Simplified FileSystem Asset Card
                    ClayCard(
                      color: VelvetColors.surface(context),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.drive_file_rename_outline, color: VelvetColors.iconColor(context)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'FileSystem Asset Info',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: VelvetColors.textPrimary(context),
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: VelvetColors.periwinkle),
                                onPressed: () => _showEditPathDialog(project),
                              ),
                            ],
                          ),
                          const Divider(height: 20, color: VelvetColors.clayTan),
                          _buildDetailRow('Target OS', project.storageOs ?? 'Not Configured'),
                          _buildDetailRow('Drive/Mount', project.storageDrive ?? 'Not Configured'),
                          _buildDetailRow('Path', project.storagePath ?? 'Not Configured'),
                          _buildDetailRow('Backup Path', project.backupPath ?? 'Not Configured'),
                          _buildDetailRow(
                            'Subfolders',
                            project.storageSubfoldersJson != null
                                ? (jsonDecode(project.storageSubfoldersJson!) as List).join(', ')
                                : 'None Configured',
                          ),
                        ],
                      ),
                    ),
                    if (project.storagePath != null && project.storagePath!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      FolderTreeWidget(
                        storagePath: project.storagePath,
                        mockSubfoldersJson: project.storageSubfoldersJson,
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Project Analytics & Connected Insights Card
                    ClayCard(
                      color: VelvetColors.surface(context),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.analytics_outlined, color: VelvetColors.iconColor(context)),
                              const SizedBox(width: 8),
                              Text(
                                'Project Analytics & Insights',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: VelvetColors.textPrimary(context),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20, color: VelvetColors.clayTan),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Donut Chart Column
                              Column(
                                children: [
                                  SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: CustomPaint(
                                      painter: _DonutChartPainter(
                                        percent: percent,
                                        completedColor: VelvetColors.coralPeach,
                                        remainingColor: VelvetColors.border(context),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${(percent * 100).toInt()}%',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: VelvetColors.textPrimary(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$completedCount of $totalCount Tasks',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: VelvetColors.textSecondary(context),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              // Linked Assets Column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CONNECTED WORKSPACE ASSETS',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: VelvetColors.textSecondary(context),
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Linked Papers
                                    papersAsync.when(
                                      data: (papers) {
                                        final linked = papers.where((p) => p.projectId == project.id).toList();
                                        if (linked.isEmpty) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                                            child: Text(
                                              'No linked research papers',
                                              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: VelvetColors.textSecondary(context)),
                                            ),
                                          );
                                        }
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: linked.map((paper) {
                                            return InkWell(
                                              onTap: () => context.push('/research/${paper.id}'),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.description_rounded, size: 14, color: VelvetColors.periwinkle),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        paper.title,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                          color: VelvetColors.periwinkle,
                                                          decoration: TextDecoration.underline,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      },
                                      loading: () => const SizedBox(
                                        height: 12,
                                        child: LinearProgressIndicator(),
                                      ),
                                      error: (_, __) => const SizedBox.shrink(),
                                    ),
                                    
                                    Divider(height: 12, color: VelvetColors.border(context)),
                                    
                                    // Linked Jobs
                                    jobsAsync.when(
                                      data: (jobs) {
                                        final linked = jobs.where((j) => j.projectId == project.id).toList();
                                        if (linked.isEmpty) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                                            child: Text(
                                              'No linked job applications',
                                              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: VelvetColors.textSecondary(context)),
                                            ),
                                          );
                                        }
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: linked.map((job) {
                                            return InkWell(
                                              onTap: () => context.push('/jobs/${job.id}'),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.work_rounded, size: 14, color: VelvetColors.coralPeach),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        '${job.role} at ${job.company}',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                          color: VelvetColors.coralPeach,
                                                          decoration: TextDecoration.underline,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      },
                                      loading: () => const SizedBox(
                                        height: 12,
                                        child: LinearProgressIndicator(),
                                      ),
                                      error: (_, __) => const SizedBox.shrink(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tasks / Checklist Card
                    ClayCard(
                      color: VelvetColors.surface(context),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Project Subtasks',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: VelvetColors.textPrimary(context),
                            ),
                          ),
                          const Divider(height: 20, color: VelvetColors.clayTan),
                          
                          if (tasks.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'No subtasks configured yet.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: VelvetColors.textSecondary(context),
                                ),
                              ),
                            )
                          else
                            ...tasks.map((task) => Dismissible(
                                  key: Key('task_${task.id}'),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.delete_outline, color: Colors.white),
                                  ),
                                  onDismissed: (_) => _deleteTask(task.id),
                                  child: CheckboxListTile(
                                    title: Text(
                                      task.title,
                                      style: TextStyle(
                                        color: VelvetColors.textPrimary(context),
                                        fontSize: 13,
                                        decoration: task.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    value: task.isCompleted,
                                    activeColor: VelvetColors.coralPeach,
                                    onChanged: (_) => _toggleTask(task),
                                    contentPadding: EdgeInsets.zero,
                                    controlAffinity: ListTileControlAffinity.leading,
                                  ),
                                )),

                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _taskController,
                                  style: TextStyle(color: VelvetColors.textPrimary(context), fontSize: 13),
                                  decoration: InputDecoration(
                                    hintText: 'Add new subtask...',
                                    hintStyle: TextStyle(
                                      color: VelvetColors.textSecondary(context),
                                      fontSize: 13,
                                    ),
                                    border: const UnderlineInputBorder(),
                                  ),
                                  onSubmitted: (_) => _addTask(),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_box_rounded, color: VelvetColors.coralPeach),
                                onPressed: _addTask,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error loading tasks: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading project: $err')),
      ),
    ),
  );
  }

  Widget _buildBadge(String label, Color color) {
    Color bg = color.withValues(alpha: 0.18);
    Color fg = VelvetColors.cocoa;

    final lower = label.toLowerCase();
    if (lower.contains('high') || lower.contains('urgent') || lower.contains('critical')) {
      bg = const Color(0xFFFFEBEE);
      fg = const Color(0xFFC62828);
    } else if (lower.contains('medium')) {
      bg = const Color(0xFFFFF3E0);
      fg = const Color(0xFFE65100);
    } else if (lower.contains('low')) {
      bg = const Color(0xFFE8F5E9);
      fg = const Color(0xFF2E7D32);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isMono = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: VelvetColors.textSecondary(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontFamily: isMono ? 'JetBrains Mono' : null,
                color: VelvetColors.textPrimary(context),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProjectSheet extends ConsumerStatefulWidget {
  final Project project;

  const _EditProjectSheet({required this.project});

  @override
  ConsumerState<_EditProjectSheet> createState() => _EditProjectSheetState();
}

class _EditProjectSheetState extends ConsumerState<_EditProjectSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _repoUrlController;
  late TextEditingController _notesController;
  late String _priority;
  late List<String> _selectedTechStack;

  final List<String> _techOptions = [
    'Flutter 3.29', 'Dart 3.6', 'React 19', 'React Native', 'Vue 3', 'Angular', 'Svelte 5',
    'Next.js 15', 'TailwindCSS v4', 'Node.js 22', 'Express', 'NestJS', 'Go 1.24', 'Rust 1.85', 'Python 3.12', 'FastAPI',
    'C++', 'Java 21', 'Spring Boot 3', 'C#', 'NET 9', 'TypeScript 5.7', 'PostgreSQL 16', 'SQLite / Drift', 'MongoDB',
    'MySQL', 'Redis', 'DynamoDB', 'Supabase v2', 'Firebase', 'Docker / Compose',
    'Kubernetes 1.32', 'Terraform', 'GitHub Actions', 'AWS', 'GCP', 'Azure',
    'Cloudflare', 'InfinityFree', 'AI / ML', 'OpenAI GPT-4o', 'Gemini 2.0 Flash', 'Claude 3.5 Sonnet', 'DeepSeek R1', 'Llama 3.3', 'Ollama', 'Nvidia CUDA'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project.name);
    _descriptionController = TextEditingController(text: widget.project.description ?? '');
    _repoUrlController = TextEditingController(text: widget.project.repoUrl ?? '');
    _notesController = TextEditingController(text: widget.project.notes ?? '');
    _priority = widget.project.priority;
    _selectedTechStack = widget.project.techStack != null && widget.project.techStack!.isNotEmpty
        ? widget.project.techStack!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
        : [];
    // Dynamically preserve and include existing tech stack items so newest custom versions are never lost
    for (final tech in _selectedTechStack) {
      if (!_techOptions.contains(tech)) {
        _techOptions.insert(0, tech);
      }
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final repoUrl = _repoUrlController.text.trim();
    final notes = _notesController.text.trim();
    final techStack = _selectedTechStack.isEmpty ? null : _selectedTechStack.join(',');

    final updated = widget.project.copyWith(
      name: name,
      description: drift.Value(description.isEmpty ? null : description),
      repoUrl: drift.Value(repoUrl.isEmpty ? null : repoUrl),
      notes: drift.Value(notes.isEmpty ? null : notes),
      priority: _priority,
      techStack: drift.Value(techStack),
    );

    await ref.read(projectRepositoryProvider).updateProject(updated);

    if (mounted) {
      // Capture root overlay BEFORE pop so snackbar survives modal dismiss
      final overlay = Overlay.maybeOf(context, rootOverlay: true);
      Navigator.of(context).pop();
      if (overlay != null && overlay.mounted) {
        VelvetSnackBar.showSuccess(
          overlay.context,
          'Project updated successfully ✓',
        );
      }
    }
  }

  InputDecoration _buildInputDecoration(BuildContext context, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? Colors.white70 : VelvetColors.cocoa.withValues(alpha: 0.7),
      ),
      filled: true,
      fillColor: isDark ? const Color(0xFF27221F) : VelvetColors.clayTan.withValues(alpha: 0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? VelvetColors.mint.withValues(alpha: 0.3) : VelvetColors.clayTan,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? VelvetColors.mint.withValues(alpha: 0.3) : VelvetColors.clayTan.withValues(alpha: 0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: VelvetColors.coralPeach, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : VelvetColors.cocoa;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B18) : VelvetColors.cream,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(
            color: isDark
                ? VelvetColors.mint.withValues(alpha: 0.3)
                : VelvetColors.clayTan.withValues(alpha: 0.50),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.5) : VelvetColors.cocoa.withValues(alpha: 0.10),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: textColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Edit Project Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: textColor),
                  decoration: _buildInputDecoration(context, 'Project Name'),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a project name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  style: TextStyle(color: textColor),
                  maxLines: 3,
                  decoration: _buildInputDecoration(context, 'Description'),
                ),
                const SizedBox(height: 20),
                ModularTechStackPicker(
                  selectedTechStack: _selectedTechStack,
                  onChanged: (updated) {
                    setState(() {
                      _selectedTechStack.clear();
                      _selectedTechStack.addAll(updated);
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _repoUrlController,
                  style: TextStyle(color: textColor),
                  decoration: _buildInputDecoration(context, 'GitHub Repository URL (Optional)'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  style: TextStyle(color: textColor),
                  maxLines: 2,
                  decoration: _buildInputDecoration(context, 'Personal Notes & Architecture Decisions (Optional)'),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: _priority,
                  dropdownColor: isDark ? const Color(0xFF27221F) : VelvetColors.cream,
                  decoration: _buildInputDecoration(context, 'Priority'),
                  items: ['Low', 'Medium', 'High'].map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Text(p, style: TextStyle(color: textColor)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _priority = val);
                    }
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VelvetColors.coralPeach,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _submit,
                  child: const Text('Save Details', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final double percent;
  final Color completedColor;
  final Color remainingColor;

  _DonutChartPainter({
    required this.percent,
    required this.completedColor,
    required this.remainingColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);
    const strokeWidth = 8.0;

    final paintRemaining = Paint()
      ..color = remainingColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final paintCompleted = Paint()
      ..color = completedColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw full remaining circle
    canvas.drawCircle(center, radius - strokeWidth / 2, paintRemaining);

    // Draw completed arc
    if (percent > 0) {
      final sweepAngle = 2 * math.pi * percent;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        -math.pi / 2,
        sweepAngle,
        false,
        paintCompleted,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.percent != percent ||
        oldDelegate.completedColor != completedColor ||
        oldDelegate.remainingColor != remainingColor;
  }
}

class _GitHubSyncCard extends ConsumerStatefulWidget {
  final String projectName;
  final String? repoUrl;

  const _GitHubSyncCard({
    required this.projectName,
    this.repoUrl,
  });

  @override
  ConsumerState<_GitHubSyncCard> createState() => _GitHubSyncCardState();
}

class _GitHubSyncCardState extends ConsumerState<_GitHubSyncCard> {
  bool _isLoading = true;
  bool _repoExists = false;
  int _stars = 0;
  int _issues = 0;
  List<String> _branches = [];
  String? _lastCommitMsg;
  String? _lastCommitAuthor;
  String? _lastCommitDate;
  String? _error;
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    _fetchGitHubDetails();
  }

  Future<void> _fetchGitHubDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Read PAT from SecureStorage first (set via Settings), fallback to .env
    final secureStorage = ref.read(secureStorageProvider);
    final pat = await secureStorage.readSetting('velvet_github_pat') ??
        (dotenv.isInitialized ? dotenv.env['GITHUB_PAT'] : null);

    // 0. Robust GitHub Owner & Repo URL Resolution
    String targetOwner = '';
    String repoName = '';

    final rawRepoUrl = widget.repoUrl?.trim() ?? '';
    if (rawRepoUrl.isNotEmpty) {
      final githubMatch = RegExp(r'github\.com[/:]([\w.-]+)/([\w.-]+?)(?:\.git|/)?$').firstMatch(rawRepoUrl);
      if (githubMatch != null) {
        targetOwner = githubMatch.group(1)!;
        repoName = githubMatch.group(2)!;
      } else if (rawRepoUrl.contains('/') && !rawRepoUrl.contains('http')) {
        final parts = rawRepoUrl.split('/');
        if (parts.length == 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
          targetOwner = parts[0].trim();
          repoName = parts[1].replaceAll('.git', '').trim();
        }
      }
    }

    if (targetOwner.isEmpty || repoName.isEmpty) {
      final profile = ref.read(userProfileProvider);
      targetOwner = profile.githubUsername.isNotEmpty ? profile.githubUsername : 'user';
      final rawRepoName = widget.projectName
          .replaceAll(RegExp(r'[^a-zA-Z0-9\s-]'), '')
          .trim()
          .replaceAll(RegExp(r'\s+'), '-')
          .toLowerCase();
      repoName = rawRepoName.isEmpty ? 'pariyojana-project' : rawRepoName;
    }

    try {
      final dio = Dio();
      final headers = <String, String>{
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      };
      if (pat != null && pat.trim().isNotEmpty) {
        headers['Authorization'] = 'Bearer ${pat.trim()}';
      }

      // If owner was fallback 'user', attempt to discover authenticated user login
      if (targetOwner == 'user' && headers.containsKey('Authorization')) {
        try {
          final userRes = await dio.get<Map<String, dynamic>>(
            'https://api.github.com/user',
            options: Options(headers: headers),
          );
          if (userRes.data?['login'] != null) {
            targetOwner = userRes.data!['login'] as String;
          }
        } catch (_) {}
      }

      // 1. Fetch Repository Base Stats (authenticated, with public fallback)
      Response<Map<String, dynamic>> repoResponse;
      try {
        repoResponse = await dio.get<Map<String, dynamic>>(
          'https://api.github.com/repos/$targetOwner/$repoName',
          options: Options(headers: headers),
        );
      } catch (_) {
        // Fallback for public repos if PAT has restricted organization scope
        repoResponse = await dio.get<Map<String, dynamic>>(
          'https://api.github.com/repos/$targetOwner/$repoName',
          options: Options(headers: {
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
          }),
        );
      }

      final stars = repoResponse.data?['stargazers_count'] as int? ?? 0;
      final openIssues = repoResponse.data?['open_issues_count'] as int? ?? 0;

      // 2. Fetch Branches
      List<String> branches = [];
      try {
        final branchesResponse = await dio.get<List<dynamic>>(
          'https://api.github.com/repos/$targetOwner/$repoName/branches',
          options: Options(headers: headers),
        );
        branches = branchesResponse.data?.map((b) => b['name'] as String).toList() ?? [];
      } catch (_) {
        try {
          final branchesResponse = await dio.get<List<dynamic>>(
            'https://api.github.com/repos/$targetOwner/$repoName/branches',
            options: Options(headers: {'Accept': 'application/vnd.github+json'}),
          );
          branches = branchesResponse.data?.map((b) => b['name'] as String).toList() ?? [];
        } catch (_) {}
      }

      // 3. Fetch Commits
      String? commitMsg;
      String? commitAuthor;
      String? commitDate;

      try {
        final commitsResponse = await dio.get<List<dynamic>>(
          'https://api.github.com/repos/$targetOwner/$repoName/commits?per_page=1',
          options: Options(headers: headers),
        );

        if (commitsResponse.data != null && commitsResponse.data!.isNotEmpty) {
          final firstCommit = commitsResponse.data![0];
          commitMsg = firstCommit['commit']['message'] as String?;
          commitAuthor = firstCommit['commit']['author']['name'] as String?;
          commitDate = firstCommit['commit']['author']['date'] as String?;
        }
      } catch (_) {
        try {
          final commitsResponse = await dio.get<List<dynamic>>(
            'https://api.github.com/repos/$targetOwner/$repoName/commits?per_page=1',
            options: Options(headers: {'Accept': 'application/vnd.github+json'}),
          );

          if (commitsResponse.data != null && commitsResponse.data!.isNotEmpty) {
            final firstCommit = commitsResponse.data![0];
            commitMsg = firstCommit['commit']['message'] as String?;
            commitAuthor = firstCommit['commit']['author']['name'] as String?;
            commitDate = firstCommit['commit']['author']['date'] as String?;
          }
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() {
        _repoExists = true;
        _stars = stars;
        _issues = openIssues;
        _branches = branches;
        _lastCommitMsg = commitMsg;
        _lastCommitAuthor = commitAuthor;
        _lastCommitDate = commitDate;
        _isLoading = false;
        _error = null;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      if (e.response?.statusCode == 404) {
        setState(() {
          _repoExists = false;
          _isLoading = false;
          _error = null;
        });
      } else {
        setState(() {
          _error = 'GitHub Sync Notice: Repository offline or token scope verification required';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'GitHub Sync Notice: Remote host unreachable';
        _isLoading = false;
      });
    }
  }

  Future<void> _publishRepository() async {
    if (!mounted) return;
    setState(() {
      _isPublishing = true;
      _error = null;
    });

    // Read PAT from SecureStorage first (set via Settings), fallback to .env
    final secureStorage = ref.read(secureStorageProvider);
    final pat = await secureStorage.readSetting('velvet_github_pat') ??
        (dotenv.isInitialized ? dotenv.env['GITHUB_PAT'] : null);
    if (pat == null || pat.isEmpty) {
      if (!mounted) return;
      setState(() {
        _error = 'Connect your GitHub account in Settings → Integrations, then try again';
        _isPublishing = false;
      });
      return;
    }

    final rawRepoName = widget.projectName
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '-')
        .toLowerCase();
    final repoName = rawRepoName.isEmpty ? 'pariyojana-project' : rawRepoName;

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $pat',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      };

      await dio.post<Map<String, dynamic>>(
        'https://api.github.com/user/repos',
        data: {
          'name': repoName,
          'private': true,
          'description': 'Auto-created remote repository for project ${widget.projectName}.',
        },
        options: Options(headers: headers),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Repository created successfully on GitHub! 🚀')),
        );
      }

      await _fetchGitHubDetails();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to create repository: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ClayCard(
        color: VelvetColors.cardSurface(context),
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.0, color: VelvetColors.coralPeach),
              ),
              const SizedBox(height: 12),
              Text(
                'Syncing with GitHub...',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: VelvetColors.textPrimary(context)),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return ClayCard(
        color: VelvetColors.cardSurface(context),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 20),
                const SizedBox(width: 8),
                Text('GitHub Integration Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: VelvetColors.textPrimary(context))),
              ],
            ),
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(fontSize: 12, color: Colors.redAccent)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry Sync'),
              style: OutlinedButton.styleFrom(
                foregroundColor: VelvetColors.textPrimary(context),
                side: BorderSide(color: VelvetColors.border(context)),
              ),
              onPressed: _fetchGitHubDetails,
            ),
          ],
        ),
      );
    }

    if (!_repoExists) {
      return ClayCard(
        color: VelvetColors.cardSurface(context),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.code_rounded, color: VelvetColors.iconColor(context), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GitHub Sync Status',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: VelvetColors.textPrimary(context)),
                      ),
                      Text(
                        'No remote repository connected.',
                        style: TextStyle(fontSize: 11, color: VelvetColors.textSecondary(context)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: VelvetColors.coralPeach,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              icon: _isPublishing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.cloud_upload_rounded, size: 16),
              label: Text(_isPublishing ? 'Creating Repository...' : 'Publish to GitHub'),
              onPressed: _isPublishing ? null : _publishRepository,
            ),
          ],
        ),
      );
    }

    String cleanDate = '';
    if (_lastCommitDate != null) {
      try {
        final parsed = DateTime.parse(_lastCommitDate!);
        cleanDate = DateFormat('yMMMd HH:mm').format(parsed);
      } catch (_) {
        cleanDate = _lastCommitDate!;
      }
    }

    return ClayCard(
      color: VelvetColors.cardSurface(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.hub_outlined, color: VelvetColors.coralPeach, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${widget.projectName.replaceAll(' ', '-').toLowerCase()} Connected',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: VelvetColors.textPrimary(context)),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, size: 18, color: VelvetColors.iconColor(context)),
                onPressed: _fetchGitHubDetails,
                tooltip: 'Sync Now',
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              _buildStatPill('STARS ⭐', '$_stars'),
              const SizedBox(width: 8),
              _buildStatPill('ISSUES 🐛', '$_issues'),
              const SizedBox(width: 8),
              _buildStatPill('BRANCHES 🌿', '${_branches.length}'),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_lastCommitMsg != null) ...[
            const Text(
              'LATEST PUSH / COMMIT METADATA',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: VelvetColors.coralPeach, letterSpacing: 1.2),
            ),
            const SizedBox(height: 6),
            Text(
              '"$_lastCommitMsg"',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: VelvetColors.textPrimary(context), fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Author: $_lastCommitAuthor',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: VelvetColors.textSecondary(context)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  cleanDate,
                  style: TextStyle(fontSize: 11, color: VelvetColors.textSecondary(context), fontFamily: GoogleFonts.jetBrainsMono().fontFamily),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: VelvetColors.cardSurface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: VelvetColors.border(context)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: VelvetColors.textSecondary(context))),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
          ],
        ),
      ),
    );
  }
}
