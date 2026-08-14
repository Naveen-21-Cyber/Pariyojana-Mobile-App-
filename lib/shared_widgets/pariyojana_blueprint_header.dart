import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// PARIYOJANA BLUEPRINT BRAND HEADER — Animated Motion Implementation
///
/// Features:
/// - Clear, bold, crisp "PARIYOJANA OS" blueprint typography
/// - Floating & gliding vector animation (smooth sine float + scanning line)
/// - Blueprint corner handles & interactive cursor badge
/// ─────────────────────────────────────────────────────────────────────────────
class PariyojanaBlueprintHeader extends StatefulWidget {
  final double height;
  final String authorTag;

  const PariyojanaBlueprintHeader({
    super.key,
    this.height = 140,
    this.authorTag = 'PARIYOJANA OS',
  });

  @override
  State<PariyojanaBlueprintHeader> createState() => _PariyojanaBlueprintHeaderState();
}

class _PariyojanaBlueprintHeaderState extends State<PariyojanaBlueprintHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
    final bgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF);

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final floatOffset = math.sin(_animController.value * math.pi * 2) * 5.0;
        final scanProgress = _animController.value;

        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: Container(
            height: widget.height,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryColor.withValues(alpha: 0.4), width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.12),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CustomPaint(
              painter: _BlueprintPainter(
                color: primaryColor,
                scanProgress: scanProgress,
                authorTag: widget.authorTag,
                isDark: isDark,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BlueprintPainter extends CustomPainter {
  final Color color;
  final double scanProgress;
  final String authorTag;
  final bool isDark;

  _BlueprintPainter({
    required this.color,
    required this.scanProgress,
    required this.authorTag,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Grid background lines
    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..strokeWidth = 1.0;

    for (double x = 0; x < w; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y < h; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // 2. Outer Blueprint Box
    final boxPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final boxRect = Rect.fromLTWH(12, 10, w - 24, h - 20);
    canvas.drawRect(boxRect, boxPaint);

    // 3. Corner Handles
    final handlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    const handleSize = 6.0;

    final corners = [
      const Offset(12, 10),
      Offset(w - 12, 10),
      Offset(12, h - 10),
      Offset(w - 12, h - 10),
    ];

    for (final c in corners) {
      canvas.drawRect(
        Rect.fromCenter(center: c, width: handleSize, height: handleSize),
        Paint()..color = Colors.white,
      );
      canvas.drawRect(
        Rect.fromCenter(center: c, width: handleSize, height: handleSize),
        handlePaint..style = PaintingStyle.stroke..strokeWidth = 1.5,
      );
    }

    // 4. Blueprint Scanning Beam
    final scanX = 12 + (w - 24) * scanProgress;
    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withValues(alpha: 0.0), color.withValues(alpha: 0.35), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(scanX - 15, 10, 30, h - 20));

    canvas.drawRect(Rect.fromLTWH(scanX - 15, 10, 30, h - 20), scanPaint);

    // 5. PARIYOJANA Blueprint Title Text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'PARIYOJANA',
        style: TextStyle(
          fontFamily: GoogleFonts.syne().fontFamily,
          fontSize: (h * 0.32).clamp(24.0, 38.0),
          fontWeight: FontWeight.w900,
          letterSpacing: 6.0,
          color: isDark ? Colors.white : color,
          shadows: [
            Shadow(color: color.withValues(alpha: 0.5), blurRadius: 12),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset((w - textPainter.width) / 2, (h - textPainter.height) / 2 - 4),
    );

    // 6. Interactive Cursor Badge
    final cursorX = 12 + (w - 120) * scanProgress;
    final cursorY = h - 24;

    final cursorPath = Path()
      ..moveTo(cursorX, cursorY)
      ..lineTo(cursorX - 5, cursorY - 14)
      ..lineTo(cursorX + 12, cursorY - 8)
      ..close();

    canvas.drawPath(cursorPath, Paint()..color = color);

    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cursorX + 8, cursorY - 16, 96, 20),
      const Radius.circular(6),
    );

    canvas.drawRRect(badgeRect, Paint()..color = color);

    final badgeText = TextPainter(
      text: TextSpan(
        text: authorTag,
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.8,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    badgeText.paint(canvas, Offset(cursorX + 14, cursorY - 13));
  }

  @override
  bool shouldRepaint(covariant _BlueprintPainter oldDelegate) =>
      oldDelegate.scanProgress != scanProgress || oldDelegate.isDark != isDark;
}
