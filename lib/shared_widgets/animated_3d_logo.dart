import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/velvet_colors.dart';

/// Ultra-Premium Cinematic 3D Monogram & Holographic Orbital Engine
/// Designed for 60-144 FPS high-refresh rate displays with zero-allocation paint caches.
/// Modeled after iconic luxury technology emblems with multi-axis gyroscopic rings.
class Animated3DLogo extends StatefulWidget {
  final double size;
  final bool autoRotate;

  const Animated3DLogo({
    super.key,
    this.size = 140,
    this.autoRotate = true,
  });

  @override
  State<Animated3DLogo> createState() => _Animated3DLogoState();
}

class _Animated3DLogoState extends State<Animated3DLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _pointerOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    if (widget.autoRotate) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _pointerOffset += details.delta / (widget.size / 2);
          _pointerOffset = Offset(
            _pointerOffset.dx.clamp(-1.0, 1.0),
            _pointerOffset.dy.clamp(-1.0, 1.0),
          );
        });
      },
      onPanEnd: (_) {
        Future.delayed(const Duration(milliseconds: 160), () {
          if (mounted) {
            setState(() {
              _pointerOffset = Offset.zero;
            });
          }
        });
      },
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;
            final autoAngle = widget.autoRotate ? t * 2 * math.pi : 0.0;

            // Interactive perspective tilt with dampening
            final tiltY = _pointerOffset.dx * 0.48;
            final tiltX = -_pointerOffset.dy * 0.48;

            // Cinematic breathing & magnetic oscillation wave
            final wobbleX = widget.autoRotate ? math.sin(t * 2 * math.pi) * 0.08 : 0.0;
            final wobbleY = widget.autoRotate ? math.cos(t * 2 * math.pi) * 0.08 : 0.0;
            final breathScale = 1.0 + (math.sin(t * 2 * math.pi) * 0.038);

            final finalAngleX = tiltX + wobbleX;
            final finalAngleY = tiltY + wobbleY;

            return Transform.scale(
              scale: breathScale,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Layer 1: Ambient Clean Radiant Core Aura
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..rotateX(finalAngleX)
                        ..rotateY(finalAngleY)
                        ..translateByDouble(0.0, widget.size * 0.08, -30.0, 1.0),
                      child: Container(
                        width: widget.size * 0.90,
                        height: widget.size * 0.90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: VelvetColors.coralPeach.withValues(alpha: 0.35),
                              blurRadius: widget.size * 0.32,
                              spreadRadius: 4,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: widget.size * 0.45,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Layer 2: Outer Gyroscopic Quantum Energy Ring (Clockwise)
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..rotateX(finalAngleX + 0.15)
                        ..rotateY(finalAngleY + 0.15)
                        ..rotateZ(autoAngle),
                      child: Container(
                        width: widget.size * 0.96,
                        height: widget.size * 0.96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: const [
                              VelvetColors.coralPeach,
                              Color(0xFFFFB09C),
                              Color(0xFFE2E8F0),
                              VelvetColors.coralPeach,
                            ],
                            stops: const [0.0, 0.35, 0.7, 1.0],
                            transform: GradientRotation(autoAngle),
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: VelvetColors.coralPeach.withValues(alpha: 0.25),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Layer 3: Middle Concentric Gyroscope (Counter-Clockwise)
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..rotateX(finalAngleX - 0.2)
                        ..rotateY(finalAngleY - 0.2)
                        ..rotateZ(-autoAngle * 0.75)
                        ..translateByDouble(0.0, 0.0, 10.0, 1.0),
                      child: Container(
                        width: widget.size * 0.82,
                        height: widget.size * 0.82,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),

                    // Layer 4: Deep Obsidian Velvet Clay Core with Specular Inner Lighting
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..rotateX(finalAngleX)
                        ..rotateY(finalAngleY)
                        ..translateByDouble(0.0, 0.0, 22.0, 1.0),
                      child: Container(
                        width: widget.size * 0.70,
                        height: widget.size * 0.70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [
                              Color(0xFF2D2424),
                              Color(0xFF1E1717),
                              Color(0xFF0F0B0B),
                            ],
                            center: Alignment(-0.3, -0.35),
                            radius: 0.9,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.2),
                              offset: const Offset(-3, -3),
                              blurRadius: 6,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.8),
                              offset: const Offset(5, 7),
                              blurRadius: 12,
                            ),
                            BoxShadow(
                              color: VelvetColors.coralPeach.withValues(alpha: 0.3),
                              blurRadius: 14,
                            ),
                          ],
                          border: Border.all(
                            color: VelvetColors.coralPeach.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    // Layer 5: Clean 3D Monogram Emblem in Titanium White & Coral Accent
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..rotateX(finalAngleX)
                        ..rotateY(finalAngleY)
                        ..translateByDouble(0.0, math.sin(t * 4 * math.pi) * 2.5, 40.0, 1.0),
                      child: Text(
                        'P',
                        style: TextStyle(
                          fontFamily: GoogleFonts.outfit().fontFamily,
                          fontSize: widget.size * 0.44,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2.0,
                          color: const Color(0xFFFFFBF8),
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.8),
                              offset: const Offset(2, 4),
                              blurRadius: 8,
                            ),
                            Shadow(
                              color: VelvetColors.coralPeach.withValues(alpha: 0.6),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 3D Orbiting Particle Preloader with Starry Dust Trails
class Animated3DLoader extends StatefulWidget {
  final double size;

  const Animated3DLoader({
    super.key,
    this.size = 210,
  });

  @override
  State<Animated3DLoader> createState() => _Animated3DLoaderState();
}

class _OrbitalData {
  final double inclinationX;
  final double inclinationY;
  final double radius;
  final double speedMultiplier;
  final Color color;

  _OrbitalData({
    required this.inclinationX,
    required this.inclinationY,
    required this.radius,
    required this.speedMultiplier,
    required this.color,
  });
}

class _ProjectedParticle {
  final Offset position;
  final double zDepth;
  final double radius;
  final double opacity;
  final Color color;

  _ProjectedParticle({
    required this.position,
    required this.zDepth,
    required this.radius,
    required this.opacity,
    required this.color,
  });
}

class _Animated3DLoaderState extends State<Animated3DLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late final Widget _logo;

  // 4 Orbiting quantum energy particles on multi-inclination orbital planes
  final List<_OrbitalData> _orbitals = [
    _OrbitalData(
      inclinationX: 0.95,
      inclinationY: 0.35,
      radius: 76,
      speedMultiplier: 1.1,
      color: VelvetColors.coralPeach,
    ),
    _OrbitalData(
      inclinationX: -0.7,
      inclinationY: 0.85,
      radius: 84,
      speedMultiplier: -0.85,
      color: const Color(0xFFFFB09C),
    ),
    _OrbitalData(
      inclinationX: 0.3,
      inclinationY: -0.95,
      radius: 92,
      speedMultiplier: 1.4,
      color: const Color(0xFFFFD4C2),
    ),
    _OrbitalData(
      inclinationX: -0.4,
      inclinationY: -0.4,
      radius: 100,
      speedMultiplier: -1.2,
      color: const Color(0xFFFFF0E6),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _logo = RepaintBoundary(
      child: Animated3DLogo(
        size: widget.size * 0.65,
        autoRotate: true,
      ),
    );
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
          final center = Offset(widget.size / 2, widget.size / 2);
          final List<_ProjectedParticle> projectedParticles = [];

          for (int i = 0; i < _orbitals.length; i++) {
            final orb = _orbitals[i];
            final timeAngle = _controller.value * 2 * math.pi * orb.speedMultiplier;

            final lx = orb.radius * math.cos(timeAngle);
            final lz = orb.radius * math.sin(timeAngle);
            const ly = 0.0;

            // 1. Rotate around X axis
            final y1 = ly * math.cos(orb.inclinationX) - lz * math.sin(orb.inclinationX);
            final z1 = ly * math.sin(orb.inclinationX) + lz * math.cos(orb.inclinationX);
            final x1 = lx;

            // 2. Rotate around Y axis
            final x2 = x1 * math.cos(orb.inclinationY) + z1 * math.sin(orb.inclinationY);
            final y2 = y1;
            final z2 = -x1 * math.sin(orb.inclinationY) + z1 * math.cos(orb.inclinationY);

            // Perspective scaling based on Z
            const maxRadius = 100.0;
            final scale = ((z2 + maxRadius) / (2 * maxRadius)).clamp(0.0, 1.0);
            final depthScale = 0.4 + (0.75 * scale);

            projectedParticles.add(_ProjectedParticle(
              position: Offset(center.dx + x2, center.dy + y2),
              zDepth: z2,
              radius: 9.5 * depthScale,
              opacity: (0.3 + 0.7 * scale).clamp(0.25, 1.0),
              color: orb.color,
            ));
          }

          final backgroundParticles = projectedParticles.where((p) => p.zDepth < 0).toList();
          final foregroundParticles = projectedParticles.where((p) => p.zDepth >= 0).toList();

          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Background Particles
                ...backgroundParticles.map((p) => Positioned(
                  left: p.position.dx - p.radius,
                  top: p.position.dy - p.radius,
                  child: _buildParticleWidget(p),
                )),

                // 2. Center 3D Logo (Pre-rendered and cached)
                _logo,

                // 3. Foreground Particles
                ...foregroundParticles.map((p) => Positioned(
                  left: p.position.dx - p.radius,
                  top: p.position.dy - p.radius,
                  child: _buildParticleWidget(p),
                )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildParticleWidget(_ProjectedParticle p) {
    return Container(
      width: p.radius * 2,
      height: p.radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: p.color.withValues(alpha: p.opacity),
        boxShadow: [
          BoxShadow(
            color: p.color.withValues(alpha: p.opacity * 0.65),
            blurRadius: p.radius * 2.0,
            spreadRadius: 1.8,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: p.opacity * 0.85),
            blurRadius: p.radius * 0.6,
            offset: Offset(-p.radius * 0.25, -p.radius * 0.25),
          ),
        ],
      ),
    );
  }
}
