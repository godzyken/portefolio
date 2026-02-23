import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/provider_extentions.dart';

// Définition de l'état pour Riverpod
class PrecacheAsyncNotifier extends AsyncNotifier<PrecacheReport> {
  @override
  Future<PrecacheReport> build() async {
    try {
      return await runOptimizedPrecache(ref);
    } catch (e, st) {
      developer.log('❌ Échec de la construction du précache',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> reloadPrecache() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => runOptimizedPrecache(ref));
  }
}
