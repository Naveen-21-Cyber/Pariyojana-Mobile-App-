import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/velvet_colors.dart';
import 'package:velvet/core/sounds/sound_service.dart';
import 'glass_snackbar.dart';
import 'app_introduction_sheet.dart';
import 'dynamic_island.dart';
import '../features/presentation/navigation_shell.dart';
import '../features/project_tracker/presentation/providers/project_provider.dart';
import '../features/research_tracker/presentation/widgets/pdf_highlighter_sheet.dart';

class CyberCommandLauncher extends ConsumerStatefulWidget {
  const CyberCommandLauncher({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      useSafeArea: true,
      builder: (context) => const CyberCommandLauncher(),
    );
  }

  @override
  ConsumerState<CyberCommandLauncher> createState() => _CyberCommandLauncherState();
}

class _CyberCommandLauncherState extends ConsumerState<CyberCommandLauncher> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final soundEnabled = ref.watch(masterSoundEnabledProvider);
    final projects = ref.watch(projectsStreamProvider).asData?.value ?? [];

    final actions = [
      {
        'icon': Icons.add_box_rounded,
        'title': 'Create New Project',
        'subtitle': 'Add a new software or cybersecurity asset',
        'color': VelvetColors.coralPeach,
        'onTap': () {
          Navigator.pop(context);
          ref.read(quickAddTriggerProvider.notifier).state = 'project';
        },
      },
      {
        'icon': Icons.edit_note_rounded,
        'title': 'PDF Annotator & Quote Exporter',
        'subtitle': 'Annotate paper quotes & export markdown to clipboard',
        'color': VelvetColors.periwinkle,
        'onTap': () {
          Navigator.pop(context);
          PdfHighlighterSheet.show(context, 'PDF Research Document');
        },
      },
      {
        'icon': Icons.work_history_rounded,
        'title': 'Track New Job Application',
        'subtitle': 'Log target role, company & outreach stage',
        'color': VelvetColors.periwinkle,
        'onTap': () {
          Navigator.pop(context);
          context.go('/jobs');
        },
      },
      {
        'icon': Icons.lightbulb_rounded,
        'title': 'Capture Ephemeral Idea',
        'subtitle': 'Instant AI classification & tag prediction',
        'color': Colors.amber,
        'onTap': () {
          Navigator.pop(context);
          ref.read(quickCaptureTriggerProvider.notifier).state = 1;
        },
      },
      {
        'icon': soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
        'title': soundEnabled ? 'Mute Master Audio' : 'Enable Master Audio',
        'subtitle': soundEnabled ? 'Mute all UI sounds, music & voice' : 'Enable full audio engine',
        'color': VelvetColors.mint,
        'onTap': () {
          Navigator.pop(context);
          ref.read(masterSoundEnabledProvider.notifier).state = !soundEnabled;
          GlassSnackBar.show(
            context,
            !soundEnabled ? '🔊 Master Audio ENABLED' : '🔇 Master Audio MUTED',
          );
        },
      },
      {
        'icon': Icons.explore_rounded,
        'title': 'Open App Tour Guide',
        'subtitle': 'Review privacy & core workspace pillars',
        'color': Colors.indigoAccent,
        'onTap': () {
          Navigator.pop(context);
          showModalBottomSheet(
            context: context,
            useRootNavigator: true,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AppIntroductionSheet(),
          );
        },
      },
    ];

    final filteredActions = actions.where((a) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return (a['title'] as String).toLowerCase().contains(q) ||
          (a['subtitle'] as String).toLowerCase().contains(q);
    }).toList();

    final mediaQuery = MediaQuery.of(context);
    final keyboardOffset = mediaQuery.viewInsets.bottom;
    final dialogMaxHeight = (mediaQuery.size.height - keyboardOffset - 48).clamp(180.0, 560.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        constraints: BoxConstraints(maxHeight: dialogMaxHeight),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: VelvetColors.surface(context),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: VelvetColors.coralPeach, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: VelvetColors.coralPeach.withValues(alpha: 0.15),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: VelvetColors.coralPeach,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: VelvetColors.coralPeach.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'CYBER COMMAND LAUNCHER',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          color: VelvetColors.textPrimary(context),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Instant Workspace Command Center',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: VelvetColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 22, color: VelvetColors.iconColor(context)),
                  onPressed: () => Navigator.pop(context),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // High-contrast Search Bar
            TextField(
              controller: _searchController,
              autofocus: false,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: VelvetColors.textPrimary(context)),
              onChanged: (val) => setState(() => _query = val),
              decoration: InputDecoration(
                hintText: 'Search commands, projects, tools or actions...',
                hintStyle: TextStyle(fontSize: 12, color: VelvetColors.textSecondary(context).withValues(alpha: 0.6)),
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: VelvetColors.coralPeach),
                filled: true,
                fillColor: VelvetColors.inputFill(context),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: VelvetColors.border(context), width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: VelvetColors.border(context), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: VelvetColors.coralPeach, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.flash_on_rounded, size: 14, color: VelvetColors.periwinkle),
                        SizedBox(width: 4),
                        Text(
                          'QUICK WORKSPACE ACTIONS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: VelvetColors.periwinkle,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...filteredActions.map((act) {
                      final color = act['color'] as Color;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Material(
                          color: VelvetColors.cardSurface(context),
                          borderRadius: BorderRadius.circular(16),
                          elevation: 1,
                          shadowColor: Colors.black.withValues(alpha: 0.08),
                          child: InkWell(
                            onTap: act['onTap'] as VoidCallback,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(act['icon'] as IconData, size: 20, color: color),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          act['title'] as String,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                            color: VelvetColors.textPrimary(context),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          act['subtitle'] as String,
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            color: VelvetColors.textSecondary(context),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    if (projects.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Icon(Icons.folder_special_rounded, size: 14, color: VelvetColors.coralPeach),
                          SizedBox(width: 4),
                          Text(
                            'ACTIVE REGISTERED PROJECTS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: VelvetColors.coralPeach,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...projects.take(4).map((p) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Material(
                            color: VelvetColors.cardSurface(context),
                            borderRadius: BorderRadius.circular(16),
                            elevation: 1,
                            shadowColor: Colors.black.withValues(alpha: 0.08),
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                context.go('/projects/${p.id}');
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.35), width: 1.5),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: VelvetColors.coralPeach.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.code_rounded, size: 20, color: VelvetColors.coralPeach),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p.name,
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold,
                                              color: VelvetColors.textPrimary(context),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            p.techStack ?? p.status,
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              color: VelvetColors.textSecondary(context),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: VelvetColors.coralPeach),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

