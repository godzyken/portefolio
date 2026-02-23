import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;

import '../config/image_preload_config.dart';

/// 🎯 Gestionnaire unifié d'images avec cache intelligent
///
/// CORRECTIONS v2 :
/// - Vérifie le cache Flutter natif (PaintingBinding.imageCache) avant tout chargement
/// - Filtre les variantes de résolution (/2.0x/, /3.0x/) dès l'initialisation
/// - Ne crée jamais deux streams parallèles pour le même chemin
/// - Distingue les erreurs critiques des erreurs de chargement d'assets
class UnifiedImageManager with ChangeNotifier {
  static final UnifiedImageManager _instance = UnifiedImageManager._internal();
  factory UnifiedImageManager() => _instance;
  UnifiedImageManager._internal();

  // ── Caches internes ────────────────────────────────────────────────────────

  /// Provider résolu → utilisé comme clé ImageCache Flutter
  final Map<String, ImageProvider> _rasterProviders = {};
  final Map<String, svg.PictureInfo> _svgCache = {};

  /// Chemins connus du manifest (sans variantes)
  final Map<String, String> _assetManifest = {};

  final Set<String> _loadingPaths = {};
  final Set<String> _loadedPaths = {};
  final Set<String> _failedPaths = {};

  ImageConfiguration _baseConfig = const ImageConfiguration();
  bool _initialized = false;
  int _totalToLoad = 0;

  // ── Initialisation ─────────────────────────────────────────────────────────

  /// Initialise depuis AssetManifest — idempotent.
  ///
  /// Filtre automatiquement les variantes de densité (/2.0x/, /3.0x/)
  /// qui sont gérées nativement par Flutter et ne doivent pas être
  /// préchargées manuellement (source des 400/404 sur le web).
  Future<void> initialize({ImageConfiguration? config}) async {
    if (_initialized) return;

    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final allAssets = manifest.listAssets();

      _assetManifest.clear();
      for (final path in allAssets) {
        if (!path.startsWith('assets/images/')) continue;
        // ✅ Exclure les variantes de résolution — Flutter les sélectionne
        //    automatiquement via AssetImage ; les charger manuellement
        //    provoque des requêtes 400/404 sur le serveur web.
        if (_isResolutionVariant(path)) continue;
        _assetManifest[path] = path;
        ImagePreloadConfig.registerImage(path);
      }

      _baseConfig = config ?? const ImageConfiguration();
      _initialized = true;
      developer.log(
        '✅ UnifiedImageManager — ${_assetManifest.length} assets indexés',
        name: 'ImageManager',
      );
    } catch (e, st) {
      developer.log(
        '❌ UnifiedImageManager — échec initialisation',
        name: 'ImageManager',
        error: e,
        stackTrace: st,
      );
    }
  }

  // ── Préchargement ──────────────────────────────────────────────────────────

  Future<bool> preloadImage(
    String path, {
    BuildContext? context,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    if (!_initialized) return false;

    final cleanPath = _normalizePath(path);

    // ✅ 1. Déjà chargé en interne
    if (_loadedPaths.contains(cleanPath)) return true;

    // ✅ 2. Déjà dans le cache Flutter natif (évite le double chargement)
    if (_isInFlutterCache(cleanPath)) {
      _loadedPaths.add(cleanPath);
      return true;
    }

    // ✅ 3. Chargement en cours — évite les requêtes parallèles
    if (_loadingPaths.contains(cleanPath)) return false;

    // ✅ 4. Déjà échoué — ne pas réessayer indéfiniment
    if (_failedPaths.contains(cleanPath)) return false;

    final lower = cleanPath.toLowerCase();

    // Les fichiers JSON/Lottie ne sont pas des images — on les marque loaded
    if (lower.endsWith('.json')) {
      _loadedPaths.add(cleanPath);
      return true;
    }

    if (lower.endsWith('.svg')) {
      return _preloadSvgSafe(cleanPath, context);
    }

    if (_isRasterExtension(lower)) {
      return _preloadRasterSafe(cleanPath, timeout);
    }

    return false;
  }

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
        batch.map((p) => preloadImage(p, context: context)),
      );
      success += results.where((r) => r).length;
      failed += results.where((r) => !r).length;

      if (i + batchSize < paths.length) {
        await Future.delayed(delayBetweenBatches);
      }
    }
    return PreloadResult(success, failed);
  }

  // ── Accesseurs ─────────────────────────────────────────────────────────────

  ImageProvider? getCachedImage(String path) {
    final cleanPath = _normalizePath(path);
    return _rasterProviders[cleanPath];
  }

  svg.PictureInfo? getCachedSvg(String path) {
    final cleanPath = _normalizePath(path);
    return _svgCache[cleanPath];
  }

  bool isLoaded(String path) => _loadedPaths.contains(_normalizePath(path));
  bool hasFailed(String path) => _failedPaths.contains(_normalizePath(path));

  List<String> getAssetPaths() => _assetManifest.keys.toList();

  bool isAvailable(String path) {
    final clean = _normalizePath(path);
    return _assetManifest.containsKey(clean) || clean.startsWith('http');
  }

  CacheStats getStats() => CacheStats(
        totalAssets: _totalToLoad > 0 ? _totalToLoad : _assetManifest.length,
        loadedRaster: _rasterProviders.length,
        loadedSvg: _svgCache.length,
        failed: _failedPaths.length,
        loading: _loadingPaths.length,
      );

  void setTotalToLoad(int total) {
    _totalToLoad = total;
    notifyListeners();
  }

  void clearCache() {
    for (final info in _svgCache.values) {
      info.picture.dispose();
    }
    _rasterProviders.clear();
    _svgCache.clear();
    _loadedPaths.clear();
    _failedPaths.clear();
    developer.log('🧹 Cache nettoyé', name: 'ImageManager');
  }

  void evict(String path) {
    final clean = _normalizePath(path);
    _rasterProviders.remove(clean);
    _svgCache.remove(clean);
    _loadedPaths.remove(clean);
    _failedPaths.remove(clean);
  }

  // ── Chargement interne ─────────────────────────────────────────────────────

  Future<bool> _preloadRasterSafe(String cleanPath, Duration timeout) async {
    _loadingPaths.add(cleanPath);
    try {
      final provider = cleanPath.startsWith('http')
          ? NetworkImage(cleanPath) as ImageProvider
          : AssetImage(cleanPath);

      final completer = Completer<void>();
      final stream = provider.resolve(_baseConfig);
      ImageStreamListener? listener;

      listener = ImageStreamListener(
        (ImageInfo info, bool sync) {
          if (!completer.isCompleted) {
            _rasterProviders[cleanPath] = provider;
            info.dispose();
            completer.complete();
          }
          stream.removeListener(listener!);
        },
        onError: (Object error, StackTrace? st) {
          if (!completer.isCompleted) completer.completeError(error, st);
          stream.removeListener(listener!);
        },
      );
      stream.addListener(listener);

      await completer.future.timeout(timeout, onTimeout: () {
        stream.removeListener(listener!);
        throw TimeoutException('Timeout: $cleanPath');
      });

      _loadedPaths.add(cleanPath);
      return true;
    } catch (e) {
      // ⚠️ Erreur de chargement d'asset = non critique, pas de log error
      developer.log(
        '⚠️ Asset non chargé: $cleanPath — ${e.runtimeType}',
        name: 'ImageManager',
        level: 900, // WARNING
      );
      _failedPaths.add(cleanPath);
      return false;
    } finally {
      _loadingPaths.remove(cleanPath);
      notifyListeners();
    }
  }

  Future<bool> _preloadSvgSafe(String cleanPath, BuildContext? context) async {
    _loadingPaths.add(cleanPath);
    try {
      final loader = cleanPath.startsWith('http')
          ? svg.SvgNetworkLoader(cleanPath)
          : svg.SvgAssetLoader(cleanPath);
      final pictureInfo = await svg.vg.loadPicture(loader, null);
      _svgCache[cleanPath] = pictureInfo;
      _loadedPaths.add(cleanPath);
      return true;
    } catch (e) {
      developer.log('⚠️ SVG non chargé: $cleanPath — ${e.runtimeType}',
          name: 'ImageManager', level: 900);
      _failedPaths.add(cleanPath);
      return false;
    } finally {
      _loadingPaths.remove(cleanPath);
      notifyListeners();
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Corrige les chemins doublement préfixés (assets/assets/...)
  String _normalizePath(String path) {
    var p = path.trim();
    while (p.startsWith('assets/assets/')) {
      p = p.replaceFirst('assets/assets/', 'assets/');
    }
    return p;
  }

  /// Vérifie si l'image est dans le cache Flutter natif
  bool _isInFlutterCache(String cleanPath) {
    try {
      final provider = cleanPath.startsWith('http')
          ? NetworkImage(cleanPath) as ImageProvider
          : AssetImage(cleanPath);
      // Utilise le cache interne Flutter — pas de requête réseau
      final status = PaintingBinding.instance.imageCache.statusForKey(provider);
      return status.keepAlive || status.live;
    } catch (_) {
      return false;
    }
  }

  /// Variantes de résolution que Flutter gère nativement
  bool _isResolutionVariant(String path) {
    final lower = path.toLowerCase();
    return lower.contains('/2.0x/') ||
        lower.contains('/3.0x/') ||
        lower.contains('/1.5x/') ||
        lower.contains('/4.0x/');
  }

  bool _isRasterExtension(String lower) =>
      lower.endsWith('.png') ||
      lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.webp') ||
      lower.endsWith('.gif');
}

// ── Extension preloadWithPriorities ───────────────────────────────────────────

extension UnifiedImageManagerExtension on UnifiedImageManager {
  Future<PreloadResult> preloadWithPriorities(
    List<ImagePriority> images, {
    BuildContext? context,
  }) async {
    final sorted = List<ImagePriority>.from(images)
      ..sort((a, b) => a.priority.compareTo(b.priority));

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

    if (critical.isNotEmpty) {
      final res = await preloadBatch(critical, context: context, batchSize: 3);
      totalSuccess += res.success;
      totalFailed += res.failed;
    }
    if (lazy.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 200));
      final res = await preloadBatch(lazy, context: context, batchSize: 5);
      totalSuccess += res.success;
      totalFailed += res.failed;
    }
    if (background.isNotEmpty) {
      // Fire & forget — ne pas attendre
      preloadBatch(background, context: context, batchSize: 2).then((res) {
        developer.log(
          '✅ Background preload terminé (${res.success} succès)',
          name: 'ImageManager',
        );
      }).catchError((_) {}); // ← silencieux par définition
    }

    return PreloadResult(totalSuccess, totalFailed);
  }
}

// ── Data classes ──────────────────────────────────────────────────────────────

class PreloadResult {
  final int success;
  final int failed;
  const PreloadResult(this.success, this.failed);
  int get total => success + failed;
  double get successRate => total > 0 ? success / total : 0.0;
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
}

enum PreloadStrategy { critical, lazy, background }

class ImagePriority {
  final String path;
  final PreloadStrategy strategy;
  final int priority;

  const ImagePriority(
    this.path, {
    this.strategy = PreloadStrategy.lazy,
    this.priority = 5,
  });
}
