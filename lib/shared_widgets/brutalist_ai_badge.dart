import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// BRUTALIST AI BADGE — 1:1 CSS Spec Implementation (Resizable)
///
/// Features:
/// - Brutalist card with 3px solid white border & #e71c1c red hard shadow
/// - Gradient shift background (#5688fd -> #a9daff -> #ffffff)
/// - Center Gemini 4-point star SVG logo
/// - Hover/Tap dynamics: logo shrinks & spins 360°, text "POWERED BY PARIYOJANA" slides up
/// ─────────────────────────────────────────────────────────────────────────────
class BrutalistAiBadge extends StatefulWidget {
  final String topText;
  final String bottomText;
  final double size;
  final VoidCallback? onTap;

  const BrutalistAiBadge({
    super.key,
    this.topText = 'POWERED BY',
    this.bottomText = 'PARIYOJANA AI',
    this.size = 140,
    this.onTap,
  });

  @override
  State<BrutalistAiBadge> createState() => _BrutalistAiBadgeState();
}

class _BrutalistAiBadgeState extends State<BrutalistAiBadge>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late final AnimationController _spinController;

  static const String _geminiSvg = '''
<svg viewBox="0 0 512 512" fill="#5688FD">
  <path d="M255,509.74387c0,-4.181-3.317,-28.439-5.002,-36.579C236.393,407.429,200.023,350.391,146,310.064
  C109.903,283.118,65.342,265.064,21,259.419C2.049,257.007,2,256.997,2,255.656c0,-0.867,3.652,-1.618,11.85,-2.438
  c38.338,-3.833,80.042,-18.019,112.65,-38.319c23.694,-14.751,48.995,-36.708,66.719,-57.901
  C226.066,117.724,248.675,63.978,253.999,12.516c0.625,-6.041,1.393,-11.216,1.707,-11.5c0.314,-0.284,0.293,4.884,-0.047,11.484
  c-1.321,25.677-10.726,59.973-24.194,88.221c-34.683,72.748-100.264,127.322-176.921,147.225
  c-12.636,3.281-32.545,6.989-38.425,7.157L12.5,255.207l3.5,0.84c1.925,0.462,8.225,1.58,14,2.486
  c73.44,11.519,140.669,55.521,183.292,119.968c23.169,35.032,40.183,83.112,42.569,120.298l0.687,10.702l0.668,-11
  c1.702,-28.041,13.91,-69.245,28.789,-97.172c52.456,-101.263,125.876,-153.258,213.665,-166.444
  c10.874,-1.633,13.495,-2.481,7.67,-2.481c-10.386,0-42.126,-7.28-60.524,-13.882c-38.019,-13.643-68.831,-32.968-98.143,-61.554
  c-30.616,-30.612-56.843,-78.819-67.646,-133.72c-2.378,-12.085-4.54,-35.844-3.261,-35.844c0.285,0,1.058,5.063,1.716,11.25
  c2.509,23.581,9.097,50.547,17.529,71.75c8.973,22.563,25.437,50.946,40.281,69.441c8.244,10.272,27.297,29.575,38.251,38.754
  c40.38,33.835,91.66,55.563,143.75,60.908c8.747,0.898,12.25,1.629,12.25,2.558c0,1.559-1.286,1.835-15.5,3.318
  c-78.493,8.19-154.6,56.62-197.252,125.522c-21.977,35.502-36.117,77.76-39.735,118.75c-0.502,5.692-1.06,7.75-2.099,7.75
  C255.637,511,255,510.435,255,509.744z"/>
</svg>
''';

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _onHoverChanged(bool hovered) {
    setState(() => _isHovered = hovered);
    if (hovered) {
      _spinController.repeat();
    } else {
      _spinController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor = widget.size / 140.0;
    final logoNormal = 85.0 * scaleFactor;
    final logoSmall = 54.0 * scaleFactor;

    return MouseRegion(
      onEnter: (_) => _onHoverChanged(true),
      onExit: (_) => _onHoverChanged(false),
      child: GestureDetector(
        onTap: () {
          _onHoverChanged(!_isHovered);
          if (widget.onTap != null) widget.onTap!();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: const Cubic(0.175, 0.885, 0.32, 1.275),
          width: widget.size,
          height: widget.size,
          transform: Matrix4.translationValues(
            _isHovered ? -4 : 0,
            _isHovered ? -4 : 0,
            0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16 * scaleFactor),
            border: Border.all(color: Colors.white, width: 3 * scaleFactor),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF5688FD),
                Color(0xFFA9DAFF),
                Colors.white,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE71C1C),
                offset: _isHovered ? Offset(8 * scaleFactor, 8 * scaleFactor) : Offset(4 * scaleFactor, 4 * scaleFactor),
                blurRadius: 0,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Gemini Logo Container
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: const Cubic(0.68, -0.55, 0.265, 1.55),
                top: _isHovered ? 12 * scaleFactor : 20 * scaleFactor,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: _isHovered ? logoSmall : logoNormal,
                  height: _isHovered ? logoSmall : logoNormal,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, Color(0xFFB6E0FD), Color(0xFF719BFD)],
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Center(
                    child: RotationTransition(
                      turns: _spinController,
                      child: AnimatedScale(
                        scale: _isHovered ? 0.75 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: SvgPicture.string(
                          _geminiSvg,
                          width: 32 * scaleFactor,
                          height: 32 * scaleFactor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Sliding Text Badge
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: const Cubic(0.68, -0.55, 0.265, 1.55),
                bottom: _isHovered ? 10 * scaleFactor : -35,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _isHovered ? 1.0 : 0.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.topText,
                        style: TextStyle(
                          fontSize: 9 * scaleFactor,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        widget.bottomText,
                        style: TextStyle(
                          fontSize: 10.5 * scaleFactor,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.8,
                          shadows: const [
                            Shadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 1)),
                          ],
                        ),
                      ),
                    ],
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
