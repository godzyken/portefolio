import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/grid_config_provider.dart';

/// Taille brute de l’écran (mise à jour par ResponsiveScope)
final screenSizeProvider = StateProvider<Size>((_) => Size.zero);

/// Orientation
final isPortraitProvider = Provider<bool>((ref) {
  final size = ref.watch(screenSizeProvider);
  return size.height >= size.width;
});

/// Vues pratiques
final isWatchProvider = Provider<bool>(
  (ref) => ref.watch(screenSizeProvider).width < 200,
); // petites montres

final isMobileProvider = Provider<bool>(
  (ref) =>
      ref.watch(screenSizeProvider).width >= 200 &&
      ref.watch(screenSizeProvider).width < 600,
);

final isTabletProvider = Provider<bool>(
  (ref) =>
      ref.watch(screenSizeProvider).width >= 600 &&
      ref.watch(screenSizeProvider).width < 1024,
);

final isDesktopProvider = Provider<bool>(
  (ref) =>
      ref.watch(screenSizeProvider).width >= 1024 &&
      ref.watch(screenSizeProvider).width < 1920,
);

final isLargeDesktopProvider = Provider<bool>(
  (ref) => ref.watch(screenSizeProvider).width >= 1920,
);

/// Retourne `true` si la largeur logique de l'écran est très compacte
final isCompactWidthProvider = Provider<bool>(
  (ref) => ref.watch(screenSizeProvider).width < 400,
);

/// Retourne une largeur de carte adaptative selon le nombre de colonnes
final cardWidthProvider = Provider<double>((ref) {
  final w = ref.watch(screenSizeProvider).width;
  final cols = ref.watch(gridConfigProvider).columns;
  return w / cols - 16; // -16 pour le padding/margin
});

final cardHeightRatioProvider = Provider<double>((ref) {
  final isMobile = ref.watch(isMobileProvider);
  final isTablet = ref.watch(isTabletProvider);
  final isDesktop = ref.watch(isDesktopProvider);

  if (isMobile) return 0.85; // 85% sur mobile
  if (isTablet) return 0.7; // 70% sur tablette
  if (isDesktop) return 0.5; // 50% sur desktop

  return 0.6; // fallback
});
