// lib/core/ui/widgets/error_boundary.dart
//
// CORRECTIONS vs l'ancienne version :
//   • FlutterError.onError assigné UNE SEULE FOIS dans initState (plus dans didChangeDependencies)
//   • Handler original sauvegardé et restauré dans dispose
//   • setState() appelé avec _error/_stackTrace renseignés
//   • debugPrint() supprimé → AppLogger
//   • Propagation vers ErrorNotifier pour les dashboards de monitoring

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../exceptions/app_error.dart';
import '../../exceptions/error/error_screen.dart';
import '../../exceptions/error_notifier.dart';
import '../../logging/app_logger.dart';
import '../../provider/providers.dart';

class ErrorBoundary extends ConsumerStatefulWidget {
  final Widget child;
  final String contextLabel;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.contextLabel = 'App',
  });

  @override
  ConsumerState<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends ConsumerState<ErrorBoundary> {
  AppError? _localError;
  StackTrace? _localStack;

  /// Handler Flutter original — restauré au dispose pour ne pas polluer les tests
  FlutterExceptionHandler? _previousFlutterHandler;

  @override
  void initState() {
    super.initState();
    // ✅ UNE SEULE FOIS ici, pas dans didChangeDependencies
    _previousFlutterHandler = FlutterError.onError;
    FlutterError.onError = _onFlutterError;
  }

  @override
  void dispose() {
    // ✅ Restauration du handler original
    FlutterError.onError = _previousFlutterHandler;
    super.dispose();
  }

  // ── Handlers ───────────────────────────────────────────────────────────────

  void _onFlutterError(FlutterErrorDetails details) {
    // Toujours appeler le handler précédent (console, DevTools, crash reporters)
    _previousFlutterHandler?.call(details);
    _capture(details.exception, details.stack);
  }

  void _capture(Object error, StackTrace? stackTrace) {
    // Log via la catégorie de ce boundary
    try {
      ref.read(loggerProvider(widget.contextLabel)).log(
            'Erreur capturée',
            level: LogLevel.error,
            error: error,
            stackTrace: stackTrace,
          );

      // Propager vers ErrorNotifier (silent = true car le boundary gère l'UI local)
      ref.read(errorNotifierProvider.notifier).report(
            error,
            stackTrace: stackTrace,
            context: widget.contextLabel,
            silent: true,
          );
    } catch (_) {
      // Ne jamais crasher depuis un gestionnaire d'erreur
    }

    // ✅ postFrameCallback : évite setState pendant un build/layout en cours
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          // ✅ _error ET _stackTrace correctement renseignés
          _localError = AppError.from(
            error,
            stackTrace: stackTrace,
            context: widget.contextLabel,
          );
          _localStack = stackTrace;
        });
      }
    });
  }

  void _reset() {
    setState(() {
      _localError = null;
      _localStack = null;
    });
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_localError != null) {
      return ErrorScreen(
        error: _localError!.message,
        stackTrace: _localStack,
        onRetry: _reset,
      );
    }

    return widget.child;
  }
}
