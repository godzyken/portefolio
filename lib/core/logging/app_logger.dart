import 'dart:developer' as developer;

enum LogLevel { debug, info, warning, error, critical }

class AppLogger {
  final String category;

  AppLogger(this.category);

  void log(
    String message, {
    LogLevel level = LogLevel.info,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final now =
        DateTime.now().toIso8601String().substring(11, 23); // HH:mm:ss.mmm
    final levelStr = _levelToString(level);

    final buffer = StringBuffer()
      ..writeln('[$now] [$category] [$levelStr] $message');

    if (error != null) buffer.writeln('   ❌ Error: $error');
    final conciseTrace = _formatStackTrace(stackTrace);
    if (conciseTrace != null) buffer.writeln(conciseTrace);

    developer.log(
      buffer.toString(),
      name: category,
      level: _levelToInt(level),
      error: error,
      stackTrace: stackTrace,
    );
  }

  static String _levelToString(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.critical:
        return 'CRITICAL';
    }
  }

  static int _levelToInt(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.critical:
        return 1200;
    }
  }

  static String? _formatStackTrace(StackTrace? stackTrace, {int maxLines = 5}) {
    if (stackTrace == null) return null;
    final lines = stackTrace.toString().split('\n');
    final filtered = lines.where(
      (l) => !l.contains('dart:async') && !l.contains('package:flutter/'),
    );
    final concise = filtered.take(maxLines).toList();
    return concise.isEmpty
        ? null
        : '   📍 Stack:\n      ${concise.join('\n      ')}';
  }
}
