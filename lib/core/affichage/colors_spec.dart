import 'package:flutter/material.dart';

/// 🎨 Helpers unifiés pour manipulation et création de couleurs
class ColorHelpers {
  // ============================================================================
  // COULEURS PAR NIVEAU/INDEX
  // ============================================================================

  /// Obtient une couleur selon un niveau (0.0 à 1.0)
  static Color getColorForLevel(double level) {
    if (level >= 0.9) return Colors.green.shade600;
    if (level >= 0.7) return Colors.blue.shade600;
    if (level >= 0.5) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  /// Obtient une couleur selon un index (pour graphiques)
  static Color getColorForIndex(int index) {
    return chartColors[index % chartColors.length];
  }

  // ============================================================================
  // COULEURS POUR PROJETS (ancien BenchmarkColors)
  // ============================================================================

  /// Palette complète pour les graphiques
  static const List<Color> chartColors = [
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Rose
    Color(0xFF10B981), // Vert
    Color(0xFFF59E0B), // Orange
    Color(0xFF3B82F6), // Bleu
    Color(0xFFEF4444), // Rouge
    Color(0xFF06B6D4), // Cyan
    Color(0xFFA78BFA), // Violet clair
    Color(0xFFFBBF24), // Jaune
    Color(0xFF6366F1), // Indigo
  ];

  /// Couleurs spécifiques pour benchmarks
  static const purple = Color(0xFF8B5CF6);
  static const pink = Color(0xFFEC4899);
  static const green = Color(0xFF00C49F);
  static const gray = Color(0xFFE0E0E0);
  static const darkBg = Color(0xFF1F2937);
  static const gridColor = Color(0xFF374151);
  static const textGray = Color(0xFF9CA3AF);
  static const cyan = Color(0xFF00D9FF);
  static const magenta = Color(0xFFFF2D78);
  static const surface = Color(0xFF0D1117);
  static const surfaceAlt = Color(0xFF111827);
  static const border = Color(0xFF1E2D40);
  static const textPrimary = Color(0xFFE8F4FD);
  static const textSecondary = Color(0xFF8BA3BF);
  static const textMuted = Color(0xFF8BA3BF);

  /// Gradient pour background space/dark
  static const bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF111827),
      Color(0xFF581C87),
      Color(0xFF111827),
    ],
  );

  /// Retourne une couleur unique pour chaque projet
  static Color getProjectColor(int index) {
    return chartColors[index % chartColors.length];
  }

  /// Retourne un gradient pour les cartes de recommandations
  static List<Color> getProjectGradient(int index) {
    final gradients = [
      [Color(0xFF581C87), Color(0xFF6B21A8), Color(0xFF7C3AED)], // Violet
      [Color(0xFF9F1239), Color(0xFFBE123C), Color(0xFFEC4899)], // Rose
      [Color(0xFF065F46), Color(0xFF059669), Color(0xFF10B981)], // Vert
      [Color(0xFF92400E), Color(0xFFB45309), Color(0xFFF59E0B)], // Orange
      [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF3B82F6)], // Bleu
      [Color(0xFF991B1B), Color(0xFFDC2626), Color(0xFFEF4444)], // Rouge
      [Color(0xFF155E75), Color(0xFF0891B2), Color(0xFF06B6D4)], // Cyan
      [Color(0xFF6D28D9), Color(0xFF7C3AED), Color(0xFFA78BFA)], // Violet clair
    ];
    return gradients[index % gradients.length];
  }

  /// Retourne une couleur avec opacité
  static Color getProjectColorWithOpacity(int index, double opacity) {
    return getProjectColor(index).withValues(alpha: opacity);
  }

  // ============================================================================
  // MANIPULATION DE COULEURS
  // ============================================================================

  /// Crée une version plus claire d'une couleur
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Crée une version plus foncée d'une couleur
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Interpole entre deux couleurs
  static Color interpolate(Color start, Color end, double t) {
    return Color.lerp(start, end, t) ?? start;
  }

  /// Crée une couleur avec alpha spécifique
  static Color withAlpha(Color color, double alpha) {
    assert(alpha >= 0.0 && alpha <= 1.0);
    return color.withValues(alpha: alpha);
  }

  /// Obtient une couleur contrastante (noir ou blanc)
  static Color getContrastColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Vérifie si une couleur est considérée comme "claire"
  static bool isLight(Color color) {
    return color.computeLuminance() > 0.5;
  }

  /// Vérifie si une couleur est considérée comme "foncée"
  static bool isDark(Color color) {
    return !isLight(color);
  }

  // ============================================================================
  // GRADIENTS
  // ============================================================================

  /// Crée un gradient linéaire standard
  static LinearGradient createLinearGradient({
    required Color start,
    required Color end,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry fin = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: fin,
      colors: [start, end],
    );
  }

  /// Crée un gradient radial
  static RadialGradient createRadialGradient({
    required Color center,
    required Color edge,
    AlignmentGeometry centerAlignment = Alignment.center,
    double radius = 1.0,
  }) {
    return RadialGradient(
      center: centerAlignment,
      radius: radius,
      colors: [center, edge],
    );
  }

  /// Gradient pour le background space/dark
  static LinearGradient createSpaceGradient({
    required Color primary,
    required Color secondary,
  }) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primary.withValues(alpha: 0.1),
        secondary.withValues(alpha: 0.05),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  /// Gradient pour les cartes
  static LinearGradient createCardGradient({
    required Color color,
    bool isVertical = false,
  }) {
    return LinearGradient(
      begin: isVertical ? Alignment.topCenter : Alignment.centerLeft,
      end: isVertical ? Alignment.bottomCenter : Alignment.centerRight,
      colors: [
        color.withValues(alpha: 0.15),
        color.withValues(alpha: 0.05),
      ],
    );
  }

  // ============================================================================
  // COULEURS SPÉCIFIQUES
  // ============================================================================

  /// Palette de couleurs pour l'expertise
  static Color getExpertiseColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 70) return Colors.blue;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  /// Couleurs pour les badges selon le niveau
  static Color getBadgeColor(String level) {
    switch (level.toLowerCase()) {
      case 'expert':
        return Colors.amber;
      case 'confirmé':
      case 'confirme':
        return Colors.grey;
      case 'intermédiaire':
      case 'intermediaire':
        return Colors.orange;
      case 'fonctionnel':
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  /// Couleurs pour les status
  static const Color successColor = Colors.green;
  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.orange;
  static const Color infoColor = Colors.blue;

  // ============================================================================
  // EFFETS VISUELS
  // ============================================================================

  /// Crée un BoxShadow standard avec une couleur
  static BoxShadow createShadow({
    required Color color,
    double blurRadius = 8.0,
    double spreadRadius = 2.0,
    Offset offset = const Offset(0, 4),
    double alpha = 0.3,
  }) {
    return BoxShadow(
      color: color.withValues(alpha: alpha),
      blurRadius: blurRadius,
      spreadRadius: spreadRadius,
      offset: offset,
    );
  }

  /// Crée un glow effect (ombre lumineuse)
  static List<BoxShadow> createGlowEffect({
    required Color color,
    double blurRadius = 20.0,
    double spreadRadius = 5.0,
    double alpha = 0.5,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: alpha),
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
    ];
  }

  // ============================================================================
  // UTILITAIRES
  // ============================================================================

  /// Crée une palette harmonieuse à partir d'une couleur de base
  static List<Color> createHarmoniousPalette(Color baseColor, {int count = 5}) {
    final hsl = HSLColor.fromColor(baseColor);
    final colors = <Color>[];

    for (int i = 0; i < count; i++) {
      final hue = (hsl.hue + (360 / count) * i) % 360;
      colors.add(
        HSLColor.fromAHSL(
          hsl.alpha,
          hue,
          hsl.saturation,
          hsl.lightness,
        ).toColor(),
      );
    }

    return colors;
  }
}

// ============================================================================
// EXTENSIONS
// ============================================================================

/// Extension sur Color pour ajouter des méthodes utilitaires
extension ColorExtensions on Color {
  Color lighten([double amount = 0.1]) => ColorHelpers.lighten(this, amount);
  Color darken([double amount = 0.1]) => ColorHelpers.darken(this, amount);
  Color get contrastColor => ColorHelpers.getContrastColor(this);
  bool get isLight => ColorHelpers.isLight(this);
  bool get isDark => ColorHelpers.isDark(this);
  Color alpha(double alpha) => ColorHelpers.withAlpha(this, alpha);
}

/// Extension sur Int pour faciliter l'utilisation
extension ProjectColorExtension on int {
  Color get projectColor => ColorHelpers.getProjectColor(this);
  List<Color> get projectGradient => ColorHelpers.getProjectGradient(this);
  Color get chartColor => ColorHelpers.getColorForIndex(this);
}
