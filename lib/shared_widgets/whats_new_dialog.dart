import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../core/theme/velvet_colors.dart';
import '../core/haptics/haptic_service.dart';
import '../core/services/update_checker_service.dart';

class WhatsNewDialog extends ConsumerWidget {
  const WhatsNewDialog({super.key, this.isManualTrigger = false});

  final bool isManualTrigger;

  static const String _storageKey = 'pariyojana_last_seen_whats_new_version';
  static const String _currentVersionKey = '1.2.1+11';

  /// Show the dialog automatically if the user has updated to a new version.
  static Future<void> showIfNeeded(BuildContext context, WidgetRef ref) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String currentVersion = _currentVersionKey;
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        if (packageInfo.version.isNotEmpty) {
          currentVersion = packageInfo.version;
        }
      } catch (_) {}

      final lastSeen = prefs.getString(_storageKey);
      if (lastSeen == currentVersion) {
        return; // Already seen this version's release notes
      }

      // Mark as seen immediately so it NEVER loops on app reopening
      await prefs.setString(_storageKey, currentVersion);

      if (!context.mounted) return;

      await showDialog(
        context: context,
        useRootNavigator: true,
        barrierDismissible: true,
        builder: (context) => const WhatsNewDialog(),
      );
    } catch (_) {}
  }

  /// Show the dialog manually on-demand (e.g. from Settings).
  static Future<void> showManual(BuildContext context) async {
    await showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (context) => const WhatsNewDialog(isManualTrigger: true),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final haptic = ref.read(hapticServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : const Color(0xFFFFFBF7),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: VelvetColors.coralPeach.withValues(alpha: isDark ? 0.6 : 0.9),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.6)
                  : VelvetColors.cocoa.withValues(alpha: 0.25),
              blurRadius: 30,
              spreadRadius: 4,
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rocket / App Update Header
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: VelvetColors.coralPeach.withValues(alpha: isDark ? 0.22 : 0.15),
                  border: Border.all(color: VelvetColors.coralPeach, width: 2),
                ),
                child: const Center(
                  child: Text(
                    '🚀',
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Text(
                'PARIYOJANA — WHAT\'S NEW',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: VelvetColors.coralPeach,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),

              FutureBuilder<String>(
                future: UpdateCheckerService.currentAppVersion(),
                builder: (context, snapshot) {
                  final ver = snapshot.data ?? '1.2.0';
                  return Text(
                    'Version $ver Update Notes',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFE2E8F0) : VelvetColors.cocoa,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              const SizedBox(height: 18),

              // Feature Highlights Card (Shloka style)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFF9F5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: VelvetColors.coralPeach.withValues(alpha: isDark ? 0.5 : 0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    _buildFeatureItem(
                      context,
                      icon: '🧭',
                      title: 'Humanized Feature Compass',
                      desc: 'Jargon-free 3-step action recipes and everyday lifehacks across all 24 workspace capabilities.',
                      isDark: isDark,
                    ),
                    const Divider(height: 20, color: Colors.black12),
                    _buildFeatureItem(
                      context,
                      icon: '🛡️',
                      title: 'Zero-Data-Loss Safety Engine',
                      desc: 'Protected database engine with automatic .safety_bak snapshot creation and permanent vault defense.',
                      isDark: isDark,
                    ),
                    const Divider(height: 20, color: Colors.black12),
                    _buildFeatureItem(
                      context,
                      icon: '💻',
                      title: 'Cyber Command Terminal Guard',
                      desc: '1-tap quick launcher embedded in the Dynamic Island with auto-clamping keyboard viewport mechanics.',
                      isDark: isDark,
                    ),
                    const Divider(height: 20, color: Colors.black12),
                    _buildFeatureItem(
                      context,
                      icon: '⚡',
                      title: '120 FPS Turbo Optimization',
                      desc: 'SQLite WAL mode engine and dedicated GPU repaint boundaries for silky sub-millisecond local execution.',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    haptic.lightTap();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VelvetColors.coralPeach,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    'Explore Workspace 🚀',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required String icon,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFF1F5F9) : VelvetColors.cocoa,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.35,
                  color: isDark ? const Color(0xFF94A3B8) : VelvetColors.cocoa.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
