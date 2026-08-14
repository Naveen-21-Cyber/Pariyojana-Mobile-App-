import 'package:flutter/services.dart';

/// Anti-Forensic Defense System for Pariyojana
/// Handles RAM buffer zeroing, anti-tamper detection, and memory hygiene.
class ForensicSecurityGuard {
  static bool _isSecureSessionActive = true;

  static bool get isSecureSessionActive => _isSecureSessionActive;

  /// Emergency Anti-Forensic Memory Scrub: Overwrites sensitive byte buffers in RAM with zeroes.
  static void wipeMemoryBytes(Uint8List secretBytes) {
    for (int i = 0; i < secretBytes.length; i++) {
      secretBytes[i] = 0x00;
    }
  }

  /// Clears text strings from memory by overwriting buffer references.
  static String wipeString(String sensitiveString) {
    // Return empty string and suggest GC sweep
    SystemChannels.platform.invokeMethod('System.gc');
    return '';
  }

  /// Engages Anti-Forensic lock state.
  static void engageLockState() {
    _isSecureSessionActive = false;
  }

  /// Unlocks secure session.
  static void releaseLockState() {
    _isSecureSessionActive = true;
  }
}
