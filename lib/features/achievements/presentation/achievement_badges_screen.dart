import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/velvet_colors.dart';
import '../../../shared_widgets/clay_card.dart';
import '../../idea_vault/presentation/providers/idea_provider.dart';
import '../../project_tracker/presentation/providers/project_provider.dart';
import '../../job_tracker/presentation/providers/job_provider.dart';

class BadgeItem {
  final String id;
  final String title;
  final String desc;
  final String emoji;
  final bool unlocked;
  const BadgeItem({required this.id, required this.title, required this.desc, required this.emoji, required this.unlocked});
}

class AchievementBadgesScreen extends ConsumerWidget {
  const AchievementBadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final ideas = ref.watch(ideasStreamProvider).valueOrNull ?? [];
    final projects = ref.watch(projectsStreamProvider).valueOrNull ?? [];
    final jobs = ref.watch(jobApplicationsStreamProvider).valueOrNull ?? [];

    final badges = [
      BadgeItem(id: '1', title: 'First Spark', desc: 'Captured your 1st idea in Vault', emoji: '💡', unlocked: ideas.isNotEmpty),
      BadgeItem(id: '2', title: 'Idea Architect', desc: 'Captured 5+ ideas in Vault', emoji: '⚡', unlocked: ideas.length >= 5),
      BadgeItem(id: '3', title: 'Builder Mindset', desc: 'Created 1st engineering project', emoji: '🛠️', unlocked: projects.isNotEmpty),
      BadgeItem(id: '4', title: 'Shipper', desc: 'Completed at least 1 project', emoji: '🚀', unlocked: projects.any((p) => p.status == 'DONE' || p.status == 'Done')),
      BadgeItem(id: '5', title: 'Career Hustler', desc: 'Tracked 1st job application', emoji: '🎯', unlocked: jobs.isNotEmpty),
      BadgeItem(id: '6', title: 'Interview Ready', desc: 'Reached interview stage', emoji: '💼', unlocked: jobs.any((j) => j.status == 'Interview' || j.status == 'Interviewing')),
      const BadgeItem(id: '7', title: 'Zero Trust Master', desc: 'Biometric lock enabled', emoji: '🔐', unlocked: true),
      const BadgeItem(id: '8', title: 'Token Miser', desc: 'BYOK AI token saver active', emoji: '💎', unlocked: true),
    ];

    final unlockedCount = badges.where((b) => b.unlocked).length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: VelvetColors.cocoa),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? const [VelvetColors.darkBg, VelvetColors.darkSurface, VelvetColors.darkBg]
                      : const [VelvetColors.cream, Color(0xFFF6ECE1), Color(0xFFFFF2EE)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Achievements 🏆', style: TextStyle(fontFamily: GoogleFonts.outfit().fontFamily, fontSize: 26, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
                  const SizedBox(height: 4),
                  Text('$unlockedCount / ${badges.length} Unlocked — Auto-earned through work', style: TextStyle(fontSize: 12, color: VelvetColors.textSecondary(context))),
                  const SizedBox(height: 20),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: badges.length,
                    itemBuilder: (context, idx) {
                      final b = badges[idx];
                      return ClayCard(
                        color: b.unlocked ? VelvetColors.surface(context) : VelvetColors.surface(context).withValues(alpha: 0.4),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(b.unlocked ? b.emoji : '🔒', style: TextStyle(fontSize: 32, color: b.unlocked ? null : Colors.grey)),
                            const SizedBox(height: 6),
                            Text(
                              b.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: b.unlocked ? VelvetColors.textPrimary(context) : VelvetColors.textSecondary(context),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              b.desc,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 9.5, color: VelvetColors.textSecondary(context)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
