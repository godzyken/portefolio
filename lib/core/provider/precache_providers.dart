import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'image_providers.dart';
import 'json_data_provider.dart';

class PrecacheReport {
  final int total;
  final int success;
  final int failed;
  const PrecacheReport(this.total, this.success, this.failed);
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
        final imageProvider = path.startsWith('http')
            ? NetworkImage(path)
            : AssetImage(path) as ImageProvider;
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
