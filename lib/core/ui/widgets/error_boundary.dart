import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../exceptions/error/error_screen.dart';
import '../../logging/app_logger.dart';
import '../../provider/providers.dart';

/// Widget qui capture les erreurs enfants et les envoie au logger.
class ErrorBoundary extends ConsumerStatefulWidget {
  final Widget child;
  final String? contextLabel;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.contextLabel,
  });

  @override
  ConsumerState<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends ConsumerState<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Gestion des erreurs Flutter globales dans ce sous-arbre.
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleError(details.exception, details.stack);
    };
  }

  void _handleError(Object error, StackTrace? stackTrace) {
    if (!mounted) {
      // Si le widget n'est plus monté, on ne peut rien faire de plus que de logger.
      // On ne peut pas utiliser ref ni setState.
      debugPrint('Erreur capturée sur un widget démonté: $error');
      return;
    }

    // `ref` est maintenant sûr à utiliser
    ref.read(loggerProvider(widget.contextLabel ?? 'ErrorBoundary')).log(
          'Erreur capturée dans ErrorBoundary',
          level: LogLevel.error,
          error: error,
          stackTrace: stackTrace,
        );

    setState(() {
      _error = error;
      _stackTrace = stackTrace;
    });
  }

  void _resetError() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return ErrorScreen(
        error: _error!,
        stackTrace: _stackTrace,
        onRetry: _resetError,
      );
    }

    // Zone protégée : capture des erreurs dans le build des enfants
    return Builder(
      builder: (context) {
        try {
          return widget.child;
        } catch (e, st) {
          // Cette erreur est synchrone, on peut appeler notre handler sûr.
          // Il faut le faire dans un post-frame callback pour éviter
          // de faire un setState pendant un build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleError(e, st);
          });

          // On retourne immédiatement un placeholder.
          // L'UI se mettra à jour au prochain frame avec l'écran d'erreur.
          return const SizedBox.shrink();
        }
      },
    );
  }
}
