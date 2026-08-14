import 'package:flutter/services.dart';

class AndroidWidgetService {
  static const MethodChannel _channel = MethodChannel('com.pariyojana.app/widget');

  /// Notify native Android Home Screen App Widget to refresh state
  static Future<void> updateWidgetData({required int ideaCount, required int projectCount}) async {
    try {
      await _channel.invokeMethod('updateWidget', {
        'ideaCount': ideaCount,
        'projectCount': projectCount,
      });
    } on PlatformException catch (_) {
      // Graceful fallback on non-Android or missing native channel
    }
  }
}
