import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../project_tracker/presentation/providers/project_provider.dart';
import '../../../research_tracker/presentation/providers/research_provider.dart';

class SkillTreeRadarChartCard extends ConsumerWidget {
  const SkillTreeRadarChartCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsStreamProvider);
    final papersAsync = ref.watch(researchPapersStreamProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VelvetColors.cardSurface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VelvetColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.radar_rounded, color: VelvetColors.coralPeach, size: 20),
              const SizedBox(width: 8),
              Text(
                'Skill Tree & Tech Stack Radar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: VelvetColors.textPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Dynamic mastery mapping based on active projects & research papers',
            style: TextStyle(fontSize: 11, color: VelvetColors.textSecondary(context)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: projectsAsync.when(
              data: (projects) {
                return papersAsync.when(
                  data: (papers) {
                    final Map<String, int> counts = {
                      'Flutter': 0,
                      'Dart': 0,
                      'Python': 0,
                      'Docker': 0,
                      'Security': 0,
                      'SQL': 0,
                    };

                    for (final p in projects) {
                      final stack = (p.techStack ?? '').toLowerCase();
                      if (stack.contains('flutter')) counts['Flutter'] = (counts['Flutter'] ?? 0) + 2;
                      if (stack.contains('dart')) counts['Dart'] = (counts['Dart'] ?? 0) + 2;
                      if (stack.contains('python')) counts['Python'] = (counts['Python'] ?? 0) + 2;
                      if (stack.contains('docker')) counts['Docker'] = (counts['Docker'] ?? 0) + 2;
                      if (stack.contains('security') || stack.contains('auth')) counts['Security'] = (counts['Security'] ?? 0) + 2;
                      if (stack.contains('sql') || stack.contains('db')) counts['SQL'] = (counts['SQL'] ?? 0) + 2;
                    }

                    for (final paper in papers) {
                      final tags = (paper.keywords ?? '').toLowerCase();
                      if (tags.contains('security') || tags.contains('crypto')) counts['Security'] = (counts['Security'] ?? 0) + 3;
                      if (tags.contains('python') || tags.contains('ai')) counts['Python'] = (counts['Python'] ?? 0) + 3;
                      if (tags.contains('sql') || tags.contains('database')) counts['SQL'] = (counts['SQL'] ?? 0) + 3;
                    }

                    // Default baseline so the radar is always visually engaging
                    counts['Flutter'] = math.max(counts['Flutter']!, 4);
                    counts['Dart'] = math.max(counts['Dart']!, 4);
                    counts['Security'] = math.max(counts['Security']!, 5);
                    counts['Python'] = math.max(counts['Python']!, 3);
                    counts['Docker'] = math.max(counts['Docker']!, 3);
                    counts['SQL'] = math.max(counts['SQL']!, 4);

                    return CustomPaint(
                      size: const Size(double.infinity, 200),
                      painter: _RadarChartPainter(
                        scores: counts,
                        isDark: Theme.of(context).brightness == Brightness.dark,
                        textColor: VelvetColors.textPrimary(context),
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final Map<String, int> scores;
  final bool isDark;
  final Color textColor;

  _RadarChartPainter({
    required this.scores,
    required this.isDark,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2.6;
    final keys = scores.keys.toList();
    final int sides = keys.length;

    final gridPaint = Paint()
      ..color = isDark ? Colors.white12 : Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final fillPaint = Paint()
      ..color = (isDark ? const Color(0xFF00E5FF) : VelvetColors.coralPeach).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = isDark ? const Color(0xFF00E5FF) : VelvetColors.coralPeach
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Draw background web polygons (4 concentric levels)
    for (int step = 1; step <= 4; step++) {
      final stepRadius = radius * (step / 4);
      final path = Path();
      for (int i = 0; i < sides; i++) {
        final angle = (i * 2 * math.pi / sides) - (math.pi / 2);
        final x = center.dx + stepRadius * math.cos(angle);
        final y = center.dy + stepRadius * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Draw spoke lines & labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final dataPath = Path();

    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - (math.pi / 2);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), gridPaint);

      // Label text
      final label = keys[i];
      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      );
      textPainter.layout();
      final labelX = center.dx + (radius + 16) * math.cos(angle) - (textPainter.width / 2);
      final labelY = center.dy + (radius + 16) * math.sin(angle) - (textPainter.height / 2);
      textPainter.paint(canvas, Offset(labelX, labelY));

      // Calculate data point score (scaled 1-10)
      final double scoreRatio = math.min(scores[label]! / 10.0, 1.0);
      final dataX = center.dx + (radius * scoreRatio) * math.cos(angle);
      final dataY = center.dy + (radius * scoreRatio) * math.sin(angle);

      if (i == 0) {
        dataPath.moveTo(dataX, dataY);
      } else {
        dataPath.lineTo(dataX, dataY);
      }
    }
    dataPath.close();

    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) => true;
}
