/*
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SmartImageCacheNotifier extends AsyncNotifier<Set<String>> {
  bool _isContextInitialized = false;

  void setContext(BuildContext context) {
    if (!_isContextInitialized) {
      context = context;
      _isContextInitialized = true;
    }
  }

  @override
  FutureOr<Set<String>> build() {
    return <String>{};
  }

  bool isCached(String path) {
    return state.asData?.value.contains(path) ?? false;
  }

  Future<void> preloadImage(String path, BuildContext context) async {
    if (!context.mounted) return;

    final current = state.asData?.value ?? <String>{};

    if (current.contains(path)) return;

    try {
      if (path.toLowerCase().endsWith('.svg')) {
        // ✅ Cache spécifique pour SVG
        final loader = path.startsWith('http')
            ? SvgNetworkLoader(path)
            : SvgAssetLoader(path);

        // On pré-charge les bytes du SVG dans le cache de flutter_svg
        await svg.cache
            .putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
      } else {
        // ✅ Cache standard pour PNG/JPG/WebP
        final imageProvider = path.startsWith('http')
            ? NetworkImage(path)
            : AssetImage(path) as ImageProvider;
        await precacheImage(imageProvider, context);
      }
      state = AsyncValue.data({...current, path});
    } catch (e, st) {
      debugPrint('❌ SmartImage precache error: $path, $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> preloadImages(List<String> paths, BuildContext context) async {
    final current = state.asData?.value ?? <String>{};
    final toLoad = paths.where((p) => !current.contains(p)).toList();

    if (toLoad.isEmpty) return;

    try {
      // Précharge toutes les images en parallèle
      await Future.wait(
          toLoad.map((path) => precacheImage(NetworkImage(path), context)));

      // Met à jour le cache de paths
      state = AsyncValue.data({...current, ...toLoad});
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
*/
