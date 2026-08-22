import 'dart:math' as math;
import 'package:flutter/material.dart';

class ParticleExplosion {
  static void show(BuildContext context, Offset position, {Color color = const Color(0xFFFFB4A2)}) {
    final overlayState = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _ExplosionWidget(
        position: position,
        color: color,
        onComplete: () {
          entry.remove();
        },
      ),
    );

    overlayState.insert(entry);
  }
}

class _ExplosionWidget extends StatefulWidget {
  final Offset position;
  final Color color;
  final VoidCallback onComplete;

  const _ExplosionWidget({
    required this.position,
    required this.color,
    required this.onComplete,
  });

  @override
  State<_ExplosionWidget> createState() => _ExplosionWidgetState();
}

class _ExplosionWidgetState extends State<_ExplosionWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ParticleData> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Initialize 24 radiating particles
    final random = math.Random.secure();
    for (int i = 0; i < 24; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final speed = 3.0 + random.nextDouble() * 5.0;
      _particles.add(_ParticleData(
        velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
        size: 3.0 + random.nextDouble() * 5.0,
      ));
    }

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ExplosionPainter(
                  origin: widget.position,
                  particles: _particles,
                  progress: _controller.value,
                  color: widget.color,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ParticleData {
  final Offset velocity;
  final double size;

  _ParticleData({
    required this.velocity,
    required this.size,
  });
}

class _ExplosionPainter extends CustomPainter {
  final Offset origin;
  final List<_ParticleData> particles;
  final double progress;
  final Color color;

  _ExplosionPainter({
    required this.origin,
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    for (var p in particles) {
      // Calculate current position with gravity pulling down slightly
      final x = origin.dx + p.velocity.dx * progress * 20;
      final y = origin.dy + p.velocity.dy * progress * 20 + (progress * progress * 60); // gravity pull

      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      paint.color = color.withValues(alpha: opacity);

      canvas.drawCircle(Offset(x, y), p.size * (1.0 - progress * 0.4), paint);
      
      // Draw secondary white spark highlight
      paint.color = Colors.white.withValues(alpha: opacity * 0.7);
      canvas.drawCircle(Offset(x - 1, y - 1), p.size * 0.4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
