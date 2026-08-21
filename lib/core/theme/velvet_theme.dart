import 'package:flutter/material.dart';
import 'velvet_colors.dart';
import 'font_provider.dart';

class VelvetTheme {
  VelvetTheme._();

  static ThemeData get lightTheme => getTheme(ThemeAccent.velvetCocoa);
  static ThemeData get darkTheme => getDarkTheme(ThemeAccent.cyberObsidian);

  static TextTheme _buildCleanTextTheme(TextTheme base, Color textColor, AppFontFamily font) {
    final fontTheme = font.buildTextTheme(base);
    return fontTheme.copyWith(
      displayLarge: fontTheme.displayLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.0,
      ),
      displayMedium: fontTheme.displayMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.0,
      ),
      displaySmall: fontTheme.displaySmall?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.0,
      ),
      headlineLarge: fontTheme.headlineLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.0,
      ),
      headlineMedium: fontTheme.headlineMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
      ),
      headlineSmall: fontTheme.headlineSmall?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
      ),
      titleLarge: fontTheme.titleLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
      titleMedium: fontTheme.titleMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      titleSmall: fontTheme.titleSmall?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      bodyLarge: fontTheme.bodyLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
      ),
      bodyMedium: fontTheme.bodyMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
      ),
      bodySmall: fontTheme.bodySmall?.copyWith(
        color: textColor.withValues(alpha: 0.75),
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
      ),
      labelLarge: fontTheme.labelLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.25,
      ),
      labelMedium: fontTheme.labelMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.25,
      ),
      labelSmall: fontTheme.labelSmall?.copyWith(
        color: textColor.withValues(alpha: 0.75),
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
    );
  }

  static ThemeData getDarkTheme(ThemeAccent accent, {AppFontFamily font = AppFontFamily.ubuntu}) {
    final accentColor = VelvetColors.getAccentColor(accent);
    const darkSurface = VelvetColors.darkSurface;
    const darkBg = VelvetColors.darkBg;
    const darkCard = VelvetColors.darkCard;
    const darkText = VelvetColors.darkText;

    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: font.resolvedFontFamily,
      fontFamilyFallback: const ['sans-serif', 'Arial'],
      colorScheme: ColorScheme.dark(
        primary: accentColor,
        secondary: VelvetColors.periwinkle,
        surface: darkSurface,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: darkText,
        error: Colors.redAccent,
      ),
      scaffoldBackgroundColor: darkBg,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        labelStyle: const TextStyle(color: darkText),
        floatingLabelStyle: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all<Color>(darkCard),
          surfaceTintColor: WidgetStateProperty.all<Color>(Colors.transparent),
          elevation: WidgetStateProperty.all<double>(8.0),
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.white12),
            ),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: darkCard,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white24, width: 1.5),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStateProperty.all<Color>(darkCard),
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.white24, width: 1.5),
            ),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.white12),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );

    final textTheme = _buildCleanTextTheme(baseTheme.textTheme, darkText, font);

    return baseTheme.copyWith(
      textTheme: textTheme,
      cardColor: darkCard,
      cardTheme: CardThemeData(
        color: darkCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white10),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        textColor: darkText,
        iconColor: Color(0xFFE6EDF3),
      ),
      dividerColor: Colors.white12,
    );
  }

  static ThemeData getTheme(ThemeAccent accent, {AppFontFamily font = AppFontFamily.ubuntu}) {
    final accentColor = VelvetColors.getAccentColor(accent);
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: font.resolvedFontFamily,
      fontFamilyFallback: const ['sans-serif', 'Arial'],
      colorScheme: ColorScheme.light(
        primary: accentColor,
        secondary: VelvetColors.periwinkle,
        surface: VelvetColors.cream,
        onPrimary: VelvetColors.cocoa,
        onSecondary: VelvetColors.cocoa,
        onSurface: VelvetColors.cocoa,
        error: Colors.redAccent,
      ),
      scaffoldBackgroundColor: VelvetColors.cream,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: VelvetColors.cocoa),
        floatingLabelStyle: TextStyle(
            color: accentColor, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: VelvetColors.clayTan, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: VelvetColors.clayTan, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all<Color>(VelvetColors.cream),
          surfaceTintColor: WidgetStateProperty.all<Color>(Colors.transparent),
          elevation: WidgetStateProperty.all<double>(8.0),
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: VelvetColors.clayTan, width: 1.5),
            ),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: VelvetColors.clayTan, width: 1.5),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStateProperty.all<Color>(VelvetColors.cream),
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: VelvetColors.clayTan, width: 1.5),
            ),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: VelvetColors.cream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: VelvetColors.cream,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );

    final textTheme = _buildCleanTextTheme(baseTheme.textTheme, VelvetColors.cocoa, font);

    return baseTheme.copyWith(
      textTheme: textTheme,
      cardColor: VelvetColors.cream,
      cardTheme: CardThemeData(
        color: VelvetColors.cream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: VelvetColors.clayTan.withValues(alpha: 0.7)),
        ),
        shadowColor: const Color(0x18C4A98A),
      ),
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        textColor: VelvetColors.cocoa,
        iconColor: VelvetColors.cocoa,
      ),
      dividerColor: VelvetColors.clayTan,
    );
  }
}
