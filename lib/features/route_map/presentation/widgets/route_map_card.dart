import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velvet/core/theme/velvet_colors.dart';
import 'package:velvet/shared_widgets/clay_card.dart';
import 'package:velvet/features/route_map/data/repositories/route_repository.dart';

final routeDetailsProvider = FutureProvider.family<RouteDirectionsResult, String>((ref, address) async {
  final repo = ref.read(routeRepositoryProvider);
  final geocode = await repo.geocodeAddress(address);
  // Default start point at New York Center coordinates: 40.7128, -74.0060
  return repo.getDirections(40.7128, -74.0060, geocode.latitude, geocode.longitude);
});

class RouteMapCard extends ConsumerWidget {
  final String address;

  const RouteMapCard({super.key, required this.address});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (address.trim().isEmpty) return const SizedBox.shrink();

    final directionsAsync = ref.watch(routeDetailsProvider(address));

    return directionsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(color: VelvetColors.coralPeach),
        ),
      ),
      error: (err, stack) => ClayCard(
        color: VelvetColors.cream,
        padding: const EdgeInsets.all(16),
        child: Text(
          'Error loading route preview: $err',
          style: const TextStyle(fontSize: 12, color: Colors.redAccent),
        ),
      ),
      data: (route) {
        final km = (route.distance / 1000.0).toStringAsFixed(1);
        final mins = (route.duration / 60.0).toStringAsFixed(0);

        return ClayCard(
          color: VelvetColors.cream,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Route Preview',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: VelvetColors.cocoa,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: VelvetColors.periwinkle.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$km km • $mins mins',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: VelvetColors.cocoa,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Vector Map Canvas
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: VelvetColors.clayTan.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: VelvetColors.clayTan.withValues(alpha: 0.8)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CustomPaint(
                    painter: RouteVectorPainter(coordinates: route.coordinates),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Directions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: VelvetColors.cocoa,
                ),
              ),
              const SizedBox(height: 8),

              // Horizontal list of directions steps
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: route.steps.length,
                  itemBuilder: (context, idx) {
                    final step = route.steps[idx];
                    final stepKm = (step.distance / 1000.0).toStringAsFixed(1);
                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: VelvetColors.cream,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: VelvetColors.clayTan.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.instruction,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: VelvetColors.cocoa,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Text(
                            'in $stepKm km',
                            style: TextStyle(
                              fontSize: 10,
                              color: VelvetColors.cocoa.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RouteVectorPainter extends CustomPainter {
  final List<List<double>> coordinates;

  RouteVectorPainter({required this.coordinates});

  @override
  void paint(Canvas canvas, Size size) {
    if (coordinates.length < 2) return;

    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLon = double.infinity;
    double maxLon = -double.infinity;

    for (final coord in coordinates) {
      final lat = coord[0];
      final lon = coord[1];
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lon < minLon) minLon = lon;
      if (lon > maxLon) maxLon = lon;
    }

    final latRange = maxLat - minLat;
    final lonRange = maxLon - minLon;

    final double safeLatRange = latRange == 0 ? 1.0 : latRange;
    final double safeLonRange = lonRange == 0 ? 1.0 : lonRange;

    final padding = size.width * 0.15;
    final drawWidth = size.width - (padding * 2);
    final drawHeight = size.height - (padding * 2);

    Offset mapToCanvas(double lat, double lon) {
      final x = padding + ((lon - minLon) / safeLonRange) * drawWidth;
      final y = size.height - padding - (((lat - minLat) / safeLatRange) * drawHeight);
      return Offset(x, y);
    }

    final gridPaint = Paint()
      ..color = VelvetColors.cocoa.withValues(alpha: 0.08)
      ..strokeWidth = 1.0;
    
    for (int i = 1; i < 5; i++) {
      final x = size.width * (i / 5);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      final y = size.height * (i / 5);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final pathPaint = Paint()
      ..color = VelvetColors.coralPeach
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final startOffset = mapToCanvas(coordinates.first[0], coordinates.first[1]);
    path.moveTo(startOffset.dx, startOffset.dy);

    for (int i = 1; i < coordinates.length; i++) {
      final offset = mapToCanvas(coordinates[i][0], coordinates[i][1]);
      path.lineTo(offset.dx, offset.dy);
    }
    canvas.drawPath(path, pathPaint);

    final startPaint = Paint()..color = VelvetColors.mint;
    canvas.drawCircle(startOffset, 6.0, startPaint);
    canvas.drawCircle(startOffset, 10.0, Paint()..color = VelvetColors.mint.withValues(alpha: 0.3));

    final endOffset = mapToCanvas(coordinates.last[0], coordinates.last[1]);
    final endPaint = Paint()..color = VelvetColors.coralPeach;
    canvas.drawCircle(endOffset, 6.0, endPaint);
    canvas.drawCircle(endOffset, 12.0, Paint()..color = VelvetColors.coralPeach.withValues(alpha: 0.3));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
