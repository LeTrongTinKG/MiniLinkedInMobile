import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// ThemeData cho chế độ Dark Mode của ứng dụng Mini LinkedIn.
ThemeData buildAppDarkTheme() {
  final base = GoogleFonts.beVietnamProTextTheme();
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF60A5FA), // Light blue 400
      onPrimary: AppColors.darkBackground,
      primaryContainer: Color(0xFF1E3A8A), // Blue 900
      onPrimaryContainer: Color(0xFFDBEAFE),
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.darkBorder,
      surfaceContainerHighest: AppColors.darkSurfaceSubtle,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: base.copyWith(
      bodyLarge: base.bodyLarge?.copyWith(color: AppColors.darkTextPrimary),
      bodyMedium: base.bodyMedium?.copyWith(color: AppColors.darkTextPrimary),
      bodySmall: base.bodySmall?.copyWith(color: AppColors.darkTextMuted),
      labelLarge: base.labelLarge?.copyWith(color: AppColors.darkTextPrimary),
      labelSmall: base.labelSmall?.copyWith(color: AppColors.darkTextMuted),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.beVietnamPro(
        color: AppColors.darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF60A5FA),
        minimumSize: const Size(64, 48),
        side: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurfaceSubtle,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
        borderSide: const BorderSide(color: Color(0xFF60A5FA), width: 1.5),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkBorder,
      thickness: 1,
    ),
  );
}
