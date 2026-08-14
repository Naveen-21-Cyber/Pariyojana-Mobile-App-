import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

/// Centralized haptic feedback service using native Vibration API.
/// Flutter's HapticFeedback.vibrate() is unreliable on many Android
/// devices (Nothing A142, Pixels with custom ROMs, etc.).
/// This uses the `vibration` plugin which calls Android's Vibrator
/// service directly with configurable duration/pattern.
class HapticService {
  bool _hasVibrator = false;
  bool _hasAmplitudeControl = false;

  /// Initialize and check device capabilities.
  Future<void> initialize() async {
    _hasVibrator = await Vibration.hasVibrator() == true;
    _hasAmplitudeControl = await Vibration.hasAmplitudeControl() == true;
  }

  /// Light tap — for button presses, list item taps.
  Future<void> lightTap() async {
    if (!_hasVibrator) return;
    if (_hasAmplitudeControl) {
      await Vibration.vibrate(duration: 30, amplitude: 60);
    } else {
      await Vibration.vibrate(duration: 30);
    }
  }

  /// Medium impact — for card tap, selection confirmations.
  Future<void> mediumImpact() async {
    if (!_hasVibrator) return;
    if (_hasAmplitudeControl) {
      await Vibration.vibrate(duration: 50, amplitude: 128);
    } else {
      await Vibration.vibrate(duration: 50);
    }
  }

  /// Heavy impact — for long press, important actions.
  Future<void> heavyImpact() async {
    if (!_hasVibrator) return;
    if (_hasAmplitudeControl) {
      await Vibration.vibrate(duration: 80, amplitude: 200);
    } else {
      await Vibration.vibrate(duration: 80);
    }
  }

  /// Double pulse — for double tap actions (quick reveal).
  Future<void> doublePulse() async {
    if (!_hasVibrator) return;
    // pattern: [pause, vibrate, pause, vibrate]
    await Vibration.vibrate(pattern: [0, 60, 80, 60]);
  }

  /// Success pattern — 3 quick pulses for task completion.
  Future<void> successPattern() async {
    if (!_hasVibrator) return;
    await Vibration.vibrate(pattern: [0, 40, 60, 40, 60, 40]);
  }

  /// Warning pulse — single long rumble for alerts.
  Future<void> warningPulse() async {
    if (!_hasVibrator) return;
    if (_hasAmplitudeControl) {
      await Vibration.vibrate(duration: 200, amplitude: 255);
    } else {
      await Vibration.vibrate(duration: 200);
    }
  }

  /// Notification buzz — distinct pattern for push notifications.
  Future<void> notificationBuzz() async {
    if (!_hasVibrator) return;
    await Vibration.vibrate(pattern: [0, 100, 200, 100]);
  }

  /// Error/rejection haptic.
  Future<void> errorBuzz() async {
    if (!_hasVibrator) return;
    await Vibration.vibrate(pattern: [0, 80, 60, 80, 60, 120]);
  }

  /// Long-press reveal pattern — ascending intensity.
  Future<void> jokeReveal() async {
    if (!_hasVibrator) return;
    if (_hasAmplitudeControl) {
      await Vibration.vibrate(
        pattern: [0, 30, 50, 50, 50, 80],
        intensities: [0, 50, 0, 120, 0, 255],
      );
    } else {
      await Vibration.vibrate(pattern: [0, 30, 50, 50, 50, 80]);
    }
  }

  /// Cancel any ongoing vibration.
  Future<void> cancel() async {
    await Vibration.cancel();
  }
}

final hapticServiceProvider = Provider<HapticService>((ref) {
  return HapticService();
});
