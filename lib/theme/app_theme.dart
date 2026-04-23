import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFFF36805); // your button color
  static const Color inputField = Color(0xFFFFEAD4); // input background
  static const Color text = Colors.black87;
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        error: Color(0xFFE53935),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: Color(0x33F36805),
        selectionHandleColor: AppColors.primary,
      ),

      textTheme: GoogleFonts.interTextTheme().copyWith(
        headlineMedium: const TextStyle(fontWeight: FontWeight.bold),
      ),

      appBarTheme: AppBarTheme(
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputField,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        // Default (unfocused) border — subtle, matches the cream fill
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8C89A), width: 1.2),
        ),
        // Focused — primary orange, slightly thicker
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        // Validation error — red, same radius
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.8),
        ),
        // Disabled state
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDDD0C0), width: 1.0),
        ),
        // Label color in resting state
        labelStyle: TextStyle(
          color: Colors.black.withValues(alpha: 0.45),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        // Label color when floating above the field
        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        // Hint text style
        hintStyle: TextStyle(
          color: Colors.black.withValues(alpha: 0.30),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        // Inline validation error text
        errorStyle: const TextStyle(
          color: Color(0xFFE53935),
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        // Icons shift to primary orange on focus
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) return AppColors.primary;
          if (states.contains(WidgetState.error)) return Color(0xFFE53935);
          return Color(0xFFBE8A5A);
        }),
        suffixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) return AppColors.primary;
          if (states.contains(WidgetState.error)) return Color(0xFFE53935);
          return Color(0xFFBE8A5A);
        }),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(36),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),
    );
  }
}
