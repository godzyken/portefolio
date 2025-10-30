import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/error_providers.dart';
import '../state/global_error_state.dart';

// Déclare un container global accessible partout
final globalContainer = ProviderContainer();

/// Exception personnalisée pour forcer une mise à jour
class ForceUpdateException implements Exception {
  final String message;
  final String updateUrl;

  ForceUpdateException({required this.message, required this.updateUrl});

  @override
  String toString() => 'ForceUpdateException: $message';
}

/// Gestionnaire global des erreurs
/// Gestionnaire global des erreurs pour Riverpod 3
class GlobalErrorHandler {
  /// [ref] est passé depuis un Widget ou Provider
  static void handle(Object error, WidgetRef ref, [StackTrace? stackTrace]) {
    final notifier = ref.read(globalErrorProvider.notifier);

    if (error is ForceUpdateException) {
      notifier.setError(GlobalErrorState(
        message: error.message,
        updateUrl: error.updateUrl,
        isForceUpdate: true,
      ));
      return;
    }

    if (error is SocketException) {
      notifier.setError(GlobalErrorState(
        message: 'Aucune connexion internet', // Marker pour pas de réseau
      ));
      return;
    }

    // Gestion des erreurs HTTP ou Timeout (optionnel)
    if (error is HttpException) {
      notifier.setError(GlobalErrorState(
        message: 'Erreur HTTP : ${error.message}',
      ));
      return;
    }

    if (error is TimeoutException) {
      notifier.setError(GlobalErrorState(
        message: 'La requête a expiré',
      ));
      return;
    }

    // Fallback pour toutes les autres erreurs
    notifier.setError(GlobalErrorState(message: error.toString()));
  }
}
