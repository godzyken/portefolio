import 'dart:developer' as developer;

enum LogLevel { debug, info, warning, error, critical }

class AppLogger {
  final String category;

  const AppLogger(this.category);

  // ── Méthodes raccourcies ───────────────────────────────────────────────────

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

  // ── Méthode principale (compatibilité ascendante) ──────────────────────────

  void log(
    String message, {
    LogLevel level = LogLevel.info,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final now = DateTime.now().toIso8601String().substring(11, 23);
    final levelStr = _levelToString(level);
    final emoji = _levelToEmoji(level);

    final buffer = StringBuffer()
      ..write('$emoji [$now][$category][$levelStr] $message');

    if (error != null) buffer.write('\n   ❌ Error: $error');

    final conciseTrace = _formatStackTrace(stackTrace);
    if (conciseTrace != null) buffer.write('\n$conciseTrace');

    developer.log(
      buffer.toString(),
      name: category,
      level: _levelToInt(level),
      error: error,
      stackTrace: stackTrace,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _levelToString(LogLevel level) => switch (level) {
        LogLevel.debug => 'DEBUG',
        LogLevel.info => 'INFO',
        LogLevel.warning => 'WARN',
        LogLevel.error => 'ERROR',
        LogLevel.critical => 'CRITICAL',
      };

  static String _levelToEmoji(LogLevel level) => switch (level) {
        LogLevel.debug => '🔍',
        LogLevel.info => 'ℹ️',
        LogLevel.warning => '⚠️',
        LogLevel.error => '❌',
        LogLevel.critical => '💥',
      };

  static int _levelToInt(LogLevel level) => switch (level) {
        LogLevel.debug => 500,
        LogLevel.info => 800,
        LogLevel.warning => 900,
        LogLevel.error => 1000,
        LogLevel.critical => 1200,
      };

  static String? _formatStackTrace(
    StackTrace? stackTrace, {
    int maxLines = 6,
  }) {
    if (stackTrace == null) return null;
    final lines = stackTrace.toString().split('\n');
    final filtered = lines
        .where((l) =>
            l.isNotEmpty &&
            !l.contains('dart:async') &&
            !l.contains('package:flutter/') &&
            !l.contains('dart:_internal'))
        .take(maxLines);
    if (filtered.isEmpty) return null;
    return '   📍 Stack:\n      ${filtered.join('\n      ')}';
  }
}
