import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppFontFamily {
  outfit('Outfit', 'Modern & Geometric (Default)', 'Outfit'),
  plusJakartaSans('Plus Jakarta Sans', 'Clean & Contemporary UI', 'Plus Jakarta Sans'),
  inter('Inter', 'Hyper-Legible Silicon Valley Standard', 'Inter'),
  urbanist('Urbanist', 'Ultra-Sleek Modernist Sans', 'Urbanist'),
  sora('Sora', 'Crisp Futuristic Tech Sans', 'Sora'),
  manrope('Manrope', 'Premium Minimalist Fintech Style', 'Manrope'),
  jetbrainsMono('JetBrains Mono', 'Elite Developer & Terminal Font', 'JetBrains Mono');

  final String displayName;
  final String description;
  final String googleFontName;

  const AppFontFamily(this.displayName, this.description, this.googleFontName);
}

class AppFontNotifier extends StateNotifier<AppFontFamily> {
  static const _storageKey = 'user_preferred_font';
  final FlutterSecureStorage _storage;

  AppFontNotifier(this._storage) : super(AppFontFamily.outfit) {
    loadFont();
  }

  Future<void> loadFont() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefSaved = prefs.getString(_storageKey);
      if (prefSaved != null) {
        final match = AppFontFamily.values.firstWhere(
          (f) => f.name == prefSaved,
          orElse: () => AppFontFamily.outfit,
        );
        state = match;
        return;
      }
      final saved = await _storage.read(key: _storageKey);
      if (saved != null) {
        final match = AppFontFamily.values.firstWhere(
          (f) => f.name == saved,
          orElse: () => AppFontFamily.outfit,
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
    switch (state) {
      case AppFontFamily.outfit:
        return GoogleFonts.outfitTextTheme(base);
      case AppFontFamily.plusJakartaSans:
        return GoogleFonts.plusJakartaSansTextTheme(base);
      case AppFontFamily.inter:
        return GoogleFonts.interTextTheme(base);
      case AppFontFamily.urbanist:
        return GoogleFonts.urbanistTextTheme(base);
      case AppFontFamily.sora:
        return GoogleFonts.soraTextTheme(base);
      case AppFontFamily.manrope:
        return GoogleFonts.manropeTextTheme(base);
      case AppFontFamily.jetbrainsMono:
        return GoogleFonts.jetBrainsMonoTextTheme(base);
    }
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
    switch (this) {
      case AppFontFamily.outfit:
        return GoogleFonts.outfitTextTheme(base);
      case AppFontFamily.plusJakartaSans:
        return GoogleFonts.plusJakartaSansTextTheme(base);
      case AppFontFamily.inter:
        return GoogleFonts.interTextTheme(base);
      case AppFontFamily.urbanist:
        return GoogleFonts.urbanistTextTheme(base);
      case AppFontFamily.sora:
        return GoogleFonts.soraTextTheme(base);
      case AppFontFamily.manrope:
        return GoogleFonts.manropeTextTheme(base);
      case AppFontFamily.jetbrainsMono:
        return GoogleFonts.jetBrainsMonoTextTheme(base);
    }
  }
}
