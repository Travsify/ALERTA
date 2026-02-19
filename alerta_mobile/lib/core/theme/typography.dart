import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextStyle get heading1 => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        color: Colors.white,
      );

  static TextStyle get heading2 => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        color: Colors.white,
      );

  static TextStyle get bodyLarge => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      );

  static TextStyle get bodyMedium => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.white70,
      );

  static TextStyle get bodySmall => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.white60,
      );

  static TextStyle get labelLarge => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: Colors.white,
      );

  static TextStyle get labelMedium => GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: Colors.white54,
      );
      
  static TextStyle get panicButton => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
        color: Colors.white,
      );
}
