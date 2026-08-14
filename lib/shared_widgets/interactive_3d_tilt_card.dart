import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vmath;
import 'package:vibration/vibration.dart';
import '../core/theme/velvet_colors.dart';

class Interactive3DTiltCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const Interactive3DTiltCard({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  State<Interactive3DTiltCard> createState() => _Interactive3DTiltCardState();
}

class _Interactive3DTiltCardState extends State<Interactive3DTiltCard> {
  double _rotateX = 0.0;
  double _rotateY = 0.0;
  double _scale = 1.0;
  bool _isHovered = false;

  void _onPointerMove(PointerMoveEvent event, Size size) {
    final dx = (event.localPosition.dx - size.width / 2) / (size.width / 2);
    final dy = (event.localPosition.dy - size.height / 2) / (size.height / 2);

    setState(() {
      _rotateX = -dy * 0.28; // Increased tilt to 0.28 radians for maximum visibility
      _rotateY = dx * 0.28;
      _scale = 0.96;
      _isHovered = true;
    });
  }

  void _onPointerReset() {
    setState(() {
      _rotateX = 0.0;
      _rotateY = 0.0;
      _scale = 1.0;
      _isHovered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return Listener(
          onPointerDown: (e) {
            setState(() {
              _scale = 0.96;
              _isHovered = true;
            });
          },
          onPointerMove: (e) => _onPointerMove(e, size),
          onPointerUp: (_) => _onPointerReset(),
          onPointerCancel: (_) => _onPointerReset(),
          child: GestureDetector(
            onTap: () async {
              try {
                final hasVib = await Vibration.hasVibrator();
                if (hasVib == true) {
                  await Vibration.vibrate(duration: 50, amplitude: 220);
                }
              } catch (_) {}
              widget.onTap?.call();
            },
            child: RepaintBoundary(
              child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOutCubic,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0025) // High perspective 3D depth
                ..rotateX(_rotateX)
                ..rotateY(_rotateY)
                ..scaleByVector3(vmath.Vector3(_scale, _scale, 1.0)),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: VelvetColors.coralPeach.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: Offset(-_rotateY * 30, _rotateX * 30),
                        ),
                        BoxShadow(
                          color: VelvetColors.periwinkle.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ]
                    : [],
              ),
              child: widget.child,
            ),
          ),
        ),
      );
    },
  );
  }
}
