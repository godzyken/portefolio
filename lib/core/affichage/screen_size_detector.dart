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
  static const double desktop = 1440;
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

  final shortestSide = size.shortestSide;

  late DeviceType type;
  late GridConfig grid;

  // Logique corrigée pour le DeviceType
  if (shortestSide < Breakpoints.watch) {
    type = DeviceType.watch;
    grid = const GridConfig(1, 1.6);
  } else if (shortestSide < Breakpoints.mobile) {
    // Mobile (jusqu'à 600)
    type = DeviceType.mobile;
    grid = GridConfig(1, orientation == Orientation.portrait ? 1.4 : 1.1);
  } else if (shortestSide < Breakpoints.smallTablet) {
    // Petite Tablette (600 à 800)
    type = DeviceType.smallTablet; // NOUVEAU TYPE AJOUTÉ
    grid = GridConfig(2, orientation == Orientation.portrait ? 1.2 : 1.0);
  } else if (shortestSide < Breakpoints.tablet) {
    // Tablette (800 à 1024)
    type = DeviceType.tablet;
    grid = GridConfig(orientation == Orientation.portrait ? 2 : 3, 0.7);
  } else if (shortestSide < Breakpoints.desktop) {
    // Desktop (1024 à 1440)
    type = DeviceType.desktop;
    grid = GridConfig(orientation == Orientation.portrait ? 3 : 4, 0.5);
  } else {
    // Large Desktop (1440+)
    type = DeviceType.largeDesktop;
    grid = GridConfig(orientation == Orientation.portrait ? 4 : 6, 0.45);
  }

  final cardWidth = size.width / grid.columns - 16; // padding/marge
  final cardHeightRatio = switch (type) {
    DeviceType.watch => 1.6,
    DeviceType.mobile => orientation == Orientation.portrait ? 0.85 : 0.6,
    DeviceType.smallTablet => orientation == Orientation.portrait
        ? 0.75
        : 0.55, // RATIO POUR SMALL TABLETTE
    DeviceType.tablet => orientation == Orientation.portrait ? 0.7 : 0.5,
    DeviceType.desktop => orientation == Orientation.portrait ? 0.5 : 0.4,
    DeviceType.largeDesktop => orientation == Orientation.portrait ? 0.6 : 0.35,
  };

  return ResponsiveInfo(
    size: size,
    orientation: orientation,
    type: type,
    grid: grid,
    cardWidth: cardWidth,
    cardHeightRatio: cardHeightRatio,
  );
});
