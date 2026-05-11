// ARQUIVO: lib/core/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle get label => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF18181B),
  );

  static TextStyle get button => GoogleFonts.poppins(
    color: Colors.white,
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );
}