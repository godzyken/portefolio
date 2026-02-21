import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/constants/app_images.dart';

import '../config/assets_config.dart';

// Cache global pour les assets chargés une seule fois
final _assetCache = <String, List<String>>{};

/// ✅ Charge les assets via AssetManifest API (compatible Flutter ≥ 3.10)
/// Remplace l'ancien rootBundle.loadString('AssetManifest.json')
Future<List<String>> _loadAssetsFromManifest({String? filter}) async {
  try {
    final cacheKey = filter ?? 'all';
    if (_assetCache.containsKey(cacheKey)) {
      developer.log('📦 Assets $cacheKey chargés depuis cache');
      return _assetCache[cacheKey]!;
    }

    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    var assets = manifest.listAssets().toList();

    if (filter != null) {
      assets = assets.where((path) => path.startsWith(filter)).toList();
    }

    _assetCache[cacheKey] = assets;
    developer.log('✅ ${assets.length} assets chargés (filtre: $filter)');
    return assets;
  } catch (e, st) {
    developer.log('❌ Erreur chargement assets: $e', stackTrace: st);
    return [];
  }
}

// ── Providers ────────────────────────────────────────────────────────────────

final allImagesProvider = FutureProvider<List<String>>((ref) async {
  return _loadAssetsFromManifest(filter: 'assets/images/');
});

final imageFilesProvider = FutureProvider<List<String>>((ref) async {
  final allAssets = await ref.watch(allImagesProvider.future);
  return allAssets.where((path) {
    final lower = path.toLowerCase();
    if (lower.contains('/2.0x/') || lower.contains('/3.0x/')) return false;
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp');
  }).toList();
});

final techLogosAssetsProvider = FutureProvider<List<String>>((ref) async {
  return _loadAssetsFromManifest(filter: 'assets/images/logos/');
});

final appImagesProvider = FutureProvider<AppImages>((ref) async {
  final localImages = await ref.watch(allImagesProvider.future);
  final networkImages = [
    'https://storage.googleapis.com/cms-storage-bucket/build-more-with-flutter.f399274b364a6194c43d.png',
    'https://assets.setmore.com/website/v2/images/integrations-listing/wordpress/wordpress-plugin-crop@2x.webp',
  ];
  return AppImages(local: localImages, network: networkImages);
});

final isImageAvailableProvider =
    FutureProvider.family<bool, String>((ref, imagePath) async {
  final images = await ref.watch(allImagesProvider.future);
  return images.contains(imagePath);
});

final imageCountProvider = FutureProvider<Map<String, int>>((ref) async {
  final all = await ref.watch(allImagesProvider.future);
  final images = await ref.watch(imageFilesProvider.future);
  final logos = await ref.watch(techLogosAssetsProvider.future);
  return {'all': all.length, 'images': images.length, 'logos': logos.length};
});

final characterModelProvider = Provider<String>((ref) {
  if (kIsWeb) return AssetsConfig.characterModelUrl;
  return 'assets/images/models/perso_samurail.glb';
});

final skillLogoPathProvider =
    Provider.family<String?, String>((ref, skillName) {
  final logoAssetsAsync = ref.watch(techLogosAssetsProvider);
  return logoAssetsAsync.when(
    loading: () => null,
    error: (err, stack) => null,
    data: (paths) {
      final normalizedName = skillName.toLowerCase();
      final path = paths.firstWhere(
        (p) {
          final fileName = p.split('/').last.split('.').first;
          return fileName.startsWith(normalizedName);
        },
        orElse: () => '',
      );
      return path.isEmpty ? null : path;
    },
  );
});

final rasterImagesProvider = FutureProvider<List<String>>((ref) async {
  final allAssets = await ref.watch(allImagesProvider.future);
  return allAssets.where((path) {
    final p = path.toLowerCase();
    return (p.endsWith('.png') || p.endsWith('.jpg') || p.endsWith('.webp')) &&
        !p.contains('/2.0x/') &&
        !p.contains('/3.0x/');
  }).toList();
});

final svgImagesProvider = FutureProvider<List<String>>((ref) async {
  final allAssets = await ref.watch(allImagesProvider.future);
  return allAssets.where((p) => p.toLowerCase().endsWith('.svg')).toList();
});

final gltfImagesProvider = FutureProvider<List<String>>((ref) async {
  final allAssets = await ref.watch(allImagesProvider.future);
  return allAssets.where((p) => p.toLowerCase().endsWith('.gltf')).toList();
});

final lottieAssetsProvider = FutureProvider<List<String>>((ref) async {
  final all = await ref.watch(allImagesProvider.future);
  return all.where((path) => path.toLowerCase().endsWith('.json')).toList();
});
