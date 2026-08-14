import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:translator/translator.dart';
import '../security/secure_storage_service.dart';
import '../security/auth_service.dart';

// --- Google Translator singleton --------------------------------------------

final googleTranslatorProvider = Provider<GoogleTranslator>((ref) {
  return GoogleTranslator();
});

// --- Supported Languages ----------------------------------------------------

class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  const AppLanguage({required this.code, required this.name, required this.nativeName});
}

const List<AppLanguage> kSupportedLanguages = [
  AppLanguage(code: 'sa',    name: 'Sanskrit',             nativeName: 'संस्कृतम्'),
  AppLanguage(code: 'en',    name: 'English',              nativeName: 'English'),
  AppLanguage(code: 'hi',    name: 'Hindi',                nativeName: 'हिन्दी'),
  AppLanguage(code: 'kn',    name: 'Kannada',              nativeName: 'ಕನ್ನಡ'),
  AppLanguage(code: 'bn',    name: 'Bengali',              nativeName: 'বাংলা'),
  AppLanguage(code: 'mr',    name: 'Marathi',              nativeName: 'मराठी'),
  AppLanguage(code: 'gu',    name: 'Gujarati',             nativeName: 'ગુજરાતી'),
  AppLanguage(code: 'ta',    name: 'Tamil',                nativeName: 'தமிழ்'),
  AppLanguage(code: 'te',    name: 'Telugu',               nativeName: 'తెలుగు'),
  AppLanguage(code: 'ml',    name: 'Malayalam',            nativeName: 'മലയാളം'),
  AppLanguage(code: 'as',    name: 'Assamese',             nativeName: 'অসমীয়া'),
  AppLanguage(code: 'ks',    name: 'Kashmiri',             nativeName: 'كشميري'),
  AppLanguage(code: 'haryanvi', name: 'Haryanvi',          nativeName: 'हरयाणवी'),
  AppLanguage(code: 'bho',   name: 'Bihari (Bhojpuri)',    nativeName: 'भोजपुरी'),
  AppLanguage(code: 'ja',    name: 'Japanese',             nativeName: '日本語'),
  AppLanguage(code: 'zh-tw', name: 'Chinese (Traditional)',nativeName: '繁體中文'),
  AppLanguage(code: 'fr',    name: 'French',               nativeName: 'Français'),
  AppLanguage(code: 'es',    name: 'Spanish',              nativeName: 'Español'),
  AppLanguage(code: 'pt',    name: 'Portuguese',           nativeName: 'Português'),
  AppLanguage(code: 'de',    name: 'German',               nativeName: 'Deutsch'),
  AppLanguage(code: 'ru',    name: 'Russian',              nativeName: 'Русский'),
  AppLanguage(code: 'ar',    name: 'Arabic',               nativeName: 'العربية'),
  AppLanguage(code: 'ko',    name: 'Korean',               nativeName: '한국어'),
  AppLanguage(code: 'it',    name: 'Italian',              nativeName: 'Italiano'),
  AppLanguage(code: 'nl',    name: 'Dutch',                nativeName: 'Nederlands'),
  AppLanguage(code: 'tr',    name: 'Turkish',              nativeName: 'Türkçe'),
  AppLanguage(code: 'vi',    name: 'Vietnamese',           nativeName: 'Tiếng Việt'),
  AppLanguage(code: 'th',    name: 'Thai',                 nativeName: 'ไทย'),
  AppLanguage(code: 'id',    name: 'Indonesian',           nativeName: 'Bahasa Indonesia'),
  AppLanguage(code: 'pl',    name: 'Polish',               nativeName: 'Polski'),
];

// --- Language State ---------------------------------------------------------

const _languageKey = 'pariyojana_selected_language';

class LanguageNotifier extends StateNotifier<String> {
  final SecureStorageService _storage;

  LanguageNotifier({required SecureStorageService storage})
      : _storage = storage,
        super('en') {
    _loadLang();
  }

  Future<void> _loadLang() async {
    final lang = await _storage.readSetting(_languageKey);
    state = lang ?? 'en';
  }

  Future<void> changeLanguage(String langCode) async {
    await _storage.writeSetting(_languageKey, langCode);
    state = langCode;
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return LanguageNotifier(storage: storage);
});

// --- Memory Translation Cache & Offline Fallbacks --------------------------

final Map<String, String> _translationCache = {};

const Map<String, Map<String, String>> _offlineDictionary = {
  'ml': {
    'Settings': 'ക്രമീകരണങ്ങൾ',
    'Projects': 'പദ്ധതികൾ',
    'Idea Vault': 'ആശയങ്ങളുടെ കലവറ',
    'Research Papers': 'ഗവേഷണ പ്രബന്ധങ്ങൾ',
    'Job Applications': 'ജോലി അപേക്ഷകൾ',
    'Sync Now': 'ഇപ്പോൾ സിങ്ക് ചെയ്യുക',
    'Personalization': 'വ്യക്തിഗതമാക്കൽ',
    'Security Settings': 'സുരക്ഷാ ക്രമീകരണങ്ങൾ',
    'Developer Profile': 'ഡെവലപ്പർ പ്രൊഫൈൽ',
    'About Developer': 'ഡെവലപ്പറെക്കുറിച്ച്',
    'User Profile': 'ഉപയോക്തൃ പ്രൊഫൈൽ',
  },
  'haryanvi': {
    'Settings': 'സെറ്റിങ്സ് (सेटिंग्स)',
    'Projects': 'काम-काज (प्रोजेक्ट्स)',
    'Idea Vault': 'विचारों का ख़ज़ाना',
    'Research Papers': 'शोध पत्र',
    'Job Applications': 'नौकरी के फ़ॉर्म',
    'Sync Now': 'इब सिंक करो',
    'Personalization': 'पसंद संवारो',
    'Security Settings': 'सुरक्षा सेटिंग्स',
    'Developer Profile': 'डेवलपर प्रोफाइल',
    'About Developer': 'डेवलपर के बारे में',
    'User Profile': 'यूज़र प्रोफाइल',
  },
  'zh-tw': {
    'Settings': '設定',
    'Projects': '專案項目',
    'Idea Vault': '靈感寶庫',
    'Research Papers': '研究論文',
    'Job Applications': '求職申請',
    'Sync Now': '立即同步',
    'Personalization': '個人化設定',
    'Security Settings': '安全性設定',
    'Developer Profile': '開發者檔案',
    'About Developer': '關於開發者',
    'User Profile': '使用者檔案',
  },
};

// --- Translation FutureProvider --------------------------------------------

final translationProvider = FutureProvider.family<String, String>((ref, text) async {
  final currentLang = ref.watch(languageProvider);
  if (currentLang == 'en' || text.trim().isEmpty) return text;

  final cacheKey = '$currentLang:$text';
  if (_translationCache.containsKey(cacheKey)) {
    return _translationCache[cacheKey]!;
  }

  final normLang = currentLang == 'haryanvi' ? 'hi' : currentLang.toLowerCase();

  // Check offline dictionary first
  if (_offlineDictionary.containsKey(currentLang) &&
      _offlineDictionary[currentLang]!.containsKey(text)) {
    final cached = _offlineDictionary[currentLang]![text]!;
    _translationCache[cacheKey] = cached;
    return cached;
  }

  final translator = ref.watch(googleTranslatorProvider);
  try {
    final result = await translator.translate(text, to: normLang);
    _translationCache[cacheKey] = result.text;
    return result.text;
  } catch (_) {
    return text;
  }
});

// --- TranslatedText Widget -------------------------------------------------

/// Drop-in replacement for [Text] that auto-translates using [languageProvider].
class TranslatedText extends ConsumerWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translation = ref.watch(translationProvider(text));
    return translation.when(
      data: (t) => Text(t, style: style, textAlign: textAlign, maxLines: maxLines, overflow: overflow),
      loading: () => Text(text, style: style?.copyWith(color: style?.color?.withValues(alpha: 0.5)), textAlign: textAlign, maxLines: maxLines, overflow: overflow),
      error: (_, __) => Text(text, style: style, textAlign: textAlign, maxLines: maxLines, overflow: overflow),
    );
  }
}
