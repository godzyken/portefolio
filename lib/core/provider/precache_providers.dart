import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifier/precache_notifier.dart';
import 'image_providers.dart';
import 'json_data_provider.dart'; // Importe la classe AsyncNotifier

// --- Structures de Données ---

class PrecacheReport {
  final int total;
  final int success;
  final int failed;
  const PrecacheReport(this.total, this.success, this.failed);

  @override
  String toString() =>
      'PrecacheReport(total: $total, success: $success, failed: $failed)';
}

// --- Fonctions Utilitaires (Découplées du BuildContext) ---

/// ✅ Précache une seule image avec timeout configurable utilisant ImageConfiguration.
/// Cette fonction est publique pour être utilisée par le Notifier.
Future<bool> precacheSingleImageWithConfig(
  String path,
  ImageConfiguration config, // Remplace BuildContext
  Duration timeout,
) async {
  try {
    final provider = (path.contains('http')
        ? NetworkImage(path)
        : AssetImage(path)) as ImageProvider;

    final Completer<void> completer = Completer<void>();
    final ImageStream stream = provider.resolve(config);
    ImageStreamListener? listener;

    listener = ImageStreamListener(
      (ImageInfo? image, bool sync) {
        if (!completer.isCompleted) {
          completer.complete();
        }
        // IMPORTANT : Retirer immédiatement l'écouteur
        stream.removeListener(listener!);
      },
      onError: (Object exception, StackTrace? stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(exception, stackTrace);
        }
        stream.removeListener(listener!);
        developer.log('⚠️ Erreur stream précache: $path ($exception)');
      },
    );
    stream.addListener(listener);

    // Attendre la complétion du Future ou le timeout
    await completer.future.timeout(
      timeout,
      onTimeout: () {
        developer.log('⏰ Timeout précache: $path');
        // Retirer l'écouteur si le timeout se produit
        stream.removeListener(listener!);
        throw TimeoutException('Precache timed out for $path');
      },
    );

    return true;
  } catch (e) {
    developer.log('⚠️ Échec précache: $path ($e)');
    return false;
  }
}

/// ✅ Précharge les polices si elles existent.
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

/// ✅ Précache par lots avec délai entre chaque lot.
/// Utilise ImageConfiguration.
Future<List<bool>> _precacheImagesInBatches(
  List<String> imagePaths,
  ImageConfiguration config, {
  int batchSize = 3,
  Duration timeout = const Duration(seconds: 2),
  Duration delayBetweenImages = const Duration(milliseconds: 20),
}) async {
  final results = <bool>[];

  final totalImages = imagePaths.length;

  for (int i = 0; i < totalImages; i++) {
    final path = imagePaths[i];

    // 🎯 Précache l'image (séquentiellement)
    final success = await precacheSingleImageWithConfig(path, config, timeout);
    results.add(success);

    // 🎯 Délai après chaque image pour décharger le pipeline
    if (i < totalImages - 1) {
      await Future.delayed(delayBetweenImages);
    }
  }
  return results;
}

/// ✅ Lance le reste du précache en arrière-plan (Fire and Forget)
/// Utilise ImageConfiguration.
void _precacheImagesInBackground(
  List<String> imagePaths,
  ImageConfiguration config,
) async {
  const defaultTimeout = Duration(seconds: 3);
  const delayBetweenLaunches = Duration(milliseconds: 100);

  for (final path in imagePaths) {
    precacheSingleImageWithConfig(path, config, defaultTimeout).then(
      (result) {
        // Log minimaliste pour le Fire & Forget
      },
      onError: (error) {
        developer.log('⚠️ Erreur Fire & Forget $path: $error');
      },
    );

    await Future.delayed(delayBetweenLaunches);
  }
  developer.log(
      '🎯 Précache de ${imagePaths.length} images lancé en background (Fire & Forget)');
}

// --- Fonction de Logique d'exécution (Le Cœur du Processus) ---

/// ✅ Fonction de logique d'exécution complète. Appelée par l'AsyncNotifier.
Future<PrecacheReport> runOptimizedPrecache(Ref ref) async {
  developer.log('🚀 [1/4] Précache parallèle optimisé (Découplé)...');
  await Future.delayed(const Duration(milliseconds: 100));

  int success = 0;
  int failed = 0;

  try {
    const ImageConfiguration config = ImageConfiguration();

    // Étape 1 : Chargement des JSONs
    developer.log('➡️ [2/4] Chargement JSON...');
    await Future.wait([
      ref.read(projectsProvider.future),
      ref.read(experiencesProvider.future),
      ref.read(servicesJsonProvider.future),
      ref.read(comparaisonsJsonProvider.future),
    ]);

    // Étape 2 : Chargement des Polices
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

    // Étape 3 : Images Critiques (Blocage + Batches)
    developer.log('➡️ [4/4] Précache images critiques...');
    final allImages = await ref.read(allImagesProvider
        .future); // Utilisez appImagesProvider pour obtenir la liste complète

    // Définition des filtres pour les images critiques
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

    // Étape 4 : Lancement du reste en arrière-plan
    final remainingImages =
        allImages.where((p) => !criticalImages.contains(p)).toList();

    _precacheImagesInBackground(remainingImages, config);

    developer.log('✅ Précache critique terminé. Le reste est en arrière-plan.');
  } catch (e, st) {
    developer.log('❌ Erreur précache dans runOptimizedPrecache: $e',
        stackTrace: st);
    rethrow;
  }

  return PrecacheReport(success + failed, success, failed);
}

/// 🔹 Le Provider d'état utilise l'AsyncNotifier pour gérer l'état asynchrone du précache.
final precacheNotifierProvider =
    AsyncNotifierProvider<PrecacheAsyncNotifier, PrecacheReport>(
        PrecacheAsyncNotifier.new);
