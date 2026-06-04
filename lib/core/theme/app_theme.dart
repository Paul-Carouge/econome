import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ─── Colors ───────────────────────────────────────────────────────
  static const Color amberAccent = Color(0xFFF59E0B);
  static const Color amberDark = Color(0xFFD97706);
  static const Color amberLight = Color(0xFFFBBF24);

  static const Color zinc950 = Color(0xFF09090B);
  static const Color zinc900 = Color(0xFF18181B);
  static const Color zinc800 = Color(0xFF27272A);
  static const Color zinc700 = Color(0xFF3F3F46);
  static const Color zinc600 = Color(0xFF52525B);
  static const Color zinc500 = Color(0xFF71717A);
  static const Color zinc400 = Color(0xFFA1A1AA);
  static const Color zinc300 = Color(0xFFD4D4D8);
  static const Color zinc200 = Color(0xFFE4E4E7);
  static const Color zinc100 = Color(0xFFF4F4F5);
  static const Color zinc50 = Color(0xFFFAFAFA);

  static const Color greenAccent = Color(0xFF22C55E);
  static const Color redAccent = Color(0xFFEF4444);

  // ─── Theme Data ───────────────────────────────────────────────────
  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: amberAccent,
      brightness: Brightness.dark,
    ).copyWith(
      primary: amberAccent,
      onPrimary: zinc950,
      primaryContainer: amberAccent.withValues(alpha: 0.15),
      onPrimaryContainer: amberLight,
      secondary: amberDark,
      onSecondary: zinc950,
      surface: zinc900,
      surfaceContainerHighest: zinc800,
      onSurface: zinc100,
      onSurfaceVariant: zinc400,
      outline: zinc700,
      outlineVariant: zinc700,
      error: redAccent,
      onError: zinc50,
      inverseSurface: zinc100,
      onInverseSurface: zinc900,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: zinc950,
      textTheme: GoogleFonts.interTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32, fontWeight: FontWeight.w700,
          color: zinc100, letterSpacing: -0.02,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28, fontWeight: FontWeight.w600,
          color: zinc100, letterSpacing: -0.02,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 24, fontWeight: FontWeight.w600,
          color: zinc100, letterSpacing: -0.01,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 22, fontWeight: FontWeight.w600,
          color: zinc100, letterSpacing: -0.01,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20, fontWeight: FontWeight.w600,
          color: zinc100,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: zinc100,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w500,
          color: zinc100,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w400,
          color: zinc200, height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w400,
          color: zinc300, height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w400,
          color: zinc400, height: 1.4,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w500,
          color: zinc100, letterSpacing: 0.01,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w500,
          color: zinc300, letterSpacing: 0.02,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10, fontWeight: FontWeight.w500,
          color: zinc400, letterSpacing: 0.03,
        ),
      ),

      // ─── Cards ───────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: zinc900,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: zinc800, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      ),

      // ─── Bottom Navigation ───────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: zinc900,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: amberAccent,
        unselectedItemColor: zinc500,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w400,
        ),
        enableFeedback: true,
      ),

      // ─── AppBar ──────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: zinc950,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: zinc100,
        ),
        iconTheme: const IconThemeData(color: zinc100),
      ),

      // ─── Buttons ─────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: amberAccent,
          foregroundColor: zinc950,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: amberAccent,
          foregroundColor: zinc950,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: amberAccent,
          side: const BorderSide(color: amberAccent, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: amberAccent,
          textStyle: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // ─── Input ───────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: zinc900,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: zinc700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: zinc700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: amberAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: redAccent, width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14, color: zinc400,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14, color: zinc600,
        ),
        errorStyle: GoogleFonts.inter(
          fontSize: 12, color: redAccent,
        ),
      ),

      // ─── Dialog ──────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: zinc900,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: zinc100,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14, color: zinc300,
        ),
      ),

      // ─── Snackbar ────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: zinc800,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14, color: zinc100,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // ─── Chip ────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: zinc800,
        selectedColor: amberAccent.withValues(alpha: 0.15),
        labelStyle: GoogleFonts.inter(fontSize: 13, color: zinc300),
        secondaryLabelStyle: GoogleFonts.inter(fontSize: 13, color: amberAccent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: zinc700),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ─── Bottom Sheet ────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: zinc900,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // ─── Divider ─────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: zinc800,
        thickness: 1,
        space: 1,
      ),

      // ─── Progress Indicator ──────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        linearTrackColor: zinc800,
        color: amberAccent,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
