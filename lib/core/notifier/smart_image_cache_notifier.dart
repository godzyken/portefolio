import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SmartImageCacheNotifier extends AsyncNotifier<Set<String>> {
  late BuildContext _context;
  bool _isContextInitialized = false;

  void setContext(BuildContext context) {
    if (!_isContextInitialized) {
      _context = context;
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

  Future<void> preloadImage(String path) async {
    final current = state.asData?.value ?? <String>{};

    if (current.contains(path)) return;

    try {
      await precacheImage(NetworkImage(path), _context);
      state = AsyncValue.data({...current, path});
    } catch (e, st) {
      debugPrint('❌ SmartImage precache error: $path, $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> preloadImages(List<String> paths) async {
    final current = state.asData?.value ?? <String>{};
    final toLoad = paths.where((p) => !current.contains(p)).toList();

    if (toLoad.isEmpty) return;

    try {
      // Précharge toutes les images en parallèle
      await Future.wait(
          toLoad.map((path) => precacheImage(NetworkImage(path), _context)));

      // Met à jour le cache de paths
      state = AsyncValue.data({...current, ...toLoad});
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
