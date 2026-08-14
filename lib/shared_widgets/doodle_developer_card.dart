import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// DOODLE PAPER SKETCH DEVELOPER CARD — 1:1 CSS Spec Implementation
///
/// Features:
/// - Hand-drawn paper notebook background with horizontal lines
/// - Washi paper tape corner at top with flutter animation
/// - Doodle decorations: Yellow Star, Mint Sparkle, Rotating Swirl
/// - Bouncing & Blinking animated avatar face with spiky hair
/// - Sketchy typography with mint role badge
/// - Skewed circle social buttons (Portfolio, GitHub, LinkedIn)
/// ─────────────────────────────────────────────────────────────────────────────
class DoodleDeveloperCard extends StatefulWidget {
  final String name;
  final String role;
  final String? websiteUrl;
  final String? githubUrl;
  final String? linkedinUrl;

  const DoodleDeveloperCard({
    super.key,
    this.name = 'Naveen Telasang',
    this.role = 'Solo Dev • Systems Architect & Security',
    this.websiteUrl = 'https://naveencyber.gt.tc/?i=1',
    this.githubUrl = 'https://github.com/Naveen-21-Cyber',
    this.linkedinUrl = 'https://cyberbuddy.gt.tc/?i=1',
  });

  @override
  State<DoodleDeveloperCard> createState() => _DoodleDeveloperCardState();
}

class _DoodleDeveloperCardState extends State<DoodleDeveloperCard>
    with TickerProviderStateMixin {
  bool _isHovered = false;

  // Animation Controllers
  late final AnimationController _floatController;
  late final AnimationController _tapeController;
  late final AnimationController _sparkleController;
  late final AnimationController _swirlController;
  late final AnimationController _blinkController;

  static const Color _bgColor = Color(0xFFFDFBF7);
  static const Color _inkColor = Color(0xFF2C2C2C);
  static const Color _tapeColor = Color(0xD9FFDDA1);
  static const Color _accentCoral = Color(0xFFFF8BA7);
  static const Color _accentMint = Color(0xFFC6E377);
  static const Color _accentLavender = Color(0xFFC0BBFE);

  static const String _starSvg = '''
<svg viewBox="0 0 24 24">
  <path fill="#FFDF6C" stroke="#2C2C2C" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" d="M12 2L15 9L22 10L17 15L18.5 22L12 18.5L5.5 22L7 15L2 10L9 9L12 2Z"/>
</svg>
''';

  static const String _sparkleSvg = '''
<svg viewBox="0 0 24 24">
  <path fill="#C6E377" stroke="#2C2C2C" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" d="M12 0C12 6.6 17.4 12 24 12C17.4 12 12 17.4 12 24C12 17.4 6.6 12 0 12C6.6 12 12 6.6 12 0Z"/>
</svg>
''';

  static const String _swirlSvg = '''
<svg viewBox="0 0 100 100">
  <path fill="none" stroke="#C0BBFE" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" d="M50 10C27.9 10 10 27.9 10 50C10 72.1 27.9 90 50 90C72.1 90 90 72.1 90 50C90 32.3 75.7 18 58 18C44.3 18 33 29.3 33 43C33 53.5 41.5 62 52 62C59.7 62 66 55.7 66 48"/>
</svg>
''';

  static const String _githubSvg = '''
<svg viewBox="0 0 24 24" fill="#2C2C2C">
  <path d="M12 0C5.37 0 0 5.37 0 12C0 17.31 3.435 21.8 8.205 23.385C8.805 23.495 9 23.125 9 22.81C9 22.535 8.99 21.67 8.985 20.655C5.645 21.38 4.94 19.045 4.94 19.045C4.395 17.655 3.61 17.285 3.61 17.285C2.525 16.545 3.69 16.56 3.69 16.56C4.89 16.645 5.525 17.795 5.525 17.795C6.595 19.63 8.33 19.1 9.015 18.79C9.12 18.01 9.435 17.48 9.785 17.18C7.12 16.88 4.325 15.85 4.325 11.235C4.325 9.92 4.795 8.845 5.56 7.99C5.435 7.685 5.025 6.465 5.675 4.825C5.675 4.825 6.685 4.5 8.985 6.06C9.945 5.795 10.975 5.665 12 5.66C13.025 5.665 14.055 5.795 15.015 6.06C17.315 4.5 18.325 4.825 18.325 4.825C18.975 6.465 18.565 7.685 18.445 7.99C19.21 8.845 19.675 9.92 19.675 11.235C19.675 15.865 16.875 16.875 14.205 17.17C14.635 17.54 15.02 18.265 15.02 19.385C15.02 20.99 15.005 22.28 15.005 22.81C15.005 23.13 15.2 23.51 15.815 23.385C20.57 21.795 24 17.305 24 12C24 5.37 18.63 0 12 0Z"/>
</svg>
''';

  static const String _websiteSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="#2C2C2C" stroke-width="2">
  <circle cx="12" cy="12" r="10"></circle>
  <line x1="2" y1="12" x2="22" y2="12"></line>
  <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"></path>
</svg>
''';

  static const String _linkedinSvg = '''
<svg viewBox="0 0 24 24" fill="#2C2C2C">
  <path d="M20.447 20.452H16.92V14.88C16.92 13.55 16.896 11.84 15.074 11.84C13.228 11.84 12.945 13.28 12.945 14.786V20.452H9.423V9H12.8V10.561H12.848C13.318 9.673 14.464 8.742 16.143 8.742C19.667 8.742 20.447 11.062 20.447 14.032V20.452ZM5.337 7.433C4.204 7.433 3.285 6.516 3.285 5.385C3.285 4.254 4.204 3.336 5.337 3.336C6.467 3.336 7.387 4.254 7.387 5.385C7.387 6.516 6.467 7.433 5.337 7.433ZM7.1 20.452H3.571V9H7.1V20.452Z"/>
</svg>
''';

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _tapeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _swirlController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _tapeController.dispose();
    _sparkleController.dispose();
    _swirlController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  Future<void> _launch(String? url) async {
    if (url != null && url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => setState(() => _isHovered = !_isHovered),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _floatController,
            _tapeController,
            _sparkleController,
            _swirlController,
            _blinkController,
          ]),
          builder: (context, child) {
            final floatY = math.sin(_floatController.value * math.pi * 2) * 6.0;
            final tapeAngle = -0.07 + (math.sin(_tapeController.value * math.pi * 2) * 0.03);
            final sparkleScale = 0.85 + (_sparkleController.value * 0.25);
            final swirlAngle = _swirlController.value * math.pi * 2;

            // Blink state
            final blinkVal = _blinkController.value;
            final isBlinking = blinkVal > 0.48 && blinkVal < 0.52;

            return Transform.translate(
              offset: Offset(0, _isHovered ? -12.0 : floatY),
              child: Transform.rotate(
                angle: _isHovered ? 0.017 : 0.0,
                child: SizedBox(
                  width: 270,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      // Paper Notebook Container Card
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 38, 20, 24),
                        decoration: BoxDecoration(
                          color: _bgColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _inkColor, width: 3.5),
                          boxShadow: [
                            BoxShadow(
                              color: _inkColor,
                              offset: _isHovered ? const Offset(10, 12) : const Offset(7, 7),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          foregroundPainter: _PaperLinesPainter(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Avatar / Photo with Bounce & Blink
                              Transform.translate(
                                offset: Offset(0, math.sin(_floatController.value * math.pi * 2) * 2.5),
                                child: Container(
                                  width: 95,
                                  height: 95,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFDEB3),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: _inkColor, width: 3),
                                    boxShadow: const [
                                      BoxShadow(color: _accentCoral, offset: Offset(4, 4), blurRadius: 0),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Spiky Hair Base
                                      Positioned(
                                        top: 6,
                                        child: Container(
                                          width: 70,
                                          height: 38,
                                          decoration: const BoxDecoration(
                                            color: _accentLavender,
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                                          ),
                                        ),
                                      ),

                                      // Eyes & Blush
                                      Positioned(
                                        top: 44,
                                        child: Row(
                                          children: [
                                            // Left eye + blush
                                            Column(
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: isBlinking ? 1.5 : 8,
                                                  decoration: const BoxDecoration(
                                                    color: _inkColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Container(
                                                  width: 9,
                                                  height: 4,
                                                  decoration: BoxDecoration(
                                                    color: _accentCoral.withValues(alpha: 0.8),
                                                    borderRadius: BorderRadius.circular(2),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 24),
                                            // Right eye + blush
                                            Column(
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: isBlinking ? 1.5 : 8,
                                                  decoration: const BoxDecoration(
                                                    color: _inkColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Container(
                                                  width: 9,
                                                  height: 4,
                                                  decoration: BoxDecoration(
                                                    color: _accentCoral.withValues(alpha: 0.8),
                                                    borderRadius: BorderRadius.circular(2),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Smiling Mouth
                                      Positioned(
                                        top: 56,
                                        child: CustomPaint(
                                          size: const Size(20, 10),
                                          painter: _SmilePainter(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Name & Title
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  widget.name,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                    color: _inkColor,
                                    shadows: [
                                      Shadow(color: _accentLavender, offset: Offset(1.5, 1.5)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Role Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _accentMint,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: _inkColor, width: 2),
                                  boxShadow: const [
                                    BoxShadow(color: _inkColor, offset: Offset(2, 2), blurRadius: 0),
                                  ],
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    widget.role.toUpperCase(),
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                      color: _inkColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Social Buttons Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _DoodleSocialBtn(
                                    svg: _websiteSvg,
                                    hoverColor: _accentLavender,
                                    onTap: () => _launch(widget.websiteUrl),
                                  ),
                                  const SizedBox(width: 14),
                                  _DoodleSocialBtn(
                                    svg: _githubSvg,
                                    hoverColor: _accentCoral,
                                    onTap: () => _launch(widget.githubUrl),
                                  ),
                                  const SizedBox(width: 14),
                                  _DoodleSocialBtn(
                                    svg: _linkedinSvg,
                                    hoverColor: _accentMint,
                                    onTap: () => _launch(widget.linkedinUrl),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Top Washi Paper Tape Corner
                      Positioned(
                        top: -12,
                        child: Transform.rotate(
                          angle: tapeAngle,
                          child: Container(
                            width: 80,
                            height: 22,
                            decoration: BoxDecoration(
                              color: _tapeColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.black.withValues(alpha: 0.15)),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, offset: Offset(1, 2), blurRadius: 3),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Yellow Star Doodle (Top Right)
                      Positioned(
                        top: 22,
                        right: 18,
                        child: Transform.scale(
                          scale: sparkleScale,
                          child: SvgPicture.string(_starSvg, width: 26, height: 26),
                        ),
                      ),

                      // Mint Sparkle Doodle (Top Left)
                      Positioned(
                        top: 60,
                        left: 18,
                        child: Transform.scale(
                          scale: sparkleScale,
                          child: SvgPicture.string(_sparkleSvg, width: 22, height: 22),
                        ),
                      ),

                      // Lavender Swirl Doodle (Bottom Right)
                      Positioned(
                        bottom: 22,
                        right: 14,
                        child: Transform.rotate(
                          angle: swirlAngle,
                          child: SvgPicture.string(_swirlSvg, width: 38, height: 38),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DoodleSocialBtn extends StatefulWidget {
  final String svg;
  final Color hoverColor;
  final VoidCallback onTap;

  const _DoodleSocialBtn({
    required this.svg,
    required this.hoverColor,
    required this.onTap,
  });

  @override
  State<_DoodleSocialBtn> createState() => _DoodleSocialBtnState();
}

class _DoodleSocialBtnState extends State<_DoodleSocialBtn> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 180),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _isHovered ? widget.hoverColor : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2C2C2C), width: 2.2),
              boxShadow: const [
                BoxShadow(color: Color(0xFF2C2C2C), offset: Offset(3, 3), blurRadius: 0),
              ],
            ),
            child: Center(
              child: SvgPicture.string(
                widget.svg,
                width: 20,
                height: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaperLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE6E0D4).withValues(alpha: 0.5)
      ..strokeWidth = 1.0;
    for (double y = 20; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldPainter) => false;
}

class _SmilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2C2C2C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(size.width / 2, size.height * 1.5, size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldPainter) => false;
}
