import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/constants/app_images.dart';

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
        lower.endsWith('.webp');
  }).toList();
});

/// Logos de technologies (assets/images/logos/)
final techLogosAssetsProvider = FutureProvider<List<String>>((ref) async {
  return _loadAssetsFromManifest(filter: 'assets/images/logos/');
});

/// Images du portfolio (projets, home, etc.)
final portfolioImagesProvider = FutureProvider<List<String>>((ref) async {
  final allImages = await ref.watch(allImagesProvider.future);
  return allImages.where((path) {
    final lower = path.toLowerCase();
    // Exclure les logos pour avoir les images de contenu
    return !lower.contains('logos/');
  }).toList();
});

/// Fichiers JSON (données)
final dataFilesProvider = FutureProvider<List<String>>((ref) async {
  return _loadAssetsFromManifest(filter: 'assets/data/');
});

/// Polices de caractères
final fontFilesProvider = FutureProvider<List<String>>((ref) async {
  return _loadAssetsFromManifest(filter: 'assets/fonts/');
});

/// 🔹 Combine tout (local + réseau)
final appImagesProvider = FutureProvider<AppImages>((ref) async {
  // Charger les images locales
  final localImages = await ref.watch(allImagesProvider.future);

  final networkImages = [
    'https://www.tatvasoft.com/outsourcing/wp-content/uploads/2023/06/Angular-Architecture.jpg',
    'https://techpearl.com/wp-content/uploads/2021/11/Ionic-App.svg',
    'https://cenotia.com/wp-content/uploads/2017/05/transformation-digitale.jpg',
    'https://teachmeidea.com/wp-content/uploads/2025/04/ChatGPT-Image-Apr-3-2025-03_36_47-PM-1024x683.png',
    'https://storage.googleapis.com/cms-storage-bucket/build-more-with-flutter.f399274b364a6194c43d.png',
    'https://www.pyreweb.com/files/medias/images/Wordpress-Security-Issues-1.jpg',
    'https://www.reacteur.com/content/uploads/2018/05/magento-logo.png',
    'https://pro.packlink.fr/wp-content/uploads/2021/12/services-g0e8be1220_640-1.jpg',
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
  return appImages.all;
});

// ============================================================================
// PROVIDERS SPÉCIALISÉS (Si besoin de séparation)

/// Uniquement les images PNG haute qualité
final highQualityImagesProvider = FutureProvider<List<String>>((ref) async {
  final images = await ref.watch(imageFilesProvider.future);
  return images.where((path) => path.toLowerCase().endsWith('.png')).toList();
});

/// Uniquement les images WebP (pour web)
final webOptimizedImagesProvider = FutureProvider<List<String>>((ref) async {
  final images = await ref.watch(imageFilesProvider.future);
  return images.where((path) => path.toLowerCase().endsWith('.webp')).toList();
});

// ============================================================================
// HELPER: Vérifier si une image existe
// ============================================================================

/// Vérifie si une image est disponible localement
final isImageAvailableProvider =
    FutureProvider.family<bool, String>((ref, imagePath) async {
  final images = await ref.watch(allImagesProvider.future);
  return images.contains(imagePath);
});

// ============================================================================
// HELPER: Compter les images par catégorie
// ============================================================================

/// Compte le nombre d'images disponibles
final imageCountProvider = FutureProvider<Map<String, int>>((ref) async {
  final all = await ref.watch(allImagesProvider.future);
  final images = await ref.watch(imageFilesProvider.future);
  final logos = await ref.watch(techLogosAssetsProvider.future);
  final data = await ref.watch(dataFilesProvider.future);

  return {
    'all': all.length,
    'images': images.length,
    'logos': logos.length,
    'data': data.length,
  };
});
