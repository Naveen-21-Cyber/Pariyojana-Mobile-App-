import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeAccent {
  velvetCocoa,
  sunsetOrange,
  pureWhite,
  warmLatte,
  cyberObsidian,
  vedicGold,
  emeraldMint,
}

// ── Persistent Theme Mode ─────────────────────────────────────────────────────

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const _key = 'pariyojana_theme_mode';
  final FlutterSecureStorage _storage;

  ThemeModeNotifier(this._storage) : super(ThemeMode.light) {
    load();
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefSaved = prefs.getString(_key);
      if (prefSaved != null) {
        state = prefSaved == 'dark' ? ThemeMode.dark : ThemeMode.light;
        return;
      }
      final saved = await _storage.read(key: _key);
      if (saved != null) {
        state = saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
        await prefs.setString(_key, saved);
      }
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final val = mode == ThemeMode.dark ? 'dark' : 'light';
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, val);
      await _storage.write(key: _key, value: val);
    } catch (_) {}
  }

  Future<void> setMode(ThemeMode mode) => setThemeMode(mode);
}

final appThemeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(const FlutterSecureStorage());
});

// ── Persistent Theme Accent ───────────────────────────────────────────────────

class ThemeAccentNotifier extends StateNotifier<ThemeAccent> {
  static const _key = 'pariyojana_theme_accent';
  final FlutterSecureStorage _storage;

  ThemeAccentNotifier(this._storage) : super(ThemeAccent.sunsetOrange) {
    load();
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefSaved = prefs.getString(_key);
      if (prefSaved != null) {
        state = ThemeAccent.values.firstWhere(
          (a) => a.name == prefSaved,
          orElse: () => ThemeAccent.sunsetOrange,
        );
        return;
      }
      final saved = await _storage.read(key: _key);
      if (saved != null) {
        state = ThemeAccent.values.firstWhere(
          (a) => a.name == saved,
          orElse: () => ThemeAccent.sunsetOrange,
        );
        await prefs.setString(_key, saved);
      }
    } catch (_) {}
  }

  Future<void> setAccent(ThemeAccent accent) async {
    state = accent;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, accent.name);
      await _storage.write(key: _key, value: accent.name);
    } catch (_) {}
  }
}

final themeAccentProvider = StateNotifierProvider<ThemeAccentNotifier, ThemeAccent>((ref) {
  return ThemeAccentNotifier(const FlutterSecureStorage());
});

class VelvetColors {
  VelvetColors._();

  static const Color cream = Color(0xFFF5EBE0);       // warm page bg
  static const Color coralPeach = Color(0xFFFF6B4A);  // accent — deeper coral
  static const Color periwinkle = Color(0xFF7C8FFF);  // accent — richer periwinkle
  static const Color cocoa = Color(0xFF3D2B1F);       // deep espresso — strong contrast
  static const Color clayTan = Color(0xFFC4A98A);     // borders — visible but warm
  static const Color mint = Color(0xFF2DB88E);        // action green — vivid

  // Dark mode surfaces — Elevated Cyber Obsidian Slate
  static const Color darkBg = Color(0xFF090D16);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkText = Color(0xFFF8FAFC);

  // Design system helpers
  static const Color glassBorder = Color(0x1F6B4F4F);
  static const Color glassFill = Color(0x0F6B4F4F);

  // ─── Context-aware helpers ────────────────────────────────────────────────

  /// Returns darkBg in dark mode, cream in light mode.
  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkBg : cream;
  }

  /// Returns dark surface in dark mode, cream in light mode.
  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkSurface : cream;
  }

  /// Slightly elevated card surface in dark mode, white in light mode for contrast against cream bg.
  static Color cardSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkCard : Colors.white;
  }

  /// High-contrast text in dark mode, cocoa in light mode.
  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkText : cocoa;
  }

  /// Subdued text in dark mode, dark espresso 65% in light mode — still readable.
  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkText.withValues(alpha: 0.65)
        : const Color(0xFF6B5040); // warm medium brown
  }

  /// High-contrast primary text helper — returns white in dark mode, cocoa in light mode.
  static Color cocoaText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkText : cocoa;
  }

  /// Subtle divider/border in dark mode, clayTan in light mode.
  static Color border(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? Colors.white12 : clayTan;
  }

  /// Input field fill — darkCard in dark mode, white in light mode.
  static Color inputFill(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkCard : Colors.white;
  }

  /// Chip/tag background — subtle white12 in dark mode, warm off-white in light mode.
  static Color chipBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : const Color(0xFFF0EBE5);
  }

  /// Dropdown / popup menu fill — darkSurface in dark mode, cream in light mode.
  static Color dropdownFill(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkSurface : cream;
  }

  /// Icon color — light grey in dark mode, cocoa in light mode.
  static Color iconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFE6EDF3)
        : cocoa;
  }

  // ─── Theme Accent Palette ─────────────────────────────────────────────────
  static Color getAccentColor(ThemeAccent accent) {
    switch (accent) {
      case ThemeAccent.velvetCocoa:
        return coralPeach;
      case ThemeAccent.sunsetOrange:
        return const Color(0xFFFF6D00);
      case ThemeAccent.pureWhite:
        return const Color(0xFFF8FAFC);
      case ThemeAccent.warmLatte:
        return const Color(0xFFD7CCC8);
      case ThemeAccent.cyberObsidian:
        return const Color(0xFF00E5FF);
      case ThemeAccent.vedicGold:
        return const Color(0xFFD4AF37);
      case ThemeAccent.emeraldMint:
        return const Color(0xFF10B981);
    }
  }
}
