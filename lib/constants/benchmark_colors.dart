import 'package:flutter/material.dart';

class BenchmarkColors {
  static const purple = Color(0xFF8B5CF6); // Projet 1
  static const pink = Color(0xFFEC4899); // Projet 2
  static const green = Color(0xFF00C49F); // Score obtenu
  static const gray = Color(0xFFE0E0E0); // Restant
  static const darkBg = Color(0xFF1F2937); // Fond cartes
  static const gridColor = Color(0xFF374151);
  static const textGray = Color(0xFF9CA3AF);

  static final bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF111827),
      Color(0xFF581C87),
      Color(0xFF111827),
    ],
  );
}
