import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/security/auth_service.dart';
import '../../core/theme/velvet_colors.dart';
import '../../shared_widgets/glass_container.dart';
import '../../shared_widgets/liquid_fab.dart';
import '../../shared_widgets/pariyojana_logo.dart';
import '../../shared_widgets/dynamic_island.dart';
import '../../shared_widgets/gita_shloka_dialog.dart';
import '../../shared_widgets/whats_new_dialog.dart';
import '../../shared_widgets/quick_thought_capture_sheet.dart';
import '../../shared_widgets/executive_profile_sheet.dart';
import '../../shared_widgets/feature_explainer_sheet.dart';
import '../focus_shield/presentation/focus_shield_overlay.dart';

import '../../shared_widgets/app_introduction_sheet.dart';
import '../../core/providers/feature_toggles_provider.dart';

final quickCaptureTriggerProvider = StateProvider<int?>((ref) => null);

class NavigationShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const NavigationShell({
    super.key,
    required this.navigationShell,
  });

  @override
  ConsumerState<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends ConsumerState<NavigationShell> with WidgetsBindingObserver {
  bool _shlokaShown = false;

  // Auto-lock: lock vault after 5 min in background
  DateTime? _backgroundedAt;
  static const Duration _autoLockDuration = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFirstTimeBlueprintIfNeeded();
    });
  }

  Future<void> _showFirstTimeBlueprintIfNeeded() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final forceWelcome = prefs.getBool('pariyojana_show_welcome_on_mount') ?? false;
      final blueprintShown = prefs.getBool('pariyojana_app_blueprint_shown') ?? false;

      if (forceWelcome || !blueprintShown) {
        await prefs.setBool('pariyojana_show_welcome_on_mount', false);
        await prefs.setBool('pariyojana_app_blueprint_shown', true);
        if (mounted) {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AppIntroductionSheet(),
          );
        }
      }
    } catch (_) {}

    if (mounted && !_shlokaShown) {
      _shlokaShown = true;
      await GitaStartupDialog.showIfNeeded(context, ref);
      if (mounted) {
        await WhatsNewDialog.showIfNeeded(context, ref);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _backgroundedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_backgroundedAt != null) {
        final elapsed = DateTime.now().difference(_backgroundedAt!);
        if (elapsed >= _autoLockDuration) {
          ref.read(authServiceProvider.notifier).lock();
          if (mounted) {
            context.go('/pin_login');
          }
        }
        _backgroundedAt = null;
      }
    }
  }

  void _onTap(BuildContext context, int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Top Header Deck (Dynamic Island on top + Top Nav Bar below it)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // A. Dynamic Island Pill
                  const Align(
                    alignment: Alignment.topCenter,
                    child: DynamicIslandHeader(),
                  ),

                  const SizedBox(height: 8),

                  // B. Top Bar (Logo Left, Actions Right)
                  RepaintBoundary(
                    child: GlassContainer(
                      borderRadius: 22,
                      blurSigma: 8,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Logo + App Name (Tapping opens App Blueprint Deck)
                        InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const AppIntroductionSheet(),
                            );
                          },
                          child: Tooltip(
                            message: 'Executive App Blueprint & Philosophy Deck',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const PariyojanaLogo(size: 30),
                                const SizedBox(width: 10),
                                Text(
                                  'Pariyojana',
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.outfit().fontFamily,
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: VelvetColors.textPrimary(context),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Right: Feature Compass + Knowledge/AI Graph + Settings
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.explore_outlined, color: VelvetColors.coralPeach, size: 22),
                              tooltip: 'Feature Compass & Explainer 🧭',
                              onPressed: () {
                                FeatureExplainerSheet.show(
                                  context,
                                  initialTabIndex: widget.navigationShell.currentIndex + 1,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.hub_outlined, color: VelvetColors.periwinkle, size: 22),
                              tooltip: 'Mitnick AI',
                              onPressed: () => context.push('/mitnick'),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.settings_outlined,
                                color: VelvetColors.textPrimary(context),
                                size: 22,
                              ),
                              tooltip: 'Settings',
                              onPressed: () => context.push('/settings'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Screen Content: Expanded to fill remaining height with ZERO overlap
          Expanded(
            child: widget.navigationShell,
          ),
        ],
      ),
    ),
    floatingActionButton: LiquidFab(
      onPressed: () => _showSpeedDialSheet(context, ref),
      icon: const Icon(Icons.add, color: Colors.white, size: 28),
      tooltip: 'Quick Capture Speed Dial',
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    bottomNavigationBar: Builder(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final outerHPad = screenWidth < 360 ? 8.0 : screenWidth < 400 ? 12.0 : 16.0;
        final innerHPad = screenWidth < 360 ? 4.0 : 8.0;
        final fabSpacerWidth = screenWidth < 360 ? 32.0 : screenWidth < 400 ? 38.0 : 44.0;

        return RepaintBoundary(
          child: Container(
            color: Colors.transparent,
            child: SafeArea(
              minimum: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: outerHPad),
                child: GlassContainer(
                  borderRadius: 24,
                  blurSigma: 8,
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: innerHPad),
                  child: Row(
                    children: [
                      Expanded(child: _buildNavItem(context, 0, Icons.lightbulb_outline, 'Vault')),
                      Expanded(child: _buildNavItem(context, 1, Icons.folder_open_outlined, 'Projects')),
                      SizedBox(width: fabSpacerWidth), // Space for FAB
                      Expanded(child: _buildNavItem(context, 2, Icons.menu_book_outlined, 'Research')),
                      Expanded(child: _buildNavItem(context, 3, Icons.work_outline_outlined, 'Jobs')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final isSelected = index == widget.navigationShell.currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isSelected
        ? VelvetColors.coralPeach
        : (isDark ? Colors.white.withValues(alpha: 0.6) : VelvetColors.cocoa.withValues(alpha: 0.55));
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth < 360 ? 20.0 : 22.0;
    final fontSize = screenWidth < 360 ? 10.0 : 11.0;

    return InkWell(
      onTap: () => _onTap(context, index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: iconSize),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSpeedDialSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.58,
        minChildSize: 0.35,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: VelvetColors.surface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: VelvetColors.border(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  'Quick Action Speed Dial ⚡',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.spaceAround,
                children: [
                  _buildSpeedDialOption(context, ref, 'Quick Idea', Icons.lightbulb_outline, VelvetColors.coralPeach, 0),
                  _buildSpeedDialOption(context, ref, 'Quick Project', Icons.folder_open_outlined, VelvetColors.mint, 1),
                  _buildSpeedDialOption(context, ref, 'Quick Paper', Icons.menu_book_outlined, VelvetColors.periwinkle, 2),
                  _buildSpeedDialOption(context, ref, 'Quick Job', Icons.work_outline_outlined, VelvetColors.clayTan, 3),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 10),
              Center(
                child: Text('Power Features & Command Deck:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VelvetColors.textSecondary(context))),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.explore_rounded, size: 14, color: VelvetColors.coralPeach),
                    label: const Text('Feature Guide 🧭', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.pop(context);
                      FeatureExplainerSheet.show(
                        context,
                        initialTabIndex: widget.navigationShell.currentIndex + 1,
                      );
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.flash_on_rounded, size: 14, color: VelvetColors.coralPeach),
                    label: const Text('Quick Thought ⚡', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.pop(context);
                      QuickThoughtCaptureSheet.show(context);
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.account_circle_outlined, size: 14, color: VelvetColors.coralPeach),
                    label: const Text('Executive Profile 👤', style: TextStyle(fontSize: 10.5)),
                    onPressed: () {
                      Navigator.pop(context);
                      ExecutiveProfileSheet.show(context, ref);
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.bolt_rounded, size: 14, color: VelvetColors.coralPeach),
                    label: const Text('Mitnick AI ⚡', style: TextStyle(fontSize: 10.5)),
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/mitnick');
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.shield_outlined, size: 14),
                    label: const Text('Focus Shield 🛡️', style: TextStyle(fontSize: 10.5)),
                    onPressed: () {
                      Navigator.pop(context);
                      FocusShieldLauncher.show(context);
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.analytics_outlined, size: 14),
                    label: const Text('Analytics 📊', style: TextStyle(fontSize: 10.5)),
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/analytics');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedDialOption(BuildContext context, WidgetRef ref, String label, IconData icon, Color color, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        widget.navigationShell.goBranch(index);
        Future.delayed(const Duration(milliseconds: 120), () {
          ref.read(quickCaptureTriggerProvider.notifier).state = index;
        });
      },
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.20),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 1.5),
              ),
              child: Icon(icon, color: VelvetColors.iconColor(context), size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
