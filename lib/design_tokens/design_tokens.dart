// design_tokens.dart – tokens visuels glassmorphism Bank App
import 'package:flutter/material.dart';

class DesignTokens {
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  Glassmorphism palette
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static const Color navy900 = Color(0xFF0A1628);
  static const Color navy800 = Color(0xFF0F2236);
  static const Color navy700 = Color(0xFF152A40);
  static const Color navy600 = Color(0xFF1B3450);

  static const Color teal500 = Color(0xFF14B8A6);
  static const Color teal400 = Color(0xFF2DD4BF);
  static const Color teal300 = Color(0xFF5EEAD4);
  static const Color tealGlow = Color(0xFF2DD4BF);

  static const Color gold500 = Color(0xFFD4AF37);
  static const Color gold400 = Color(0xFFE5C158);
  static const Color gold300 = Color(0xFFF5D47A);

  static const Color glassWhite = Color(0x14FFFFFF); // ~8% white
  static const Color glassBorder = Color(0x26FFFFFF); // ~15% white
  static const Color glassHighlight = Color(0x33FFFFFF); // ~20% white

  // Legacy tokens (conservés pour compatibilité minimale)
  static const Color primary = teal400;
  static const Color primaryDark = navy700;
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = navy900;
  static const Color surfaceLight = Color(0xFFF5F5F5);
  static const Color surfaceDark = navy800;
  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFB91C1C);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  Gradients
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [teal300, teal500],
  );

  static const LinearGradient tealGradientHorizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [teal500, teal300, teal500],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold300, gold500],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [navy900, navy800],
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  Spacing (in logical pixels)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static const double spacing0 = 0.0;
  static const double spacing1 = 4.0;
  static const double spacing2 = 8.0;
  static const double spacing3 = 12.0;
  static const double spacing4 = 16.0;
  static const double spacing5 = 20.0;
  static const double spacing6 = 24.0;
  static const double spacing7 = 28.0;
  static const double spacing8 = 32.0;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  Typography
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static const String fontFamily = 'Satisfy';
  static const double fontSizeBase = 16.0;
  static const double lineHeightBase = 1.5;
  static const double letterSpacingBase = 0.02;
  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemiBold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  Animation
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationMedium = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 350);
  static const Curve easeStandard = Curves.easeInOut;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  Helpers
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static BoxDecoration surfaceDecoration({bool dark = true}) {
    return BoxDecoration(
      color: dark ? glassWhite : surfaceLight,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: glassBorder),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration glassDecoration({
    double radius = 24,
    Color? tint,
    BorderSide? border,
  }) {
    return BoxDecoration(
      color: tint ?? glassWhite,
      borderRadius: BorderRadius.circular(radius),
      border: Border.fromBorderSide(border ?? const BorderSide(color: glassBorder)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
