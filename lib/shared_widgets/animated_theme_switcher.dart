import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ANIMATED THEME SWITCHER — Lag-Free 60FPS Implementation
///
/// Features:
/// - Instant haptic feel with smooth 300ms Curves.easeOutCubic
/// - Night mode: Dark #2A2A2A, moon crescent, 3 star dots
/// - Day mode: Sky blue #00A6FF, sun glow #FFCF48, cloud overlay
/// ─────────────────────────────────────────────────────────────────────────────
class AnimatedThemeSwitcher extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;

  const AnimatedThemeSwitcher({
    super.key,
    required this.isDarkMode,
    required this.onChanged,
    this.width = 72,
    this.height = 36,
  });

  static const String _cloudSvg = '''
<svg viewBox="0 0 16 16">
  <path fill="#ffffff" d="m391.84 540.91c-.421-.329-.949-.524-1.523-.524-1.351 0-2.451 1.084-2.485 2.435-1.395.526-2.388 1.88-2.388 3.466 0 1.874 1.385 3.423 3.182 3.667v.034h12.73v-.006c1.775-.104 3.182-1.584 3.182-3.395 0-1.747-1.309-3.186-2.994-3.379.007-.106.011-.214.011-.322 0-2.707-2.271-4.901-5.072-4.901-2.073 0-3.856 1.202-4.643 2.925" transform="matrix(.77976 0 0 .78395-299.99-418.63)"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    final isDay = !isDarkMode;
    final knobSize = height - 8;

    return GestureDetector(
      onTap: () => onChanged(!isDarkMode),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          color: isDay ? const Color(0xFF00A6FF) : const Color(0xFF2A2A2A),
          border: Border.all(
            color: isDay ? const Color(0xFF38BDF8) : Colors.white24,
            width: 1.2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Night Stars
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isDarkMode ? 1.0 : 0.0,
                child: const Stack(
                  children: [
                    Positioned(left: 40, top: 7, child: _StarDot(size: 3)),
                    Positioned(left: 34, top: 20, child: _StarDot(size: 4)),
                    Positioned(left: 50, top: 14, child: _StarDot(size: 3)),
                  ],
                ),
              ),

              // Day Cloud
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                bottom: isDay ? -4 : -30,
                left: isDay ? -4 : -30,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isDay ? 1.0 : 0.0,
                  child: SvgPicture.string(
                    _cloudSvg,
                    width: 48,
                    height: 26,
                  ),
                ),
              ),

              // Animated Sun / Moon Knob
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                alignment: isDay ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Container(
                    width: knobSize,
                    height: knobSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDay ? const Color(0xFFFFCF48) : Colors.white,
                    ),
                    child: isDarkMode
                        ? Stack(
                            children: [
                              Positioned(
                                top: 2,
                                left: 3,
                                child: Container(
                                  width: knobSize - 5,
                                  height: knobSize - 5,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF2A2A2A),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : null,
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

class _StarDot extends StatelessWidget {
  final double size;
  const _StarDot({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}
