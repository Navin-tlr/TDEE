import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class AppTheme {
  // MARK: - Layout Tokens
  static const double baseUnit = 8.0;
  static const double compactPadding = 16.0;
  static const double regularPadding = 24.0;
  static const double referenceWidth = 375.0; // iPhone baseline
  
  // MARK: - Typography Families
  static const String fontFamily = 'SF Pro Display';
  static const String fontFamilyText = 'SF Pro Text';
  // Web-safe system font fallbacks to avoid remote Roboto fetch
  static const List<String> webFontFallback = <String>[
    '-apple-system',
    'BlinkMacSystemFont',
    'Segoe UI',
    'Helvetica Neue',
    'Helvetica',
    'Arial',
    'Apple Color Emoji',
    'Segoe UI Emoji',
    'Segoe UI Symbol',
    'Noto Color Emoji',
    'sans-serif',
  ];

  // MARK: - Cupertino Dynamic Colors (resolved at runtime)
  static Color labelColor(BuildContext context) =>
      CupertinoDynamicColor.resolve(CupertinoColors.label, context);
  static Color secondaryLabelColor(BuildContext context) =>
      CupertinoDynamicColor.resolve(CupertinoColors.secondaryLabel, context);
  static Color systemGroupedBackground(BuildContext context) =>
      CupertinoDynamicColor.resolve(CupertinoColors.systemGroupedBackground, context);
  static Color systemOrange(BuildContext context) =>
      CupertinoDynamicColor.resolve(CupertinoColors.systemOrange, context);

  // MARK: - App Accent Goal Colors (static for now)
  static const Color goalCut = Color(0xFFFFB300); // Amber
  static const Color goalBulk = Color(0xFF18A75D); // Emerald  
  static const Color goalRecomp = Color(0xFF0A84FF); // Blue
  
  // MARK: - Corner Radii
  static const double cardRadius = 12.0;
  static const double buttonRadius = 12.0;
  static const double chipRadius = 8.0;
  static const double fabRadius = 28.0;
  
  // MARK: - Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 8,
      color: Color(0x14000000), // 8% opacity
    ),
  ];
  
  // MARK: - Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // MARK: - Spec Typography Tokens
  // Sizes follow iOS points roughly equivalent to logical pixels.
  static const TextStyle hero24 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600, // Semibold
    height: 1.2,
  );
  static const TextStyle body17 = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );
  static const TextStyle caption13 = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      // On web, do not force a downloadable font (avoids gstatic fetch).
      fontFamily: kIsWeb ? null : fontFamilyText,
      fontFamilyFallback: kIsWeb ? webFontFallback : null,
      // Prefer iOS typography to further avoid Roboto on web.
      typography: Typography.material2021(platform: TargetPlatform.iOS),
      // iOS systemGray6
      scaffoldBackgroundColor: const Color(0xFFF2F2F7),
      colorScheme: ColorScheme.fromSeed(
        seedColor: goalRecomp,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(cardRadius)),
        ),
        color: Colors.white,
        shadowColor: Color(0x14000000),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFFFF9500),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          // Avoid infinite width in unconstrained rows (web); only enforce height
          minimumSize: const Size(0, 52),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          side: const BorderSide(color: Color(0x1F000000)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(0, 48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        // subtle off-white fill
        fillColor: const Color(0xFFF2F2F7),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E5EA), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E5EA), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF9500), width: 2),
        ),
        labelStyle: const TextStyle(
          fontFamily: fontFamilyText,
          fontSize: 17,
          height: 1.35,
          color: Color(0x99000000),
        ),
        hintStyle: const TextStyle(
          fontFamily: fontFamilyText,
          fontSize: 17,
          height: 1.35,
          color: Color(0x99000000),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(chipRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        shape: CircleBorder(),
        backgroundColor: goalRecomp,
        foregroundColor: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: Colors.white,
        indicatorColor: goalRecomp.withOpacity(0.1),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(
            fontFamily: fontFamilyText,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: hero24, // map hero
        displayMedium: hero24,
        headlineMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        bodyLarge: body17,
        bodyMedium: body17,
        bodySmall: caption13,
        labelSmall: caption13,
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: kIsWeb ? null : fontFamilyText,
      fontFamilyFallback: kIsWeb ? webFontFallback : null,
      typography: Typography.material2021(platform: TargetPlatform.iOS),
      scaffoldBackgroundColor: const Color(0xFF000000),
      colorScheme: ColorScheme.fromSeed(
        seedColor: goalRecomp,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(cardRadius)),
        ),
        color: Color(0xFF1C1C1E),
        shadowColor: Color(0x4D000000),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x1AFFFFFF),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3A3A3C), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3A3A3C), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF9500), width: 2),
        ),
        labelStyle: const TextStyle(
          fontFamily: fontFamilyText,
          fontSize: 17,
          height: 1.35,
          color: Color(0xCCFFFFFF),
        ),
        hintStyle: const TextStyle(
          fontFamily: fontFamilyText,
          fontSize: 17,
          height: 1.35,
          color: Color(0x99FFFFFF),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: hero24,
        displayMedium: hero24,
        headlineMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: Colors.white,
        ),
        bodyLarge: body17,
        bodyMedium: body17,
        bodySmall: caption13,
        labelSmall: caption13,
      ),
    );
  }
}

class GoalColors {
  static Color getColorForGoal(String goal) {
    switch (goal.toLowerCase()) {
      case 'cut':
        return AppTheme.goalCut;
      case 'bulk':
        return AppTheme.goalBulk;
      case 'recomp':
        return AppTheme.goalRecomp;
      default:
        return AppTheme.goalRecomp;
    }
  }
}

class Spacing {
  static const double xs = AppTheme.baseUnit; // 8
  static const double sm = AppTheme.baseUnit * 2; // 16
  static const double md = AppTheme.baseUnit * 3; // 24
  static const double lg = AppTheme.baseUnit * 4; // 32
  static const double xl = AppTheme.baseUnit * 5; // 40
  static const double xxl = AppTheme.baseUnit * 6; // 48
}
