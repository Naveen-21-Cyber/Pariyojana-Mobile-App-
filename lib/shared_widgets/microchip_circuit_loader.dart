import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Animated Microchip & Circuit Traces Loader Widget inspired by Uiverse.io
class MicrochipCircuitLoader extends StatefulWidget {
  final double width;
  final double height;
  final String label;

  const MicrochipCircuitLoader({
    super.key,
    this.width = 320,
    this.height = 200,
    this.label = 'Synthesizing Intel...',
  });

  @override
  State<MicrochipCircuitLoader> createState() => _MicrochipCircuitLoaderState();
}

class _MicrochipCircuitLoaderState extends State<MicrochipCircuitLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(color: const Color(0xFF334155), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: CustomPaint(
                  size: Size(widget.width - 24, widget.height - 60),
                  painter: _CircuitPainter(progress: _controller.value),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: GoogleFonts.outfit().fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CircuitPainter extends CustomPainter {
  final double progress;

  _CircuitPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const chipW = 100.0;
    const chipH = 65.0;

    final bgPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw Traces Background & Flowing Signal Pulses
    _drawTrace(canvas, bgPaint, size, [
      const Offset(20, 20), const Offset(70, 20), Offset(70, center.dy - 15), Offset(center.dx - chipW / 2, center.dy - 15)
    ], const Color(0xFFA855F7));

    _drawTrace(canvas, bgPaint, size, [
      Offset(15, center.dy - 10), Offset(50, center.dy - 10), Offset(50, center.dy), Offset(center.dx - chipW / 2, center.dy)
    ], const Color(0xFF38BDF8));

    _drawTrace(canvas, bgPaint, size, [
      Offset(25, size.height - 20), Offset(65, size.height - 20), Offset(65, center.dy + 15), Offset(center.dx - chipW / 2, center.dy + 15)
    ], const Color(0xFFEAB308));

    _drawTrace(canvas, bgPaint, size, [
      Offset(size.width - 20, 25), Offset(size.width - 65, 25), Offset(size.width - 65, center.dy - 15), Offset(center.dx + chipW / 2, center.dy - 15)
    ], const Color(0xFF22C55E));

    _drawTrace(canvas, bgPaint, size, [
      Offset(size.width - 15, center.dy - 10), Offset(size.width - 55, center.dy - 10), Offset(size.width - 55, center.dy), Offset(center.dx + chipW / 2, center.dy)
    ], const Color(0xFFEF4444));

    _drawTrace(canvas, bgPaint, size, [
      Offset(size.width - 25, size.height - 20), Offset(size.width - 70, size.height - 20), Offset(size.width - 70, center.dy + 15), Offset(center.dx + chipW / 2, center.dy + 15)
    ], const Color(0xFFF97316));

    // Draw End Connection Terminals (Nodes)
    final nodePaint = Paint()..color = Colors.black..style = PaintingStyle.fill;
    final nodeBorder = Paint()..color = const Color(0xFF64748B)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    for (final p in [
      const Offset(20, 20), Offset(15, center.dy - 10), Offset(25, size.height - 20),
      Offset(size.width - 20, 25), Offset(size.width - 15, center.dy - 10), Offset(size.width - 25, size.height - 20)
    ]) {
      canvas.drawCircle(p, 4.5, nodePaint);
      canvas.drawCircle(p, 4.5, nodeBorder);
    }

    // Draw Microchip Body
    final chipRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: chipW, height: chipH),
      const Radius.circular(14),
    );

    final chipBodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(chipRect.outerRect);

    final chipBorderPaint = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRRect(chipRect, chipBodyPaint);
    canvas.drawRRect(chipRect, chipBorderPaint);

    // Draw Microchip Pins (Left & Right)
    final pinPaint = Paint()..color = const Color(0xFF94A3B8);
    for (int i = 0; i < 4; i++) {
      final pinY = center.dy - 20 + (i * 13);
      // Left pin
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(center.dx - chipW / 2 - 6, pinY, 6, 7), const Radius.circular(2)),
        pinPaint,
      );
      // Right pin
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(center.dx + chipW / 2, pinY, 6, 7), const Radius.circular(2)),
        pinPaint,
      );
    }

    // Draw "CPU / AI" Text Inside Chip
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'PARIYOJANA',
        style: TextStyle(
          fontFamily: GoogleFonts.outfit().fontFamily,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF94A3B8),
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2));
  }

  void _drawTrace(Canvas canvas, Paint bgPaint, Size size, List<Offset> points, Color glowColor) {
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, bgPaint);

    // Draw animated pulse travelling along path
    final metric = path.computeMetrics().first;
    final totalLen = metric.length;
    const pulseLen = 35.0;
    final currentOffset = (progress * totalLen * 1.5) % (totalLen + pulseLen);

    final startLen = math.max(0.0, currentOffset - pulseLen);

    if (startLen < totalLen) {
      final extracted = metric.extractPath(startLen, math.min(totalLen, currentOffset));
      final pulsePaint = Paint()
        ..color = glowColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3.0);
      canvas.drawPath(extracted, pulsePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CircuitPainter oldDelegate) => oldDelegate.progress != progress;
}
