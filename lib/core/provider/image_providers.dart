import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/constants/app_images.dart';

List<String>? _cachedAssets;

Future<List<String>> _loadAssetsFromManifest({String? filter}) async {
  try {
    _cachedAssets ??= await () {
      final manifestContent = rootBundle.loadString('AssetManifest.json');
      return manifestContent.then((data) {
        final manifestMap = json.decode(data) as Map<String, dynamic>;
        return manifestMap.keys.cast<String>().toList();
      });
    }();

    final assets = _cachedAssets!;
    if (filter != null) {
      return assets.where((path) => path.contains(filter)).toList();
    }
    return assets;
  } catch (e) {
    developer.log('⚠️ Error loading assets: $e');
    return [];
  }
}

/// 🔹 Images locales groupées par domaine
final projectImagesProvider = FutureProvider<List<String>>(
  (ref) => _loadAssetsFromManifest(filter: 'assets/projects/'),
);

final experienceImagesProvider = FutureProvider<List<String>>(
  (ref) => _loadAssetsFromManifest(filter: 'assets/experience/'),
);

final serviceImagesProvider = FutureProvider<List<String>>(
  (ref) => _loadAssetsFromManifest(filter: 'assets/services/'),
);

/// 🔹 Combine tout (local + réseau)
final appImagesProvider = FutureProvider<AppImages>((ref) async {
  final projects = await ref.read(projectImagesProvider.future);
  final experiences = await ref.read(experienceImagesProvider.future);
  final services = await ref.read(serviceImagesProvider.future);

  final networkImages = [
    'https://www.tatvasoft.com/outsourcing/wp-content/uploads/2023/06/Angular-Architecture.jpg',
    'https://storage.googleapis.com/cms-storage-bucket/build-more-with-flutter.f399274b364a6194c43d.png',
  ];

  return AppImages(
    projects: projects,
    experiences: experiences,
    services: services,
    network: networkImages,
  );
});
