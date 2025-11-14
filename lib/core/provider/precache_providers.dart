import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'image_providers.dart';
import 'json_data_provider.dart';

class PrecacheReport {
  final int total;
  final int success;
  final int failed;
  const PrecacheReport(this.total, this.success, this.failed);

  @override
  String toString() =>
      'PrecacheReport(total: $total, success: $success, failed: $failed)';
}

/// 🔹 Précache global (à appeler depuis le SplashScreen)
final precacheAllAssetsProvider =
    FutureProvider.family<PrecacheReport, BuildContext>((ref, context) async {
  developer.log('🚀 Démarrage du précache global...');

  // Étape 1 : Charger données et polices
  await Future.wait([
    ref.read(projectsProvider.future),
    ref.read(experiencesProvider.future),
    ref.read(servicesJsonProvider.future),
    ref.read(comparaisonsJsonProvider.future),
  ]);
  developer.log('✅ JSON chargé');

  // Étape 2 : Précharger les images
  final images = await ref.read(appImagesProvider.future);
  developer.log('📸 ${images.all} images à précacher');

  int success = 0;
  int failed = 0;

  for (final path in images.all) {
    if (!context.mounted) break;

    unawaited(Future(() async {
      try {
        final imageProvider = (path.startsWith('http')
            ? NetworkImage(path)
            : AssetImage(path)) as ImageProvider;
        await precacheImage(imageProvider, context)
            .timeout(const Duration(seconds: 5), onTimeout: () {
          developer.log('⏰ Timeout précache : $path');
        });

        success++;
      } catch (e, st) {
        developer.log('⚠️ Erreur précache $path : $e', stackTrace: st);
        failed++;
      }
    }));
  }
  developer.log('✅ JSONs chargés (${[
    'projects',
    'experiences',
    'services'
  ].join(', ')})');
  developer.log('🎉 Précache terminé ($success/${images.all.length})');
  return PrecacheReport(images.all.length, success, failed);
});

/// 🔹 Version optimisée qui précache en parallèle (plus rapide mais plus de charge)
final precacheAllAssetsParallelProvider =
    FutureProvider.family<PrecacheReport, BuildContext>((ref, context) async {
  final context = WidgetsBinding.instance.rootElement;
  if (context == null) {
    developer.log('❌ Aucun context trouvé, précache annulé.');
    return const PrecacheReport(0, 0, 0);
  }
  developer.log('🚀 [1/5] Initialisation du précache global...');

  // Petit délai pour laisser le splash s'afficher
  await Future.delayed(const Duration(milliseconds: 300));

  int success = 0;
  int failed = 0;

  try {
    // Étape 1 : Charger les JSONs
    developer.log('➡️ [2/5] Chargement des données JSON...');
    await Future.wait([
      ref.read(projectsProvider.future),
      ref.read(experiencesProvider.future),
      ref.read(servicesJsonProvider.future),
      ref.read(comparaisonsJsonProvider.future),
    ]);
    developer.log('✅ [2/5] Données JSON chargées.');

    // Étape 2 : Charger les polices (si besoin)
    developer.log('➡️ [3/5] Chargement des polices...');
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
    developer.log('✅ [3/5] Polices chargées.');

    // Étape 3 : Récupérer les images locales + réseau
    developer.log('➡️ [4/5] Récupération des images à précacher...');
    final allImages = await ref.read(imagesToPrecacheProvider.future);
    developer.log('📸 Total d\'images à précacher : ${allImages.length}');

    // Étape 4 : Précache en lots pour éviter surcharge mémoire
    const batchSize = 5;
    final results = await _precacheImagesInBatches(
      allImages,
      context,
      batchSize: batchSize,
    );

    success = results.where((r) => r).length;
    failed = results.where((r) => !r).length;

    developer
        .log('✅ [5/5] Précache terminé : $success succès, $failed erreurs');
  } catch (e, st) {
    developer.log('❌ Erreur globale du précache : $e', stackTrace: st);
  }

  return PrecacheReport(success + failed, success, failed);
});

/// ============================================================================
/// 🔹 Fonction utilitaire pour précacher les images par lots
Future<List<bool>> _precacheImagesInBatches(
  List<String> imagePaths,
  BuildContext context, {
  int batchSize = 5,
  Duration timeout = const Duration(seconds: 5),
}) async {
  final results = <bool>[];

  for (int i = 0; i < imagePaths.length; i += batchSize) {
    final batch = imagePaths.skip(i).take(batchSize).toList();

    final batchResults = await Future.wait(batch.map((path) async {
      try {
        final provider = (path.contains('http')
            ? NetworkImage(path)
            : AssetImage(path)) as ImageProvider;
        await precacheImage(provider, context).timeout(timeout, onTimeout: () {
          developer.log('⏰ Timeout précache : $path');
          return;
        });

        return true;
      } catch (e) {
        developer.log('⚠️ Erreur précache image: $path ($e)');
        return false;
      }
    }));

    results.addAll(batchResults);
  }

  return results;
}

/// ============================================================================
/// 🔹 Fonction utilitaire pour charger une police si elle existe
Future<void> _loadFontIfExists(String path, String family) async {
  try {
    final data = await rootBundle.load(path);
    final loader = FontLoader(family)..addFont(Future.value(data));
    await loader.load();
    developer.log('✅ Police chargée : $family');
  } catch (_) {
    developer.log('⚠️ Police non trouvée : $path');
  }
}
