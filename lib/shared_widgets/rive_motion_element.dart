import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide RadialGradient, LinearGradient;
import '../core/theme/velvet_colors.dart';

class RiveMotionElement extends StatefulWidget {
  final String? assetPath;
  final String? url;
  final String? artboardName;
  final String? stateMachineName;
  final double width;
  final double height;
  final Widget? fallback;
  final Color primaryColor;
  final Color secondaryColor;
  final VoidCallback? onTap;

  const RiveMotionElement({
    super.key,
    this.assetPath,
    this.url,
    this.artboardName,
    this.stateMachineName,
    this.width = 60,
    this.height = 60,
    this.fallback,
    this.primaryColor = VelvetColors.coralPeach,
    this.secondaryColor = VelvetColors.periwinkle,
    this.onTap,
  });

  @override
  State<RiveMotionElement> createState() => _RiveMotionElementState();
}

class _RiveMotionElementState extends State<RiveMotionElement> with SingleTickerProviderStateMixin {
  Artboard? _riveArtboard;
  StateMachineController? _controller;
  SMITrigger? _bumpTrigger;
  SMIBool? _isHoveredBool;
  late AnimationController _fallbackController;

  @override
  void initState() {
    super.initState();
    _fallbackController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    if (widget.assetPath != null) {
      _loadAssetRive(widget.assetPath!);
    } else if (widget.url != null) {
      _loadNetworkRive(widget.url!);
    }
  }

  Future<void> _loadAssetRive(String path) async {
    try {
      final file = await RiveFile.asset(path);
      final artboard = widget.artboardName != null
          ? file.artboardByName(widget.artboardName!)
          : file.mainArtboard;
      if (artboard != null) {
        StateMachineController? controller;
        if (widget.stateMachineName != null) {
          controller = StateMachineController.fromArtboard(artboard, widget.stateMachineName!);
        } else if (artboard.stateMachines.isNotEmpty) {
          controller = StateMachineController.fromArtboard(artboard, artboard.stateMachines.first.name);
        }
        if (controller != null) {
          artboard.addController(controller);
          _bumpTrigger = controller.findSMI<SMITrigger>('bump') ?? controller.findSMI<SMITrigger>('Trigger 1');
          _isHoveredBool = controller.findSMI<SMIBool>('hover') ?? controller.findSMI<SMIBool>('Hover');
        }
        if (mounted) {
          setState(() {
            _riveArtboard = artboard;
            _controller = controller;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _loadNetworkRive(String url) async {
    try {
      final file = await RiveFile.network(url);
      final artboard = widget.artboardName != null
          ? file.artboardByName(widget.artboardName!)
          : file.mainArtboard;
      if (artboard != null) {
        final controller = StateMachineController.fromArtboard(
          artboard,
          widget.stateMachineName ?? 'State Machine 1',
        );
        if (controller != null) {
          artboard.addController(controller);
          _bumpTrigger = controller.findSMI<SMITrigger>('bump');
          _isHoveredBool = controller.findSMI<SMIBool>('hover');
        }
        if (mounted) {
          setState(() {
            _riveArtboard = artboard;
            _controller = controller;
          });
        }
      }
    } catch (_) {
      // Fallback painter handles gracefully if offline or URL unavailable
    }
  }

  void _triggerAnimation() {
    _bumpTrigger?.fire();
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _fallbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_riveArtboard != null) {
      return RepaintBoundary(
        child: GestureDetector(
          onTap: _triggerAnimation,
          onTapDown: (_) => _isHoveredBool?.value = true,
          onTapUp: (_) => _isHoveredBool?.value = false,
          onTapCancel: () => _isHoveredBool?.value = false,
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: Rive(artboard: _riveArtboard!, fit: BoxFit.contain),
          ),
        ),
      );
    }

    // High-performance liquid vector canvas painter strictly constrained to width/height
    return RepaintBoundary(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _fallbackController,
            builder: (context, child) {
              final t = _fallbackController.value;
              return CustomPaint(
                size: Size(widget.width, widget.height),
                painter: LiquidBlobPainter(
                  progress: t,
                  primaryColor: widget.primaryColor,
                  secondaryColor: widget.secondaryColor,
                ),
                child: widget.fallback ?? const SizedBox.shrink(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class LiquidBlobPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color secondaryColor;

  LiquidBlobPainter({
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final paint = Paint()
      ..shader = RadialGradient(
          colors: [primaryColor, secondaryColor],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    final path = Path();
    const pointCount = 8;
    const angleStep = (math.pi * 2) / pointCount;

    for (int i = 0; i < pointCount; i++) {
      final angle = i * angleStep;
      final wave = math.sin(angle * 3 + progress * math.pi * 2) * (radius * 0.12);
      final r = radius * 0.88 + wave;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawShadow(path, primaryColor.withValues(alpha: 0.4), 8, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant LiquidBlobPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
