import 'package:flutter/material.dart';
import '../../design_tokens/design_tokens.dart';

class AppTheme {
  // ── Core Brand Colors ──
  static const Color primaryColor = DesignTokens.teal400;
  static const Color secondaryColor = DesignTokens.success;
  static const Color errorColor = DesignTokens.error;

  // ── Light Theme Colors ──
  static const Color backgroundColor = DesignTokens.backgroundLight;
  static const Color surfaceColor = DesignTokens.surfaceLight;

  // ── Dark Theme Colors ──
  static const Color darkBackground = DesignTokens.navy900;
  static const Color darkSurface = DesignTokens.navy800;
  static const Color darkSurfaceLight = DesignTokens.glassWhite;
  static const Color darkBorder = DesignTokens.glassBorder;
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // ── Common text style helper ──
  static TextStyle _textStyle(Color color, FontWeight weight, double size) {
    return TextStyle(
      fontFamily: DesignTokens.fontFamily,
      color: color,
      fontWeight: weight,
      fontSize: size,
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  LIGHT THEME
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: DesignTokens.fontFamily,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: surfaceColor,
        surfaceContainerHighest: backgroundColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      cardTheme: const CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        elevation: 2,
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  DARK THEME (default glassmorphism)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: DesignTokens.fontFamily,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        onPrimary: Colors.white,
        surfaceContainerHighest: darkSurfaceLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _textStyle(darkTextPrimary, FontWeight.w700, 20).copyWith(
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DesignTokens.navy800.withValues(alpha: 0.95),
        selectedItemColor: primaryColor,
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: _textStyle(primaryColor, FontWeight.w600, 12),
        unselectedLabelStyle: _textStyle(darkTextSecondary, FontWeight.w400, 11),
      ),
      cardTheme: CardThemeData(
        color: darkSurfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: darkBorder.withValues(alpha: 0.6)),
        ),
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: DesignTokens.navy900,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: _textStyle(DesignTokens.navy900, FontWeight.w700, 16).copyWith(
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: darkSurfaceLight,
        labelStyle: _textStyle(darkTextSecondary, FontWeight.w400, 14),
        hintStyle: _textStyle(darkTextSecondary, FontWeight.w400, 14),
        prefixIconColor: darkTextSecondary,
        suffixIconColor: darkTextSecondary,
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 0.5,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: primaryColor,
        textColor: darkTextPrimary,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: primaryColor,
        unselectedLabelColor: darkTextSecondary,
        indicatorColor: primaryColor,
        indicatorSize: TabBarIndicatorSize.label,
      ),
      textTheme: TextTheme(
        headlineLarge: _textStyle(darkTextPrimary, FontWeight.w800, 32),
        headlineMedium: _textStyle(darkTextPrimary, FontWeight.w700, 28),
        headlineSmall: _textStyle(darkTextPrimary, FontWeight.w700, 24),
        titleLarge: _textStyle(darkTextPrimary, FontWeight.w700, 20),
        titleMedium: _textStyle(darkTextPrimary, FontWeight.w600, 18),
        titleSmall: _textStyle(darkTextPrimary, FontWeight.w600, 16),
        bodyLarge: _textStyle(darkTextPrimary, FontWeight.w400, 16),
        bodyMedium: _textStyle(darkTextSecondary, FontWeight.w400, 14),
        bodySmall: _textStyle(darkTextSecondary, FontWeight.w400, 12),
        labelLarge: _textStyle(darkTextPrimary, FontWeight.w600, 14),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurface,
        contentTextStyle: _textStyle(darkTextPrimary, FontWeight.w500, 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: _textStyle(darkTextPrimary, FontWeight.w700, 20),
        contentTextStyle: _textStyle(darkTextSecondary, FontWeight.w400, 16),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceLight,
        selectedColor: primaryColor.withValues(alpha: 0.2),
        labelStyle: _textStyle(darkTextPrimary, FontWeight.w500, 12),
        secondaryLabelStyle: _textStyle(primaryColor, FontWeight.w500, 12),
        side: const BorderSide(color: darkBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: darkBorder,
      ),
    );
  }
}
