import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import '../service/unified_image_manager.dart';

class ImagePreloadConfig {
  static List<ImagePriority> get criticalImages => [
        // Logo (priorité max)
        ImagePriority(
          'assets/images/entreprises/logo_godzyken.png',
          strategy: PreloadStrategy.critical,
          priority: 0,
        ),

        // Avatar principal
        ImagePriority(
          'assets/images/pers_do_am.png',
          strategy: PreloadStrategy.critical,
          priority: 1,
        ),

        // Logos de techs principales
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

  static List<ImagePriority> get lazyImages => [
        // Images de projets (lazy loading)
        ImagePriority(
          'assets/images/realisations/business_app.svg',
          strategy: PreloadStrategy.lazy,
          priority: 5,
        ),
        // ... autres images
      ];

  static List<ImagePriority> get backgroundImages => [
        // Images non critiques
        ImagePriority(
          'assets/images/backgrounds/line.svg',
          strategy: PreloadStrategy.background,
          priority: 10,
        ),
        ImagePriority(
          'assets/images/backgrounds/frise_mur.png',
          strategy: PreloadStrategy.background,
          priority: 10,
        ),
        ImagePriority(
          'assets/images/backgrounds/tapis_poker.png',
          strategy: PreloadStrategy.background,
          priority: 10,
        ),
      ];

  // Liste dynamique pour les images détectées dans les cards
  static final Set<String> _dynamicPaths = {};

  static List<ImagePriority> get allImagesToPreload {
    final List<ImagePriority> list = [];

    // 1. On récupère TOUS les assets connus par l'app (via le manifest)
    // C'est ici que la magie opère pour ne pas tout lister à la main.
    final List<String> allAssets = _getAllAvailableAssets();

    for (String path in allAssets) {
      // Ignorer ce qui n'est pas une image
      if (!path.contains('assets/images/')) continue;

      // --- LOGIQUE DE PRIORITÉ PAR DOSSIER ---

      // PRIORITÉ 0 : Ton Logo (Le plus critique)
      if (path.contains('logo_godzyken.png')) {
        list.add(ImagePriority(path,
            strategy: PreloadStrategy.critical, priority: 0));
      }
      // PRIORITÉ 1 : Éléments d'identité (Avatar, logos tech)
      else if (path.contains('/entreprises/') || path.contains('/logos/')) {
        list.add(ImagePriority(path,
            strategy: PreloadStrategy.critical, priority: 1));
      }
      // PRIORITÉ 2 : Services (Souvent sur la Home)
      else if (path.contains('/services/')) {
        list.add(
            ImagePriority(path, strategy: PreloadStrategy.lazy, priority: 2));
      }
      // PRIORITÉ 3 : Réalisations / Projets
      else if (path.contains('/realisations/')) {
        list.add(
            ImagePriority(path, strategy: PreloadStrategy.lazy, priority: 3));
      }
      // PRIORITÉ 4 : Workshop et images en vrac
      else {
        list.add(ImagePriority(path,
            strategy: PreloadStrategy.background, priority: 10));
      }
    }

    // On ajoute les images enregistrées dynamiquement par les widgets
    for (var path in _dynamicPaths) {
      if (!list.any((e) => e.path == path)) {
        list.add(
            ImagePriority(path, strategy: PreloadStrategy.lazy, priority: 5));
      }
    }

    // On trie par priorité (0 étant le plus urgent)
    list.sort((a, b) => a.priority.compareTo(b.priority));
    return list;
  }

  static void registerImage(String path,
      {PreloadStrategy strategy = PreloadStrategy.lazy}) {
    if (path.isNotEmpty) _dynamicPaths.add(path);
  }

  /// Helper pour extraire les chemins du manifest de Flutter
  static List<String> _getAllAvailableAssets() {
    // Cette liste est normalement générée au build.
    // Pour être 100% automatique, tu peux utiliser le rootBundle (voir AssetValidator)
    // Mais pour la config, on peut aussi lister les dossiers clés.
    return []; // À remplir via le chargement du AssetManifest
  }

  static bool get shouldLimitCache => kIsWeb && _isMobileBrowser();

  static bool _isMobileBrowser() {
    // Logique simple pour détecter un navigateur mobile
    final userAgent = ui.PlatformDispatcher.instance.views.first
        .platformDispatcher.defaultRouteName;
    return userAgent.contains('iPhone') || userAgent.contains('Android');
  }
}
