import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/velvet_colors.dart';

// ─── State ───────────────────────────────────────────────────────────────────

final focusShieldProvider =
    StateNotifierProvider<FocusShieldNotifier, FocusShieldState>((ref) {
  return FocusShieldNotifier();
});

class FocusShieldState {
  final bool isActive;
  final int durationMinutes;
  final DateTime? activatedAt;
  final String mode;

  const FocusShieldState({
    this.isActive = false,
    this.durationMinutes = 60,
    this.activatedAt,
    this.mode = 'focus',
  });

  FocusShieldState copyWith({bool? isActive, int? durationMinutes, DateTime? activatedAt, String? mode}) {
    return FocusShieldState(
      isActive: isActive ?? this.isActive,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      activatedAt: activatedAt ?? this.activatedAt,
      mode: mode ?? this.mode,
    );
  }

  String get remainingLabel {
    if (!isActive || activatedAt == null || durationMinutes == 0) return '\u221e';
    final elapsed = DateTime.now().difference(activatedAt!);
    final total = Duration(minutes: durationMinutes);
    final rem = total - elapsed;
    if (rem.isNegative) return 'Done';
    final h = rem.inHours;
    final m = rem.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m left';
    return '${m}m left';
  }
}

class FocusShieldNotifier extends StateNotifier<FocusShieldState> {
  FocusShieldNotifier() : super(const FocusShieldState());

  void activate({int durationMinutes = 60, String mode = 'focus'}) {
    state = FocusShieldState(isActive: true, durationMinutes: durationMinutes, activatedAt: DateTime.now(), mode: mode);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Color(0x88200000), statusBarIconBrightness: Brightness.light));
  }

  void deactivate() {
    state = const FocusShieldState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }
}

// ─── Overlay ─────────────────────────────────────────────────────────────────

class FocusShieldOverlay extends ConsumerStatefulWidget {
  final Widget child;
  const FocusShieldOverlay({super.key, required this.child});

  @override
  ConsumerState<FocusShieldOverlay> createState() => _FocusShieldOverlayState();
}

class _FocusShieldOverlayState extends ConsumerState<FocusShieldOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  Timer? _autoTimer;
  Timer? _quoteTimer;
  int _quoteIdx = 0;

  static const _quotes = [
    ['योगः कर्मसु कौशलम्', 'Excellence in action is true Yoga. — BG 2.50'],
    ['नैनं छिन्दन्ति शस्त्राणि', 'Weapons cannot cut the soul; it is eternal. — BG 2.23'],
    ['मा फलेषु कदाचन', 'You have a right to act, never to the fruits thereof. — BG 2.47'],
    ['युक्ताहारविहारस्य', 'Moderation in food, recreation and sleep destroys all sorrow. — BG 6.17'],
    ['सर्वधर्मान् परित्यज्य', 'Surrender completely — I shall liberate you from all sins. — BG 18.66'],
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _autoTimer?.cancel();
    _quoteTimer?.cancel();
    super.dispose();
  }

  void _start(FocusShieldState s) {
    _fadeCtrl.forward();
    _autoTimer?.cancel();
    _quoteTimer?.cancel();
    if (s.durationMinutes > 0) {
      _autoTimer = Timer(Duration(minutes: s.durationMinutes), () {
        if (mounted) ref.read(focusShieldProvider.notifier).deactivate();
      });
    }
    _quoteTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) setState(() => _quoteIdx = (_quoteIdx + 1) % _quotes.length);
    });
  }

  void _stop() {
    _fadeCtrl.reverse();
    _autoTimer?.cancel();
    _quoteTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(focusShieldProvider);
    ref.listen<FocusShieldState>(focusShieldProvider, (prev, next) {
      if (!(prev?.isActive ?? false) && next.isActive) _start(next);
      if ((prev?.isActive ?? false) && !next.isActive) _stop();
    });

    return Stack(
      children: [
        widget.child,
        if (s.isActive)
          FadeTransition(opacity: _fadeAnim, child: _buildOverlay(context, s)),
      ],
    );
  }

  Widget _buildOverlay(BuildContext context, FocusShieldState s) {
    final accent = s.mode == 'deep' ? const Color(0xFF00E5FF) : const Color(0xFFFFB347);
    final bgTop = s.mode == 'deep' ? const Color(0xFF000D1A) : const Color(0xFF150A00);
    final q = _quotes[_quoteIdx % _quotes.length];

    return GestureDetector(
      onTap: () {},
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [bgTop.withValues(alpha: 0.9), const Color(0xFF050300).withValues(alpha: 0.96)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Badge
                  Column(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(border: Border.all(color: accent.withValues(alpha: 0.5)), borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(s.mode == 'sleep' ? Icons.nightlight_round : Icons.shield_rounded, color: accent, size: 13),
                        const SizedBox(width: 6),
                        Text(
                          s.mode == 'sleep' ? 'SLEEP MODE' : s.mode == 'deep' ? 'DEEP WORK SHIELD' : 'FOCUS SHIELD',
                          style: TextStyle(fontFamily: GoogleFonts.outfit().fontFamily, fontSize: 10, fontWeight: FontWeight.bold, color: accent, letterSpacing: 1.2),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 6),
                    Text(s.remainingLabel, style: TextStyle(fontSize: 12, color: accent.withValues(alpha: 0.65), fontFamily: GoogleFonts.outfit().fontFamily)),
                  ]),

                  // Gita Shloka
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 700),
                    child: Column(
                      key: ValueKey(_quoteIdx),
                      children: [
                        Text(q[0], textAlign: TextAlign.center, style: TextStyle(fontFamily: GoogleFonts.notoSans().fontFamily, fontSize: 24, fontWeight: FontWeight.w300, color: Colors.white.withValues(alpha: 0.9), height: 1.6)),
                        const SizedBox(height: 14),
                        Text(q[1], textAlign: TextAlign.center, style: TextStyle(fontFamily: GoogleFonts.outfit().fontFamily, fontSize: 13, color: accent.withValues(alpha: 0.8), height: 1.6, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),

                  // Exit
                  Column(children: [
                    Text('Breathe. Focus. Build.', style: TextStyle(fontFamily: GoogleFonts.outfit().fontFamily, fontSize: 11, color: Colors.white.withValues(alpha: 0.35), letterSpacing: 2)),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onLongPress: () => ref.read(focusShieldProvider.notifier).deactivate(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(border: Border.all(color: Colors.white.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(30)),
                        child: Text('Hold to Exit', style: TextStyle(fontFamily: GoogleFonts.outfit().fontFamily, fontSize: 12, color: Colors.white.withValues(alpha: 0.45))),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Launcher Sheet ───────────────────────────────────────────────────────────

class FocusShieldLauncher {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FocusShieldSheet(),
    );
  }
}

class _FocusShieldSheet extends ConsumerStatefulWidget {
  const _FocusShieldSheet();

  @override
  ConsumerState<_FocusShieldSheet> createState() => _FocusShieldSheetState();
}

class _FocusShieldSheetState extends ConsumerState<_FocusShieldSheet> {
  int _dur = 60;
  String _mode = 'focus';

  static const _durations = [
    {'label': '30 min', 'v': 30}, {'label': '1 hour', 'v': 60},
    {'label': '2 hours', 'v': 120}, {'label': '4 hours', 'v': 240}, {'label': '\u221e Night', 'v': 0},
  ];
  static const _modes = [
    {'id': 'focus', 'emoji': 'U0001F3AF', 'label': 'Focus'},
    {'id': 'deep', 'emoji': 'U0001F4BB', 'label': 'Deep Work'},
    {'id': 'sleep', 'emoji': 'U0001F319', 'label': 'Sleep'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: isDark ? VelvetColors.darkSurface : VelvetColors.cream,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 36, height: 4, decoration: BoxDecoration(color: VelvetColors.border(context), borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Row(children: [
          const Text('U0001F6E1\uFE0F', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Text('Focus Shield', style: TextStyle(fontFamily: GoogleFonts.outfit().fontFamily, fontSize: 20, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
        ]),
        const SizedBox(height: 4),
        Text('Lock into deep work. Silence distractions. Build.', style: TextStyle(fontSize: 12.5, color: VelvetColors.textSecondary(context))),
        const SizedBox(height: 20),
        Align(alignment: Alignment.centerLeft, child: Text('Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: VelvetColors.textSecondary(context)))),
        const SizedBox(height: 8),
        Row(children: _modes.map((m) {
          final sel = _mode == m['id'];
          return Expanded(child: GestureDetector(
            onTap: () => setState(() => _mode = m['id'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: sel ? VelvetColors.coralPeach.withValues(alpha: 0.15) : VelvetColors.surface(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: sel ? VelvetColors.coralPeach : VelvetColors.border(context), width: sel ? 1.5 : 1),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(m['emoji'] as String, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    m['label'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: sel ? VelvetColors.coralPeach : VelvetColors.textPrimary(context)),
                  ),
                ),
              ]),
            ),
          ));
        }).toList()),
        const SizedBox(height: 20),
        Align(alignment: Alignment.centerLeft, child: Text('Duration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: VelvetColors.textSecondary(context)))),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: _durations.map((d) {
          final sel = _dur == (d['v'] as int);
          return GestureDetector(
            onTap: () => setState(() => _dur = d['v'] as int),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? VelvetColors.coralPeach : VelvetColors.surface(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? VelvetColors.coralPeach : VelvetColors.border(context)),
              ),
              child: Text(d['label'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: sel ? Colors.white : VelvetColors.textPrimary(context))),
            ),
          );
        }).toList()),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: VelvetColors.coralPeach, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), elevation: 4),
            icon: const Icon(Icons.shield_rounded, size: 20),
            label: Text('Activate Focus Shield', style: TextStyle(fontFamily: GoogleFonts.outfit().fontFamily, fontWeight: FontWeight.bold, fontSize: 15)),
            onPressed: () {
              Navigator.pop(context);
              ref.read(focusShieldProvider.notifier).activate(durationMinutes: _dur, mode: _mode);
            },
          ),
        ),
      ]),
    );
  }
}
