/// Defense against AI Prompt Injection, Adversarial Jailbreaks, API Key leakage,
/// AND Token-Efficiency Optimization for ultra-fast, low-cost LLM responses.
class AiPromptSanitizer {
  // Dangerous prompt injection & jailbreak attack patterns
  static final List<RegExp> _adversarialPatterns = [
    RegExp(r'ignore\s+(all\s+)?(previous|prior|above)\s+instructions?', caseSensitive: false),
    RegExp(r'you\s+are\s+now\s+an?\s+(unrestricted|unfiltered|jailbroken|DAN|developer\s+mode)\s+AI', caseSensitive: false),
    RegExp(r'system\s+override', caseSensitive: false),
    RegExp(r'print\s+(system\s+prompt|api\s*key|secret|password|master\s*pin)', caseSensitive: false),
    RegExp(r'reveal\s+(your\s+)?(system\s+prompt|instructions?|guidelines?)', caseSensitive: false),
    RegExp(r'output\s+(your\s+)?initial\s+(prompt|instructions?)', caseSensitive: false),
    RegExp(r'repeat\s+(all\s+)?(words\s+above|previous\s+text)', caseSensitive: false),
    RegExp(r'bypass\s+security\s+filters', caseSensitive: false),
    RegExp(r'forget\s+(all\s+)?safety\s+rules', caseSensitive: false),
    RegExp(r'do\s+anything\s+now', caseSensitive: false),
    RegExp(r'enable\s+(sudo|god|unrestricted)\s+mode', caseSensitive: false),
    RegExp(r'</?(user_input_sandbox|system|context|im_start|im_end|INST|SYS)>', caseSensitive: false),
    RegExp(r'\[SYSTEM\s+PROMPT\]', caseSensitive: false),
    RegExp(r'\[INST\]|\[/INST\]|<<SYS>>|<</SYS>>', caseSensitive: false),
  ];

  // Regex patterns for detecting and redacting API keys & tokens
  static final List<RegExp> _secretPatterns = [
    RegExp(r'sk-or-v1-[A-Za-z0-9]{40,70}'), // OpenRouter API Key
    RegExp(r'gsk_[A-Za-z0-9]{40,70}'), // Groq API Key
    RegExp(r'sk-ant-[A-Za-z0-9-_]{70,120}'), // Anthropic API Key
    RegExp(r'AIzaSy[A-Za-z0-9_-]{33}'), // Google Gemini API Key
    RegExp(r'sk-(proj-)?[A-Za-z0-9-_]{32,80}'), // OpenAI Key
    RegExp(r'ghp_[A-Za-z0-9]{36}'), // GitHub Classic PAT
    RegExp(r'github_pat_[A-Za-z0-9_]{70,95}'), // GitHub Fine-grained PAT
    RegExp(r'eyJ[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+'), // JWT Token
    RegExp(r'AKIA[0-9A-Z]{16}'), // AWS Access Key
  ];

  /// Token Efficiency Compressor: Collapses redundant spaces, double newlines,
  /// and conversational fluff to minimize token consumption and reduce API latency.
  static String compressPromptTokens(String rawText, {int maxTokensEstimate = 1200}) {
    if (rawText.trim().isEmpty) return '';

    String compressed = rawText
        .replaceAll(RegExp(r'\r\n|\r'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
        .trim();

    // Approximate token limit truncation (~4 chars per token)
    final maxChars = maxTokensEstimate * 4;
    if (compressed.length > maxChars) {
      compressed = compressed.substring(0, maxChars);
    }

    return compressed;
  }

  /// Sanitizes user prompts for LLM queries, stripping adversarial injections, API keys,
  /// and applying token compression.
  static String sanitizePrompt(String rawPrompt, {bool wrapSandbox = true, bool compressTokens = true}) {
    if (rawPrompt.trim().isEmpty) return '';

    String cleanPrompt = compressTokens ? compressPromptTokens(rawPrompt) : rawPrompt;

    // 1. Redact any sensitive API keys or credentials
    for (final secretRegex in _secretPatterns) {
      cleanPrompt = cleanPrompt.replaceAllMapped(secretRegex, (match) {
        final keyStr = match.group(0) ?? '';
        final prefix = keyStr.length > 6 ? keyStr.substring(0, 6) : 'KEY';
        return '[REDACTED_SECRET_${prefix}_***]';
      });
    }

    // 2. Neutralize adversarial prompt injection attack directives
    for (final injectionRegex in _adversarialPatterns) {
      cleanPrompt = cleanPrompt.replaceAllMapped(injectionRegex, (match) {
        return '[NEUTRALIZED_PROMPT_INJECTION_ATTACK]';
      });
    }

    // 3. Enclose prompt in sandbox boundary tags if requested
    if (wrapSandbox) {
      return '<user_input_sandbox>\n$cleanPrompt\n</user_input_sandbox>';
    }

    return cleanPrompt;
  }

  /// System prompt suffix enforcing token-dense concise output format.
  static const String tokenEfficiencySystemInstruction =
      '\n[SYSTEM CONSTRAINT: Be dense, token-efficient, and direct. Respond in bullet points without conversational fluff.]';
}
