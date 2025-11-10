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

  /// Retourne une couleur unique pour chaque projet (support infini)
  static Color getProjectColor(int index) {
    final colors = [
      Color(0xFF8B5CF6), // Violet (projet 1)
      Color(0xFFEC4899), // Rose (projet 2)
      Color(0xFF10B981), // Vert (projet 3)
      Color(0xFFF59E0B), // Orange (projet 4)
      Color(0xFF3B82F6), // Bleu (projet 5)
      Color(0xFFEF4444), // Rouge (projet 6)
      Color(0xFF8B5CF6), // Cyan (projet 7)
      Color(0xFFA78BFA), // Violet clair (projet 8)
    ];

    // Utiliser modulo pour supporter un nombre infini de projets
    return colors[index % colors.length];
  }

  /// Retourne un gradient pour les cartes de recommandations
  static List<Color> getProjectGradient(int index) {
    final gradients = [
      // Violet (projet 1)
      [Color(0xFF581C87), Color(0xFF6B21A8), Color(0xFF7C3AED)],
      // Rose (projet 2)
      [Color(0xFF9F1239), Color(0xFFBE123C), Color(0xFFEC4899)],
      // Vert (projet 3)
      [Color(0xFF065F46), Color(0xFF059669), Color(0xFF10B981)],
      // Orange (projet 4)
      [Color(0xFF92400E), Color(0xFFB45309), Color(0xFFF59E0B)],
      // Bleu (projet 5)
      [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF3B82F6)],
      // Rouge (projet 6)
      [Color(0xFF991B1B), Color(0xFFDC2626), Color(0xFFEF4444)],
      // Cyan (projet 7)
      [Color(0xFF155E75), Color(0xFF0891B2), Color(0xFF06B6D4)],
      // Violet clair (projet 8)
      [Color(0xFF6D28D9), Color(0xFF7C3AED), Color(0xFFA78BFA)],
    ];

    return gradients[index % gradients.length];
  }

  /// Retourne une couleur avec opacité pour les graphiques
  static Color getProjectColorWithOpacity(int index, double opacity) {
    return getProjectColor(index).withValues(alpha: opacity);
  }

  /// Palette complète pour les graphiques (pie charts, etc.)
  static List<Color> chartColors = [
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Rose
    Color(0xFF10B981), // Vert
    Color(0xFFF59E0B), // Orange
    Color(0xFF3B82F6), // Bleu
    Color(0xFFEF4444), // Rouge
    Color(0xFF06B6D4), // Cyan
    Color(0xFFA78BFA), // Violet clair
    Color(0xFFFBBF24), // Jaune
    Color(0xFF8B5CF6), // Indigo
  ];

  /// Obtenir une couleur de chart par index
  static Color getChartColor(int index) {
    return chartColors[index % chartColors.length];
  }
}

// ============================================================================
// 📊 Extension pour faciliter l'utilisation
// ============================================================================

extension BenchmarkColorsExtension on int {
  /// Retourne la couleur du projet
  Color get projectColor => BenchmarkColors.getProjectColor(this);

  /// Retourne le gradient du projet
  List<Color> get projectGradient => BenchmarkColors.getProjectGradient(this);

  /// Retourne la couleur de chart
  Color get chartColor => BenchmarkColors.getChartColor(this);
}
