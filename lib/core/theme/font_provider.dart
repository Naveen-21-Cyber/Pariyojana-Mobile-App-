import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppFontFamily {
  ubuntu('Ubuntu', 'Canonical Developer Standard — Default', 'Ubuntu'),
  sfPro('SF Pro', 'Apple Cupertino Clean Standard', 'SF Pro'),
  jetbrainsMono('JetBrains Mono', 'Elite Developer & Terminal Font', 'JetBrains Mono'),
  plusJakartaSans('Plus Jakarta Sans', 'Clean & Contemporary UI', 'Plus Jakarta Sans'),
  inter('Inter', 'Hyper-Legible Silicon Valley Standard', 'Inter'),
  sora('Sora', 'Crisp Futuristic Tech Sans', 'Sora'),
  unifora('Unifora', 'Editorial Serif — Cormorant Garamond', 'Unifora'),
  waltograph('Waltograph', 'Expressive Script — Pacifico', 'Waltograph');

  final String displayName;
  final String description;
  final String googleFontName;

  const AppFontFamily(this.displayName, this.description, this.googleFontName);
}

class AppFontNotifier extends StateNotifier<AppFontFamily> {
  static const _storageKey = 'user_preferred_font';
  final FlutterSecureStorage _storage;

  AppFontNotifier(this._storage) : super(AppFontFamily.ubuntu) {
    loadFont();
  }

  Future<void> loadFont() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefSaved = prefs.getString(_storageKey);
      if (prefSaved != null) {
        final match = AppFontFamily.values.firstWhere(
          (f) => f.name == prefSaved,
          orElse: () => AppFontFamily.ubuntu,
        );
        state = match;
        return;
      }
      final saved = await _storage.read(key: _storageKey);
      if (saved != null) {
        final match = AppFontFamily.values.firstWhere(
          (f) => f.name == saved,
          orElse: () => AppFontFamily.ubuntu,
        );
        state = match;
        await prefs.setString(_storageKey, saved);
      }
    } catch (_) {}
  }

  Future<void> setFont(AppFontFamily font) async {
    state = font;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, font.name);
      await _storage.write(key: _storageKey, value: font.name);
    } catch (_) {}
  }

  TextTheme buildTextTheme(TextTheme base) {
    return state.buildTextTheme(base);
  }
}

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final appFontProvider = StateNotifierProvider<AppFontNotifier, AppFontFamily>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AppFontNotifier(storage);
});

extension AppFontFamilyExt on AppFontFamily {
  TextTheme buildTextTheme(TextTheme base) {
    try {
      switch (this) {
        case AppFontFamily.ubuntu:
          return GoogleFonts.ubuntuTextTheme(base);
        case AppFontFamily.sfPro:
          // SF Pro not on Google Fonts — use Inter as best Cupertino match
          return GoogleFonts.interTextTheme(base);
        case AppFontFamily.jetbrainsMono:
          return GoogleFonts.jetBrainsMonoTextTheme(base);
        case AppFontFamily.plusJakartaSans:
          return GoogleFonts.plusJakartaSansTextTheme(base);
        case AppFontFamily.inter:
          return GoogleFonts.interTextTheme(base);
        case AppFontFamily.sora:
          return GoogleFonts.soraTextTheme(base);
        case AppFontFamily.unifora:
          // Unifora is proprietary — Cormorant Garamond is the best free editorial serif match
          return GoogleFonts.cormorantGaramondTextTheme(base);
        case AppFontFamily.waltograph:
          // Waltograph is proprietary — Pacifico is the best free expressive script match
          return GoogleFonts.pacificoTextTheme(base);
      }
    } catch (_) {
      return base;
    }
  }

  TextStyle getPreviewTextStyle(BuildContext context) {
    try {
      final theme = buildTextTheme(Theme.of(context).textTheme);
      return theme.titleMedium ?? const TextStyle();
    } catch (_) {
      return const TextStyle();
    }
  }

  String? get resolvedFontFamily {
    try {
      return buildTextTheme(const TextTheme()).bodyMedium?.fontFamily;
    } catch (_) {
      return null;
    }
  }
}
