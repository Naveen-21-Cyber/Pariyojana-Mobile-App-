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
import '../../shared_widgets/executive_profile_sheet.dart';
import '../focus_shield/presentation/focus_shield_overlay.dart';

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
      if (!_shlokaShown) {
        _shlokaShown = true;
        GitaStartupDialog.showIfNeeded(context, ref);
      }
    });
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
                  // Layer 1: Dynamic Island
                  const Align(
                    alignment: Alignment.topCenter,
                    child: DynamicIslandHeader(),
                  ),
                  const SizedBox(height: 6),

                  // Layer 2: Glassmorphic Round-Edged Top Navigation Bar
                  GlassContainer(
                    borderRadius: 22,
                    blurSigma: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Circle Monogram + Pariyojana
                        Row(
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

                        // Right: Knowledge/AI Graph + Settings
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.hub_outlined, color: VelvetColors.coralPeach, size: 22),
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
      bottomNavigationBar: Container(
        color: Colors.transparent,
        child: SafeArea(
          minimum: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GlassContainer(
              borderRadius: 24,
              blurSigma: 20,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(context, 0, Icons.lightbulb_outline, 'Vault'),
                  _buildNavItem(context, 1, Icons.folder_open_outlined, 'Projects'),
                  const SizedBox(width: 48), // Space for FAB
                  _buildNavItem(context, 2, Icons.menu_book_outlined, 'Research'),
                  _buildNavItem(context, 3, Icons.work_outline_outlined, 'Jobs'),
                ],
              ),
            ),
          ),
        ),
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
    final hPad = screenWidth < 360 ? 6.0 : screenWidth < 400 ? 9.0 : 12.0;

    return InkWell(
      onTap: () => _onTap(context, index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: color,
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
