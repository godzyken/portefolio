import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider pour le store de cache des tuiles
final mapCacheStoreProvider = Provider<FMTCStore>((ref) {
  return FMTCStore('mapStore');
});

/// Provider pour initialiser FMTC
final fmtcInitializationProvider = FutureProvider<void>((ref) async {
  if (kIsWeb) return;

  await FMTCObjectBoxBackend().initialise();

  // Créer le store s'il n'existe pas
  final store = ref.read(mapCacheStoreProvider);
  if (!await store.manage.ready) {
    await store.manage.create();
  } else {
    // Supprimer les tuiles obsolètes
    final expiry = DateTime.timestamp().subtract(const Duration(days: 30));
    await store.manage.removeTilesOlderThan(expiry: expiry);
  }
});

final cacheSizeProvider = StreamProvider<double>((ref) async* {
  if (kIsWeb) {
    yield 0.0;
    return;
  }

  // 1. Obtenir le flux de notification (qui est Stream<void>)
  final Stream<void> changeSignal =
      FMTCRoot.stats.watchStores(storeNames: ['mapStore']);

  // 2. Fonction locale pour récupérer la taille via FMTCRoot.stats
  Future<double> fetchSize() async {
    try {
      // storesAvailable est un Future<List<FMTCStore>>
      final List<FMTCStore> stores = await FMTCRoot.stats.storesAvailable;

      // On trouve le store correspondant
      final mapStore = stores.firstWhere(
        (s) => s.storeName == 'mapStore',
      );

      // On récupère les stats de ce store spécifique
      // La propriété s'appelle généralement 'stats' sur l'objet FMTCStore
      final stats = await mapStore.stats.all;

      return stats.size / (1024 * 1024); // Conversion Mo
    } catch (e) {
      developer.log('⚠️ Erreur stats: $e');
      return 0.0;
    }
  }

  // 3. Émission initiale
  yield await fetchSize();

  // 4. À chaque notification 'void', on ré-interroge les stats
  await for (final _ in changeSignal) {
    yield await fetchSize();
  }
});
