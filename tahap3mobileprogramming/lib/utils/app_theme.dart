import 'package:flutter/material.dart';

/// Konstanta warna dan tema Material 3 agar tampilan konsisten di seluruh halaman.
class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF3949AB);
  static const Color background = Color(0xFFF5F6FB);
  static const Color border = Color(0xFFE3E6EF);
  static const Color textDark = Color(0xFF1F2430);
  static const Color textMuted = Color(0xFF5B6275);
  static const Color danger = Color(0xFFC62828);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primary),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Dekorasi input yang dipakai bersama oleh kolom pencarian dan form tugas.
InputDecoration appInputDecoration({
  String? label,
  String? hint,
  IconData? prefixIcon,
  Widget? suffixIcon,
}) {
  OutlineInputBorder border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: border(AppTheme.border),
    enabledBorder: border(AppTheme.border),
    focusedBorder: border(AppTheme.primary, 1.8),
    errorBorder: border(AppTheme.danger),
    focusedErrorBorder: border(AppTheme.danger, 1.8),
  );
}
