import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand - Digital Earth
  static const Color deepEmerald = Color(0xFF081C15);
  static const Color forestGreen = Color(0xFF1B4332);
  static const Color bone = Color(0xFFFDFCF9);
  static const Color earthYellow = Color(0xFFD4A373);

  // Legacy/UI Support - Aliases for compatibility
  static const Color green = forestGreen;
  static const Color earthBrown = earthYellow;
  static const Color skyBlue = forestGreen; // Or a specific blue if needed
  static const Color successGreen = forestGreen;
  static const Color alertRed = Color(0xFFE74C3C);
  static const Color warmYellow = Color(0xFFF5A623);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF95A5A6);
  static const Color lightGray = Color(0xFFECF0F1);
  static const Color white = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.forestGreen,
      scaffoldBackgroundColor: AppColors.deepEmerald,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.forestGreen,
        primary: AppColors.forestGreen,
        secondary: AppColors.earthYellow,
        error: AppColors.alertRed,
        surface: AppColors.deepEmerald,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: AppColors.bone,
          letterSpacing: -1,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.bone,
          letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.bone,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.bone,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.bone,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.bone.withValues(alpha: 0.7),
          height: 1.5,
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.forestGreen,
      scaffoldBackgroundColor: AppColors.bone,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.forestGreen,
        primary: AppColors.forestGreen,
        secondary: AppColors.deepEmerald,
        error: AppColors.alertRed,
        surface: AppColors.white,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: AppColors.deepEmerald,
          letterSpacing: -1,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.deepEmerald,
          letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.deepEmerald,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.deepEmerald,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.deepEmerald,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.deepEmerald.withValues(alpha: 0.7),
          height: 1.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forestGreen,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 64),
          shape: const StadiumBorder(),
          elevation: 0,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.forestGreen,
          side: const BorderSide(color: AppColors.forestGreen, width: 2),
          minimumSize: const Size(double.infinity, 64),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
