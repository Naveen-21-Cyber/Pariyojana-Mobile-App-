import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// NEON SKEW BUTTON — 1:1 CSS Spec Implementation
///
/// CSS Spec:
/// - Pill container: background #66FF66, border-radius 500px, overflow hidden
/// - Text: 17px, font-weight 700, letter-spacing 0.05rem, color ghostwhite (#F8F8FF)
/// - Skew overlay (::before): background #000000, skewed 30deg
/// - Hover / Tap transition: skew translates out (+100%), text transitions to #000000
/// ─────────────────────────────────────────────────────────────────────────────
class NeonSkewButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry? padding;
  final double fontSize;

  const NeonSkewButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.padding,
    this.fontSize = 17,
  });

  @override
  State<NeonSkewButton> createState() => _NeonSkewButtonState();
}

class _NeonSkewButtonState extends State<NeonSkewButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const neonGreen = Color(0xFF66FF66);
    const ghostWhite = Color(0xFFF8F8FF);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isHovered = true),
        onTapUp: (_) => setState(() => _isHovered = false),
        onTapCancel: () => setState(() => _isHovered = false),
        onTap: () async {
          await HapticFeedback.mediumImpact();
          widget.onPressed();
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(500),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: const Cubic(0.3, 1, 0.8, 1),
            color: neonGreen,
            padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Skewed Black Background Layer (::before pseudo-element)
                Positioned.fill(
                  child: AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 400),
                    curve: const Cubic(0.3, 1, 0.8, 1),
                    alignment: Alignment.centerLeft,
                    widthFactor: _isHovered ? 0.0 : 1.4,
                    child: Transform(
                      transform: Matrix4.skewX(-0.4), // 30-degree skew equivalent
                      alignment: Alignment.center,
                      child: Container(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                // Button Label & Icon Content (span layer)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 400),
                        style: TextStyle(
                          color: _isHovered ? Colors.black : ghostWhite,
                          fontSize: widget.fontSize + 2,
                        ),
                        child: Icon(
                          widget.icon,
                          size: widget.fontSize + 2,
                          color: _isHovered ? Colors.black : ghostWhite,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 400),
                      style: TextStyle(
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: _isHovered ? Colors.black : ghostWhite,
                        fontFamily: GoogleFonts.outfit().fontFamily,
                      ),
                      child: Text(widget.label),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
