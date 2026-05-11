import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF28669b);
  static const Color lightBlue = Color(0xFF3FA9F5);
  static const Color green = Color(0xFF3CB878);
  static const Color orange = Color(0xFFF7931E);
  static const Color lime = Color(0xFFB7D433);
  static const Color lightBackground = Color(0xFFF9FAFB);
  static const Color lightSurface = Colors.white;
  static const Color lightPrimaryText = Color(0xFF1F2D3D);
  static const Color lightSecondaryText = Color(0xFF6B7280);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightIcon = Color(0xFF3F4E63);
  static const Color darkText = Color(0xFF263860);
  static const Color lightThemeColor = primaryBlue;
  static const LinearGradient integraGradient = LinearGradient(
    colors: [primaryBlue, lightBlue, green, orange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static ThemeData? get lightTheme => null;
  static Color? get accent => null;
  static Color? get secondary => null;
  static Color? get warningText => null;
  // static const Color secondaryGreen = Color(0xFF4b8c40);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey300 = Color(0xFFe0e0e0);
  static const Color grey600 = Color(0xFF757575);
  static const Color authPrimary = Color(0xFF00B24C);
  static const Color authSecondary = Color(0xFF009688);
  static const Color authBackground = Colors.white;
  static const Color authText = Color(0xFF2D3748);
  static const Color authBorder = Color(0xFFE2E8F0);
  static const Color background = Color(0xFFF8FAFC);
  static const Color primaryGreen = Color(0xFF20A076);
  static const Color secondaryGreen = Color(0xFF5B9754);

  // static const Color primaryBlue = Color(0xFF28669b);
  // static const Color lightBlue = Color(0xFF3FA9F5);
  // static const Color secondaryGreen = Color(0xFF4b8c40);
  // static const Color darkText = Color(0xFF263860);
  // static const Color lightBackground = Color(0xFFf6f8f6);
}
