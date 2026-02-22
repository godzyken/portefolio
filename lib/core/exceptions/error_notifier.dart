import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logging/app_logger.dart';
import 'app_error.dart';

class ErrorNotifier extends Notifier<AppError?> {
  static const _log = AppLogger('ErrorNotifier');

  @override
  AppError? build() => null;

  // ── API publique ───────────────────────────────────────────────────────────

  /// Signale une erreur depuis n'importe où (service, provider, widget).
  /// [silent] = true → log uniquement, ne bloque pas l'UI.
  void report(
    Object error, {
    StackTrace? stackTrace,
    String? context,
    bool silent = false,
  }) {
    final appError =
        AppError.from(error, stackTrace: stackTrace, context: context);
    _emit(appError);
    if (!silent) state = appError;
  }

  /// Signale un [AppError] déjà construit.
  void reportAppError(AppError appError, {bool silent = false}) {
    _emit(appError);
    if (!silent) state = appError;
  }

  /// Remet à zéro (bouton "Réessayer" / "Accueil").
  void clear() {
    _log.info('Erreur globale effacée');
    state = null;
  }

  // ── Logging interne ────────────────────────────────────────────────────────

  void _emit(AppError e) {
    final level = e.isCritical ? LogLevel.critical : LogLevel.error;
    final ctx = e.context != null ? ' [ctx: ${e.context}]' : '';
    _log.log(
      '${e.type.name.toUpperCase()}$ctx — ${e.message}',
      level: level,
      error: e.raw,
      stackTrace: e.stackTrace,
    );
  }
}

/// Provider principal — remplace globalErrorProvider
final errorNotifierProvider =
    NotifierProvider<ErrorNotifier, AppError?>(ErrorNotifier.new);

/// Sélecteur : true si une erreur bloquante est active
final hasGlobalErrorProvider = Provider<bool>(
  (ref) => ref.watch(errorNotifierProvider) != null,
);
