import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ANIMATED DELIVERY BUTTON — 1:1 CSS Spec Implementation
///
/// Features:
/// - Blue starry sky gradient background
/// - Tap triggers full delivery animation: package closes, car drives across & loads box, reveals "Done ✅"
/// ─────────────────────────────────────────────────────────────────────────────
class AnimatedDeliveryButton extends StatefulWidget {
  final String orderText;
  final String doneText;
  final VoidCallback? onPressed;
  final double width;
  final double height;

  const AnimatedDeliveryButton({
    super.key,
    this.orderText = 'Place Order',
    this.doneText = 'Done ✅',
    this.onPressed,
    this.width = 220,
    this.height = 54,
  });

  @override
  State<AnimatedDeliveryButton> createState() => _AnimatedDeliveryButtonState();
}

class _AnimatedDeliveryButtonState extends State<AnimatedDeliveryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _anim.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isDone = true);
        if (widget.onPressed != null) {
          widget.onPressed!();
        }
      }
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _triggerAnimation() {
    if (!_anim.isAnimating) {
      setState(() => _isDone = false);
      _anim.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _triggerAnimation,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, child) {
          final progress = _anim.value;

          // Car position driving from -1.0 (off left) -> 0.0 (center pick up) -> 1.5 (drive off right)
          double carX = -1.2;
          if (progress > 0.1 && progress <= 0.5) {
            carX = -1.2 + (progress - 0.1) * 3.0; // drives to center
          } else if (progress > 0.5) {
            carX = 0.0 + (progress - 0.5) * 3.0; // drives out right
          }

          // Package translation
          double packageY = 0.0;
          if (progress > 0.4) {
            packageY = -60.0 * (progress - 0.4);
          }

          // Text opacity & translation
          final orderTextOpacity = (1.0 - progress * 4.0).clamp(0.0, 1.0);
          final doneTextOpacity = (progress > 0.85 || _isDone) ? 1.0 : 0.0;

          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF0313FC), width: 2),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0004DA),
                  Color(0xFF1873FC),
                  Color(0xFF00A2FF),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00A2FF).withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Starry Sky Dots
                  if (progress < 0.2)
                    const Stack(
                      children: [
                        Positioned(left: 20, top: 10, child: _StarDot()),
                        Positioned(left: 60, top: 28, child: _StarDot()),
                        Positioned(left: 110, top: 14, child: _StarDot()),
                        Positioned(left: 170, top: 32, child: _StarDot()),
                        Positioned(left: 190, top: 8, child: _StarDot()),
                      ],
                    ),

                  // Initial Order Text
                  Opacity(
                    opacity: orderTextOpacity,
                    child: Text(
                      widget.orderText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  // Package Box
                  if (progress > 0.1 && progress < 0.8)
                    Transform.translate(
                      offset: Offset(0, packageY),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB571),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFD57D2B), width: 1.5),
                        ),
                        child: const Center(
                          child: Text('📦', style: TextStyle(fontSize: 10)),
                        ),
                      ),
                    ),

                  // Delivery Car
                  if (progress > 0.1 && progress < 0.9)
                    Align(
                      alignment: Alignment(carX, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 38,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFED54A),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.black, width: 1.5),
                            ),
                            child: const Center(
                              child: Text('🚚', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Done Status Text
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: doneTextOpacity,
                    child: Text(
                      widget.doneText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StarDot extends StatelessWidget {
  const _StarDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2.5,
      height: 2.5,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}
