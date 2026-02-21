import 'package:flutter/foundation.dart';

import '../service/unified_image_manager.dart';

/// Configuration et registre du précache d'images.
///
/// Plus aucune liste statique à maintenir à la main :
/// [registerImage] est appelé par [runOptimizedPrecache] après lecture
/// du manifest Flutter, et [allImagesToPreload] assemble tout.
class ImagePreloadConfig {
  ImagePreloadConfig._();

  // -------------------------------------------------------------------------
  // Images critiques (déclarées statiquement, garanties en priorité 0-3)
  // -------------------------------------------------------------------------

  static const List<ImagePriority> _staticCritical = [
    ImagePriority(
      'assets/images/entreprises/logo_godzyken.png',
      strategy: PreloadStrategy.critical,
      priority: 0,
    ),
    ImagePriority(
      'assets/images/pers_do_am.png',
      strategy: PreloadStrategy.critical,
      priority: 1,
    ),
    ImagePriority(
      'assets/images/logos/flutter.svg',
      strategy: PreloadStrategy.critical,
      priority: 2,
    ),
    ImagePriority(
      'assets/images/logos/dart.svg',
      strategy: PreloadStrategy.critical,
      priority: 3,
    ),
  ];

  // -------------------------------------------------------------------------
  // Registre dynamique (alimenté par runOptimizedPrecache via le manifest)
  // -------------------------------------------------------------------------

  static final Set<String> _dynamicPaths = {};

  /// Enregistre un chemin découvert dynamiquement depuis le manifest Flutter.
  /// Idempotent — les doublons sont ignorés.
  static void registerImage(String path, {PreloadStrategy? strategy}) {
    if (path.isNotEmpty) _dynamicPaths.add(path);
  }

  /// Remet à zéro le registre dynamique (utile en test).
  static void clearDynamic() => _dynamicPaths.clear();

  // -------------------------------------------------------------------------
  // Liste unifiée et triée par priorité
  // -------------------------------------------------------------------------

  static List<ImagePriority> get allImagesToPreload {
    final seen = <String>{};
    final list = <ImagePriority>[];

    // 1. Images statiques critiques en tête
    for (final img in _staticCritical) {
      if (seen.add(img.path)) list.add(img);
    }

    // 2. Images découvertes via le manifest
    for (final path in _dynamicPaths) {
      if (!seen.add(path)) continue;

      // Exclure les variantes de résolution générées par generate_all_assets_variants.py
      final lower = path.toLowerCase();
      if (lower.contains('/2.0x/') || lower.contains('/3.0x/')) continue;

      list.add(_priorityFor(path));
    }

    list.sort((a, b) => a.priority.compareTo(b.priority));
    return list;
  }

  // -------------------------------------------------------------------------
  // Règles de priorité par dossier
  // -------------------------------------------------------------------------

  static ImagePriority _priorityFor(String path) {
    if (path.contains('logo_godzyken')) {
      return ImagePriority(path,
          strategy: PreloadStrategy.critical, priority: 0);
    }
    if (path.contains('/entreprises/') || path.contains('/logos/')) {
      return ImagePriority(path,
          strategy: PreloadStrategy.critical, priority: 1);
    }
    if (path.contains('/services/')) {
      return ImagePriority(path, strategy: PreloadStrategy.lazy, priority: 2);
    }
    if (path.contains('/realisations/')) {
      return ImagePriority(path, strategy: PreloadStrategy.lazy, priority: 3);
    }
    if (path.contains('/animations/')) {
      return ImagePriority(path, strategy: PreloadStrategy.lazy, priority: 4);
    }
    // backgrounds, WorkShop, Emap, models, etc.
    return ImagePriority(path,
        strategy: PreloadStrategy.background, priority: 10);
  }

  // -------------------------------------------------------------------------
  // Détection navigateur mobile (Web-safe, sans dart:html direct)
  // -------------------------------------------------------------------------

  /// Réduit le cache image sur navigateurs mobiles pour éviter les OOM.
  static bool get shouldLimitCache => kIsWeb && _isMobileBrowser();

  static bool _isMobileBrowser() {
    if (!kIsWeb) return false;
    // dart:html ne doit pas être importé directement dans un fichier non conditionnel
    // → on délègue à une méthode platform-stub si nécessaire.
    // Par défaut on retourne false ; override via web_stub.dart si besoin.
    return false;
  }
}
