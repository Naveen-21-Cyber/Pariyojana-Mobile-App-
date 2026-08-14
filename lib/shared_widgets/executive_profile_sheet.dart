import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/velvet_colors.dart';
import '../core/profile/user_profile_provider.dart';
import '../features/command_center/presentation/providers/semantic_search_provider.dart';
import '../features/settings/presentation/pdf_report_exporter.dart';
import '../shared_widgets/executive_user_avatar.dart';
import '../shared_widgets/clay_card.dart';
import '../shared_widgets/glass_snackbar.dart';
import '../core/sounds/sound_service.dart';
import '../features/focus_shield/presentation/focus_shield_overlay.dart';

/// Ultra-Luxurious Executive Profile Cockpit Sheet Modal
class ExecutiveProfileSheet {
  static void show(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final statsAsync = ref.watch(dbStatsProvider);
        final profile = ref.watch(userProfileProvider);

        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.45,
          maxChildSize: 0.94,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: VelvetColors.surface(context),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: VelvetColors.border(context)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.2),
                    blurRadius: 30,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: VelvetColors.border(context),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header Bar with Title & Close
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: VelvetColors.coralPeach.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.stars_rounded, color: VelvetColors.coralPeach, size: 18),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'EXECUTIVE PROFILE & COCKPIT',
                            style: TextStyle(
                              fontFamily: GoogleFonts.outfit().fontFamily,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.6,
                              color: VelvetColors.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: VelvetColors.iconColor(context), size: 20),
                        onPressed: () => Navigator.pop(sheetCtx),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Hero Profile Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                const Color(0xFF221A1A),
                                const Color(0xFF181313),
                              ]
                            : [
                                const Color(0xFFFFF7F2),
                                const Color(0xFFFFEDE4),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.35), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: VelvetColors.coralPeach.withValues(alpha: 0.15),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Glowing High-Res Avatar
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: VelvetColors.coralPeach.withValues(alpha: 0.45),
                                        blurRadius: 18,
                                        spreadRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: const ExecutiveUserAvatar(
                                    size: 64,
                                    showHalo: true,
                                    showBadge: true,
                                    borderWidth: 2.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.displayName,
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.outfit().fontFamily,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: VelvetColors.textPrimary(context),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    profile.title.isNotEmpty ? profile.title : 'Tech Innovator & Project Builder',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: VelvetColors.coralPeach,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: VelvetColors.mint.withValues(alpha: 0.20),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: VelvetColors.mint.withValues(alpha: 0.5)),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.verified_user_rounded, color: VelvetColors.mint, size: 11),
                                        SizedBox(width: 4),
                                        Text(
                                          'ZERO-TRUST ENCLAVE VERIFIED',
                                          style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: VelvetColors.mint, letterSpacing: 0.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Action Buttons: 1-Tap Google Photo Sync + Settings Edit
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: VelvetColors.coralPeach.withValues(alpha: 0.15),
                                  foregroundColor: VelvetColors.textPrimary(context),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: const BorderSide(color: VelvetColors.coralPeach, width: 1),
                                  ),
                                ),
                                onPressed: () async {
                                  await HapticFeedback.mediumImpact();
                                  if (context.mounted) {
                                    GlassSnackBar.show(context, 'Syncing Google Account Photo... 🌐');
                                  }
                                  final photo = await ref.read(userProfileProvider.notifier).syncGooglePhoto();
                                  if (photo != null && context.mounted) {
                                    GlassSnackBar.show(context, 'Google Photo linked successfully! 📷✨');
                                  }
                                },
                                icon: const Icon(Icons.account_circle_outlined, size: 15, color: VelvetColors.coralPeach),
                                label: const Text(
                                  'Sync Google Photo 🌐',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: VelvetColors.periwinkle.withValues(alpha: 0.15),
                                  foregroundColor: VelvetColors.textPrimary(context),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: const BorderSide(color: VelvetColors.periwinkle, width: 1),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(sheetCtx);
                                  context.push('/settings');
                                },
                                icon: const Icon(Icons.edit_outlined, size: 15, color: VelvetColors.periwinkle),
                                label: const Text(
                                  'Edit Profile ⚙️',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Real-Time Workspace Metric Counters
                  statsAsync.when(
                    data: (stats) => Row(
                      children: [
                        _buildMetricPill(context, 'Ideas', stats.ideasCount, VelvetColors.coralPeach, Icons.lightbulb_outline, () {
                          Navigator.pop(sheetCtx);
                          context.go('/ideas');
                        }),
                        const SizedBox(width: 8),
                        _buildMetricPill(context, 'Projects', stats.projectsCount, VelvetColors.mint, Icons.folder_open_outlined, () {
                          Navigator.pop(sheetCtx);
                          context.go('/projects');
                        }),
                        const SizedBox(width: 8),
                        _buildMetricPill(context, 'Research', stats.researchPapersCount, VelvetColors.periwinkle, Icons.menu_book_outlined, () {
                          Navigator.pop(sheetCtx);
                          context.go('/research');
                        }),
                        const SizedBox(width: 8),
                        _buildMetricPill(context, 'Jobs', stats.jobApplicationsCount, VelvetColors.clayTan, Icons.work_outline_outlined, () {
                          Navigator.pop(sheetCtx);
                          context.go('/jobs');
                        }),
                      ],
                    ),
                    loading: () => const Center(child: LinearProgressIndicator(color: VelvetColors.coralPeach)),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),

                  // Power Deck Features
                  ClayCard(
                    color: VelvetColors.surface(context),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Executive Launchers & Diagnostics 🚀',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5, color: VelvetColors.textPrimary(context)),
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: VelvetColors.periwinkle.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.hub_outlined, color: VelvetColors.periwinkle, size: 20),
                          ),
                          title: const Text('AI Command Center 🛰️', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                          subtitle: const Text('Graph relationship visualizer & DB vacuum optimizer', style: TextStyle(fontSize: 10)),
                          trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                          onTap: () {
                            Navigator.pop(sheetCtx);
                            context.push('/command_center');
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: VelvetColors.coralPeach.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.bolt_rounded, color: VelvetColors.coralPeach, size: 20),
                          ),
                          title: const Text('Mitnick AI Cybersecurity Terminal ⚡', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                          subtitle: const Text('Multi-persona auditor (Mitnick, Newton, Jobs)', style: TextStyle(fontSize: 10)),
                          trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                          onTap: () {
                            Navigator.pop(sheetCtx);
                            context.push('/mitnick');
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: VelvetColors.mint.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.analytics_outlined, color: VelvetColors.mint, size: 20),
                          ),
                          title: const Text('Analytics & Heatmap 📊', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                          subtitle: const Text('Velocity metrics & 360° radar competency', style: TextStyle(fontSize: 10)),
                          trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                          onTap: () {
                            Navigator.pop(sheetCtx);
                            context.push('/analytics');
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: VelvetColors.coralPeach.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.shield_rounded, color: VelvetColors.coralPeach, size: 20),
                          ),
                          title: const Text('Focus Shield 🛡️', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                          subtitle: const Text('Distraction-free Gita screensaver mode', style: TextStyle(fontSize: 10)),
                          trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                          onTap: () {
                            Navigator.pop(sheetCtx);
                            FocusShieldLauncher.show(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Export PDF Report Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VelvetColors.coralPeach,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                    label: const Text(
                      'Export Executive Portfolio PDF 📄',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      PdfReportExporter.exportExecutiveReport(context, ref);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Signature Audio Voice Boot Sound Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VelvetColors.cardSurface(context),
                      foregroundColor: VelvetColors.textPrimary(context),
                      minimumSize: const Size.fromHeight(42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: VelvetColors.border(context)),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.volume_up_rounded, size: 18, color: VelvetColors.coralPeach),
                    label: const Text(
                      'Play Pariyojana Voice Sound 🎙️',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    onPressed: () {
                      final soundEnabled = ref.read(masterSoundEnabledProvider);
                      if (!soundEnabled) {
                        GlassSnackBar.show(context, '🔊 App Audio is MUTED in Settings!');
                        return;
                      }
                      ref.read(soundServiceProvider).playPariyojanaBootSound();
                      GlassSnackBar.show(context, '🔊 Playing Pariyojana Voice Sound...');
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildMetricPill(
    BuildContext context,
    String label,
    int count,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(height: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  fontFamily: GoogleFonts.outfit().fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: VelvetColors.textPrimary(context),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: VelvetColors.textSecondary(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
