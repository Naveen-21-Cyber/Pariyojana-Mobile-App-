import 'package:flutter/material.dart';
import '../core/theme/velvet_colors.dart';

class ClayCard extends StatefulWidget {
  final Widget child;
  final Color color;
  final double borderRadius;
  final double depth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const ClayCard({
    super.key,
    required this.child,
    this.color = VelvetColors.clayTan,
    this.borderRadius = 28.0,
    this.depth = 8.0,
    this.padding = const EdgeInsets.all(20.0),
    this.margin,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  State<ClayCard> createState() => _ClayCardState();
}

class _ClayCardState extends State<ClayCard> {
  bool _isPressed = false;

  void _resetPress() {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final depth = _isPressed ? widget.depth * 0.25 : widget.depth;
    final scale = _isPressed ? 0.97 : 1.0;

    // Adapt color for Dark Mode if card has light/cream color
    Color effectiveColor = widget.color;
    if (isDark) {
      if (widget.color == VelvetColors.cream ||
          widget.color == VelvetColors.clayTan ||
          widget.color == Colors.white ||
          widget.color == const Color(0xFFFFFBF7)) {
        effectiveColor = VelvetColors.darkCard;
      }
    }

    final shadowList = isDark
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: depth * 2,
              offset: Offset(depth * 0.8, depth * 0.8),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.05),
              blurRadius: depth * 0.5,
              offset: Offset(-depth * 0.4, -depth * 0.4),
            ),
          ]
        : [
            BoxShadow(
              color: VelvetColors.cocoa.withValues(alpha: 0.07),
              blurRadius: depth * 2.5,
              spreadRadius: depth * 0.2,
              offset: Offset(depth * 0.8, depth * 0.8),
            ),
            BoxShadow(
              color: VelvetColors.cocoa.withValues(alpha: 0.04),
              blurRadius: depth * 1.0,
              offset: Offset(depth * 0.4, depth * 0.4),
            ),
          ];


    final cardWidget = AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      transformAlignment: Alignment.center,
      transform: Matrix4.identity()
        // ignore: deprecated_member_use
        ..scale(scale),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: isDark ? Border.all(color: Colors.white12, width: 1.0) : null,
        boxShadow: shadowList,
      ),
      child: Container(
        padding: widget.padding,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: IconTheme.merge(
          data: IconThemeData(
            color: isDark ? const Color(0xFFE6EDF3) : VelvetColors.cocoa,
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: isDark ? VelvetColors.darkText : VelvetColors.cocoa,
            ),
            child: widget.child,
          ),
        ),
      ),
    );

    if (widget.onTap == null) {
      return cardWidget;
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => _resetPress(),
      onTapCancel: () => _resetPress(),
      onTap: widget.onTap,
      child: cardWidget,
    );
  }
}
