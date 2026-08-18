import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AnalyticsService {
  static const _sessionKey = 'velvet_session_count';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool get isInitialized => true;

  Future<void> logAppOpen() async {
    try {
      final countStr = await _storage.read(key: _sessionKey);
      final current = int.tryParse(countStr ?? '0') ?? 0;
      await _storage.write(key: _sessionKey, value: '${current + 1}');
    } catch (e) {
      debugPrint('Session counter error: $e');
    }
  }

  /// Returns real cumulative session count (across all launches on this device).
  Future<int> getSessionCount() async {
    try {
      final countStr = await _storage.read(key: _sessionKey);
      return int.tryParse(countStr ?? '0') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> logScreenView(String screenName) async {
    // Zero-knowledge privacy: No remote telemetry
  }

  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    // Zero-knowledge privacy: No remote telemetry
  }
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});
