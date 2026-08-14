import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/i18n/app_translation.dart';
import '../../core/theme/velvet_colors.dart';
import 'glass_snackbar.dart';
import 'executive_user_avatar.dart';
import 'executive_profile_sheet.dart';
import '../features/focus_shield/presentation/focus_shield_overlay.dart';

final quickAddTriggerProvider = StateProvider<String?>((ref) => null);

class DynamicIslandHeader extends ConsumerStatefulWidget {
  const DynamicIslandHeader({super.key});

  @override
  ConsumerState<DynamicIslandHeader> createState() => _DynamicIslandHeaderState();
}

class _DynamicIslandHeaderState extends ConsumerState<DynamicIslandHeader>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _pulseController;

  final List<Map<String, String>> _langList = [
    {'code': 'en', 'name': 'EN 🇬🇧'},
    {'code': 'hi', 'name': 'HI 🇮🇳'},
    {'code': 'te', 'name': 'TE 🇮🇳'},
    {'code': 'kn', 'name': 'KN 🇮🇳'},
    {'code': 'es', 'name': 'ES 🇪🇸'},
    {'code': 'ja', 'name': 'JA 🇯🇵'},
    {'code': 'de', 'name': 'DE 🇩🇪'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _cycleLanguage() {
    final currentLang = ref.read(languageProvider);
    int currentIndex = _langList.indexWhere((l) => l['code'] == currentLang);
    if (currentIndex == -1) currentIndex = 0;
    final nextLang = _langList[(currentIndex + 1) % _langList.length];
    
    ref.read(languageProvider.notifier).changeLanguage(nextLang['code']!);
    GlassSnackBar.show(context, 'Language switched to: ${nextLang['name']} 🌐');
  }



  void _showQuickNoteDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: VelvetColors.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: VelvetColors.coralPeach),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Quick Idea Note',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: VelvetColors.textPrimary(context),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Brainstorm or quick insight...',
            filled: true,
            fillColor: VelvetColors.cardSurface(context),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          style: TextStyle(color: VelvetColors.textPrimary(context)),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: TextStyle(color: VelvetColors.textSecondary(context))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: VelvetColors.coralPeach,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(dialogCtx);
                GlassSnackBar.show(context, 'Note captured & encrypted! 💡🔐');
              }
            },
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final expandedWidth = (screenWidth * 0.94).clamp(320.0, 420.0);
    final currentLangCode = ref.watch(languageProvider).toUpperCase();

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        width: _isExpanded ? expandedWidth : 255,
        height: _isExpanded ? 148 : 36,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: VelvetColors.cardSurface(context).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(_isExpanded ? 22 : 18),
          border: Border.all(
            color: VelvetColors.coralPeach.withValues(alpha: 0.5),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: _isExpanded ? 18 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_isExpanded ? 22 : 18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 180),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: _buildCompactContent(currentLangCode),
                secondChild: _buildExpandedContent(context, currentLangCode),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactContent(String langCode) {
    return SizedBox(
      height: 26,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: VelvetColors.mint,
                          boxShadow: [
                            BoxShadow(
                              color: VelvetColors.mint.withValues(alpha: 0.8 * _pulseController.value),
                              blurRadius: 6,
                              spreadRadius: 2.5,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'PARIYOJANA ⚡',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: GoogleFonts.outfit().fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: VelvetColors.textPrimary(context),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: VelvetColors.coralPeach.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  '🌐 $langCode',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: VelvetColors.textPrimary(context),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ExecutiveProfileSheet.show(context, ref);
                },
                child: const ExecutiveUserAvatar(
                  size: 20,
                  showHalo: false,
                  showBadge: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, String langCode) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt_rounded, color: VelvetColors.coralPeach, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Dynamic Power Cockpit',
                    style: TextStyle(
                      fontFamily: GoogleFonts.outfit().fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: VelvetColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: () => setState(() => _isExpanded = false),
                child: Icon(Icons.close_rounded, color: VelvetColors.iconColor(context), size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Row 1: Mitnick AI & Command Center
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.bolt_rounded,
                label: 'Mitnick AI ⚡',
                color: VelvetColors.coralPeach,
                onTap: () {
                  setState(() => _isExpanded = false);
                  context.push('/mitnick');
                },
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildActionButton(
                icon: Icons.shield_outlined,
                label: 'Focus Shield 🛡️',
                color: VelvetColors.periwinkle,
                onTap: () {
                  setState(() => _isExpanded = false);
                  FocusShieldLauncher.show(context);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Row 2: Executive Profile & Settings
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.account_circle_outlined,
                label: 'Executive Profile 👤',
                color: VelvetColors.coralPeach,
                onTap: () {
                  setState(() => _isExpanded = false);
                  ExecutiveProfileSheet.show(context, ref);
                },
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildActionButton(
                icon: Icons.settings_outlined,
                label: 'Settings ⚙️',
                color: VelvetColors.mint,
                onTap: () {
                  setState(() => _isExpanded = false);
                  context.push('/settings');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Row 3: Language Switcher & Quick Note
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.language_rounded,
                label: 'Lang: $langCode 🌐',
                color: VelvetColors.periwinkle,
                onTap: _cycleLanguage,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildActionButton(
                icon: Icons.edit_note_rounded,
                label: 'Quick Note 💡',
                color: VelvetColors.clayTan,
                onTap: _showQuickNoteDialog,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6.5, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.45), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: VelvetColors.textPrimary(context)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: VelvetColors.textPrimary(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
