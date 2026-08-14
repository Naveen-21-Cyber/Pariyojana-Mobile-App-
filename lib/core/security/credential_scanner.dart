import 'package:flutter/material.dart';
import '../../shared_widgets/glass_snackbar.dart';

class CredentialScanner {
  static final List<RegExp> _patterns = [
    RegExp(r'ghp_[a-zA-Z0-9]{36}'), // GitHub PAT
    RegExp(r'gho_[a-zA-Z0-9]{36}'), // GitHub OAuth
    RegExp(r'github_pat_[a-zA-Z0-9]{22}_[a-zA-Z0-9]{59}'), // Fine-grained PAT
    RegExp(r'sk-[a-zA-Z0-9]{32,}'), // OpenAI API Key
    RegExp(r'AKIA[0-9A-Z]{16}'), // AWS Access Key ID
    RegExp(r'-----BEGIN (RSA|EC|PRIVATE) KEY-----'), // Private Key
    RegExp(r'xox[baprs]-[0-9a-zA-Z]{10,48}'), // Slack token
  ];

  /// Scans text for exposed credentials or secret keys.
  /// Returns `true` if a sensitive secret was detected, `false` otherwise.
  static bool scanAndAlert(BuildContext context, String text, {String fieldName = 'Text Field'}) {
    if (text.isEmpty) return false;

    for (final pattern in _patterns) {
      if (pattern.hasMatch(text)) {
        GlassSnackBar.show(
          context,
          '⚠️ SECURITY ALERT: Exposed secret API key or token detected in $fieldName! Please redact sensitive credentials before saving.',
          icon: Icons.security_rounded,
        );
        return true;
      }
    }
    return false;
  }
}
