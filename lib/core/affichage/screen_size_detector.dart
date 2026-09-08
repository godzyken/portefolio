import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifier/screen_notifiers.dart';
import 'grid_config.dart';

/// 📐 Breakpoints centralisés
class Breakpoints {
  static const double watch = 200;
  static const double mobile = 600;
  static const double smallTablet = 800;
  static const double tablet = 1024;
  static const double desktop = 1280; // Réduit à 1280 pour inclure les laptops standards
  static const double largeDesktop = 1920;
}

/// Catégorisation de l’écran
enum DeviceType { watch, mobile, smallTablet, tablet, desktop, largeDesktop }

/// Objet regroupant toutes les infos responsive
class ResponsiveInfo {
  final Size size;
  final Orientation orientation;
  final DeviceType type;
  final GridConfig grid;
  final double cardWidth;
  final double cardHeightRatio;

  const ResponsiveInfo({
    required this.size,
    required this.orientation,
    required this.type,
    required this.grid,
    required this.cardWidth,
    required this.cardHeightRatio,
  });

  bool get isPortrait => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;

  bool get isWatch => type == DeviceType.watch;
  bool get isMobile => type == DeviceType.mobile;
  bool get isSmallTablet => type == DeviceType.smallTablet;
  bool get isTablet => type == DeviceType.tablet;
  bool get isDesktop => type == DeviceType.desktop;
  bool get isLargeDesktop => type == DeviceType.largeDesktop;
}

/// Taille brute de l’écran (mise à jour par ResponsiveScope)
final screenSizeProvider =
    NotifierProvider<ScreenSizeNotifier, Size>(ScreenSizeNotifier.new);

/// Fournit un objet `ResponsiveInfo` complet
final responsiveInfoProvider = Provider<ResponsiveInfo>((ref) {
  final size = ref.watch(screenSizeProvider);
  final orientation =
      size.width >= size.height ? Orientation.landscape : Orientation.portrait;

  final width = size.width;
  final height = size.height;

  late DeviceType type;
  late GridConfig grid;

  // Utilisation de la largeur pour les breakpoints (plus fiable sur Web/Desktop)
  if (width < Breakpoints.watch) {
    type = DeviceType.watch;
    grid = const GridConfig(1, 1.6);
  } else if (width < Breakpoints.mobile) {
    type = DeviceType.mobile;
    grid = GridConfig(1, orientation == Orientation.portrait ? 1.4 : 1.1);
  } else if (width < Breakpoints.smallTablet) {
    type = DeviceType.smallTablet;
    grid = GridConfig(2, orientation == Orientation.portrait ? 1.2 : 1.0);
  } else if (width < Breakpoints.tablet) {
    type = DeviceType.tablet;
    grid = GridConfig(orientation == Orientation.portrait ? 2 : 3, 0.7);
  } else if (width < Breakpoints.desktop) {
    type = DeviceType.desktop;
    grid = GridConfig(orientation == Orientation.portrait ? 3 : 4, 0.5);
  } else {
    type = DeviceType.largeDesktop;
    grid = GridConfig(orientation == Orientation.portrait ? 4 : 6, 0.45);
  }

  // Ajustement dynamique du ratio de hauteur des cartes selon la hauteur dispo
  // Évite que les cartes soient trop hautes sur des écrans "Wide" mais peu profonds
  final cardWidth = size.width / grid.columns - 16;
  
  // Ratio adaptatif : si l'écran est très large mais peu haut (Laptop), on réduit le ratio
  final baseRatio = switch (type) {
    DeviceType.watch => 1.6,
    DeviceType.mobile => orientation == Orientation.portrait ? 0.85 : 0.6,
    DeviceType.smallTablet => orientation == Orientation.portrait ? 0.75 : 0.55,
    DeviceType.tablet => orientation == Orientation.portrait ? 0.7 : 0.5,
    DeviceType.desktop => orientation == Orientation.portrait ? 0.5 : 0.4,
    DeviceType.largeDesktop => orientation == Orientation.portrait ? 0.6 : 0.35,
  };

  // Correction si la hauteur est limitée (Laptop typique : 1366x768 ou 1440x900)
  // On réduit le ratio pour que la carte prenne moins de place verticale
  final cardHeightRatio = (height < 750 && type == DeviceType.desktop) ? baseRatio * 0.8 : baseRatio;

  return ResponsiveInfo(
    size: size,
    orientation: orientation,
    type: type,
    grid: grid,
    cardWidth: cardWidth,
    cardHeightRatio: cardHeightRatio,
  );
});
