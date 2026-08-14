import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// SPARKLE GENERATE BUTTON — Vivid Purple Glow & Active Sparkle Implementation
///
/// Features:
/// - Signature #683FEA -> #A47CF3 vibrant purple gradient
/// - Electric #9917FF neon glow shadow
/// - Continuously animated rotating & twinkling sparkle SVG icon
/// - Touch & click ripple feedback with active scale animation
/// ─────────────────────────────────────────────────────────────────────────────
class SparkleGenerateButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double width;
  final double height;
  final IconData? customIcon;

  const SparkleGenerateButton({
    super.key,
    this.label = 'Generate',
    this.onPressed,
    this.isLoading = false,
    this.width = 230,
    this.height = 54,
    this.customIcon,
  });

  @override
  State<SparkleGenerateButton> createState() => _SparkleGenerateButtonState();
}

class _SparkleGenerateButtonState extends State<SparkleGenerateButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late final AnimationController _sparkleAnim;

  static const String _sparkleSvg = '''
<svg height="24" width="24" fill="#FFFFFF" viewBox="0 0 24 24">
  <path d="M10,21.236,6.755,14.745.264,11.5,6.755,8.255,10,1.764l3.245,6.491L19.736,11.5l-6.491,3.245ZM18,21l1.5,3L21,21l3-1.5L21,18l-1.5-3L18,18l-3,1.5ZM19.333,4.667,20.5,7l1.167-2.333L24,3.5,21.667,2.333,20.5,0,19.333,2.333,17,3.5Z"/>
</svg>
''';

  @override
  void initState() {
    super.initState();
    _sparkleAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _sparkleAnim.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) setState(() => _isPressed = false);
      });
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _isPressed = false) : null,
        onTap: _handleTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : (_isHovered ? 1.03 : 1.0),
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color(0xFF683FEA),
                  Color(0xFFA47CF3),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9917FF).withValues(alpha: _isPressed ? 0.9 : 0.7),
                  blurRadius: _isPressed ? 30 : 20,
                  spreadRadius: _isPressed ? 4 : 2,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.4),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Continuously Animated Sparkle Icon (Rotation + Pulse Twinkle)
                        AnimatedBuilder(
                          animation: _sparkleAnim,
                          builder: (context, child) {
                            final rotation = _sparkleAnim.value * math.pi * 2;
                            final pulseScale = 1.0 + (math.sin(_sparkleAnim.value * math.pi * 2) * 0.2);

                            return Transform.rotate(
                              angle: rotation,
                              child: Transform.scale(
                                scale: pulseScale * 1.15,
                                child: widget.customIcon != null
                                    ? Icon(
                                        widget.customIcon,
                                        size: 22,
                                        color: Colors.white,
                                      )
                                    : SvgPicture.string(
                                        _sparkleSvg,
                                        width: 22,
                                        height: 22,
                                        colorFilter: const ColorFilter.mode(
                                          Colors.white,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.label,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Color(0x66000000), blurRadius: 4, offset: Offset(0, 1)),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
