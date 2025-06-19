import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Taille brute de l’écran (mise à jour par ResponsiveScope)
final screenSizeProvider = StateProvider<Size>((_) => Size.zero);

/// Vues pratiques
final isMobileProvider =
    Provider<bool>((ref) => ref.watch(screenSizeProvider).width < 600);
final isTabletProvider = Provider<bool>((ref) {
  final w = ref.watch(screenSizeProvider).width;
  return w >= 600 && w < 1024;
});
final isDesktopProvider =
    Provider<bool>((ref) => ref.watch(screenSizeProvider).width >= 1024);

/// Combien de colonnes pour un Grid
final columnsProvider = Provider<int>((ref) {
  final w = ref.watch(screenSizeProvider).width;
  if (w < 600) return 1;
  if (w < 1024) return 2;
  return 4; // desktop large
});

/// Orientation
final isPortraitProvider = Provider<bool>((ref) {
  final size = ref.watch(screenSizeProvider);
  return size.height >= size.width;
});
