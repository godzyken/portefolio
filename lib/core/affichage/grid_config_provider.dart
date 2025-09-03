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
  final w = ref.watch(screenSizeProvider).width;
  final isPortrait = ref.watch(isPortraitProvider);

  if (w < 200) return const GridConfig(1, 1.6); // smartwatch
  if (w < 600) return GridConfig(1, isPortrait ? 1.4 : 1.1); // mobile portrait
  if (w < 800) return const GridConfig(2, 1.2); // mobile paysage
  if (w < 1024) return GridConfig(isPortrait ? 2 : 3, 1.0); // tablette portrait
  if (w < 1440) return const GridConfig(3, 0.9); // desktop standard
  if (w < 1920) return GridConfig(isPortrait ? 3 : 4, 0.9); // desktop large
  return GridConfig(isPortrait ? 4 : 6, 0.85); // TV / 4K
});

final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
  (_) => GlobalKey<NavigatorState>(),
);
