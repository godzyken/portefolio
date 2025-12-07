import 'package:flutter/material.dart';

/// Helpers pour manipulation et création de couleurs
class ColorHelpers {
  /// Obtient une couleur selon un niveau (0.0 à 1.0)
  static Color getColorForLevel(double level) {
    if (level >= 0.9) return Colors.green.shade600;
    if (level >= 0.7) return Colors.blue.shade600;
    if (level >= 0.5) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  /// Obtient une couleur selon un index (pour graphiques)
  static Color getColorForIndex(int index) {
    final colors = [
      Colors.blue.shade600,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.red.shade600,
      Colors.teal.shade600,
      Colors.pink.shade600,
      Colors.indigo.shade600,
    ];
    return colors[index % colors.length];
  }

  /// Palette de couleurs pour les graphiques
  static List<Color> getChartColors() {
    return [
      Colors.blue.shade600,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.red.shade600,
    ];
  }

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

  /// Obtient une couleur contrastante (noir ou blanc)
  static Color getContrastColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

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

  /// Palette de couleurs pour l'expertise
  static Color getExpertiseColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 70) return Colors.blue;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  /// Couleurs pour les status
  static const Color successColor = Colors.green;
  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.orange;
  static const Color infoColor = Colors.blue;

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

  /// Vérifie si une couleur est considérée comme "claire"
  static bool isLight(Color color) {
    return color.computeLuminance() > 0.5;
  }

  /// Vérifie si une couleur est considérée comme "foncée"
  static bool isDark(Color color) {
    return !isLight(color);
  }
}

/// Extension sur Color pour ajouter des méthodes utilitaires
extension ColorExtensions on Color {
  /// Crée une version plus claire
  Color lighten([double amount = 0.1]) {
    return ColorHelpers.lighten(this, amount);
  }

  /// Crée une version plus foncée
  Color darken([double amount = 0.1]) {
    return ColorHelpers.darken(this, amount);
  }

  /// Obtient la couleur contrastante
  Color get contrastColor {
    return ColorHelpers.getContrastColor(this);
  }

  /// Vérifie si la couleur est claire
  bool get isLight {
    return ColorHelpers.isLight(this);
  }

  /// Vérifie si la couleur est foncée
  bool get isDark {
    return ColorHelpers.isDark(this);
  }

  /// Crée une version avec alpha
  Color alpha(double alpha) {
    return ColorHelpers.withAlpha(this, alpha);
  }
}
