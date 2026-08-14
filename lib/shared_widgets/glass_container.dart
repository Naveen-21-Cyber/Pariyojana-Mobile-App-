import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/velvet_colors.dart';

/// A premium glassmorphism container with frosted backdrop blur,
/// specular highlight gradient, and subtle refraction border.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurSigma;
  final Color? tintColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 20.0,
    this.blurSigma = 12.0,
    this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final fill = tintColor ?? (isDark 
        ? const Color(0xFF161B22).withValues(alpha: 0.75)
        : VelvetColors.glassFill);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: VelvetColors.cocoa.withValues(alpha: 0.08),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(-2, -2),
                ),
              ],
      ),
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: isDark 
                      ? Colors.white.withValues(alpha: 0.12)
                      : VelvetColors.glassBorder,
                  width: 1.0,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.white.withValues(alpha: 0.08),
                          Colors.white.withValues(alpha: 0.02),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.45),
                          Colors.white.withValues(alpha: 0.08),
                        ],
                ),
              ),
              child: DefaultTextStyle.merge(
                style: isDark ? const TextStyle(color: Color(0xFFE6EDF3)) : null,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
