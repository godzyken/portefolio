import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Niveaux de log (compatibles dart:developer)
// ─────────────────────────────────────────────────────────────────────────────

enum LogLevel {
  debug, // 500  — traces de développement
  info, // 800  — événements normaux
  warning, // 900  — anomalies non bloquantes
  error, // 1000 — erreurs récupérables
  critical, // 1200 — erreurs bloquantes → peut stopper l'app
}

// ─────────────────────────────────────────────────────────────────────────────
// AppLogger
// ─────────────────────────────────────────────────────────────────────────────

class AppLogger {
  final String category;

  const AppLogger(this.category);

  // ── Raccourcis ─────────────────────────────────────────────────────────────

  void debug(String message, {Object? error, StackTrace? stackTrace}) =>
      log(message, level: LogLevel.debug, error: error, stackTrace: stackTrace);

  void info(String message, {Object? error, StackTrace? stackTrace}) =>
      log(message, level: LogLevel.info, error: error, stackTrace: stackTrace);

  void warning(String message, {Object? error, StackTrace? stackTrace}) =>
      log(message,
          level: LogLevel.warning, error: error, stackTrace: stackTrace);

  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      log(message, level: LogLevel.error, error: error, stackTrace: stackTrace);

  void critical(String message, {Object? error, StackTrace? stackTrace}) =>
      log(message,
          level: LogLevel.critical, error: error, stackTrace: stackTrace);

  // ── Méthode principale ─────────────────────────────────────────────────────

  void log(
    String message, {
    LogLevel level = LogLevel.info,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final now = DateTime.now().toIso8601String().substring(11, 23);
    final emoji = _emoji(level);
    final levelStr = _levelStr(level);

    // ✅ Localisation précise : extrait le fichier + ligne depuis la stack
    final source = _extractSource(stackTrace ?? StackTrace.current);

    final buffer = StringBuffer()..write('$emoji [$now][$category][$levelStr]');

    if (source != null) buffer.write('[$source]');

    buffer.write(' $message');

    if (error != null) buffer.write('\n   ❌ ${error.runtimeType}: $error');

    final formattedStack = _formatStackTrace(stackTrace);
    if (formattedStack != null) buffer.write('\n$formattedStack');

    developer.log(
      buffer.toString(),
      name: category,
      level: _levelInt(level),
      error: error,
      stackTrace: stackTrace,
    );
  }

  // ── Extraction de la source ─────────────────────────────────────────────────

  /// Extrait "fichier.dart:ligne" depuis le frame le plus pertinent du projet.
  ///
  /// Ignore : dart:*, package:flutter/*, package:riverpod/*
  /// Priorise : package:portefolio/*, lib/*
  static String? _extractSource(StackTrace stackTrace) {
    final lines = stackTrace.toString().split('\n');

    for (final line in lines) {
      // On cherche les frames du projet (pas des frameworks)
      if (!line.contains('package:portefolio') && !line.contains('lib/')) {
        continue;
      }
      if (line.contains('app_logger.dart')) continue;
      if (line.contains('dart:')) continue;

      // Extrait "fichier.dart:ligne:col"
      final match = RegExp(r'([\w/]+\.dart):(\d+)').firstMatch(line);
      if (match != null) {
        // ignore: avoid-non-null-assertion
        final file = match.group(1)!.split('/').last; // Juste le nom du fichier
        final lineNum = match.group(2);
        return '$file:$lineNum';
      }
    }
    return null;
  }

  // ── Formatage de la stack ───────────────────────────────────────────────────

  static String? _formatStackTrace(StackTrace? stackTrace, {int maxLines = 5}) {
    if (stackTrace == null) return null;

    final lines = stackTrace.toString().split('\n');

    // ✅ On garde UNIQUEMENT les frames du projet → localisation immédiate
    final projectFrames = lines
        .where((l) {
          if (l.isEmpty) return false;
          if (l.contains('dart:async') ||
              l.contains('dart:_internal') ||
              l.contains('package:flutter/') ||
              l.contains('package:riverpod/') ||
              l.contains('package:flutter_riverpod/') ||
              l.contains('app_logger.dart')) {
            return false;
          }
          return true;
        })
        .take(maxLines)
        .toList();

    if (projectFrames.isEmpty) return null;

    return '   📍 Stack (projet):\n      ${projectFrames.join('\n      ')}';
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _emoji(LogLevel level) => switch (level) {
        LogLevel.debug => '🔍',
        LogLevel.info => 'ℹ️',
        LogLevel.warning => '⚠️',
        LogLevel.error => '❌',
        LogLevel.critical => '💥',
      };

  static String _levelStr(LogLevel level) => switch (level) {
        LogLevel.debug => 'DEBUG',
        LogLevel.info => 'INFO',
        LogLevel.warning => 'WARN',
        LogLevel.error => 'ERROR',
        LogLevel.critical => 'CRITICAL',
      };

  static int _levelInt(LogLevel level) => switch (level) {
        LogLevel.debug => 500,
        LogLevel.info => 800,
        LogLevel.warning => 900,
        LogLevel.error => 1000,
        LogLevel.critical => 1200,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Règles d'arrêt de l'app
// ─────────────────────────────────────────────────────────────────────────────

/// Détermine si une erreur doit stopper l'application.
///
/// SEULES les erreurs CRITIQUES arrêtent l'app.
/// Toutes les autres sont loggées et ignorées (l'UI gère localement).
class AppErrorPolicy {
  const AppErrorPolicy._();

  /// Retourne true uniquement si l'erreur est irrécupérable.
  static bool shouldHaltApp(Object error) {
    // Erreurs de layout Flutter → JAMAIS bloquantes
    // (affichent un bandeau jaune/noir mais l'app reste fonctionnelle)
    if (_isLayoutError(error)) return false;

    // Erreurs de cycle de vie des widgets → JAMAIS bloquantes
    if (_isLifecycleError(error)) return false;

    // Erreurs d'assets / réseau / timeout → JAMAIS bloquantes
    if (_isAssetError(error)) return false;
    if (_isNetworkError(error)) return false;
    if (_isTimeoutError(error)) return false;

    // Erreurs de rendu SVG / image → non bloquantes
    if (_isImageError(error)) return false;

    // Par défaut : récupérable — laisser l'ErrorBoundary décider
    return false;
  }

  /// Classe une erreur pour le logging.
  static LogLevel classifyLevel(Object error) {
    // Erreurs silencieuses de rendu/layout → WARNING seulement
    if (_isLayoutError(error)) return LogLevel.warning;
    if (_isLifecycleError(error)) return LogLevel.warning;
    if (_isAssetError(error) || _isImageError(error)) return LogLevel.warning;
    if (_isNetworkError(error) || _isTimeoutError(error)) {
      return LogLevel.warning;
    }
    return LogLevel.error;
  }

  /// ✅ NOUVEAU : filtre pour FlutterError.onError
  ///
  /// À utiliser dans main.dart pour intercepter les FlutterError avant
  /// qu'ils ne remontent à ErrorNotifier / ZonedGuard.
  ///
  /// Usage :
  /// ```dart
  /// FlutterError.onError = AppErrorPolicy.handleFlutterError;
  /// ```
  static void handleFlutterError(FlutterErrorDetails details) {
    final error = details.exception;
    final level = classifyLevel(error);

    if (level == LogLevel.warning) {
      // Erreur silencieuse : log simple, PAS de propagation vers ErrorNotifier
      developer.log(
        '⚠️ [${details.library}] ${details.exceptionAsString()}',
        name: 'FlutterError',
        level: 900,
      );
      // Affiche le bandeau de debug en mode développement (comportement normal)
      if (kDebugMode) FlutterError.presentError(details);
      return; // ← NE PAS appeler la logique d'arrêt
    }

    // Erreur sérieuse : log complet + propagation normale
    developer.log(
      '❌ [${details.library}] ${details.exceptionAsString()}',
      name: 'FlutterError',
      level: 1000,
      error: details.exception,
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
    // Votre ErrorNotifier / ZonedGuard peut être appelé ici si nécessaire
  }

  // ── Détecteurs ─────────────────────────────────────────────────────────────

  /// Overflows de layout (RenderFlex, RenderBox…) — visuellement non fatals
  static bool _isLayoutError(Object e) {
    final s = e.toString();
    return s.contains('RenderFlex overflowed') ||
        s.contains('overflowed by') ||
        s.contains('does not fit within the constraints') ||
        s.contains('RenderBox was not laid out');
  }

  /// Erreurs de cycle de vie (setState after dispose, etc.)
  static bool _isLifecycleError(Object e) {
    final s = e.toString();
    return s.contains('setState() called after dispose') ||
        s.contains('called after dispose()') ||
        s.contains('no longer mounted') ||
        s.contains('lifecycle state: defunct');
  }

  static bool _isAssetError(Object e) {
    final s = e.toString().toLowerCase();
    return s.contains('unable to load asset') ||
        s.contains('assetmanifest') ||
        s.contains('404') ||
        s.contains('400');
  }

  static bool _isNetworkError(Object e) {
    final s = e.toString().toLowerCase();
    return s.contains('socket') ||
        s.contains('network') ||
        s.contains('connection refused') ||
        s.contains('xmlhttprequest');
  }

  static bool _isTimeoutError(Object e) =>
      e is TimeoutException ||
      e.toString().toLowerCase().contains('timeout') ||
      e.toString().toLowerCase().contains('timed out');

  static bool _isImageError(Object e) {
    final s = e.toString().toLowerCase();
    return s.contains('imagecodec') ||
        s.contains('unable to load image') ||
        s.contains('pictureinfo') ||
        s.contains('svgparser') ||
        (s.contains('failed to load') && s.contains('image'));
  }
}
