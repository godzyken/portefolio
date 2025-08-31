import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';

/// Objet immuable retourné par le provider
class GridConfig {
  final int columns;
  final double aspectRatio;
  const GridConfig(this.columns, this.aspectRatio);
}

final gridConfigProvider = Provider<GridConfig>((ref) {
  final Size size = ref.watch(screenSizeProvider);
  final double width = size.width;

  if (width >= 1400) {
    return const GridConfig(4, 1.15); // desktop large
  } else if (width >= 1000) {
    return const GridConfig(3, 1.10); // laptop
  } else if (width >= 680) {
    return const GridConfig(2, 0.95); // tablette
  } else {
    return const GridConfig(1, 1.50); // mobile = liste
  }
});

final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
  (_) => GlobalKey<NavigatorState>(),
);
