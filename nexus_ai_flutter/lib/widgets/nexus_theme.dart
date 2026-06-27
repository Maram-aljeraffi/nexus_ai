import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NexusTheme {
  // الألوان الأساسية
  static const Color primary = Color(0xFF4F46E5);     // بنفسجي
  static const Color secondary = Color(0xFF7C3AED);  // بنفسجي فاتح
  static const Color accent = Color(0xFF38BDF8);     // أزرق سماوي
  static const Color dark = Color(0xFF0F172A);       // غامق
  static const Color success = Color(0xFF10B981);    // أخضر
  static const Color warning = Color(0xFFF59E0B);    // برتقالي
  static const Color error = Color(0xFFEF4444);      // أحمر

  // التدرجات اللونية
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const Gradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF312E81)],
  );

  static const Gradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, primary],
  );

  // الظلال
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];

  static List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> strongShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 30,
      offset: const Offset(0, 12),
    ),
  ];

  // الأنماط النصية
  static TextTheme textTheme = GoogleFonts.poppinsTextTheme().copyWith(
    displayLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold),
    displayMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600),
    displaySmall: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600),
    headlineMedium: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
    titleLarge: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
    bodyLarge: GoogleFonts.poppins(fontSize: 16),
    bodyMedium: GoogleFonts.poppins(fontSize: 14),
    bodySmall: GoogleFonts.poppins(fontSize: 12),
    labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
  );
}