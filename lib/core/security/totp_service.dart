import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/digests/sha1.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/api.dart';

class TotpService {
  static const String _base32Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

  /// Decodes a Base32 string to Uint8List.
  static Uint8List _decodeBase32(String base32) {
    final sanitized = base32.toUpperCase().replaceAll(' ', '').replaceAll('=', '');
    if (sanitized.isEmpty) return Uint8List(0);

    final List<int> bytes = [];
    int buffer = 0;
    int bitsCount = 0;

    for (var i = 0; i < sanitized.length; i++) {
      final char = sanitized[i];
      final val = _base32Chars.indexOf(char);
      if (val == -1) {
        throw FormatException('Invalid Base32 character: $char');
      }

      buffer = (buffer << 5) | val;
      bitsCount += 5;

      if (bitsCount >= 8) {
        bytes.add((buffer >> (bitsCount - 8)) & 0xff);
        bitsCount -= 8;
      }
    }
    return Uint8List.fromList(bytes);
  }

  /// Encodes a Uint8List to Base32 string.
  static String encodeBase32(Uint8List bytes) {
    if (bytes.isEmpty) return '';
    final buffer = StringBuffer();
    int val = 0;
    int bits = 0;
    for (var i = 0; i < bytes.length; i++) {
      val = (val << 8) | bytes[i];
      bits += 8;
      while (bits >= 5) {
        buffer.write(_base32Chars[(val >> (bits - 5)) & 31]);
        bits -= 5;
      }
    }
    if (bits > 0) {
      buffer.write(_base32Chars[(val << (5 - bits)) & 31]);
    }
    return buffer.toString();
  }

  /// Generates a cryptographically secure random Base32 secret (160-bit key, 20 bytes).
  static String generateSecret() {
    final random = Random.secure();
    final bytes = Uint8List.fromList(List.generate(20, (_) => random.nextInt(256)));
    return encodeBase32(bytes);
  }

  /// Computes the 6-digit TOTP code for a given secret and specific timestamp.
  static String getOtp(String secret, int timestampMs) {
    final keyBytes = _decodeBase32(secret);
    final counter = (timestampMs ~/ 1000) ~/ 30;

    // Convert counter to 8-byte big-endian array
    final counterBytes = Uint8List(8);
    var temp = counter;
    for (var i = 7; i >= 0; i--) {
      counterBytes[i] = temp & 0xff;
      temp >>= 8;
    }

    // Compute HMAC-SHA1
    final hmac = HMac(SHA1Digest(), 64)..init(KeyParameter(keyBytes));
    final hmacOutput = hmac.process(counterBytes);

    // Dynamic truncation
    final offset = hmacOutput[hmacOutput.length - 1] & 0x0f;
    final binary = ((hmacOutput[offset] & 0x7f) << 24) |
        ((hmacOutput[offset + 1] & 0xff) << 16) |
        ((hmacOutput[offset + 2] & 0xff) << 8) |
        (hmacOutput[offset + 3] & 0xff);

    final otpVal = binary % 1000000;
    return otpVal.toString().padLeft(6, '0');
  }

  /// Verifies a TOTP code against the secret key, allowing a time window of +/- 1 steps (30 seconds) for network/time drift.
  static bool verifyOtp(String secret, String code, {int? timestampMs}) {
    final cleanCode = code.trim().replaceAll(' ', '');
    if (cleanCode.length != 6) return false;

    final now = timestampMs ?? DateTime.now().millisecondsSinceEpoch;

    // Verify current step, previous step, and next step to handle clock drift
    for (var i = -1; i <= 1; i++) {
      final testTime = now + (i * 30 * 1000);
      if (getOtp(secret, testTime) == cleanCode) {
        return true;
      }
    }
    return false;
  }
}
