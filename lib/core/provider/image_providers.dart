import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/constants/app_images.dart';

import '../config/assets_config.dart';

// Cache global pour les assets chargés une seule fois
final _assetCache = <String, List<String>>{};

/// Charge les assets depuis le manifest et les filtre optionnellement
Future<List<String>> _loadAssetsFromManifest({
  String? filter,
}) async {
  try {
    // Vérifier si déjà en cache
    final cacheKey = filter ?? 'all';
    if (_assetCache.containsKey(cacheKey)) {
      developer.log('📦 Assets $cacheKey chargés depuis cache');
      return _assetCache[cacheKey]!;
    }

    // Charger le manifest
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = jsonDecode(manifestContent);

    // Récupérer tous les chemins d'assets
    var assets = manifestMap.keys.cast<String>().toList();

    // Filtrer si nécessaire
    if (filter != null) {
      assets = assets.where((path) => path.startsWith(filter)).toList();
    }

    // Mettre en cache
    _assetCache[cacheKey] = assets;
    developer.log('✅ ${assets.length} assets chargés avec filtre: $filter');

    return assets;
  } catch (e, st) {
    developer.log('❌ Erreur chargement assets: $e', stackTrace: st);
    return [];
  }
}

// ============================================================================
// PROVIDERS SPÉCIFIQUES PAR CATÉGORIE
// ============================================================================

/// Toutes les images du projet
final allImagesProvider = FutureProvider<List<String>>((ref) async {
  return _loadAssetsFromManifest(filter: 'assets/images/');
});

/// Images seulement (PNG, JPG, WEBP, JPEG)
final imageFilesProvider = FutureProvider<List<String>>((ref) async {
  final allAssets = await ref.watch(allImagesProvider.future);
  return allAssets.where((path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gltf') ||
        lower.endsWith('.svg');
  }).toList();
});

/// Logos de technologies (assets/images/logos/)
final techLogosAssetsProvider = FutureProvider<List<String>>((ref) async {
  return _loadAssetsFromManifest(filter: 'assets/images/logos/');
});

/// 🔹 Combine tout (local + réseau)
final appImagesProvider = FutureProvider<AppImages>((ref) async {
  // Charger les images locales
  final localImages = await ref.watch(allImagesProvider.future);

  final networkImages = [
    'https://storage.googleapis.com/cms-storage-bucket/build-more-with-flutter.f399274b364a6194c43d.png',
    'https://assets.setmore.com/website/v2/images/integrations-listing/wordpress/wordpress-plugin-crop@2x.webp',
  ];

  return AppImages(
    local: localImages,
    network: networkImages,
  );
});

// ============================================================================
// PROVIDER POUR LE PRÉCACHE (Utilisé au démarrage)

/// Liste de toutes les images pour le précache
/// Combine images locales + réseau
final imagesToPrecacheProvider = FutureProvider<List<String>>((ref) async {
  final appImages = await ref.watch(appImagesProvider.future);
  return appImages.all
      .where((img) => img.contains('logos/') || img.contains('images/'))
      .toList();
});

/// Vérifie si une image est disponible localement
final isImageAvailableProvider =
    FutureProvider.family<bool, String>((ref, imagePath) async {
  final images = await ref.watch(allImagesProvider.future);
  return images.contains(imagePath);
});

/// Compte le nombre d'images disponibles
final imageCountProvider = FutureProvider<Map<String, int>>((ref) async {
  final all = await ref.watch(allImagesProvider.future);
  final images = await ref.watch(imageFilesProvider.future);
  final logos = await ref.watch(techLogosAssetsProvider.future);

  return {
    'all': all.length,
    'images': images.length,
    'logos': logos.length,
  };
});

final characterModelProvider = Provider<String>((ref) {
  if (kIsWeb) {
    return AssetsConfig.characterModelUrl;
  } else {
    return 'assets/images/models/perso_samurail.glb';
  }
});
