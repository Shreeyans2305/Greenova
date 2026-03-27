import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ───── Primary Palette — Sleek Charcoal Grey ─────
  static const Color primaryCharcoal = Color(0xFF1A1A2E);
  static const Color primarySlate = Color(0xFF2D2D44);
  static const Color primaryDeep = Color(0xFF0D0D1A);

  // ───── Accent — Emerald (sustainability indicator) ─────
  static const Color accentEmerald = Color(0xFF00D27F);
  static const Color accentEmeraldDark = Color(0xFF00A865);
  static const Color accentCyan = Color(0xFF00BCD4);

  // ───── Surfaces ─────
  static const Color backgroundLight = Color(0xFFF2F2F7);
  static const Color backgroundDark = Color(0xFF0D0D1A);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF252538);

  // ───── Text shades ─────
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6B6B80);
  static const Color textPrimaryDark = Color(0xFFF0F0F5);
  static const Color textSecondaryDark = Color(0xFF9999AA);

  // ───── Score / Impact Colors ─────
  static const Color scoreExcellent = Color(0xFF00D27F);
  static const Color scoreGood = Color(0xFF7ED957);
  static const Color scoreFair = Color(0xFFFFBF00);
  static const Color scorePoor = Color(0xFFFF6B35);
  static const Color scoreBad = Color(0xFFFF3355);

  // ───── Helpers ─────
  static Color getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
        return scoreExcellent;
      case 'B':
        return scoreGood;
      case 'C':
        return scoreFair;
      case 'D':
        return scorePoor;
      case 'F':
        return scoreBad;
      default:
        return Colors.grey;
    }
  }

  static Color getCarbonScoreColor(double score) {
    if (score <= 20) return scoreExcellent;
    if (score <= 40) return scoreGood;
    if (score <= 60) return scoreFair;
    if (score <= 80) return scorePoor;
    return scoreBad;
  }

  static String getEcoscoreLabel(String? grade) {
    switch (grade?.toLowerCase()) {
      case 'a':
        return 'Excellent';
      case 'b':
        return 'Good';
      case 'c':
        return 'Fair';
      case 'd':
        return 'Poor';
      case 'e':
        return 'Bad';
      default:
        return 'Unknown';
    }
  }

  // ═══════════════════════════════════════════════════════
  //  LIGHT THEME
  // ═══════════════════════════════════════════════════════
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).apply(
      bodyColor: textPrimaryLight,
      displayColor: textPrimaryLight,
    ),
    colorScheme: ColorScheme.light(
      primary: accentEmerald,
      primaryContainer: primaryCharcoal,
      secondary: accentCyan,
      surface: surfaceLight,
      error: scoreBad,
      onPrimary: Colors.white,
      onSurface: textPrimaryLight,
      onSecondary: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryCharcoal,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.outfit(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceLight,
      selectedItemColor: accentEmerald,
      unselectedItemColor: Colors.grey.shade400,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryCharcoal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        elevation: 0,
        textStyle:
            GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.all(20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: accentEmerald, width: 2),
      ),
      hintStyle: TextStyle(color: Colors.grey.shade400),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentEmerald,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade100,
      selectedColor: accentEmerald.withValues(alpha: 0.15),
      labelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: textPrimaryLight),
      secondaryLabelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: accentEmerald),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceLight,
      titleTextStyle: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimaryLight),
      contentTextStyle: GoogleFonts.outfit(fontSize: 14, color: textSecondaryLight),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: accentEmerald),
    ),
    dividerColor: Colors.grey.shade200,
  );

  // ═══════════════════════════════════════════════════════
  //  DARK THEME
  // ═══════════════════════════════════════════════════════
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: textPrimaryDark,
      displayColor: textPrimaryDark,
    ),
    colorScheme: ColorScheme.dark(
      primary: accentEmerald,
      primaryContainer: primarySlate,
      secondary: accentCyan,
      surface: surfaceDark,
      error: scoreBad,
      onPrimary: primaryDeep,
      onSurface: textPrimaryDark,
      onSecondary: primaryDeep,
    ),
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.outfit(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: accentEmerald,
      unselectedItemColor: Colors.grey.shade600,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.06), width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentEmerald,
        foregroundColor: primaryDeep,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        elevation: 0,
        textStyle:
            GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardDark,
      contentPadding: const EdgeInsets.all(20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: accentEmerald, width: 2),
      ),
      hintStyle: TextStyle(color: Colors.grey.shade600),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentEmerald,
      foregroundColor: primaryDeep,
      elevation: 4,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: cardDark,
      selectedColor: accentEmerald.withValues(alpha: 0.2),
      labelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: textPrimaryDark),
      secondaryLabelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: accentEmerald),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: cardDark,
      titleTextStyle: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimaryDark),
      contentTextStyle: GoogleFonts.outfit(fontSize: 14, color: textSecondaryDark),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: accentEmerald),
    ),
    dividerColor: Colors.white.withValues(alpha: 0.06),
  );
}
