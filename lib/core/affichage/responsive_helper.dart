import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';

/// Helpers pour la gestion du responsive design
class ResponsiveHelpers {
  /// Obtient le border radius selon la taille d'écran
  static double getBorderRadius(ResponsiveInfo info) {
    if (info.isWatch) return 12;
    if (info.isMobile) return 16;
    if (info.isTablet) return 20;
    return 24;
  }

  /// Obtient le padding selon la taille d'écran
  static double getPadding(ResponsiveInfo info) {
    if (info.isWatch) return 12;
    if (info.isMobile) return 16;
    if (info.isTablet) return 20;
    return 24;
  }

  /// Obtient un espacement responsive selon 3 tailles prédéfinies
  static double getSpacing(
    ResponsiveInfo info, {
    required double small,
    required double medium,
    required double large,
  }) {
    if (info.isWatch || info.isMobile) return small;
    if (info.isTablet) return medium;
    return large;
  }

  /// Obtient une taille de police responsive
  static double getFontSize(
    ResponsiveInfo info, {
    required double small,
    required double medium,
    required double large,
  }) {
    if (info.isWatch || info.isMobile) return small;
    if (info.isTablet) return medium;
    return large;
  }

  /// Obtient la taille d'icône selon l'écran
  static double getIconSize(ResponsiveInfo info) {
    if (info.isWatch) return 20;
    if (info.isMobile) return 24;
    if (info.isTablet) return 28;
    return 32;
  }

  /// Obtient le rayon central pour les graphiques
  static double getCenterRadius(ResponsiveInfo info) {
    if (info.isWatch) return 15;
    if (info.isMobile) return 20;
    if (info.isTablet) return 25;
    return 30;
  }

  /// Obtient le rayon pour les graphiques
  static double getRadius(ResponsiveInfo info) {
    if (info.isWatch) return 35;
    if (info.isMobile) return 50;
    if (info.isTablet) return 55;
    return 60;
  }

  /// Détermine si on doit afficher le titre selon l'écran
  static bool shouldShowTitle(ResponsiveInfo info) {
    return !info.isWatch && !info.isMobile;
  }

  /// Obtient le nombre de colonnes pour une grille
  static int getGridColumns(ResponsiveInfo info) {
    if (info.isWatch) return 1;
    if (info.isMobile) return 2;
    if (info.isTablet) return 3;
    if (info.isDesktop) return 4;
    return 5;
  }

  /// Calcule l'aspect ratio selon le type d'écran
  static double getAspectRatio(ResponsiveInfo info) {
    if (info.isWatch) return 1.0;
    if (info.isMobile) return info.isPortrait ? 0.75 : 1.5;
    if (info.isTablet) return 1.2;
    return 16 / 9;
  }

  /// Obtient la largeur maximale pour le contenu
  static double getMaxContentWidth(ResponsiveInfo info) {
    if (info.isMobile) return double.infinity;
    if (info.isTablet) return 800;
    if (info.isDesktop) return 1200;
    return 1600;
  }

  /// Calcule le padding horizontal selon la largeur d'écran
  static double getHorizontalPadding(double screenWidth) {
    if (screenWidth < 600) return 16;
    if (screenWidth < 900) return 24;
    if (screenWidth < 1200) return 48;
    return 64;
  }

  /// Calcule le padding vertical selon la hauteur d'écran
  static double getVerticalPadding(double screenHeight) {
    if (screenHeight < 600) return 16;
    if (screenHeight < 800) return 24;
    return 32;
  }

  /// Obtient EdgeInsets responsive
  static EdgeInsets getEdgeInsets(ResponsiveInfo info) {
    final padding = getPadding(info);
    return EdgeInsets.all(padding);
  }

  /// Obtient EdgeInsets symétriques responsive
  static EdgeInsets getSymmetricInsets(
    ResponsiveInfo info, {
    bool horizontal = true,
    bool vertical = true,
  }) {
    final padding = getPadding(info);
    return EdgeInsets.symmetric(
      horizontal: horizontal ? padding : 0,
      vertical: vertical ? padding : 0,
    );
  }

  /// Détermine si on doit utiliser une disposition en colonne
  static bool useColumnLayout(ResponsiveInfo info) {
    return info.isMobile || info.isPortrait;
  }

  /// Détermine si on doit utiliser une disposition en ligne
  static bool useRowLayout(ResponsiveInfo info) {
    return !useColumnLayout(info);
  }

  /// Obtient la hauteur d'un élément selon l'écran
  static double getItemHeight(
    ResponsiveInfo info, {
    double? watchHeight,
    double? mobileHeight,
    double? tabletHeight,
    double? desktopHeight,
  }) {
    if (info.isWatch && watchHeight != null) return watchHeight;
    if (info.isMobile && mobileHeight != null) return mobileHeight;
    if (info.isTablet && tabletHeight != null) return tabletHeight;
    if (desktopHeight != null) return desktopHeight;

    // Fallback
    if (info.isWatch) return 60;
    if (info.isMobile) return 80;
    if (info.isTablet) return 100;
    return 120;
  }

  /// Obtient la largeur d'un élément selon l'écran
  static double getItemWidth(
    ResponsiveInfo info, {
    double? watchWidth,
    double? mobileWidth,
    double? tabletWidth,
    double? desktopWidth,
  }) {
    if (info.isWatch && watchWidth != null) return watchWidth;
    if (info.isMobile && mobileWidth != null) return mobileWidth;
    if (info.isTablet && tabletWidth != null) return tabletWidth;
    if (desktopWidth != null) return desktopWidth;

    // Fallback
    if (info.isWatch) return 60;
    if (info.isMobile) return 100;
    if (info.isTablet) return 150;
    return 200;
  }

  /// Calcule le nombre d'éléments visibles selon la largeur
  static int calculateVisibleItems(double screenWidth, double itemWidth) {
    return (screenWidth / itemWidth).floor();
  }

  /// Détermine si on doit afficher une navigation bottom
  static bool shouldShowBottomNav(ResponsiveInfo info) {
    return info.isMobile || info.isWatch;
  }

  /// Détermine si on doit afficher une navigation drawer
  static bool shouldShowDrawer(ResponsiveInfo info) {
    return info.isDesktop || info.isTablet;
  }

  /// Obtient la taille de la carte selon le type d'écran
  static Size getCardSize(ResponsiveInfo info) {
    if (info.isWatch) return const Size(100, 150);
    if (info.isMobile) return const Size(150, 200);
    if (info.isTablet) return const Size(200, 300);
    return const Size(300, 400);
  }

  /// Calcule le crossAxisCount pour GridView selon la largeur
  static int calculateCrossAxisCount(
    double width, {
    double minItemWidth = 150,
    int maxCount = 6,
  }) {
    final count = (width / minItemWidth).floor();
    return count.clamp(1, maxCount);
  }

  /// Obtient le child aspect ratio pour GridView
  static double getChildAspectRatio(ResponsiveInfo info) {
    if (info.isWatch) return 0.8;
    if (info.isMobile) return 0.75;
    if (info.isTablet) return 0.85;
    return 1.0;
  }

  /// Détermine la largeur optimale pour un dialog
  static double getDialogWidth(ResponsiveInfo info) {
    if (info.isMobile) return info.size.width * 0.9;
    if (info.isTablet) return 600;
    return 800;
  }

  /// Détermine si on doit compacter l'UI
  static bool shouldCompactUI(ResponsiveInfo info) {
    return info.isWatch || info.size.width < 400;
  }

  /// Obtient le nombre de lignes maximum pour un texte
  static int getMaxLines(
    ResponsiveInfo info, {
    int? watchLines,
    int? mobileLines,
    int? tabletLines,
    int? desktopLines,
  }) {
    if (info.isWatch && watchLines != null) return watchLines;
    if (info.isMobile && mobileLines != null) return mobileLines;
    if (info.isTablet && tabletLines != null) return tabletLines;
    if (desktopLines != null) return desktopLines;

    // Fallback
    if (info.isWatch) return 2;
    if (info.isMobile) return 3;
    return 5;
  }
}

/// Extension sur ResponsiveInfo pour ajouter des méthodes utilitaires
extension ResponsiveInfoExtensions on ResponsiveInfo {
  /// Obtient le padding standard
  double get standardPadding => ResponsiveHelpers.getPadding(this);

  /// Obtient le border radius standard
  double get standardBorderRadius => ResponsiveHelpers.getBorderRadius(this);

  /// Obtient la taille d'icône standard
  double get standardIconSize => ResponsiveHelpers.getIconSize(this);

  /// Vérifie si on doit utiliser une layout en colonne
  bool get shouldUseColumn => ResponsiveHelpers.useColumnLayout(this);

  /// Vérifie si on doit utiliser une layout en ligne
  bool get shouldUseRow => ResponsiveHelpers.useRowLayout(this);

  /// Obtient le nombre de colonnes pour une grille
  int get gridColumns => ResponsiveHelpers.getGridColumns(this);
}
