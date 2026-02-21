import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/provider/precache_providers.dart';
import '../../../core/service/unified_image_manager.dart';
import '../controller/splash_state.dart';

/// Orchestre toute la séquence de démarrage :
/// 1. Précache des assets via [runOptimizedPrecache]
/// 2. Suivi de la progression via [UnifiedImageManager]
/// 3. Transition vers la route cible une fois prêt
class SplashNotifier extends Notifier<SplashState> {
  @override
  SplashState build() => const SplashState();

  /// Lance la séquence de démarrage.
  ///
  /// [targetRoute] : route GoRouter à ouvrir après le splash (ex. `/home`).
  /// [context] : nécessaire pour la navigation GoRouter.
  /// [minimumDisplayMs] : durée minimale du splash pour éviter un flash.
  Future<void> start({
    required BuildContext context,
    String targetRoute = '/',
    int minimumDisplayMs = 1500,
  }) async {
    if (state.phase == SplashPhase.loading) return; // Protection ré-entrance

    state = state.copyWith(
      phase: SplashPhase.loading,
      progress: 0.0,
      statusMessage: 'Initialisation…',
    );

    final startTime = DateTime.now();

    try {
      // ── Suivi de progression en temps réel ──────────────────────────────
      final manager = UnifiedImageManager();
      manager.addListener(_onManagerUpdate);

      // ── Précache ────────────────────────────────────────────────────────
      state = state.copyWith(statusMessage: 'Chargement des ressources…');
      final report = await runOptimizedPrecache(ref);

      manager.removeListener(_onManagerUpdate);

      // ── Durée minimale d'affichage ───────────────────────────────────────
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      final remaining = minimumDisplayMs - elapsed;
      if (remaining > 0) {
        await Future.delayed(Duration(milliseconds: remaining));
      }

      state = state.copyWith(
        phase: SplashPhase.ready,
        progress: 1.0,
        statusMessage: 'Prêt !',
        report: report,
      );

      developer.log('✅ SplashController ready — ${report.toString()}');

      // ── Navigation ───────────────────────────────────────────────────────
      if (context.mounted) {
        context.go(targetRoute);
      }
    } catch (e, st) {
      developer.log('❌ SplashController error', error: e, stackTrace: st);
      UnifiedImageManager().removeListener(_onManagerUpdate);

      state = state.copyWith(
        phase: SplashPhase.error,
        statusMessage: 'Erreur au démarrage',
        error: e,
      );
    }
  }

  /// Relance la séquence (bouton "Réessayer" sur l'écran d'erreur).
  Future<void> retry({
    required BuildContext context,
    String targetRoute = '/',
  }) async {
    state = const SplashState();
    await start(context: context, targetRoute: targetRoute);
  }

  void _onManagerUpdate() {
    final manager = UnifiedImageManager();
    final stats = manager.getStats();
    if (stats.totalAssets == 0) return;

    final progress = (stats.loadedRaster + stats.loadedSvg) / stats.totalAssets;
    state = state.copyWith(
      progress:
          progress.clamp(0.0, 0.95), // 0.95 max : 1.0 seulement quand done
      statusMessage:
          '${stats.loadedRaster + stats.loadedSvg} / ${stats.totalAssets} images',
    );
  }
}
