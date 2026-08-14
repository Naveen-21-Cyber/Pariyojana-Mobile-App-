import 'package:flutter_test/flutter_test.dart';
import 'package:velvet/core/security/totp_service.dart';

void main() {
  group('TOTP Service Unit Tests', () {
    const testSecret = 'JBSWY3DPEHPK3PXP'; // Base32 encoded string of "Hello!"

    test('generateSecret returns a valid 32-character Base32 secret', () {
      final secret = TotpService.generateSecret();
      expect(secret.length, 32);
      expect(RegExp(r'^[A-Z2-7]+$').hasMatch(secret), true);
    });

    test('getOtp generates different codes for different time steps', () {
      const time1 = 1719878400000; // Mon Jul 01 2024 16:00:00 GMT
      const time2 = time1 + 30000; // Mon Jul 01 2024 16:00:30 GMT (next step)

      final code1 = TotpService.getOtp(testSecret, time1);
      final code2 = TotpService.getOtp(testSecret, time2);

      expect(code1.length, 6);
      expect(code2.length, 6);
      expect(code1 != code2, true);
    });

    test('verifyOtp accepts code with time steps within clock drift window', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final currentCode = TotpService.getOtp(testSecret, now);

      // Verify current code
      expect(TotpService.verifyOtp(testSecret, currentCode, timestampMs: now), true);

      // Verify code with 30s clock drift (previous step)
      final pastCode = TotpService.getOtp(testSecret, now - 30000);
      expect(TotpService.verifyOtp(testSecret, pastCode, timestampMs: now), true);

      // Verify invalid code
      expect(TotpService.verifyOtp(testSecret, '000000', timestampMs: now), false);
    });
  });
}
