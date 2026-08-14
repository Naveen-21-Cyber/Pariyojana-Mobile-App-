import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  double _pageOffset = 0.0;
  int _currentPage = 0;

  late AnimationController _pulseController;
  late AnimationController _scanController;
  late AnimationController _flappyLoaderController;

  bool _isFlappyLoading = false;

  static const _slides = [
    // ── SLIDE 0: SANSKRIT & PARIYOJANA BLUEPRINT (SAFFRON THEME) ──────────────
    _OnboardingSlide(
      heroType: _HeroType.sanskritChakra,
      badgeText: 'THE MASTER BLUEPRINT • परियोजना',
      title: 'Welcome to Pariyojana',
      subtitle: 'योगः कर्मसु कौशलम् — "Excellence & Skill in Action"',
      description:
          'Pariyojana (ಪರಿಯೋಜನಾ) is a sovereign, privacy-first personal command center engineered for developers, AI researchers, and relentless builders.',
      features: [
        _SlideFeature('🛡️', 'Why It Exists',
            'Built 100% offline-first with AES-256 SQLCipher. Your mind\'s work stays strictly private.'),
        _SlideFeature('🎯', 'Who It Is For',
            'Engineers, researchers & creators who demand total sovereignty over their code, ideas, and career.'),
        _SlideFeature('⚡', 'How to Maximize',
            'Connect your own AI API key, import GitHub repos, record instant voice notes, and track sprints.'),
      ],
      accentColor: Color(0xFFFF9100),
      secondaryColor: Color(0xFFFF3D00),
      cardBorderColor: Color(0xFFFFAB40),
      isSpecialOrange: true,
      isSpecialPurple: false,
    ),

    // ── SLIDE 1: ENCRYPTED VAULT & GOOGLE OAUTH (CYBER CORAL THEME) ───────────
    _OnboardingSlide(
      heroType: _HeroType.cryptoVault,
      badgeText: 'SQLCIPHER AES-256 • GOOGLE OAUTH',
      title: 'Your Encrypted\nCommand Center',
      subtitle: '100% On-Device & Google Sign-In',
      description:
          'Pariyojana encrypts your projects, ideas, research papers, and job applications locally at rest with real native Google OAuth sign-in support.',
      features: [
        _SlideFeature('🔑', 'Master Key Security',
            'All database tables protected by SQLCipher AES-256 encryption.'),
        _SlideFeature('🌐', 'Google OAuth Sign-In',
            'Sign in with Google for cloud backup while preserving 100% on-device zeroization.'),
        _SlideFeature('📱', 'On-Device Sovereignty',
            'Your personal intelligence never leaves your physical hardware unencrypted.'),
      ],
      accentColor: Color(0xFFFF8BA7),
      secondaryColor: Color(0xFFFF1744),
      cardBorderColor: Color(0xFFFF8BA7),
      isSpecialOrange: false,
      isSpecialPurple: false,
    ),

    // ── SLIDE 2: BYOK ARCHITECTURE (CYBER CYAN THEME) ────────────────────────
    _OnboardingSlide(
      heroType: _HeroType.neuralMesh,
      badgeText: 'BYOK • BRING YOUR OWN AI KEY',
      title: 'Universal AI &\nZero Vendor Lock-In',
      subtitle: 'Plug & Play Any AI Model of Choice',
      description:
          'Pariyojana uses BYOK (Bring Your Own Key) architecture. Connect your own API key (OpenAI, OpenRouter, Gemini, Claude, Groq, or Local LLM) with 100% freedom.',
      features: [
        _SlideFeature('🔑', 'Your Own Keys',
            'Store personal API keys in Android Encrypted SharedPreferences TEE HSM.'),
        _SlideFeature('🧠', 'Multi-Model Freedom',
            'Generate company dossiers, summarize research papers, and automate tasks with zero vendor lock-in.'),
      ],
      accentColor: Color(0xFF00E5FF),
      secondaryColor: Color(0xFF00B0FF),
      cardBorderColor: Color(0xFF00E5FF),
      isSpecialOrange: false,
      isSpecialPurple: false,
    ),

    // ── SLIDE 3: GITHUB PUBLIC & PRIVATE REPO INSPECTOR (LIME GOLD THEME) ─────
    _OnboardingSlide(
      heroType: _HeroType.codeTerminal,
      badgeText: 'BUILDER ENGINE • GITHUB REPO INSPECTOR',
      title: 'Built for\nRelentless Devs',
      subtitle: 'Public & Private Repo Files, Trees & PAT Sync',
      description:
          'Inspect public & private GitHub repository names, folder structures, file trees, and code files lightweight without downloading heavy source archives.',
      features: [
        _SlideFeature('🌐', 'Public Repo Tree & File Inspector',
            'Fetch folder trees, file structures & code files from any public GitHub repository.'),
        _SlideFeature('🔒', 'Private Repo PAT Sync',
            'Connect encrypted PATs to inspect private repository files & issue pipelines with zero middleman servers.'),
        _SlideFeature('🎙️', 'Offline Voice Notes',
            'Speak ideas aloud to automatically transcribe and store them in your encrypted local vault.'),
      ],
      accentColor: Color(0xFFC6E377),
      secondaryColor: Color(0xFF7CB342),
      cardBorderColor: Color(0xFFC6E377),
      isSpecialOrange: false,
      isSpecialPurple: false,
    ),

    // ── SLIDE 4: HARDWARE DRM & BIOMETRIC CYBER-VAULT (GOLD HUD THEME) ───────
    _OnboardingSlide(
      heroType: _HeroType.biometricScanner,
      badgeText: 'HARDWARE DRM & TEE KEYSTORE',
      title: 'Hardware Security\n& Biometric Armor',
      subtitle: 'Widevine L1 DRM • FLAG_SECURE • TEE HSM',
      description:
          'Military-grade protection with hardware DRM, TEE KeyStore HSM, anti-screenshot shields, and anti-forensic RAM buffer zeroing.',
      features: [
        _SlideFeature('🛡️', 'Widevine L1 Hardware DRM',
            'Queries physical Widevine L1 HSM hardware signatures from Android OS.'),
        _SlideFeature('🚫', 'FLAG_SECURE Screen Shield',
            'Blocks Android screenshots, screen recording, and task-switcher snapshots.'),
        _SlideFeature('🔐', 'Android KeyStore TEE HSM',
            'Hardware-backed Master Keys generated inside Android Trusted Execution Environment.'),
        _SlideFeature('💾', 'SQLCipher AES-256 Encryption',
            '100% of local database tables (Ideas, Projects, Papers, Jobs) encrypted at rest.'),
        _SlideFeature('🧹', 'Anti-Forensic Memory Scrub',
            'Zeroes out sensitive RAM byte buffers (0x00) and triggers System.gc sweeps.'),
      ],
      accentColor: Color(0xFFFFD700),
      secondaryColor: Color(0xFFFF8F00),
      cardBorderColor: Color(0xFFFFD700),
      isSpecialOrange: false,
      isSpecialPurple: false,
    ),

    // ── SLIDE 5: CRAFTED BY A SOLO INDIE DEVELOPER (PURPLE THEME) ───────────
    _OnboardingSlide(
      heroType: _HeroType.indieHeart,
      badgeText: 'CRAFTED BY A SOLO INDIE DEV • ZERO CORPORATE ADS',
      title: 'Built With Passion,\nOwned By You',
      subtitle: 'Crafted by an Indie Developer for Sovereign Minds',
      description:
          'Built with genuine love for software craftsmanship by a solo indie developer. Zero corporate tracking, zero ads, zero investor pressure, zero subscription traps.',
      features: [
        _SlideFeature('❤️', 'Solo Indie Craftsmanship',
            'Created out of necessity & passion for developers, researchers & creators worldwide.'),
        _SlideFeature('⚡', 'Native On-Device Speed',
            'Runs 100% offline on your device with zero middleman servers or cloud latency.'),
        _SlideFeature('📦', 'Total Data Sovereignty',
            'Export your encrypted data anytime in RSA/JSON format with zero platform lock-in.'),
      ],
      accentColor: Color(0xFFD0BCFF),
      secondaryColor: Color(0xFF9A82DB),
      cardBorderColor: Color(0xFFD0BCFF),
      isSpecialOrange: false,
      isSpecialPurple: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _flappyLoaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _pageController.addListener(() {
      if (_pageController.page != null) {
        setState(() {
          _pageOffset = _pageController.page!;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    _scanController.dispose();
    _flappyLoaderController.dispose();
    super.dispose();
  }

  Future<void> _triggerFlappyLoaderTransition() async {
    if (_isFlappyLoading) return;
    setState(() => _isFlappyLoading = true);

    await HapticFeedback.heavyImpact();
    _flappyLoaderController.repeat(); // ignore: unawaited_futures

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('velvet_onboarding_complete', true);

    await Future.delayed(const Duration(milliseconds: 3000));
    if (mounted) context.go('/splash');
  }

  void _next() {
    HapticFeedback.mediumImpact();
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: const Cubic(0.16, 1.0, 0.3, 1.0),
      );
    } else {
      _triggerFlappyLoaderTransition();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSlide = _slides[_currentPage];

    final bgAccent = Color.lerp(
          _slides[_pageOffset.floor()].accentColor,
          _slides[(_pageOffset.ceil()).clamp(0, _slides.length - 1)]
              .accentColor,
          _pageOffset - _pageOffset.floor(),
        ) ??
        currentSlide.accentColor;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      body: Stack(
        children: [
          // ── Layer 1: Dynamic Background Mesh Orbs ────────────────────────
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final pulse = _pulseController.value;
              return Stack(
                children: [
                  Positioned(
                    top: -100 + (pulse * 30),
                    right: -80 + (pulse * 20),
                    child: Container(
                      width: 360,
                      height: 360,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            bgAccent.withValues(alpha: 0.32),
                            bgAccent.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -120 - (pulse * 30),
                    left: -90 - (pulse * 20),
                    child: Container(
                      width: 380,
                      height: 380,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            currentSlide.secondaryColor.withValues(alpha: 0.28),
                            bgAccent.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // ── Layer 2: Main Lenis / GSAP Onboarding Viewport ───────────────
          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: bgAccent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: bgAccent.withValues(alpha: 0.5),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: bgAccent.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Text('🔱', style: TextStyle(fontSize: 15)),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'PARIYOJANA',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: _triggerFlappyLoaderTransition,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Card Page Viewport
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) {
                      HapticFeedback.selectionClick();
                      setState(() => _currentPage = i);
                    },
                    itemCount: _slides.length,
                    itemBuilder: (context, index) => _FAANGSlideCard(
                      slide: _slides[index],
                      isActive: index == _currentPage,
                      pulseAnimation: _pulseController,
                      scanAnimation: _scanController,
                    ),
                  ),
                ),

                // ── Layer 3: Dynamic Lenis Dots & Action CTA Button ──
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            curve: const Cubic(0.16, 1.0, 0.3, 1.0),
                            margin: const EdgeInsets.symmetric(horizontal: 3.5),
                            width: _currentPage == i ? 28 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: _currentPage == i
                                  ? currentSlide.accentColor
                                  : Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: _currentPage == i
                                  ? [
                                      BoxShadow(
                                        color: currentSlide.accentColor
                                            .withValues(alpha: 0.8),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: _currentPage == _slides.length - 1
                                ? [const Color(0xFFD0BCFF), const Color(0xFF9A82DB)]
                                : (_currentPage == _slides.length - 2
                                    ? [
                                        const Color(0xFFFFD700),
                                        const Color(0xFFFF8F00)
                                      ]
                                    : [
                                        currentSlide.accentColor,
                                        currentSlide.secondaryColor,
                                      ]),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: currentSlide.accentColor
                                  .withValues(alpha: 0.50),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _next,
                          child: Shimmer.fromColors(
                            baseColor: _currentPage >= _slides.length - 2
                                ? Colors.black
                                : const Color(0xFF0A0E14),
                            highlightColor: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentPage < _slides.length - 1
                                      ? (_currentPage == 0
                                          ? 'Explore Blueprint  ➔'
                                          : 'Continue  ➔')
                                      : 'JOIN THE SOVEREIGN BUILDERS 🚀',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: _currentPage == _slides.length - 1
                                        ? 13
                                        : 14.5,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Layer 4: RETRO FLAPPY BIRD OBSTACLE FIELD LOADER OVERLAY ──────
          if (_isFlappyLoading)
            Positioned.fill(
              child: Container(
                color: const Color(0xFF0D1117).withValues(alpha: 0.95),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Circular Flappy Bird World Frame
                      AnimatedBuilder(
                        animation: _flappyLoaderController,
                        builder: (context, child) {
                          return Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFF6CCEE7), Colors.white],
                                stops: [0.6, 1.0],
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.8),
                                width: 3,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFF6CCEE7),
                                  blurRadius: 30,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Stack(
                                children: [
                                  // Scrolling Green Pipe Obstacles
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _FlappyPipesPainter(
                                          progress:
                                              _flappyLoaderController.value),
                                    ),
                                  ),

                                  // Flappy Bird Pixel Character
                                  Center(
                                    child: CustomPaint(
                                      size: const Size(60, 42),
                                      painter: _FlappyBirdPixelPainter(
                                          progress:
                                              _flappyLoaderController.value),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 28),

                      Shimmer.fromColors(
                        baseColor: const Color(0xFFFFD700),
                        highlightColor: Colors.white,
                        child: const Text(
                          'INITIALIZING SOVEREIGN VAULT...',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Loading local SQLCipher AES-256 & TEE KeyStore...',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Custom Painter for Flappy Bird Green Pipes & Sky Clouds Obstacle Field
class _FlappyPipesPainter extends CustomPainter {
  final double progress;
  _FlappyPipesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Render Scrolling Pixel Sky Clouds
    final cloudShift = (progress * size.width * 0.8) % size.width;
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);

    canvas.drawCircle(Offset(size.width * 0.3 - cloudShift, 25), 18, cloudPaint);
    canvas.drawCircle(Offset(size.width * 0.38 - cloudShift, 20), 22, cloudPaint);
    canvas.drawCircle(Offset(size.width * 0.45 - cloudShift, 26), 16, cloudPaint);

    canvas.drawCircle(Offset(size.width * 1.1 - cloudShift, 35), 20, cloudPaint);
    canvas.drawCircle(Offset(size.width * 1.18 - cloudShift, 30), 24, cloudPaint);

    // Render Green Obstacle Pipes with 3D Bevel Caps
    final pipeShift = (progress * size.width * 1.8) % size.width;

    void drawPipe(double startX, double gapY, double gapHeight) {
      final x = startX - pipeShift;
      if (x < -60 || x > size.width + 60) return;

      const pipeWidth = 42.0;
      const capHeight = 16.0;
      const capOverhang = 5.0;

      final pipeGradient = const LinearGradient(
        colors: [
          Color(0xFFE7FF8D),
          Color(0xFF9DE558),
          Color(0xFF74C029),
          Color(0xFF59811A),
        ],
        stops: [0.0, 0.25, 0.70, 1.0],
      ).createShader(Rect.fromLTWH(x, 0, pipeWidth, size.height));

      final pipePaint = Paint()..shader = pipeGradient;
      final borderPaint = Paint()
        ..color = const Color(0xFF1E3A08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      // Top Main Pipe
      final topRect = Rect.fromLTWH(x, 0, pipeWidth, gapY - capHeight);
      canvas.drawRect(topRect, pipePaint);
      canvas.drawRect(topRect, borderPaint);

      // Top Pipe 3D Cap
      final topCapRect = Rect.fromLTWH(
          x - capOverhang, gapY - capHeight, pipeWidth + (capOverhang * 2), capHeight);
      canvas.drawRect(topCapRect, pipePaint);
      canvas.drawRect(topCapRect, borderPaint);

      // Bottom Main Pipe
      final bottomRect = Rect.fromLTWH(x, gapY + gapHeight + capHeight,
          pipeWidth, size.height - (gapY + gapHeight + capHeight));
      canvas.drawRect(bottomRect, pipePaint);
      canvas.drawRect(bottomRect, borderPaint);

      // Bottom Pipe 3D Cap
      final bottomCapRect = Rect.fromLTWH(x - capOverhang, gapY + gapHeight,
          pipeWidth + (capOverhang * 2), capHeight);
      canvas.drawRect(bottomCapRect, pipePaint);
      canvas.drawRect(bottomCapRect, borderPaint);
    }

    drawPipe(size.width * 0.45, size.height * 0.25, 80);
    drawPipe(size.width * 0.95, size.height * 0.38, 80);
    drawPipe(size.width * 1.45, size.height * 0.20, 80);
  }

  @override
  bool shouldRepaint(covariant _FlappyPipesPainter oldDelegate) => true;
}

/// Custom Painter for 16-Bit Crisp Flappy Bird Pixel Character
class _FlappyBirdPixelPainter extends CustomPainter {
  final double progress;
  _FlappyBirdPixelPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final flapAngle = math.sin(progress * math.pi * 7) * 0.22;
    final flapY = math.sin(progress * math.pi * 4) * 6;

    canvas.save();
    canvas.translate(size.width / 2, (size.height / 2) + flapY);
    canvas.rotate(flapAngle);
    canvas.translate(-size.width / 2, -size.height / 2);

    final yellowPaint = Paint()..color = const Color(0xFFFFEB3B);
    final orangePaint = Paint()..color = const Color(0xFFFFC107);
    final redPaint = Paint()..color = const Color(0xFFF44336);
    final whitePaint = Paint()..color = Colors.white;
    final blackPaint = Paint()..color = const Color(0xFF1F1F1F);

    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    // Body Main Yellow Oval
    final bodyR = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.15, size.width * 0.58,
          size.height * 0.62),
      const Radius.circular(16),
    );
    canvas.drawRRect(bodyR, yellowPaint);
    canvas.drawRRect(bodyR, outlinePaint);

    // Belly Orange Accent
    final bellyR = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.22, size.height * 0.45, size.width * 0.42,
          size.height * 0.28),
      const Radius.circular(10),
    );
    canvas.drawRRect(bellyR, orangePaint);

    // Flapping Wing
    final wingPath = Path()
      ..moveTo(size.width * 0.12, size.height * 0.42)
      ..cubicTo(size.width * 0.05, size.height * 0.65, size.width * 0.35,
          size.height * 0.72, size.width * 0.40, size.height * 0.50)
      ..close();
    canvas.drawPath(wingPath, whitePaint);
    canvas.drawPath(wingPath, outlinePaint);

    // Eye White Base & Black Pupil with Glint
    final eyeCenter = Offset(size.width * 0.58, size.height * 0.32);
    canvas.drawCircle(eyeCenter, 8.5, whitePaint);
    canvas.drawCircle(eyeCenter, 8.5, outlinePaint);
    canvas.drawCircle(Offset(size.width * 0.62, size.height * 0.32), 3.5, blackPaint);
    canvas.drawCircle(Offset(size.width * 0.60, size.height * 0.29), 1.2, whitePaint);

    // Big Orange/Red Beak Lips
    final beakR = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.60, size.height * 0.46, size.width * 0.36,
          size.height * 0.24),
      const Radius.circular(8),
    );
    canvas.drawRRect(beakR, redPaint);
    canvas.drawRRect(beakR, outlinePaint);

    // Beak Lip Divider
    canvas.drawLine(Offset(size.width * 0.60, size.height * 0.58),
        Offset(size.width * 0.96, size.height * 0.58), outlinePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FlappyBirdPixelPainter oldDelegate) => true;
}

enum _HeroType {
  sanskritChakra,
  cryptoVault,
  neuralMesh,
  codeTerminal,
  biometricScanner,
  indieHeart,
}

class _OnboardingSlide {
  final _HeroType heroType;
  final String badgeText;
  final String title;
  final String subtitle;
  final String description;
  final List<_SlideFeature> features;
  final Color accentColor;
  final Color secondaryColor;
  final Color cardBorderColor;
  final bool isSpecialOrange;
  final bool isSpecialPurple;

  const _OnboardingSlide({
    required this.heroType,
    required this.badgeText,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.features,
    required this.accentColor,
    required this.secondaryColor,
    required this.cardBorderColor,
    required this.isSpecialOrange,
    required this.isSpecialPurple,
  });
}

class _SlideFeature {
  final String icon;
  final String label;
  final String desc;
  const _SlideFeature(this.icon, this.label, this.desc);
}

class _FAANGSlideCard extends StatelessWidget {
  final _OnboardingSlide slide;
  final bool isActive;
  final AnimationController pulseAnimation;
  final AnimationController scanAnimation;

  const _FAANGSlideCard({
    required this.slide,
    required this.isActive,
    required this.pulseAnimation,
    required this.scanAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 575),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: slide.isSpecialOrange
                ? const Color(0xFFBF360C)
                : (slide.isSpecialPurple
                    ? const Color(0xFF261D38)
                    : const Color(0xFF131822)),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: slide.isSpecialOrange
                  ? const Color(0xFFFFB74D)
                  : (slide.isSpecialPurple
                      ? const Color(0xFFD0BCFF)
                      : slide.accentColor.withValues(alpha: 0.5)),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: slide.accentColor.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
              const BoxShadow(
                color: Colors.black87,
                blurRadius: 28,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Shimmer.fromColors(
                      baseColor: slide.isSpecialOrange
                          ? Colors.white
                          : slide.accentColor,
                      highlightColor: Colors.white,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: slide.accentColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: slide.accentColor.withValues(alpha: 0.5),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            slide.badgeText,
                            style: TextStyle(
                              color: slide.accentColor,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Center(
                  child: _buildFAANGHeroVisual(
                    slide.heroType,
                    slide.accentColor,
                    pulseAnimation,
                    scanAnimation,
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  slide.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    height: 1.18,
                  ),
                )
                    .animate(target: isActive ? 1 : 0)
                    .fade(duration: 300.ms)
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: 4),

                Text(
                  slide.subtitle,
                  style: TextStyle(
                    color: slide.isSpecialOrange
                        ? const Color(0xFFFFECB3)
                        : (slide.isSpecialPurple
                            ? const Color(0xFFE8DEF8)
                            : slide.accentColor),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontStyle: slide.isSpecialOrange
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  slide.description,
                  style: TextStyle(
                    color: slide.isSpecialOrange
                        ? Colors.white.withValues(alpha: 0.95)
                        : Colors.white70,
                    fontSize: 12,
                    height: 1.38,
                  ),
                ),
                const SizedBox(height: 10),

                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 10),

                Column(
                  children: slide.features
                      .map((f) => Padding(
                            padding: const EdgeInsets.only(bottom: 7),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(f.icon,
                                    style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        f.label,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11.5,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        f.desc,
                                        style: TextStyle(
                                          color: slide.isSpecialOrange
                                              ? Colors.white.withValues(alpha: 0.88)
                                              : Colors.white60,
                                          fontSize: 10.8,
                                          height: 1.30,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAANGHeroVisual(
    _HeroType type,
    Color color,
    AnimationController pulse,
    AnimationController scan,
  ) {
    switch (type) {
      case _HeroType.sanskritChakra:
        return AnimatedBuilder(
          animation: pulse,
          builder: (context, child) {
            final angle = pulse.value * 3.14159 * 2;
            return SizedBox(
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: angle,
                    child: Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFFFD54F).withValues(alpha: 0.4),
                            width: 1.5),
                      ),
                      child: Center(
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFFFF8F00).withValues(alpha: 0.6),
                                width: 1.2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF6F00).withValues(alpha: 0.25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF8F00).withValues(alpha: 0.5),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('📜', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                ],
              ),
            );
          },
        );

      case _HeroType.cryptoVault:
        return AnimatedBuilder(
          animation: pulse,
          builder: (context, child) {
            final s = 1.0 + (pulse.value * 0.08);
            return SizedBox(
              height: 64,
              child: Transform.scale(
                scale: s,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.15),
                    border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 16),
                    ],
                  ),
                  child: Center(
                    child: Icon(Icons.lock_rounded, color: color, size: 28),
                  ),
                ),
              ),
            );
          },
        );

      case _HeroType.neuralMesh:
        return AnimatedBuilder(
          animation: pulse,
          builder: (context, child) {
            return SizedBox(
              height: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 68,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.1),
                      border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _nodeBadge('OpenAI', Colors.cyan),
                        const SizedBox(width: 5),
                        _nodeBadge('Gemini', Colors.blue),
                        const SizedBox(width: 5),
                        _nodeBadge('Claude', Colors.amber),
                        const SizedBox(width: 5),
                        _nodeBadge('OpenRouter', Colors.purpleAccent),
                        const SizedBox(width: 5),
                        _nodeBadge('Local', Colors.green),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );

      case _HeroType.codeTerminal:
        return Container(
          width: double.infinity,
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  _dot(Colors.red),
                  const SizedBox(width: 4),
                  _dot(Colors.yellow),
                  const SizedBox(width: 4),
                  _dot(Colors.green),
                  const SizedBox(width: 6),
                  Text('pariyojana-engine ~ bash',
                      style: TextStyle(fontSize: 9.5, color: color)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('\$ git fetch --tree --files --pat=enc',
                      style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'monospace',
                          color: color.withValues(alpha: 0.9))),
                  const SizedBox(width: 3),
                  Shimmer.fromColors(
                    baseColor: color,
                    highlightColor: Colors.white,
                    child: Container(width: 6, height: 12, color: color),
                  ),
                ],
              ),
            ],
          ),
        );

      case _HeroType.biometricScanner:
        return AnimatedBuilder(
          animation: scan,
          builder: (context, child) {
            final scanY = (scan.value * 44) - 22;
            return SizedBox(
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.fingerprint_rounded,
                        size: 32,
                        color: Color(0xFFFFD700),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, scanY),
                    child: Container(
                      width: 44,
                      height: 2,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.9),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );

      case _HeroType.indieHeart:
        return AnimatedBuilder(
          animation: pulse,
          builder: (context, child) {
            final s = 1.0 + (pulse.value * 0.10);
            return SizedBox(
              height: 54,
              child: Transform.scale(
                scale: s,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD0BCFF).withValues(alpha: 0.2),
                    border: Border.all(
                        color: const Color(0xFFD0BCFF).withValues(alpha: 0.6),
                        width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD0BCFF).withValues(alpha: 0.4),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('❤️', style: TextStyle(fontSize: 26)),
                  ),
                ),
              ),
            );
          },
        );
    }
  }

  Widget _nodeBadge(String text, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: c),
      ),
    );
  }

  Widget _dot(Color c) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );
  }
}
