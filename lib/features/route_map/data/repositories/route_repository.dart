import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velvet/core/security/secure_storage_service.dart';
import 'package:velvet/core/security/auth_service.dart';

class RouteGeocodeResult {
  final String name;
  final double latitude;
  final double longitude;

  RouteGeocodeResult({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

class RouteStep {
  final double distance;
  final double duration;
  final String instruction;

  RouteStep({
    required this.distance,
    required this.duration,
    required this.instruction,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    return RouteStep(
      distance: (json['distance'] as num? ?? 0.0).toDouble(),
      duration: (json['duration'] as num? ?? 0.0).toDouble(),
      instruction: json['instruction'] as String? ?? '',
    );
  }
}

class RouteDirectionsResult {
  final List<List<double>> coordinates; // [[latitude, longitude], ...]
  final double distance; // meters
  final double duration; // seconds
  final List<RouteStep> steps;

  RouteDirectionsResult({
    required this.coordinates,
    required this.distance,
    required this.duration,
    required this.steps,
  });
}

abstract class RouteRepository {
  Future<RouteGeocodeResult> geocodeAddress(String address);
  Future<RouteDirectionsResult> getDirections(double startLat, double startLon, double endLat, double endLon);
}

class RouteRepositoryImpl implements RouteRepository {
  final Dio _dio;
  final SecureStorageService _secureStorage;

  RouteRepositoryImpl({Dio? dio, required SecureStorageService secureStorage})
      : _dio = dio ?? Dio(),
        _secureStorage = secureStorage;

  @override
  Future<RouteGeocodeResult> geocodeAddress(String address) async {
    final apiKey = await _secureStorage.getOpenRouteServiceApiKey();
    
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw StateError('Add OpenRouteService key in Settings');
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://api.openrouteservice.org/geocode/search',
        queryParameters: {
          'api_key': apiKey,
          'text': address,
          'size': 1,
        },
      );

      final features = response.data?['features'] as List<dynamic>?;
      if (features != null && features.isNotEmpty) {
        final feature = features.first as Map<String, dynamic>;
        final geometry = feature['geometry'] as Map<String, dynamic>;
        final coords = geometry['coordinates'] as List<dynamic>; // [longitude, latitude]
        final props = feature['properties'] as Map<String, dynamic>;
        final name = props['label'] as String? ?? address;

        return RouteGeocodeResult(
          name: name,
          latitude: (coords[1] as num).toDouble(),
          longitude: (coords[0] as num).toDouble(),
        );
      }
      throw StateError('Address not found on OpenRouteService');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw StateError('OpenRouteService API key is invalid. Please update in Settings.');
      }
      throw StateError('Failed to geocode address: ${e.message}');
    }
  }


  @override
  Future<RouteDirectionsResult> getDirections(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) async {
    final apiKey = await _secureStorage.getOpenRouteServiceApiKey();

    if (apiKey == null || apiKey.trim().isEmpty) {
      throw StateError('Add OpenRouteService key in Settings');
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://api.openrouteservice.org/v2/directions/driving-car',
        queryParameters: {
          'api_key': apiKey,
          'start': '$startLon,$startLat',
          'end': '$endLon,$endLat',
        },
      );

      final features = response.data?['features'] as List<dynamic>?;
      if (features != null && features.isNotEmpty) {
        final feature = features.first as Map<String, dynamic>;
        
        final geometry = feature['geometry'] as Map<String, dynamic>;
        final rawCoords = geometry['coordinates'] as List<dynamic>;
        final coordinates = rawCoords.map<List<double>>((item) {
          final lon = (item[0] as num).toDouble();
          final lat = (item[1] as num).toDouble();
          return [lat, lon];
        }).toList();

        final properties = feature['properties'] as Map<String, dynamic>;
        final segments = properties['segments'] as List<dynamic>;
        final segment = segments.first as Map<String, dynamic>;
        
        final distance = (segment['distance'] as num? ?? 0.0).toDouble();
        final duration = (segment['duration'] as num? ?? 0.0).toDouble();
        
        final rawSteps = segment['steps'] as List<dynamic>? ?? [];
        final steps = rawSteps.map((s) => RouteStep.fromJson(s as Map<String, dynamic>)).toList();

        return RouteDirectionsResult(
          coordinates: coordinates,
          distance: distance,
          duration: duration,
          steps: steps,
        );
      }
      throw StateError('No directions found from OpenRouteService');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw StateError('OpenRouteService API key is invalid. Please update in Settings.');
      }
      throw StateError('Failed to fetch directions: ${e.message}');
    }
  }
}


final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  final secureStorage = ref.read(secureStorageProvider);
  return RouteRepositoryImpl(secureStorage: secureStorage);
});
