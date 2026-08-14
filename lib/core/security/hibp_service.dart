import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:pointycastle/digests/sha1.dart';

class HibpService {
  final Dio _dio;

  HibpService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 5);
  }

  /// Checks if a password or PIN has appeared in data breaches using HIBP k-Anonymity API.
  /// Returns the number of times it appeared in data breaches (0 if safe/unbreached).
  Future<int> checkBreachCount(String secret) async {
    if (secret.isEmpty) return 0;

    try {
      // 1. Calculate SHA-1 hash of the secret using PointyCastle
      final digest = SHA1Digest();
      final bytes = Uint8List.fromList(utf8.encode(secret));
      final hashedBytes = digest.process(bytes);
      final sha1Hash = hashedBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase();

      // 2. Split hash into first 5 chars (prefix) and remaining chars (suffix)
      final prefix = sha1Hash.substring(0, 5);
      final suffix = sha1Hash.substring(5);

      // 3. Query HIBP k-Anonymity range API with first 5 chars ONLY
      final response = await _dio.get<String>(
        'https://api.pwnedpasswords.com/range/$prefix',
        options: Options(responseType: ResponseType.plain),
      );

      if (response.statusCode == 200 && response.data != null) {
        final lines = response.data!.split('\n');
        for (final line in lines) {
          final parts = line.trim().split(':');
          if (parts.length == 2) {
            final returnedSuffix = parts[0].trim().toUpperCase();
            final count = int.tryParse(parts[1].trim()) ?? 0;
            if (returnedSuffix == suffix) {
              return count; // Found in data breach!
            }
          }
        }
      }
      return 0; // Not found in breaches (Secure!)
    } catch (_) {
      // Offline fallback: if network is unavailable, do not block local setup
      return 0;
    }
  }
}
