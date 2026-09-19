import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData dark() => _build(Brightness.dark, StudioPalette.dark);

  static ThemeData light() => _build(Brightness.light, StudioPalette.light);

  static ThemeData _build(Brightness brightness, StudioPalette palette) {
    final isDark = brightness == Brightness.dark;
    final base = isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true);
    final manrope = GoogleFonts.manropeTextTheme(base.textTheme);

    return base.copyWith(
      brightness: brightness,
      scaffoldBackgroundColor: palette.background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.primary,
        onPrimary: AppColors.primaryForeground,
        secondary: palette.muted,
        onSecondary: palette.foreground,
        error: AppColors.danger,
        onError: Colors.white,
        surface: palette.background,
        onSurface: palette.foreground,
      ),
      textTheme: manrope.apply(
        bodyColor: palette.foreground,
        displayColor: palette.foreground,
      ),
      iconTheme: IconThemeData(color: palette.foreground),
      dividerColor: palette.border,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: palette.background,
        foregroundColor: palette.foreground,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          color: palette.foreground,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.hero,
        contentTextStyle: GoogleFonts.manrope(color: AppColors.darkForeground),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.card,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: palette.cardForeground,
        ),
        contentTextStyle: GoogleFonts.manrope(
          fontSize: 14,
          color: palette.cardForeground.withValues(alpha: 0.7),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.card,
        hintStyle: GoogleFonts.manrope(color: palette.mutedForeground),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      extensions: [palette],
    );
  }
}
