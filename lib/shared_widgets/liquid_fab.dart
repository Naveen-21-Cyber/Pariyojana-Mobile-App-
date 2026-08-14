import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/velvet_colors.dart';

class LiquidFab extends ConsumerStatefulWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final String tooltip;

  const LiquidFab({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip = 'Add New Item',
  });

  @override
  ConsumerState<LiquidFab> createState() => _LiquidFabState();
}

class _LiquidFabState extends ConsumerState<LiquidFab> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeAccent = ref.watch(themeAccentProvider);
    final accentColor = VelvetColors.getAccentColor(activeAccent);

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        final double topLeft = 24 + 8 * math.sin(value * math.pi * 2);
        final double topRight = 24 + 8 * math.cos(value * math.pi * 2);
        final double bottomLeft = 24 + 8 * math.cos(value * math.pi * 2 + math.pi / 2);
        final double bottomRight = 24 + 8 * math.sin(value * math.pi * 2 + math.pi / 2);

        final borderRadius = BorderRadius.only(
          topLeft: Radius.circular(topLeft),
          topRight: Radius.circular(topRight),
          bottomLeft: Radius.circular(bottomLeft),
          bottomRight: Radius.circular(bottomRight),
        );

        return SizedBox(
          width: 58,
          height: 58,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: accentColor,
              borderRadius: borderRadius,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.onPressed,
                borderRadius: borderRadius,
                child: Tooltip(
                  message: widget.tooltip,
                  child: Center(
                    child: IconTheme(
                      data: const IconThemeData(
                        color: VelvetColors.cocoa,
                        size: 26,
                      ),
                      child: widget.icon,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
  }
}
