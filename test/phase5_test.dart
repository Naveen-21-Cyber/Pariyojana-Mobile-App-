import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velvet/features/hacker_news/data/repositories/hn_repository.dart';
import 'package:velvet/features/route_map/data/repositories/route_repository.dart';
import 'package:velvet/core/security/secure_storage_service.dart';
import 'package:dio/dio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (methodCall) async {
        if (methodCall.method == 'read') {
          return null;
        }
        return null;
      },
    );
  });

  group('Phase 5 - Hacker News & Route Map Layer Tests', () {
    test('HnStory security parsing and keyword classification works correctly', () {
      final secStory = HnStory(
        id: 1,
        title: 'New zero-day Exploit discovered in Linux Kernel (CVE-2026-XXXX)',
        author: 'sec_researcher',
        score: 412,
        time: DateTime.now(),
      );

      final nonSecStory = HnStory(
        id: 2,
        title: 'Show HN: A beautiful canvas drawer tool',
        author: 'canvas_fan',
        score: 87,
        time: DateTime.now(),
      );

      expect(secStory.isSecurity, true);
      expect(nonSecStory.isSecurity, false);
    });

    test('RouteRepository geocoding and directions throw StateError without API key', () async {
      final secureStorage = SecureStorageService();
      final repository = RouteRepositoryImpl(secureStorage: secureStorage);

      expect(() => repository.geocodeAddress('Paris, France'), throwsA(isA<StateError>()));
      expect(() => repository.getDirections(40.7128, -74.0060, 48.8566, 2.3522), throwsA(isA<StateError>()));
    });


    test('HnRepositoryImpl caches results and throttles within 20 minutes', () async {
      final mockDio = MockDio();
      final repository = HnRepositoryImpl(dio: mockDio);

      // First fetch should hit mockDio (which increments requestCount)
      final feed1 = await repository.fetchFeed('top');
      expect(feed1.isNotEmpty, true);
      final initialRequests = mockDio.requestCount;

      // Second fetch should return cached results directly without hitting mockDio
      final feed2 = await repository.fetchFeed('top');
      expect(feed2.length, feed1.length);
      expect(mockDio.requestCount, initialRequests); // requestCount should NOT increase
    });
  });
}

class MockDio extends DioMixin implements Dio {
  int requestCount = 0;

  MockDio() {
    options = BaseOptions();
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    requestCount++;
    if (path.contains('stories.json')) {
      final list = [1, 2, 3];
      return Response(
        requestOptions: RequestOptions(path: path),
        data: list as T,
        statusCode: 200,
      );
    } else {
      final item = {
        'id': 1,
        'title': 'Test Security vulnerability found',
        'by': 'hacker',
        'score': 100,
        'time': 1783409155,
      };
      return Response(
        requestOptions: RequestOptions(path: path),
        data: item as T,
        statusCode: 200,
      );
    }
  }
}
