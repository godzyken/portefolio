import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../config/image_preload_config.dart';

/// 🎯 Gestionnaire unifié d'images avec cache intelligent
class UnifiedImageManager with ChangeNotifier {
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

  int _totalToLoad = 0;

  /// Initialise le gestionnaire (à appeler au démarrage)
  Future<void> initialize({ImageConfiguration? config}) async {
    if (_initialized) return;

    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // On vide pour repartir propre
      _assetManifest.clear();

      for (String path in manifestMap.keys) {
        if (path.startsWith('assets/images/')) {
          _assetManifest[path] = path;
          // On remplit automatiquement la config ici si besoin
          ImagePreloadConfig.registerImage(path);
        }
      }

      _baseConfig = config ?? const ImageConfiguration();
      _initialized = true;
      developer
          .log('✅ Manager initialisé avec ${_assetManifest.length} images.');
    } catch (e) {
      developer.log('❌ Erreur initialisation Manager: $e');
    }
  }

  List<String> getAssetPaths() => _assetManifest.keys.toList();

  /// Précharge une image (raster ou SVG)
  Future<bool> preloadImage(String path,
      {BuildContext? context,
      Duration timeout = const Duration(seconds: 3)}) async {
    if (!_initialized) return false;

    String cleanPath = path.trim();
    if (cleanPath.startsWith('assets/assets/')) {
      cleanPath = cleanPath.replaceFirst('assets/assets/', 'assets/');
    }

    final lowerPath = cleanPath.toLowerCase();

    if (_loadedPaths.contains(cleanPath)) return true;
    if (_loadingPaths.contains(cleanPath)) return false;

    // 1. GESTION JSON/Lottie : On marque comme "chargé" mais on ne décode pas en image
    if (lowerPath.endsWith('.json')) {
      _loadedPaths.add(cleanPath);
      notifyListeners();
      return true;
    }

    // 2. GESTION SVG : Branchement exclusif
    if (lowerPath.endsWith('.svg')) {
      if (_loadedPaths.contains(cleanPath)) return true;
      _loadingPaths.add(cleanPath);
      try {
        await _preloadSvg(cleanPath, cleanPath.startsWith('http'), context);
        _loadedPaths.add(cleanPath);
        return true;
      } catch (e) {
        _failedPaths.add(cleanPath);
        return false;
      } finally {
        _loadingPaths.remove(cleanPath);
        notifyListeners();
      }
    }

    // 3. GESTION RASTER (PNG, JPG, WEBP)
    final bool isRaster = lowerPath.endsWith('.png') ||
        lowerPath.endsWith('.jpg') ||
        lowerPath.endsWith('.jpeg') ||
        lowerPath.endsWith('.webp');

    if (isRaster) {
      if (_loadedPaths.contains(cleanPath)) return true;
      _loadingPaths.add(cleanPath);
      try {
        await _preloadRaster(cleanPath, cleanPath.startsWith('http'), timeout);
        _loadedPaths.add(cleanPath);
        return true;
      } catch (e) {
        _failedPaths.add(cleanPath);
        return false;
      } finally {
        _loadingPaths.remove(cleanPath);
        notifyListeners();
      }
    }

    return false;
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

      // On lance le batch
      final results = await Future.wait(
        batch.map((path) async {
          final result = await preloadImage(path, context: context);
          notifyListeners();
          return result;
        }),
      );

      success += results.where((r) => r).length;
      failed += results.where((r) => !r).length;

      // Petite respiration pour l'UI Thread
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
      totalAssets: _totalToLoad > 0 ? _totalToLoad : _assetManifest.length,
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

  void setTotalToLoad(int total) {
    _totalToLoad = total;
    notifyListeners();
  }

  int getTotalToLoad() {
    return _totalToLoad;
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
      final PictureInfo pictureInfo = await vg.loadPicture(loader, null);
      _svgCache[path] = pictureInfo;
    } catch (e) {
      developer.log('⚠️ Erreur chargement SVG: $path ($e)');
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

    int totalSuccess = 0;
    int totalFailed = 0;

    // --- PHASE 1 : CRITIQUE (Bloquant pour le Splash) ---
    if (critical.isNotEmpty) {
      developer.log('🚀 Chargement de ${critical.length} assets critiques...');
      final res = await preloadBatch(critical, context: context, batchSize: 3);
      totalSuccess += res.success;
      totalFailed += res.failed;
    }

    // --- PHASE 2 : LAZY (Chargement séquentiel fluide) ---
    if (lazy.isNotEmpty) {
      // Petite pause pour laisser l'UI respirer après les critiques
      await Future.delayed(const Duration(milliseconds: 200));
      final res = await preloadBatch(lazy, context: context, batchSize: 5);
      totalSuccess += res.success;
      totalFailed += res.failed;
    }

    // --- PHASE 3 : BACKGROUND (Non-bloquant) ---
    if (background.isNotEmpty) {
      // On lance sans 'await' pour rendre la main au Splash rapidement
      preloadBatch(background, context: context, batchSize: 2).then((res) {
        developer.log('✅ Background preload terminé (${res.success} succès)');
      });
    }

    return PreloadResult(totalSuccess, totalFailed);
  }
}
