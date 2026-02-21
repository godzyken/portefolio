// ---------------------------------------------------------------------------
// État du Splash
// ---------------------------------------------------------------------------

import '../../../core/provider/precache_providers.dart';

enum SplashPhase {
  idle, // Avant démarrage
  loading, // Précache en cours
  ready, // Tout chargé, prêt à naviguer
  error, // Échec critique
}

class SplashState {
  final SplashPhase phase;
  final double progress; // 0.0 → 1.0
  final String statusMessage;
  final PrecacheReport? report;
  final Object? error;

  const SplashState({
    this.phase = SplashPhase.idle,
    this.progress = 0.0,
    this.statusMessage = '',
    this.report,
    this.error,
  });

  SplashState copyWith({
    SplashPhase? phase,
    double? progress,
    String? statusMessage,
    PrecacheReport? report,
    Object? error,
  }) =>
      SplashState(
        phase: phase ?? this.phase,
        progress: progress ?? this.progress,
        statusMessage: statusMessage ?? this.statusMessage,
        report: report ?? this.report,
        error: error ?? this.error,
      );

  bool get isLoading => phase == SplashPhase.loading;
  bool get isReady => phase == SplashPhase.ready;
  bool get hasError => phase == SplashPhase.error;
}
