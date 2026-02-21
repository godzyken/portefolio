import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/provider/precache_providers.dart';
import '../../../core/service/unified_image_manager.dart';
import '../controller/splash_state.dart';

/// Orchestre le précache. La navigation est gérée par le widget via ref.listen.
class SplashNotifier extends Notifier<SplashState> {
  @override
  SplashState build() => const SplashState();

  Future<void> start({int minimumDisplayMs = 1500}) async {
    if (state.phase == SplashPhase.loading) return;

    state = state.copyWith(
      phase: SplashPhase.loading,
      progress: 0.0,
      statusMessage: 'Initialisation…',
    );

    final startTime = DateTime.now();

    try {
      final manager = UnifiedImageManager();
      manager.addListener(_onManagerUpdate);

      state = state.copyWith(statusMessage: 'Chargement des ressources…');

      final report = await runOptimizedPrecache(ref);

      manager.removeListener(_onManagerUpdate);

      // Durée minimale d'affichage
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      final remaining = minimumDisplayMs - elapsed;
      if (remaining > 0) {
        await Future.delayed(Duration(milliseconds: remaining));
      }

      // ✅ On passe à ready — c'est le widget qui navigue via ref.listen
      state = state.copyWith(
        phase: SplashPhase.ready,
        progress: 1.0,
        statusMessage: 'Prêt !',
        report: report,
      );

      developer.log('✅ SplashNotifier ready — $report');
    } catch (e, st) {
      developer.log('❌ SplashNotifier error', error: e, stackTrace: st);
      UnifiedImageManager().removeListener(_onManagerUpdate);

      state = state.copyWith(
        phase: SplashPhase.error,
        statusMessage: 'Erreur au démarrage',
        error: e,
      );
    }
  }

  Future<void> retry() async {
    state = const SplashState();
    await start();
  }

  void _onManagerUpdate() {
    final stats = UnifiedImageManager().getStats();
    if (stats.totalAssets == 0) return;

    final progress = (stats.loadedRaster + stats.loadedSvg) / stats.totalAssets;
    state = state.copyWith(
      progress: progress.clamp(0.0, 0.95),
      statusMessage:
          '${stats.loadedRaster + stats.loadedSvg} / ${stats.totalAssets} images',
    );
  }
}
