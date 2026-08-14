import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../core/theme/velvet_colors.dart';

class ThreeDSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final String label;

  const ThreeDSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    required this.label,
  });

  @override
  State<ThreeDSlider> createState() => _ThreeDSliderState();
}

class _ThreeDSliderState extends State<ThreeDSlider> {
  double _tiltY = 0.0;
  bool _isDragging = false;
  int _lastIntVal = -1;

  void _updateTilt(double progress) {
    // Progress ranges from 0.0 to 1.0. Map it to Y tilt from -0.12 to +0.12 radians
    setState(() {
      _tiltY = -0.12 + (progress * 0.24);
    });
  }

  @override
  Widget build(BuildContext context) {
    final range = widget.max - widget.min;
    final progress = range > 0 ? (widget.value - widget.min) / range : 0.0;

    return GestureDetector(
      onPanStart: (_) {
        setState(() {
          _isDragging = true;
        });
      },
      onPanEnd: (_) {
        setState(() {
          _isDragging = false;
          _tiltY = 0.0;
        });
      },
      child: AnimatedRotation(
        turns: 0.0,
        duration: const Duration(milliseconds: 200),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015) // perspective
            ..rotateY(_isDragging ? _tiltY : 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontFamily: GoogleFonts.outfit().fontFamily,
                      fontWeight: FontWeight.bold,
                      color: VelvetColors.cocoa,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
                      fontWeight: FontWeight.bold,
                      color: VelvetColors.cocoa.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: VelvetColors.coralPeach,
                  inactiveTrackColor: VelvetColors.clayTan.withValues(alpha: 0.5),
                  thumbColor: VelvetColors.cream,
                  overlayColor: VelvetColors.coralPeach.withValues(alpha: 0.12),
                  trackHeight: 6.0,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10.0,
                    elevation: 4.0,
                  ),
                ),
                child: Slider(
                  value: widget.value,
                  min: widget.min,
                  max: widget.max,
                  onChanged: (val) {
                    _updateTilt((val - widget.min) / range);
                    
                    // Tactile ticks on step intervals
                    final intVal = (val * 10).round();
                    if (intVal != _lastIntVal) {
                      HapticFeedback.lightImpact();
                      _lastIntVal = intVal;
                    }
                    
                    widget.onChanged(val);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
