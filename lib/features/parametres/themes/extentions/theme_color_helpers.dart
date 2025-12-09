import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';

import '../theme/theme_data.dart';

// Extension pour BasicTheme utilisant ColorHelpers
extension BasicThemeColorHelpers on BasicTheme {
  /// Obtient une palette harmonieuse basée sur la couleur primaire
  List<Color> get harmoniousPalette {
    return ColorHelpers.createHarmoniousPalette(primaryColor, count: 5);
  }

  /// Crée un gradient pour les cartes basé sur la couleur primaire
  LinearGradient get cardGradient {
    return ColorHelpers.createCardGradient(color: primaryColor);
  }

  /// Crée un gradient spatial personnalisé
  LinearGradient get spaceGradient {
    return ColorHelpers.createSpaceGradient(
      primary: primaryColor,
      secondary: tertiaryColor,
    );
  }

  /// Obtient une version plus claire de la couleur primaire
  Color get primaryLight => ColorHelpers.lighten(primaryColor, 0.2);

  /// Obtient une version plus foncée de la couleur primaire
  Color get primaryDark => ColorHelpers.darken(primaryColor, 0.2);

  /// Crée un effet glow pour la couleur primaire
  List<BoxShadow> get primaryGlow {
    return ColorHelpers.createGlowEffect(color: primaryColor);
  }

  /// Vérifie si le thème est clair ou foncé
  bool get isPrimaryLight => ColorHelpers.isLight(primaryColor);

  /// Obtient une couleur contrastante pour le texte
  Color get primaryContrast => ColorHelpers.getContrastColor(primaryColor);
}

// Exemple d'utilisation dans toThemeData()
class EnhancedBasicTheme extends BasicTheme {
  const EnhancedBasicTheme({
    required super.primaryColorValue,
    required super.tertiaryColorValue,
    required super.neutralColorValue,
    super.mode,
    super.name,
    super.emoji,
  });

  @override
  ThemeData toThemeData() {
    final brightness = switch (mode) {
      AppThemeMode.light => Brightness.light,
      AppThemeMode.dark => Brightness.dark,
      AppThemeMode.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness,
      AppThemeMode.custom => Brightness.dark,
    };

    final isDark = brightness == Brightness.dark;

    // Utilisation de ColorHelpers pour créer des variations
    final primaryLight = ColorHelpers.lighten(primaryColor, 0.2);
    final primaryDark = ColorHelpers.darken(primaryColor, 0.2);
    final primaryContrast = ColorHelpers.getContrastColor(primaryColor);

    final harmoniousPalette =
        ColorHelpers.createHarmoniousPalette(primaryColor, count: 5);

    final labelColors = [
      harmoniousPalette[1], // Couleur accentuée 1
      harmoniousPalette[2], // Couleur accentuée 2
      harmoniousPalette[3], // Couleur accentuée 3
    ];

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      surface: neutralColor,
      tertiary: tertiaryColor,
      surfaceContainerHighest: isDark ? const Color(0xFF2A2A2A) : null,
      surfaceContainer: isDark ? const Color(0xFF1E1E1E) : null,
      surfaceContainerLow: isDark ? const Color(0xFF151515) : null,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,

      // Utilisation de ColorHelpers pour les ombres
      cardTheme: CardThemeData(
        elevation: isDark ? 4 : 2,
        color: isDark ? const Color(0xFF1A1A1A) : colorScheme.surface,
        surfaceTintColor: ColorHelpers.withAlpha(primaryColor, 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: primaryColor,
      ),

      chipTheme: ChipThemeData(
          backgroundColor: labelColors[0].withValues(alpha: 0.1),
          selectedColor: labelColors[1].withValues(alpha: 0.1),
          labelStyle: TextStyle(color: labelColors[0]),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: labelColors[0]),
          )),

      dividerTheme: DividerThemeData(
        color: harmoniousPalette.last.withValues(alpha: 0.4),
        thickness: 1,
        space: 30,
      ),

      // Gradient harmonieux pour les boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: primaryContrast,
            elevation: 2,
            shadowColor: ColorHelpers.withAlpha(primaryColor, 0.3),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            overlayColor: primaryLight,
            surfaceTintColor: primaryLight),
      ),

      // Effet glow sur FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: primaryContrast,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDark
                  ? primaryLight.withAlpha(primaryColorValue)
                  : primaryDark.withAlpha(primaryColorValue),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDark ? primaryLight : primaryDark,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          fillColor: isDark
              ? ColorHelpers.withAlpha(primaryDark, 0.05)
              : ColorHelpers.withAlpha(primaryLight, 0.05),
          filled: true,
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDark ? primaryLight : primaryDark,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDark ? primaryLight : primaryDark,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          labelStyle: TextStyle(
            color: isDark ? primaryLight : primaryDark,
          )),

      textTheme: TextTheme(
        labelLarge: TextStyle(color: primaryLight),
        bodySmall: TextStyle(color: isDark ? primaryLight : primaryDark),
        bodyMedium: TextStyle(color: isDark ? primaryLight : primaryDark),
        bodyLarge: TextStyle(color: primaryLight),
      ),

      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return primaryColor;
          }
          return isDark ? primaryDark : primaryLight;
        }),
      ),

      // Splash avec ColorHelpers
      splashColor: ColorHelpers.withAlpha(primaryColor, 0.12),
      highlightColor: ColorHelpers.withAlpha(primaryColor, 0.08),
    );
  }
}
