import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static const _sessionKey = 'velvet_firebase_session_count';

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Returns true if Firebase has been initialized successfully.
  bool get isInitialized {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> logAppOpen() async {
    try {
      await _analytics.logAppOpen();
      // Increment real session count in secure storage
      const storage = FlutterSecureStorage();
      final countStr = await storage.read(key: _sessionKey);
      final current = int.tryParse(countStr ?? '0') ?? 0;
      await storage.write(key: _sessionKey, value: '${current + 1}');
    } catch (e) {
      debugPrint('Analytics logAppOpen error: $e');
    }
  }

  /// Returns real cumulative session count (across all launches on this device).
  Future<int> getSessionCount() async {
    try {
      const storage = FlutterSecureStorage();
      final countStr = await storage.read(key: _sessionKey);
      return int.tryParse(countStr ?? '0') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (e) {
      debugPrint('Analytics logScreenView error: $e');
    }
  }

  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      debugPrint('Analytics logEvent error: $e');
    }
  }
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});
