import 'package:flutter/material.dart';

import 'screen_size_detector.dart';

/// 🎨 Classe centralisée pour gérer TOUS les aspects responsive
class ResponsiveHelper {
  final ResponsiveInfo info;

  const ResponsiveHelper(this.info);

  // ============================================================================
  // 📏 SPACING (marges, padding)
  // ============================================================================

  /// Padding adaptatif selon la taille d'écran
  EdgeInsets get screenPadding => EdgeInsets.all(
        info.isWatch
            ? 8
            : info.isMobile
                ? 16
                : info.isTablet
                    ? 24
                    : 32,
      );

  /// Spacing horizontal adaptatif
  double get horizontalSpacing => info.isWatch
      ? 8
      : info.isMobile
          ? 12
          : info.isTablet
              ? 16
              : 24;

  /// Spacing vertical adaptatif
  double get verticalSpacing => info.isWatch
      ? 6
      : info.isMobile
          ? 10
          : info.isTablet
              ? 14
              : 20;

  /// Gap entre les sections
  double get sectionGap => info.isWatch
      ? 16
      : info.isMobile
          ? 24
          : info.isTablet
              ? 32
              : 48;

  // ============================================================================
  // 📝 FONT SIZES
  // ============================================================================

  /// Titre principal (H1)
  double get displayLarge => info.isWatch
      ? 18
      : info.isMobile
          ? 28
          : info.isTablet
              ? 36
              : 48;

  /// Titre secondaire (H2)
  double get displayMedium => info.isWatch
      ? 16
      : info.isMobile
          ? 24
          : info.isTablet
              ? 30
              : 40;

  /// Titre de section (H3)
  double get displaySmall => info.isWatch
      ? 14
      : info.isMobile
          ? 20
          : info.isTablet
              ? 26
              : 32;

  /// Titre de carte/widget (H4)
  double get headlineMedium => info.isWatch
      ? 13
      : info.isMobile
          ? 16
          : info.isTablet
              ? 20
              : 24;

  /// Sous-titre
  double get titleMedium => info.isWatch
      ? 12
      : info.isMobile
          ? 14
          : info.isTablet
              ? 16
              : 18;

  /// Corps de texte
  double get bodyLarge => info.isWatch
      ? 11
      : info.isMobile
          ? 14
          : info.isTablet
              ? 16
              : 16;

  /// Petit texte (captions, labels)
  double get bodySmall => info.isWatch
      ? 9
      : info.isMobile
          ? 12
          : info.isTablet
              ? 13
              : 14;

  // ============================================================================
  // 🖼️ IMAGE & ICON SIZES
  // ============================================================================

  /// Taille des icônes principales
  double get iconSize => info.isWatch
      ? 16
      : info.isMobile
          ? 24
          : info.isTablet
              ? 28
              : 32;

  /// Taille des petites icônes (trailing, etc.)
  double get iconSizeSmall => info.isWatch
      ? 12
      : info.isMobile
          ? 16
          : info.isTablet
              ? 20
              : 24;

  /// Taille des icônes décoratives (grandes)
  double get iconSizeLarge => info.isWatch
      ? 24
      : info.isMobile
          ? 40
          : info.isTablet
              ? 56
              : 72;

  /// Taille du profil / avatar
  double get avatarSize => info.isWatch
      ? 40
      : info.isMobile
          ? 80
          : info.isTablet
              ? 120
              : 160;

  /// Taille des images de card
  double get cardImageHeight => info.isWatch
      ? 80
      : info.isMobile
          ? 150
          : info.isTablet
              ? 200
              : 250;

  // ============================================================================
  // 📦 LAYOUT
  // ============================================================================

  /// Nombre de colonnes pour une grille
  int get gridColumns => info.isWatch
      ? 1
      : info.isMobile
          ? 1
          : info.isTablet
              ? 2
              : info.isDesktop
                  ? 3
                  : 4;

  /// Aspect ratio des cards
  double get cardAspectRatio => info.isWatch
      ? 1.0
      : info.isMobile
          ? 0.85
          : info.isTablet
              ? 0.75
              : 0.7;

  /// Border radius adaptatif
  double get borderRadius => info.isWatch
      ? 8
      : info.isMobile
          ? 12
          : info.isTablet
              ? 16
              : 20;

  /// Elevation des cards
  double get cardElevation => info.isWatch
      ? 2
      : info.isMobile
          ? 4
          : info.isTablet
              ? 6
              : 8;

  // ============================================================================
  // 🎯 BUTTONS
  // ============================================================================

  /// Padding des boutons
  EdgeInsets get buttonPadding => EdgeInsets.symmetric(
        horizontal: info.isWatch
            ? 12
            : info.isMobile
                ? 20
                : info.isTablet
                    ? 24
                    : 32,
        vertical: info.isWatch
            ? 8
            : info.isMobile
                ? 12
                : info.isTablet
                    ? 16
                    : 18,
      );

  /// Taille du texte des boutons
  double get buttonFontSize => info.isWatch
      ? 11
      : info.isMobile
          ? 14
          : info.isTablet
              ? 16
              : 16;

  // ============================================================================
  // 🧮 HELPERS
  // ============================================================================

  /// Retourne une valeur selon le type d'écran
  T valueByDevice<T>({
    required T watch,
    required T mobile,
    required T tablet,
    required T desktop,
    required T largeDesktop,
  }) {
    if (info.isWatch) return watch;
    if (info.isMobile) return mobile;
    if (info.isTablet) return tablet;
    if (info.isDesktop) return desktop;
    return largeDesktop;
  }

  /// Version simplifiée avec 3 valeurs
  T valueBySize<T>({
    required T small,
    required T medium,
    required T large,
  }) {
    if (info.isWatch || info.isMobile) return small;
    if (info.isTablet) return medium;
    return large;
  }

  /// Clamp une valeur entre min et max selon l'écran
  double clampByDevice({
    required double value,
    double? minWatch,
    double? minMobile,
    double? minTablet,
    double? minDesktop,
    double? maxWatch,
    double? maxMobile,
    double? maxTablet,
    double? maxDesktop,
  }) {
    double? min;
    double? max;

    if (info.isWatch) {
      min = minWatch;
      max = maxWatch;
    } else if (info.isMobile) {
      min = minMobile;
      max = maxMobile;
    } else if (info.isTablet) {
      min = minTablet;
      max = maxTablet;
    } else {
      min = minDesktop;
      max = maxDesktop;
    }

    if (min != null && value < min) return min;
    if (max != null && value > max) return max;
    return value;
  }
}

// ============================================================================
// 🎯 EXTENSION POUR ACCÉDER FACILEMENT
// ============================================================================

extension ResponsiveInfoExtension on ResponsiveInfo {
  ResponsiveHelper get helper => ResponsiveHelper(this);
}
