import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;

import '../notifier/precache_notifier.dart';
import 'json_data_provider.dart';

/// Résumé du précache : total, succès, échecs.
class PrecacheReport {
  final int total;
  final int success;
  final int failed;
  const PrecacheReport(this.total, this.success, this.failed);

  @override
  String toString() =>
      'PrecacheReport(total: $total, success: $success, failed: $failed)';
}

// ─────────────────────────────────────────────────────────────────────────────
// PRÉCACHE D'IMAGES ET RESSOURCES
// ─────────────────────────────────────────────────────────────────────────────

Future<bool> precacheSingleImageWithConfig(
  String path,
  ImageConfiguration config,
  Duration timeout,
) async {
  try {
    final provider = (path.contains('http')
        ? NetworkImage(path)
        : AssetImage(path)) as ImageProvider;

    final completer = Completer<void>();
    final stream = provider.resolve(config);
    ImageStreamListener? listener;

    listener = ImageStreamListener(
      (ImageInfo? image, bool sync) {
        if (!completer.isCompleted) completer.complete();
        stream.removeListener(listener!);
      },
      onError: (Object exception, StackTrace? stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(exception, stackTrace);
        }
        stream.removeListener(listener!);
      },
    );

    stream.addListener(listener);

    await completer.future.timeout(timeout, onTimeout: () {
      stream.removeListener(listener!);
      throw TimeoutException('Precache timed out for $path');
    });

    return true;
  } catch (e) {
    developer.log('⚠️ Échec précache: $path ($e)');
    return false;
  }
}

/// Charge dynamiquement une police si elle existe
Future<void> _loadFontIfExists(String path, String family) async {
  try {
    final data = await rootBundle.load(path);
    final loader = FontLoader(family)..addFont(Future.value(data));
    await loader.load();
    developer.log('✅ Police chargée: $family');
  } on MissingPluginException {
    developer.log('⚠️ rootBundle non disponible pour: $path');
  } catch (_) {
    developer.log('⚠️ Police non trouvée: $path');
  }
}

/// Précache les images raster (PNG/JPG/WebP), ignore les SVG
Future<List<bool>> _precacheImagesInBatches(
  List<String> imagePaths,
  ImageConfiguration config, {
  int batchSize = 3,
  Duration timeout = const Duration(seconds: 2),
  Duration delayBetweenImages = const Duration(milliseconds: 20),
}) async {
  final results = <bool>[];
  for (int i = 0; i < imagePaths.length; i++) {
    final path = imagePaths[i];

    if (path.toLowerCase().endsWith('.svg')) {
      final ok = await _precacheSvg(path);
      results.add(ok);
      continue;
    }

    final success = await precacheSingleImageWithConfig(path, config, timeout);
    results.add(success);

    if (i < imagePaths.length - 1) {
      await Future.delayed(delayBetweenImages);
    }
  }
  return results;
}

/// (Optionnel) Précache manuel des SVG via flutter_svg
Future<bool> _precacheSvg(String path) async {
  try {
    final loader = svg.SvgAssetLoader(path);
    await svg.vg.loadPicture(loader, null);
    developer.log('✅ SVG précaché: $path');
    return true;
  } catch (e) {
    developer.log('⚠️ Échec précache SVG: $path ($e)');
    return false;
  }
}

/// Précache les images restantes en tâche de fond
void _precacheImagesInBackground(
  List<String> imagePaths,
  ImageConfiguration config,
) async {
  const defaultTimeout = Duration(seconds: 3);
  const delayBetweenLaunches = Duration(milliseconds: 100);

  for (final path in imagePaths) {
    if (path.toLowerCase().endsWith('.svg')) continue;

    precacheSingleImageWithConfig(path, config, defaultTimeout).then(
      (_) {},
      onError: (error) {
        developer.log('⚠️ Erreur Fire & Forget $path: $error');
      },
    );

    await Future.delayed(delayBetweenLaunches);
  }
}

/// Exécution complète du précache (JSON → Fonts → Images)
Future<PrecacheReport> runOptimizedPrecache(Ref ref) async {
  developer.log('🚀 [1/4] Précache optimisé...');
  await Future.delayed(const Duration(milliseconds: 100));

  int success = 0;
  int failed = 0;

  try {
    const ImageConfiguration config = ImageConfiguration();

    // ── Étape 1 : JSON ───────────────────────────────
    developer.log('➡️ [2/4] Chargement JSON...');
    await Future.wait([
      ref.read(projectsProvider.future),
      ref.read(experiencesProvider.future),
      ref.read(servicesJsonProvider.future),
      ref.read(comparaisonsJsonProvider.future),
    ]);

    // ── Étape 2 : Polices ─────────────────────────────
    developer.log('➡️ [3/4] Chargement polices...');
    await Future.wait([
      _loadFontIfExists(
        'assets/fonts/Noto_Sans/NotoSans-VariableFont_wdth-wght.ttf',
        'NotoSans',
      ),
      _loadFontIfExists(
        'assets/fonts/Noto_Sans/NotoSans-Italic-VariableFont_wdth-wght.ttf',
        'NotoSansItalic',
      ),
    ]);

    // ── Étape 3 : Images ─────────────────────────────
    developer.log('➡️ [4/4] Précache images critiques...');
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

    final allImages = manifest
        .listAssets()
        .where((p) => p.startsWith('assets/images/'))
        .where((p) =>
            !p.contains('/2.0x/') &&
            !p.contains('/3.0x/') &&
            !p.contains('/4.0x/'))
        .toList();

    final criticalImages = allImages.where((path) {
      return path.contains('logo_godzyken') ||
          path.contains('pers_do_am') ||
          path.contains('logos/flutter') ||
          path.contains('logos/dart');
    }).toList();

    developer.log('📸 ${criticalImages.length} images critiques à précacher');

    final results = await _precacheImagesInBatches(
      criticalImages,
      config,
      batchSize: 3,
      timeout: const Duration(seconds: 2),
    );

    success = results.where((r) => r).length;
    failed = results.where((r) => !r).length;

    // ── Étape 4 : Reste en background ─────────────────
    final remainingImages =
        allImages.where((p) => !criticalImages.contains(p)).toList();
    _precacheImagesInBackground(remainingImages, config);

    developer.log('✅ Précache critique terminé.');
  } catch (e, st) {
    developer.log('❌ Erreur précache: $e', stackTrace: st);
    rethrow;
  }

  return PrecacheReport(success + failed, success, failed);
}

final precacheNotifierProvider =
    AsyncNotifierProvider<PrecacheAsyncNotifier, PrecacheReport>(
        PrecacheAsyncNotifier.new);
