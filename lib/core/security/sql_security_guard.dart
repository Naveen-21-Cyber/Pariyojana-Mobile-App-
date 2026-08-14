/// Defense against SQL Injection, raw query manipulation, and wildcard attacks.
class SqlSecurityGuard {
  static final List<RegExp> _sqlInjectionPatterns = [
    RegExp(r"(\%27)|(\')|(\-\-)|(\%23)|(#)", caseSensitive: false),
    RegExp(r"((\%3D)|(=))[^\n]*((%27)|(\')|(\-\-)|(\%3B)|(;))", caseSensitive: false),
    RegExp(r"\w*((\%27)|(\'))(\s*)((\%6F)|o|(\%4F))((\%72)|r|(\%52))", caseSensitive: false),
    RegExp(r'exec(\s|\+)+(s|x)p\w+', caseSensitive: false),
    RegExp(r'UNION(\s+ALL)?\s+SELECT', caseSensitive: false),
    RegExp(r'DROP\s+TABLE', caseSensitive: false),
    RegExp(r'INSERT\s+INTO', caseSensitive: false),
    RegExp(r'DELETE\s+FROM', caseSensitive: false),
  ];

  /// Escapes dangerous SQL injection metacharacters from user search input.
  static String sanitizeSearchQuery(String input) {
    if (input.trim().isEmpty) return '';

    String safeQuery = input;

    // 1. Neutralize SQL Injection patterns
    for (final pattern in _sqlInjectionPatterns) {
      safeQuery = safeQuery.replaceAll(pattern, '');
    }

    // 2. Escape SQL LIKE wildcards
    safeQuery = safeQuery
        .replaceAll("'", "''")
        .replaceAll('\\', '\\\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');

    return safeQuery.trim();
  }
}
