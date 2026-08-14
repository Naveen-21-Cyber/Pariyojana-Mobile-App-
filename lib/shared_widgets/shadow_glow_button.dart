import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// CYBERPUNK SHADOW GLOW BUTTON — 1:1 CSS Spec Implementation
///
/// CSS Spec:
/// - Background: rgb(0, 140, 255)
/// - Font: 17px, font-weight 700, letter-spacing 4px, uppercase, color #FFFFFF
/// - Border Radius: 7px
/// - Padding: 10px 20px
/// - Default Shadow: 0 0 25px rgb(0, 140, 255)
/// - Hover / Tap Active: Intense multi-layered neon blue glow (blur 5px, 25px, 50px, 100px)
/// ─────────────────────────────────────────────────────────────────────────────
class ShadowGlowButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry? padding;

  const ShadowGlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.padding,
  });

  @override
  State<ShadowGlowButton> createState() => _ShadowGlowButtonState();
}

class _ShadowGlowButtonState extends State<ShadowGlowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const electricBlue = Color(0xFF008CFF);

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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            color: electricBlue,
            borderRadius: BorderRadius.circular(7),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: electricBlue.withValues(alpha: 0.9),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: electricBlue.withValues(alpha: 0.8),
                      blurRadius: 25,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: electricBlue.withValues(alpha: 0.6),
                      blurRadius: 50,
                      spreadRadius: 4,
                    ),
                    BoxShadow(
                      color: electricBlue.withValues(alpha: 0.4),
                      blurRadius: 100,
                      spreadRadius: 8,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: electricBlue.withValues(alpha: 0.65),
                      blurRadius: 25,
                      spreadRadius: 2,
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: 18),
                const SizedBox(width: 10),
              ],
              Text(
                widget.label.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3.5,
                  fontFamily: GoogleFonts.outfit().fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
