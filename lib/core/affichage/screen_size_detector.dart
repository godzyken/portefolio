import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/notifier/notifiers.dart';

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
enum DeviceType { watch, mobile, tablet, desktop, largeDesktop }

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
  final orientation = size.width > 0
      ? (size.width >= size.height
          ? Orientation.landscape
          : Orientation.portrait)
      : Orientation.portrait;

  final w = size.width;

  late DeviceType type;
  late GridConfig grid;

  if (w < Breakpoints.watch) {
    type = DeviceType.watch;
    grid = const GridConfig(1, 1.6);
  } else if (w < Breakpoints.mobile) {
    type = DeviceType.mobile;
    grid = GridConfig(1, orientation == Orientation.portrait ? 1.4 : 1.1);
  } else if (w < Breakpoints.smallTablet) {
    type = DeviceType.mobile;
    grid = const GridConfig(2, 1.2);
  } else if (w < Breakpoints.tablet) {
    type = DeviceType.tablet;
    grid = GridConfig(orientation == Orientation.portrait ? 2 : 3, 1.0);
  } else if (w < Breakpoints.desktop) {
    type = DeviceType.desktop;
    grid = const GridConfig(3, 0.9);
  } else if (w < Breakpoints.largeDesktop) {
    type = DeviceType.largeDesktop;
    grid = GridConfig(orientation == Orientation.portrait ? 3 : 4, 0.9);
  } else {
    type = DeviceType.largeDesktop;
    grid = GridConfig(orientation == Orientation.portrait ? 4 : 6, 0.85);
  }

  final cardWidth = w / grid.columns - 16; // padding/marge
  final cardHeightRatio = switch (type) {
    DeviceType.watch => 1.6,
    DeviceType.mobile => 0.85,
    DeviceType.tablet => 0.7,
    DeviceType.desktop => 0.5,
    DeviceType.largeDesktop => 0.6,
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
