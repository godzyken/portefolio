import 'dart:async';
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

  final Map<String, ImageProvider> _rasterCache = {};
  final Map<String, PictureInfo> _svgCache = {};
  final Map<String, String> _assetManifest = {};

  final Set<String> _loadingPaths = {};
  final Set<String> _loadedPaths = {};
  final Set<String> _failedPaths = {};

  ImageConfiguration? _baseConfig;
  bool _initialized = false;
  int _totalToLoad = 0;

  /// Initialise le gestionnaire — compatible Flutter 3.10+ (AssetManifest.bin)
  Future<void> initialize({ImageConfiguration? config}) async {
    if (_initialized) return;

    try {
      // ✅ AssetManifest.loadFromAssetBundle() gère automatiquement
      //    .bin (Flutter ≥ 3.10) ET .json (Flutter < 3.10)
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final allAssets = manifest.listAssets();

      _assetManifest.clear();
      for (final path in allAssets) {
        if (path.startsWith('assets/images/')) {
          _assetManifest[path] = path;
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

  Future<bool> preloadImage(
    String path, {
    BuildContext? context,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    if (!_initialized) return false;

    String cleanPath = path.trim();
    if (cleanPath.startsWith('assets/assets/')) {
      cleanPath = cleanPath.replaceFirst('assets/assets/', 'assets/');
    }

    final lowerPath = cleanPath.toLowerCase();

    if (_loadedPaths.contains(cleanPath)) return true;
    if (_loadingPaths.contains(cleanPath)) return false;

    if (lowerPath.endsWith('.json')) {
      _loadedPaths.add(cleanPath);
      notifyListeners();
      return true;
    }

    if (lowerPath.endsWith('.svg')) {
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

    final bool isRaster = lowerPath.endsWith('.png') ||
        lowerPath.endsWith('.jpg') ||
        lowerPath.endsWith('.jpeg') ||
        lowerPath.endsWith('.webp');

    if (isRaster) {
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
        batch.map((path) async {
          final result = await preloadImage(path, context: context);
          notifyListeners();
          return result;
        }),
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

  ImageProvider? getCachedImage(String path) => _rasterCache[path];
  PictureInfo? getCachedSvg(String path) => _svgCache[path];
  bool isAvailable(String path) =>
      _assetManifest.containsKey(path) || path.startsWith('http');

  CacheStats getStats() {
    return CacheStats(
      totalAssets: _totalToLoad > 0 ? _totalToLoad : _assetManifest.length,
      loadedRaster: _rasterCache.length,
      loadedSvg: _svgCache.length,
      failed: _failedPaths.length,
      loading: _loadingPaths.length,
    );
  }

  void clearCache() {
    for (final info in _svgCache.values) {
      info.picture.dispose();
    }
    _rasterCache.clear();
    _svgCache.clear();
    _loadedPaths.clear();
    _failedPaths.clear();
    developer.log('🧹 Cache nettoyé');
  }

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

  int getTotalToLoad() => _totalToLoad;

  // ── Privé ──────────────────────────────────────────────────────────────

  Future<void> _preloadRaster(
    String path,
    bool isNetwork,
    Duration timeout,
  ) async {
    final ImageProvider provider =
        isNetwork ? NetworkImage(path) : AssetImage(path) as ImageProvider;

    final completer = Completer<void>();
    final config = _baseConfig ?? const ImageConfiguration();
    final stream = provider.resolve(config);
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
      onError: (error, st) {
        if (!completer.isCompleted) completer.completeError(error, st);
        stream.removeListener(listener!);
      },
    );

    stream.addListener(listener);

    try {
      await completer.future.timeout(timeout, onTimeout: () {
        stream.removeListener(listener!);
        throw TimeoutException('Timeout: $path');
      });
    } catch (_) {
      stream.removeListener(listener);
      rethrow;
    }
  }

  Future<void> _preloadSvg(
    String path,
    bool isNetwork,
    BuildContext? context,
  ) async {
    final loader = isNetwork ? SvgNetworkLoader(path) : SvgAssetLoader(path);
    final pictureInfo = await vg.loadPicture(loader, null);
    _svgCache[path] = pictureInfo;
  }
}

// ── Data classes ────────────────────────────────────────────────────────────

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
      preloadBatch(background, context: context, batchSize: 2).then((res) {
        developer.log('✅ Background preload terminé (${res.success} succès)');
      });
    }

    return PreloadResult(totalSuccess, totalFailed);
  }
}
