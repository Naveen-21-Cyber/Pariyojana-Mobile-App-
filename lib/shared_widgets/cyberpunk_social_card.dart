import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// CYBERPUNK 3D SOCIAL CARD — 1:1 CSS Spec Implementation
///
/// Features:
/// - Octagonal clipped main container with red neon gradient & glow
/// - Top triangle notch & left/right door flaps
/// - Hover/Tap fold-out animation: doors open, top lifts, title reveals
/// - 2 Action buttons for GitHub & Pariyojana Website
/// ─────────────────────────────────────────────────────────────────────────────
class CyberpunkSocialCard extends StatefulWidget {
  final String title;
  final String? githubUrl;
  final String? websiteUrl;
  final VoidCallback? onGithubTap;
  final VoidCallback? onWebsiteTap;

  const CyberpunkSocialCard({
    super.key,
    this.title = 'PARIYOJANA',
    this.githubUrl = 'https://github.com',
    this.websiteUrl = 'https://pariyojana.gt.tc',
    this.onGithubTap,
    this.onWebsiteTap,
  });

  @override
  State<CyberpunkSocialCard> createState() => _CyberpunkSocialCardState();
}

class _CyberpunkSocialCardState extends State<CyberpunkSocialCard> {
  bool _isHovered = false;

  static const String _githubSvg = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="red" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M15 22v-4a4.8 4.8 0 0 0-1-3.5c3 0 6-2 6-5.5.08-1.25-.27-2.48-1-3.5.28-1.15.28-2.35 0-3.5 0 0-1 0-3 1.5-2.64-.5-5.36-.5-8 0C6 2 5 2 5 2c-.3 1.15-.3 2.35 0 3.5A5.403 5.403 0 0 0 4 9c0 3.5 3 5.5 6 5.5-.39.49-.68 1.05-.85 1.65-.17.6-.22 1.23-.15 1.85v4"></path>
  <path d="M9 18c-4.51 2-5-2-7-2"></path>
</svg>
''';

  static const String _websiteSvg = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="red" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="12" cy="12" r="10"></circle>
  <line x1="2" y1="12" x2="22" y2="12"></line>
  <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"></path>
</svg>
''';

  Future<void> _launch(String? url, VoidCallback? customCallback) async {
    if (customCallback != null) {
      customCallback();
      return;
    }
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
        child: SizedBox(
          width: 230,
          height: 300,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Red neon glow shadow underlay
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.fastOutSlowIn,
                width: 230 * 0.8,
                height: 300 * 0.8,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: _isHovered ? 0.9 : 0.6),
                      blurRadius: _isHovered ? 60 : 35,
                      spreadRadius: _isHovered ? 8 : 2,
                    ),
                  ],
                ),
              ),

              // Main polygon container
              AnimatedScale(
                scale: _isHovered ? 1.06 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: ClipPath(
                  clipper: _OctagonClipper(),
                  child: Container(
                    width: 230,
                    height: 300,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Color(0xFF3E0000),
                          Color(0xFFFF0000),
                          Color(0xFF3E0000),
                        ],
                        stops: [0.0, 0.6, 1.0],
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Top Black Triangle Flap
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.fastOutSlowIn,
                          top: _isHovered ? -55 : 0,
                          left: 0,
                          right: 0,
                          child: CustomPaint(
                            size: const Size(230, 115),
                            painter: _TopTrianglePainter(),
                          ),
                        ),

                        // Left Black Door Flap
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.fastOutSlowIn,
                          top: 0,
                          bottom: 0,
                          left: _isHovered ? -65 : 0,
                          width: 115,
                          child: Container(color: Colors.black),
                        ),

                        // Right Black Door Flap
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.fastOutSlowIn,
                          top: 0,
                          bottom: 0,
                          right: _isHovered ? -65 : 0,
                          width: 115,
                          child: Container(color: Colors.black),
                        ),

                        // Center Title
                        Positioned(
                          top: 95,
                          left: 0,
                          right: 0,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 250),
                            opacity: _isHovered ? 1.0 : 0.0,
                            child: Column(
                              children: [
                                Text(
                                  widget.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.0,
                                    color: Colors.white,
                                    shadows: [Shadow(color: Colors.red, blurRadius: 12)],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'COMMAND CENTER',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Bottom 2 Action Buttons (GitHub & Pariyojana Web)
                        Positioned(
                          bottom: 24,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _CyberButton(
                                svg: _githubSvg,
                                label: 'GitHub',
                                onTap: () => _launch(widget.githubUrl, widget.onGithubTap),
                              ),
                              const SizedBox(width: 12),
                              _CyberButton(
                                svg: _websiteSvg,
                                label: 'Website',
                                onTap: () => _launch(widget.websiteUrl, widget.onWebsiteTap),
                              ),
                            ],
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
      ),
    );
  }
}

class _CyberButton extends StatefulWidget {
  final String svg;
  final String label;
  final VoidCallback onTap;

  const _CyberButton({
    required this.svg,
    required this.label,
    required this.onTap,
  });

  @override
  State<_CyberButton> createState() => _CyberButtonState();
}

class _CyberButtonState extends State<_CyberButton> {
  bool _btnHover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _btnHover = true),
      onExit: (_) => setState(() => _btnHover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _btnHover ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.8), width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.string(
                  widget.svg,
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OctagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, 40)
      ..lineTo(w, h - 40)
      ..lineTo(w - 40, h)
      ..lineTo(40, h)
      ..lineTo(0, h - 40)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _TopTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldPainter) => false;
}
