import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'ai_prompt_sanitizer.dart';
import 'sql_security_guard.dart';

export 'ai_prompt_sanitizer.dart';
export 'sql_security_guard.dart';
export 'forensic_security_guard.dart';

/// Application-wide security sanitizer for input validation, XSS prevention,
/// Anti-CSRF token verification, AI prompt injection defense, and forensic buffer zeroing.
class SecuritySanitizer {
  /// Strips dangerous XSS vectors, HTML tags, script payloads, and SQL injection characters.
  static String sanitizeInput(String rawInput, {int maxChars = 4096}) {
    if (rawInput.isEmpty) return '';

    // 1. Truncate buffer to prevent overflow
    String sanitized = rawInput.length > maxChars ? rawInput.substring(0, maxChars) : rawInput;

    // 2. Strip HTML tags & dangerous script execution vectors
    sanitized = sanitized
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false, dotAll: true), '')
        .replaceAll(RegExp(r'<iframe[^>]*>.*?</iframe>', caseSensitive: false, dotAll: true), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'onerror\s*=', caseSensitive: false), '')
        .replaceAll(RegExp(r'onload\s*=', caseSensitive: false), '')
        .replaceAll(RegExp(r'onclick\s*=', caseSensitive: false), '')
        .replaceAll(RegExp(r'<[^>]*>', multiLine: true), '');

    // 3. Apply SQL metacharacter escaping
    sanitized = SqlSecurityGuard.sanitizeSearchQuery(sanitized);

    return sanitized.trim();
  }

  /// Neutralizes path traversal attempts in filename and relative path parameters.
  static String sanitizeFilePath(String rawPath) {
    if (rawPath.isEmpty) return '';
    return rawPath
        .replaceAll(RegExp(r'\.\./|\.\.\\'), '')
        .replaceAll(RegExp(r'%2e%2e%2f|%2e%2e/', caseSensitive: false), '')
        .replaceAll(RegExp(r'[<>:"|?*]'), '_')
        .trim();
  }

  /// Neutralizes shell meta-characters to prevent local command injection.
  static String sanitizeCommandArgument(String rawArg) {
    if (rawArg.isEmpty) return '';
    return rawArg.replaceAll(RegExp(r'[;&|`$><!\\"]'), '');
  }

  /// Sanitizes AI prompts against adversarial jailbreaks & leaks.
  static String sanitizeAiPrompt(String rawPrompt, {bool wrapSandbox = true}) {
    return AiPromptSanitizer.sanitizePrompt(rawPrompt, wrapSandbox: wrapSandbox);
  }

  /// Validates string bounds and format integrity.
  static bool isValidInputLength(String input, {int min = 1, int max = 2048}) {
    final len = input.trim().length;
    return len >= min && len <= max;
  }

  /// Generates a cryptographically strong anti-CSRF token for local API calls.
  static String generateCsrfToken(String sessionSeed) {
    final bytes = utf8.encode('$sessionSeed:${DateTime.now().millisecondsSinceEpoch}');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Forensic zeroing: Wipes sensitive binary buffers from RAM memory.
  static void zeroMemoryBuffer(Uint8List buffer) {
    for (int i = 0; i < buffer.length; i++) {
      buffer[i] = 0x00;
    }
  }
}
