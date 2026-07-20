import 'package:flutter/material.dart';

class AppTheme {
  // ─── Rəng Paleti (60 / 30 / 10 Qaydası) ────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF7F8FA);
  static const Color surfaceGrey = Color(0xFFEEF0F4);

  static const Color navyDark = Color(0xFF0A1628);
  static const Color navyMid = Color(0xFF1A2F55);
  static const Color navyLight = Color(0xFF2D4A8A);

  static const Color electric = Color(0xFF1B6EF3);
  static const Color electricLight = Color(0xFF4D8FF5);

  static const Color success = Color(0xFF2E9E5B);
  static const Color warning = Color(0xFFE0A62B);

  static const String fontFamily = 'Poppins';

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: navyDark.withOpacity(0.07),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: offWhite,
      colorScheme: ColorScheme.fromSeed(
        seedColor: electric,
        brightness: Brightness.light,
        primary: electric,
        secondary: navyMid,
        surface: white,
        background: offWhite,
        onPrimary: white,
        onSecondary: white,
        onSurface: navyDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: navyDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: navyDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: electric,
        unselectedItemColor: navyLight,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400, fontSize: 11),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: electric,
          foregroundColor: white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
              fontFamily: fontFamily, fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: navyMid,
          side: const BorderSide(color: navyMid, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
              fontFamily: fontFamily, fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: surfaceGrey, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: surfaceGrey, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: electric, width: 2),
        ),
        hintStyle: const TextStyle(
            fontFamily: fontFamily, color: Color(0xFFADB5CC), fontSize: 14),
        labelStyle: const TextStyle(fontFamily: fontFamily, color: navyMid),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceGrey,
        labelStyle: const TextStyle(
            fontFamily: fontFamily, color: navyMid, fontSize: 12, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
      ),
    );
  }
}
