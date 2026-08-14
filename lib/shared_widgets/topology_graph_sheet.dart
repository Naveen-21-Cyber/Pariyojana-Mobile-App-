import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/velvet_colors.dart';
import '../features/idea_vault/presentation/providers/idea_provider.dart';
import '../features/project_tracker/presentation/providers/project_provider.dart';
import '../features/research_tracker/presentation/providers/research_provider.dart';
import '../features/job_tracker/presentation/providers/job_provider.dart';

class TopologyGraphSheet extends ConsumerWidget {
  const TopologyGraphSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ideasAsync = ref.watch(ideasStreamProvider);
    final projectsAsync = ref.watch(projectsStreamProvider);
    final papersAsync = ref.watch(researchPapersStreamProvider);
    final jobsAsync = ref.watch(jobApplicationsStreamProvider);

    final ideasCount = ideasAsync.value?.length ?? 0;
    final projectsCount = projectsAsync.value?.length ?? 0;
    final papersCount = papersAsync.value?.length ?? 0;
    final jobsCount = jobsAsync.value?.length ?? 0;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: VelvetColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: VelvetColors.cocoa.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.hub_outlined, color: VelvetColors.coralPeach, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Asset Topology Network Map',
                    style: TextStyle(
                      fontFamily: GoogleFonts.outfit().fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: VelvetColors.cocoa,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: VelvetColors.cocoa),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: VelvetColors.clayTan.withValues(alpha: 0.4)),
              ),
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size.infinite,
                    painter: TopologyGraphPainter(
                      ideasCount: ideasCount,
                      projectsCount: projectsCount,
                      papersCount: papersCount,
                      jobsCount: jobsCount,
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: VelvetColors.mint.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: VelvetColors.mint),
                      ),
                      child: Text(
                        'LIVE DB TOPOLOGY: ${ideasCount + projectsCount + papersCount + jobsCount} ASSETS CONNECTED 🕸️',
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: VelvetColors.cocoa),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopologyGraphPainter extends CustomPainter {
  final int ideasCount;
  final int projectsCount;
  final int papersCount;
  final int jobsCount;

  TopologyGraphPainter({
    required this.ideasCount,
    required this.projectsCount,
    required this.papersCount,
    required this.jobsCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = VelvetColors.coralPeach.withValues(alpha: 0.35)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final ideaNode = Offset(size.width * 0.25, size.height * 0.3);
    final projectNode = Offset(size.width * 0.75, size.height * 0.3);
    final paperNode = Offset(size.width * 0.25, size.height * 0.7);
    final jobNode = Offset(size.width * 0.75, size.height * 0.7);

    // Draw connection lines
    canvas.drawLine(center, ideaNode, linePaint);
    canvas.drawLine(center, projectNode, linePaint);
    canvas.drawLine(center, paperNode, linePaint);
    canvas.drawLine(center, jobNode, linePaint);
    canvas.drawLine(ideaNode, projectNode, linePaint);
    canvas.drawLine(projectNode, jobNode, linePaint);

    // Draw central Pariyojana core node
    _drawNode(canvas, center, 'Pariyojana Core ⚡', VelvetColors.cocoa, VelvetColors.coralPeach, 24);
    _drawNode(canvas, ideaNode, 'Ideas ($ideasCount) 💡', VelvetColors.cream, VelvetColors.coralPeach, 20);
    _drawNode(canvas, projectNode, 'Projects ($projectsCount) 🚀', VelvetColors.cream, VelvetColors.mint, 20);
    _drawNode(canvas, paperNode, 'Research ($papersCount) 📄', VelvetColors.cream, VelvetColors.periwinkle, 20);
    _drawNode(canvas, jobNode, 'Jobs ($jobsCount) 💼', VelvetColors.cream, VelvetColors.clayTan, 20);
  }

  void _drawNode(Canvas canvas, Offset pos, String label, Color bg, Color border, double radius) {
    final fillPaint = Paint()..color = bg;
    final borderPaint = Paint()
      ..color = border
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(pos, radius, fillPaint);
    canvas.drawCircle(pos, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
