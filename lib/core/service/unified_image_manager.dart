import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:portefolio/core/config/image_preload_config.dart';

/// 🎯 Gestionnaire unifié d'images avec cache intelligent
class UnifiedImageManager {
  static final UnifiedImageManager _instance = UnifiedImageManager._internal();
  factory UnifiedImageManager() => _instance;
  UnifiedImageManager._internal();

  // Caches séparés par type
  final Map<String, ImageProvider> _rasterCache = {};
  final Map<String, PictureInfo> _svgCache = {};
  final Map<String, String> _assetManifest = {};

  // État du chargement
  final Set<String> _loadingPaths = {};
  final Set<String> _loadedPaths = {};
  final Set<String> _failedPaths = {};

  // Configuration
  ImageConfiguration? _baseConfig;
  bool _initialized = false;

  /// Initialise le gestionnaire (à appeler au démarrage)
  Future<void> initialize({
    ImageConfiguration? config,
  }) async {
    if (_initialized) return;

    try {
      // 1. Lire le manifest de Flutter pour connaître TOUS les fichiers
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // Nettoyage des clés (parfois le manifest contient des variantes 2.0x, 3.0x en clés)
      final allPaths = manifestMap.keys.toList();

      // 2. Filtrer et envoyer vers ImagePreloadConfig
      for (String path in allPaths) {
        // Sécurité : Ignorer les doublons de préfixe et dossiers systèmes
        if (path.startsWith('assets/images/') && !path.contains('/. ')) {
          _assetManifest[path] = path; // On stocke pour isAvailable()
          ImagePreloadConfig.registerImage(path);
        }
      }

      _baseConfig = config ?? ImageConfiguration();
      _initialized = true;

      // 3. Lancer le préchargement "intelligent" par batch
      // On ne 'await' pas forcément tout ici pour ne pas bloquer le Splash indéfiniment
      // mais on lance le processus.
      _startSmartPreload();
    } catch (e) {
      developer.log('❌ Erreur initialisation Manager: $e');
      // On ne throw pas pour éviter de crash l'app si un asset manque
    }
  }

  Future<void> _startSmartPreload() async {
    // Récupère la liste triée (Logo d'abord, puis logos tech, puis projets...)
    final imagesToLoad = ImagePreloadConfig.allImagesToPreload;

    // On charge par batch de 3 pour ne pas saturer le thread UI
    for (var i = 0; i < imagesToLoad.length; i += 3) {
      final end = (i + 3 < imagesToLoad.length) ? i + 3 : imagesToLoad.length;
      final batch = imagesToLoad.sublist(i, end);

      await Future.wait(batch.map((img) => preloadImage(img.path)));

      // Petite pause pour laisser l'UI respirer et l'animation du Splash tourner
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  /// Précharge une image (raster ou SVG)
  Future<bool> preloadImage(
    String path, {
    BuildContext? context,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    if (!_initialized) {
      developer.log('⚠️ Manager non initialisé, appel initialize() d\'abord');
      return false;
    }

    // 1. Nettoyage du chemin (Supprime les espaces et gère la casse)
    final cleanPath = path.trim();
    final lowerPath = cleanPath.toLowerCase();

    // Déjà chargée ou en cours
    if (_loadedPaths.contains(path)) return true;
    if (_loadingPaths.contains(path)) return false;
    if (_failedPaths.contains(path)) return false;

    // 🔹 Sécurité : Ignorer les fichiers qui ne sont pas des images (évite l'erreur ImageCodecException)
    if (lowerPath.endsWith('.json')) {
      developer.log('ℹ️ Skip JSON dans preloadImage: $path');
      return true;
    }

    final bool isSvg = lowerPath.split('?').first.endsWith('.svg');
    final bool isRaster = lowerPath.endsWith('.png') ||
        lowerPath.endsWith('.jpg') ||
        lowerPath.endsWith('.jpeg') ||
        lowerPath.endsWith('.webp');

    _loadingPaths.add(path);

    try {
      if (isSvg) {
        // ✅ Utilise impérativement le loader SVG
        await _preloadSvg(cleanPath, cleanPath.startsWith('http'), context);
      } else if (isRaster) {
        // ✅ Utilise le loader de pixels
        await _preloadRaster(cleanPath, cleanPath.startsWith('http'), timeout);
      } else {
        developer.log('ℹ️ Format ignoré (non supporté): $cleanPath');
        _loadingPaths.remove(cleanPath);
        return false;
      }

      _loadedPaths.add(cleanPath);
      _loadingPaths.remove(cleanPath);
      return true;
    } catch (e) {
      developer.log('⚠️ Échec préchargement: $cleanPath ($e)');
      _failedPaths.add(cleanPath);
      _loadingPaths.remove(cleanPath);
      return false;
    }
  }

  /// Précharge plusieurs images en batch
  Future<PreloadResult> preloadBatch(
    List<String> paths, {
    BuildContext? context,
    int batchSize = 5,
    Duration delayBetweenBatches = const Duration(milliseconds: 100),
  }) async {
    int success = 0;
    int failed = 0;

    for (int i = 0; i < paths.length; i += batchSize) {
      final batch = paths.skip(i).take(batchSize).toList();

      final results = await Future.wait(
        batch.map((path) => preloadImage(path, context: context)),
      );

      success += results.where((r) => r).length;
      failed += results.where((r) => !r).length;

      if (i + batchSize < paths.length) {
        await Future.delayed(delayBetweenBatches);
      }
    }

    developer.log('📦 Batch terminé: $success succès, $failed échecs');
    return PreloadResult(success, failed);
  }

  /// Obtient une ImageProvider depuis le cache
  ImageProvider? getCachedImage(String path) {
    if (_rasterCache.containsKey(path)) {
      return _rasterCache[path];
    }
    return null;
  }

  /// Obtient un SVG depuis le cache
  PictureInfo? getCachedSvg(String path) {
    return _svgCache[path];
  }

  /// Vérifie si une image est disponible
  bool isAvailable(String path) {
    return _assetManifest.containsKey(path) || path.startsWith('http');
  }

  /// Obtient les statistiques du cache
  CacheStats getStats() {
    return CacheStats(
      totalAssets: _assetManifest.length,
      loadedRaster: _rasterCache.length,
      loadedSvg: _svgCache.length,
      failed: _failedPaths.length,
      loading: _loadingPaths.length,
    );
  }

  /// Nettoie le cache
  void clearCache() {
    for (final info in _svgCache.values) {
      info.picture.dispose();
    }

    _rasterCache.clear();
    _svgCache.clear();
    _loadedPaths.clear();
    _failedPaths.clear();
    developer.log('🧹 Cache nettoyé et ressources SVG libérées');
  }

  /// Retire une image spécifique du cache
  void evict(String path) {
    _rasterCache.remove(path);
    _svgCache.remove(path);
    _loadedPaths.remove(path);
    _failedPaths.remove(path);
  }

  // ============================================================================
  // MÉTHODES PRIVÉES
  // ============================================================================

  Future<void> _preloadRaster(
    String path,
    bool isNetwork,
    Duration timeout, {
    int? cacheWidth,
  }) async {
    ImageProvider provider =
        isNetwork ? NetworkImage(path) : AssetImage(path) as ImageProvider;

    if (cacheWidth != null && !isNetwork) {
      provider = ResizeImage(provider as AssetImage, width: cacheWidth);
    }

    final completer = Completer<void>();

    final ImageConfiguration config = _baseConfig ?? const ImageConfiguration();
    final ImageStream stream = provider.resolve(config);

    ImageStreamListener? listener;

    listener = ImageStreamListener(
      (ImageInfo info, bool sync) {
        if (!completer.isCompleted) {
          _rasterCache[path] = provider;

          info.dispose();

          completer.complete();
        }
        stream.removeListener(listener!);
      },
      onError: (error, stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
        stream.removeListener(listener!);
      },
    );

    stream.addListener(listener);

    try {
      await completer.future.timeout(
        timeout,
        onTimeout: () {
          stream.removeListener(listener!);
          throw TimeoutException('Timeout lors du chargement de $path');
        },
      );
    } on TimeoutException {
      stream.removeListener(listener);

      rethrow;
    } catch (e) {
      stream.removeListener(listener);
      rethrow;
    }
  }

  Future<void> _preloadSvg(
    String path,
    bool isNetwork,
    BuildContext? context,
  ) async {
    try {
      final loader = isNetwork ? SvgNetworkLoader(path) : SvgAssetLoader(path);

      // Charger en mémoire
      final pictureInfo = await vg.loadPicture(loader, context);
      _svgCache[path] = pictureInfo;
    } catch (e) {
      developer.log('⚠️ Erreur chargement SVG: $path ($e)');
      rethrow;
    }
  }
}

// ============================================================================
// CLASSES DE DONNÉES
// ============================================================================

class PreloadResult {
  final int success;
  final int failed;

  const PreloadResult(this.success, this.failed);

  int get total => success + failed;
  double get successRate => total > 0 ? success / total : 0.0;

  @override
  String toString() => 'PreloadResult(success: $success, failed: $failed)';
}

class CacheStats {
  final int totalAssets;
  final int loadedRaster;
  final int loadedSvg;
  final int failed;
  final int loading;

  const CacheStats({
    required this.totalAssets,
    required this.loadedRaster,
    required this.loadedSvg,
    required this.failed,
    required this.loading,
  });

  int get totalLoaded => loadedRaster + loadedSvg;
  double get loadProgress => totalAssets > 0 ? totalLoaded / totalAssets : 0.0;

  @override
  String toString() => '''
CacheStats(
  total: $totalAssets,
  raster: $loadedRaster,
  svg: $loadedSvg,
  failed: $failed,
  loading: $loading,
  progress: ${(loadProgress * 100).toStringAsFixed(1)}%
)''';
}

// ============================================================================
// STRATÉGIES DE PRÉCHARGEMENT
// ============================================================================

enum PreloadStrategy {
  critical, // Charger immédiatement
  lazy, // Charger à la demande
  background, // Charger en arrière-plan
}

class ImagePriority {
  final String path;
  final PreloadStrategy strategy;
  final int priority; // 0 = max priority

  const ImagePriority(
    this.path, {
    this.strategy = PreloadStrategy.lazy,
    this.priority = 5,
  });
}

/// Extension pour faciliter le préchargement avec priorités
extension UnifiedImageManagerExtension on UnifiedImageManager {
  Future<PreloadResult> preloadWithPriorities(
    List<ImagePriority> images, {
    BuildContext? context,
  }) async {
    // Trier par priorité
    final sorted = List<ImagePriority>.from(images)
      ..sort((a, b) => a.priority.compareTo(b.priority));

    // Séparer par stratégie
    final critical = sorted
        .where((i) => i.strategy == PreloadStrategy.critical)
        .map((i) => i.path)
        .toList();

    final lazy = sorted
        .where((i) => i.strategy == PreloadStrategy.lazy)
        .map((i) => i.path)
        .toList();

    final background = sorted
        .where((i) => i.strategy == PreloadStrategy.background)
        .map((i) => i.path)
        .toList();

    // Charger les critiques en premier
    final criticalResult = await preloadBatch(critical, context: context);

    // Charger les lazy (avec délai)
    await Future.delayed(const Duration(milliseconds: 500));
    final lazyResult = await preloadBatch(lazy, context: context);

    // Lancer les background en Fire & Forget
    if (background.isNotEmpty) {
      _preloadBackgroundImages(background, context);
    }

    return PreloadResult(
      criticalResult.success + lazyResult.success,
      criticalResult.failed + lazyResult.failed,
    );
  }

  void _preloadBackgroundImages(List<String> paths, BuildContext? context) {
    Future(() async {
      for (final path in paths) {
        await preloadImage(path, context: context);
        await Future.delayed(const Duration(milliseconds: 200));
      }
      developer.log('✅ Background preload terminé (${paths.length} images)');
    });
  }
}
