// ─────────────────────────────────────────────────────────────────────────────
// AppError  —  modèle d'erreur unifié
//
// REMPLACE : GlobalErrorState (lib/core/exceptions/state/global_error_state.dart)
//            → ce fichier est À SUPPRIMER
// ─────────────────────────────────────────────────────────────────────────────

enum AppErrorType {
  /// Erreur réseau (socket, timeout, HTTP)
  network,

  /// Erreur interne (bug, assertion, cast)
  internal,

  /// Erreur de configuration (clé manquante, env mal défini)
  configuration,

  /// Erreur de permission (GPS, caméra…)
  permission,

  /// Mise à jour forcée requise
  forceUpdate,

  /// Erreur de parsing / JSON invalide
  parsing,

  /// Erreur inconnue
  unknown,
}

/// Erreur applicative complète, propageable via Riverpod.
///
/// Toujours construite via [AppError.from] ou les factories nommées.
class AppError {
  final String message;
  final AppErrorType type;
  final Object? raw;
  final StackTrace? stackTrace;
  final String? context;
  final DateTime timestamp;

  /// URL de mise à jour (uniquement pour [AppErrorType.forceUpdate])
  final String? updateUrl;

  AppError({
    required this.message,
    this.type = AppErrorType.unknown,
    this.raw,
    this.stackTrace,
    this.context,
    this.updateUrl,
  }) : timestamp = DateTime.now();

  // ── Factories ──────────────────────────────────────────────────────────────

  /// Détecte automatiquement le type à partir de l'exception reçue.
  factory AppError.from(
    Object error, {
    StackTrace? stackTrace,
    String? context,
  }) {
    final type = _detectType(error);
    final message = _buildMessage(error, type);

    return AppError(
      message: message,
      type: type,
      raw: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  factory AppError.network({
    required String message,
    Object? raw,
    StackTrace? stackTrace,
    String? context,
  }) =>
      AppError(
        message: message,
        type: AppErrorType.network,
        raw: raw,
        stackTrace: stackTrace,
        context: context,
      );

  factory AppError.forceUpdate({
    required String message,
    required String updateUrl,
  }) =>
      AppError(
        message: message,
        type: AppErrorType.forceUpdate,
        updateUrl: updateUrl,
      );

  factory AppError.permission(String message, {String? context}) => AppError(
        message: message,
        type: AppErrorType.permission,
        context: context,
      );

  factory AppError.configuration(String message) => AppError(
        message: message,
        type: AppErrorType.configuration,
      );

  factory AppError.parsing(String message, {Object? raw, String? context}) =>
      AppError(
        message: message,
        type: AppErrorType.parsing,
        raw: raw,
        context: context,
      );

  // ── Helpers internes ───────────────────────────────────────────────────────

  static AppErrorType _detectType(Object error) {
    final className = error.runtimeType.toString().toLowerCase();
    final errorStr = error.toString().toLowerCase();

    // Réseau
    if (className.contains('socket') ||
        errorStr.contains('socket') ||
        errorStr.contains('connection refused') ||
        errorStr.contains('network')) {
      return AppErrorType.network;
    }

    // Timeout
    if (className.contains('timeout') || errorStr.contains('timed out')) {
      return AppErrorType.network;
    }

    // HTTP
    if (className.contains('http') || errorStr.contains('http')) {
      return AppErrorType.network;
    }

    // FormatException / JSON
    if (className.contains('format') || className.contains('json')) {
      return AppErrorType.parsing;
    }

    // Permission
    if (errorStr.contains('permission') || errorStr.contains('denied')) {
      return AppErrorType.permission;
    }

    return AppErrorType.unknown;
  }

  static String _buildMessage(Object error, AppErrorType type) {
    return switch (type) {
      AppErrorType.network => _networkMessage(error),
      AppErrorType.parsing => 'Erreur de traitement des données',
      AppErrorType.permission => 'Permission refusée',
      AppErrorType.configuration => 'Erreur de configuration',
      AppErrorType.forceUpdate => 'Mise à jour requise',
      _ => error.toString(),
    };
  }

  static String _networkMessage(Object error) {
    final s = error.toString().toLowerCase();
    if (s.contains('socket') || s.contains('connection')) {
      return 'Aucune connexion internet';
    }
    if (s.contains('timeout') || s.contains('timed out')) {
      return 'La requête a expiré, veuillez réessayer';
    }
    return 'Erreur réseau : ${error.toString()}';
  }

  // ── Accesseurs utiles ──────────────────────────────────────────────────────

  bool get isNetwork => type == AppErrorType.network;
  bool get isForceUpdate => type == AppErrorType.forceUpdate;
  bool get isPermission => type == AppErrorType.permission;
  bool get isCritical =>
      type == AppErrorType.internal || type == AppErrorType.forceUpdate;

  @override
  String toString() =>
      'AppError(type: $type, message: $message, context: $context)';
}
