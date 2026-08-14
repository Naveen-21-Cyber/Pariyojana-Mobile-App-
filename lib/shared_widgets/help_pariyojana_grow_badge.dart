import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// HELP PARIYOJANA TO GROW BADGE — 1:1 CSS Spec Implementation
///
/// Features:
/// - Floating leaf tooltip with text "Help Pariyojana to Grow!!"
/// - Animated leaf fan with green gradient (#B4C7B3 -> #314328)
/// - Continuous floating Sine-wave motion & leaf fanning for mobile touchscreens
/// - Interactive tap to open GitHub / Contribution link
/// ─────────────────────────────────────────────────────────────────────────────
class HelpPariyojanaGrowBadge extends StatefulWidget {
  final String text;
  final String targetUrl;

  const HelpPariyojanaGrowBadge({
    super.key,
    this.text = 'Help Pariyojana to Grow!! 🌱',
    this.targetUrl = 'http://pariyojana.gt.tc/',
  });

  @override
  State<HelpPariyojanaGrowBadge> createState() => _HelpPariyojanaGrowBadgeState();
}

class _HelpPariyojanaGrowBadgeState extends State<HelpPariyojanaGrowBadge>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl() async {
    final uri = Uri.parse(widget.targetUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          setState(() => _isHovered = !_isHovered);
          _launchUrl();
        },
        child: AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            final floatY = math.sin(_floatController.value * math.pi * 2) * 4.0;
            final dynamicAngle = math.sin(_floatController.value * math.pi) * 0.15;

            return Transform.translate(
              offset: Offset(0, floatY),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2822) : const Color(0xFFE9F6F4),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF3F5641), width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF314328),
                      offset: Offset(3, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🌱', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.text,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: isDark ? const Color(0xFFC6E377) : const Color(0xFF3F5641),
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Animated Fan of Leaves
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _LeafShape(angle: 0.35 + dynamicAngle),
                        _LeafShape(angle: -0.35 - dynamicAngle),
                        _LeafShape(angle: 0.65 + dynamicAngle * 0.5),
                        _LeafShape(angle: -0.65 - dynamicAngle * 0.5),
                      ],
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

class _LeafShape extends StatelessWidget {
  final double angle;
  const _LeafShape({required this.angle});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 22,
        height: 14,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
          gradient: LinearGradient(
            colors: [Color(0xFFB4C7B3), Color(0xFF314328)],
          ),
        ),
      ),
    );
  }
}
