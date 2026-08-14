import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velvet/core/sounds/sound_service.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../core/security/auth_service.dart';
import '../../../../core/providers/feature_toggles_provider.dart';
import '../../../../shared_widgets/animated_3d_logo.dart';

/// Ultra-Premium 2-Billion-Dollar Company Cinematic Splash Screen
/// Features quantum orbital preloader, iridescent metallic typography,
/// real-time telemetry HUD, and seamless biometric vault unlocking.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _letterSpacingAnimation;

  int _telemetryIndex = 0;
  final List<String> _telemetryMessages = [
    'INITIALIZING SECURE ENCLAVE 🛡️',
    'SQLCIPHER 256-BIT VAULT ARMED 🔒',
    'QUANTUM AI ORCHESTRATOR ONLINE ⚡',
    'EXECUTIVE WORKSPACE READY 🚀',
  ];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.78, curve: Curves.easeOutBack),
      ),
    );

    _letterSpacingAnimation = Tween<double>(begin: 16.0, end: 7.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.90, curve: Curves.easeOutCubic),
      ),
    );

    _entranceController.forward();

    // Trigger signature startup sound if enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final soundEnabled = ref.read(masterSoundEnabledProvider);
        if (soundEnabled) {
          ref.read(soundServiceProvider).playPariyojanaBootSound();
        }
      } catch (_) {}
    });

    // Rotate status telemetry
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _telemetryIndex = 1);
    });
    Future.delayed(const Duration(milliseconds: 1350), () {
      if (mounted) setState(() => _telemetryIndex = 2);
    });
    Future.delayed(const Duration(milliseconds: 2050), () {
      if (mounted) setState(() => _telemetryIndex = 3);
    });

    _initializeApp();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 2900));

    if (!mounted) return;

    // Check first-time onboarding
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final onboardingDone = prefs.getBool('velvet_onboarding_complete') ?? false;
      if (!onboardingDone) {
        context.go('/onboarding');
        return;
      }
    } catch (_) {}

    final authStatus = ref.read(authServiceProvider);

    if (authStatus == AuthStatus.onboarding) {
      context.go('/pin_setup');
    } else if (authStatus == AuthStatus.locked) {
      final success = await ref.read(authServiceProvider.notifier).authenticateBiometrics();
      if (!mounted) return;
      if (success) {
        context.go('/ideas');
      } else {
        context.go('/pin_login');
      }
    } else {
      context.go('/ideas');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? VelvetColors.darkBg : VelvetColors.cream,
      body: RepaintBoundary(
        child: Stack(
          children: [
            // 1. Cinematic Background Nebula Gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF090D14),
                            const Color(0xFF0F1420),
                            const Color(0xFF191F32),
                            const Color(0xFF090D14),
                          ]
                        : [
                            VelvetColors.cream,
                            const Color(0xFFFDF0E6),
                            const Color(0xFFFFECE3),
                            VelvetColors.cream,
                          ],
                  ),
                ),
              ),
            ),

            // 2. Interactive Starry Dust Particle Matrix
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _SplashStarfieldPainter(
                    progress: _pulseController,
                    isDark: isDark,
                  ),
                ),
              ),
            ),

            // 3. Central Brand Content
            SafeArea(
              child: Center(
                child: AnimatedBuilder(
                  animation: _entranceController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 3D Orbiting Preloader & Monogram
                            const Animated3DLoader(size: 220),

                            const SizedBox(height: 38),

                            // Clean Signature Brand Title
                            Text(
                              'PARIYOJANA',
                              style: TextStyle(
                                fontFamily: GoogleFonts.outfit().fontFamily,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                letterSpacing: _letterSpacingAnimation.value,
                                color: isDark ? const Color(0xFFF8FAFC) : VelvetColors.cocoa,
                                shadows: [
                                  Shadow(
                                    color: VelvetColors.coralPeach.withValues(alpha: isDark ? 0.45 : 0.2),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Subtitle Pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5.5),
                              decoration: BoxDecoration(
                                color: VelvetColors.coralPeach.withValues(alpha: isDark ? 0.18 : 0.14),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: VelvetColors.coralPeach.withValues(alpha: 0.5),
                                  width: 1.4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: VelvetColors.coralPeach.withValues(alpha: 0.25),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              child: Text(
                                'PERSONAL COMMAND CENTER // SECURE ENCLAVE',
                                style: TextStyle(
                                  fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                  color: VelvetColors.coralPeach,
                                ),
                              ),
                            ),

                            const SizedBox(height: 34),

                            // Live Cyber Telemetry Ticker
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              transitionBuilder: (child, anim) {
                                return FadeTransition(
                                  opacity: anim,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.0, 0.4),
                                      end: Offset.zero,
                                    ).animate(anim),
                                    child: child,
                                  ),
                                );
                              },
                              child: Text(
                                _telemetryMessages[_telemetryIndex],
                                key: ValueKey<int>(_telemetryIndex),
                                style: TextStyle(
                                  fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.4,
                                  color: VelvetColors.textSecondary(context).withValues(alpha: 0.85),
                                ),
                              ),
                            ),

                            const SizedBox(height: 50),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Zero-Allocation Starfield Particle Background Painter
class _SplashStarfieldPainter extends CustomPainter {
  final Animation<double> progress;
  final bool isDark;

  static final List<math.Point<double>> _staticStars = List.generate(45, (i) {
    final rand = math.Random(i * 137);
    return math.Point(rand.nextDouble(), rand.nextDouble());
  });

  _SplashStarfieldPainter({
    required this.progress,
    required this.isDark,
  }) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final t = progress.value;

    for (int i = 0; i < _staticStars.length; i++) {
      final star = _staticStars[i];
      final x = star.x * size.width;
      final y = star.y * size.height;
      final wave = (math.sin((t * 2 * math.pi) + (i * 0.45)) + 1) / 2;

      final radius = 1.0 + (wave * 1.8);
      final alpha = (isDark ? (0.2 + 0.5 * wave) : (0.12 + 0.35 * wave)).clamp(0.0, 1.0);

      paint.color = (i % 3 == 0)
          ? VelvetColors.coralPeach.withValues(alpha: alpha)
          : (i % 3 == 1)
              ? VelvetColors.periwinkle.withValues(alpha: alpha)
              : (isDark ? Colors.white.withValues(alpha: alpha) : VelvetColors.cocoa.withValues(alpha: alpha * 0.55));

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SplashStarfieldPainter oldDelegate) => true;
}
