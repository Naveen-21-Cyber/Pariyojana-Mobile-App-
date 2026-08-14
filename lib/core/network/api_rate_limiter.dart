import 'package:flutter/material.dart';
import '../../shared_widgets/glass_snackbar.dart';

class ApiRateLimiter {
  static const int maxRequestsPerMinute = 5;
  static final List<DateTime> _requestTimestamps = [];

  /// Returns `true` if the request is allowed, or `false` if rate limit (5 req/min) is exceeded.
  /// Automatically shows a user-friendly GlassSnackBar warning if rate limited.
  static bool checkAndConsume(BuildContext? context, {String featureName = 'API Service'}) {
    final now = DateTime.now();
    _requestTimestamps.removeWhere((ts) => now.difference(ts).inSeconds >= 60);

    if (_requestTimestamps.length >= maxRequestsPerMinute) {
      final oldest = _requestTimestamps.first;
      final waitSeconds = 60 - now.difference(oldest).inSeconds;

      if (context != null && context.mounted) {
        GlassSnackBar.show(
          context,
          '⚠️ Rate Limit (5 req/min): Please wait $waitSeconds sec before requesting $featureName again.',
          icon: Icons.hourglass_top_rounded,
          iconColor: Colors.amber,
        );
      }
      return false;
    }

    _requestTimestamps.add(now);
    return true;
  }
}
