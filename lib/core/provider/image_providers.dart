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
}, name: 'AllImages');

final imageFilesProvider = FutureProvider<List<String>>((ref) async {
  final allAssets = await ref.watch(allImagesProvider.future);
  return allAssets.where((path) {
    final lower = path.toLowerCase();
    if (lower.contains('/2.0x/') || lower.contains('/3.0x/')) return false;
    return lower.endsWith('.webp') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg');
  }).toList();
}, name: 'ImageFiles');

final techLogosAssetsProvider = FutureProvider<List<String>>((ref) async {
  return _loadAssetsFromManifest(filter: 'assets/images/logos/');
}, name: 'TechLogosAssets');

final appImagesProvider = FutureProvider<AppImages>((ref) async {
  final localImages = await ref.watch(allImagesProvider.future);
  final networkImages = [
    'https://storage.googleapis.com/cms-storage-bucket/build-more-with-flutter.f399274b364a6194c43d.webp',
    'https://assets.setmore.com/website/v2/images/integrations-listing/wordpress/wordpress-plugin-crop@2x.webp',
  ];
  return AppImages(local: localImages, network: networkImages);
}, name: 'AppImages');

final isImageAvailableProvider =
    FutureProvider.family<bool, String>((ref, imagePath) async {
  final images = await ref.watch(allImagesProvider.future);
  return images.contains(imagePath);
}, name: 'IsImageAvailable');

final imageCountProvider = FutureProvider<Map<String, int>>((ref) async {
  final all = await ref.watch(allImagesProvider.future);
  final images = await ref.watch(imageFilesProvider.future);
  final logos = await ref.watch(techLogosAssetsProvider.future);
  return {'all': all.length, 'images': images.length, 'logos': logos.length};
}, name: 'ImageCount');

final characterModelProvider = Provider<String>((ref) {
  if (kIsWeb) return AssetsConfig.characterModelUrl;
  return 'assets/images/models/perso_samurail.glb';
}, name: 'CharacterModel');

String _cleanSkillKey(String s) {
  return s
      .toLowerCase()
      .replaceAll(' ', '')
      .replaceAll('-', '')
      .replaceAll('_', '')
      .replaceAll('.', '')
      .replaceAll('/', '')
      .replaceAll('+', 'plus')
      .replaceAll('#', 'sharp');
}

final skillLogoPathProvider =
    Provider.family<String?, String>((ref, skillName) {
  final logoAssetsAsync = ref.watch(techLogosAssetsProvider);
  return logoAssetsAsync.when(
    loading: () => null,
    error: (err, stack) => null,
    data: (paths) {
      if (paths.isEmpty) return null;
      final targetKey = _cleanSkillKey(skillName);
      if (targetKey.isEmpty) return null;

      // 1. Chercher d'abord une correspondance exacte du nom nettoyé
      for (final p in paths) {
        final rawFileName = p.split('/').last.split('.').first;
        final cleanFileName = _cleanSkillKey(rawFileName);

        if (cleanFileName == targetKey) {
          return p;
        }
      }

      // 2. Traiter les alias connus
      final aliasMap = <String, String>{
        'cplusplus': 'c_plusplus',
        'cpp': 'c_plusplus',
        'csharp': 'c_sharp',
        'cs': 'c_sharp',
        'node': 'nodejs_icon_alt',
        'nodejs': 'nodejs_icon_alt',
        'express': 'express_js',
        'expressjs': 'express_js',
        'cicd': 'ci_cd_logo',
        'firebase': 'firebase_hosting_logo',
        'github': 'github_octocat',
        'git': 'git',
        'html': 'html_5',
        'html5': 'html_5',
        'css': 'css_3',
        'css3': 'css_3',
        'typescript': 'typescript_icon_round',
        'js': 'javascript',
        'ts': 'typescript_icon_round',
        'raspi': 'raspberry_pi',
        'raspberry': 'raspberry_pi',
        'raspberrypi': 'raspberry_pi',
      };

      if (aliasMap.containsKey(targetKey)) {
        final alias = aliasMap[targetKey]!;
        for (final p in paths) {
          final rawFileName = p.split('/').last.split('.').first;
          if (rawFileName.contains(alias) ||
              _cleanSkillKey(rawFileName).contains(_cleanSkillKey(alias))) {
            return p;
          }
        }
      }

      // 3. Chercher par inclusion partielle
      for (final p in paths) {
        final rawFileName = p.split('/').last.split('.').first;
        final cleanFileName = _cleanSkillKey(rawFileName);

        if (cleanFileName.startsWith(targetKey) ||
            targetKey.startsWith(cleanFileName)) {
          if (targetKey == 'git' && cleanFileName.startsWith('github')) {
            continue;
          }
          return p;
        }
      }

      return null;
    },
  );
}, name: 'SkillLogoPath');

final rasterImagesProvider = FutureProvider<List<String>>((ref) async {
  final allAssets = await ref.watch(allImagesProvider.future);
  return allAssets.where((path) {
    final p = path.toLowerCase();
    return (p.endsWith('.webp') ||
            p.endsWith('.webp') ||
            p.endsWith('.png') ||
            p.endsWith('.jpg') ||
            p.endsWith('.jpeg')) &&
        !p.contains('/2.0x/') &&
        !p.contains('/3.0x/');
  }).toList();
}, name: 'RasterImages');

final svgImagesProvider = FutureProvider<List<String>>((ref) async {
  final allAssets = await ref.watch(allImagesProvider.future);
  return allAssets.where((p) => p.toLowerCase().endsWith('.svg')).toList();
}, name: 'SvgImages');

final gltfImagesProvider = FutureProvider<List<String>>((ref) async {
  final allAssets = await ref.watch(allImagesProvider.future);
  return allAssets.where((p) => p.toLowerCase().endsWith('.gltf')).toList();
}, name: 'GltfImages');

final lottieAssetsProvider = FutureProvider<List<String>>((ref) async {
  final all = await ref.watch(allImagesProvider.future);
  return all.where((path) => path.toLowerCase().endsWith('.json')).toList();
}, name: 'LottieAssets');
