import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color primary = Color(0xFF00E676);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.grey;

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Material 3'e uygun güncel CardTheme yapısı
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 4,
        shadowColor: Colors.black45,
        margin: EdgeInsets.all(4), // shape kısmındaki hata genelde const uyumsuzluğundan çıkar, temel özellikleri verdik
      ),

      // background yerine surface kullanıyoruz
      colorScheme: const ColorScheme.dark(
        primary: primary,
        surface: surface, 
      ),
      
      useMaterial3: true,
    );
  }
}