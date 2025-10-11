// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:web/web.dart' as web;

import '../data/location_data.dart';
import '../errors/geolocation_exception.dart';

/// Service de géolocalisation multi-plateforme (Web & Mobile)
/// utilisant l'API Web native du navigateur et un MethodChannel pour le mobile.
class GeolocationService {
  static const _channel = MethodChannel('custom_geolocation');

  StreamController<LocationData>? _controller;
  int? _watchId;

  /// Vérifie si la géolocalisation est disponible.
  static bool isSupported() {
    // CORRIGÉ : La logique a été inversée.
    if (kIsWeb) {
      // Sur le web, on vérifie la présence de l'API dans le navigateur.
      return web.window.navigator.geolocation != null;
    }
    // Pour les plateformes natives (Android, iOS), on suppose que c'est supporté.
    return true;
  }

  /// Obtenir la position actuelle (snapshot unique).
  /// Lance une [GeolocationException] en cas d'erreur.
  Future<LocationData> _getCurrentWebPosition() async {
    if (!isSupported()) {
      throw GeolocationException(
          'La géolocalisation n\'est pas supportée par ce navigateur.');
    }

    // 1. Crée un Completer qui produira une Future<LocationData>
    final completer = Completer<LocationData>();

    final options = web.PositionOptions(
      enableHighAccuracy: true,
      timeout: 10000,
      maximumAge: 0,
    );

    try {
      // 2. Appelle la méthode `getCurrentPosition` en respectant sa signature
      web.window.navigator.geolocation.getCurrentPosition(
        // PREMIER ARGUMENT : le callback de succès (obligatoire)
        (web.GeolocationPosition position) {
          final coords = position.coords;
          final loc = LocationData(
            latitude: coords.latitude.toDouble(),
            longitude: coords.longitude.toDouble(),
            accuracy: coords.accuracy.toDouble(),
            timestamp:
                DateTime.fromMillisecondsSinceEpoch(position.timestamp.toInt()),
          );
          // Quand le succès arrive, on complète la Future avec le résultat
          if (!completer.isCompleted) {
            completer.complete(loc);
          }
        }.toJS,

        // DEUXIÈME ARGUMENT : le callback d'erreur (optionnel)
        (web.GeolocationPositionError error) {
          final exception =
              GeolocationException(error.message, code: error.code.toString());
          // Quand l'erreur arrive, on complète la Future avec une erreur
          if (!completer.isCompleted) {
            completer.completeError(exception);
          }
        }.toJS,

        // TROISIÈME ARGUMENT : les options
        options,
      );
    } on web.GeolocationPositionError catch (e) {
      throw GeolocationException(e.message, code: e.code.toString());
    } catch (e) {
      // Si l'appel à `getCurrentPosition` lui-même échoue (très rare)
      if (!completer.isCompleted) {
        completer.completeError(GeolocationException(
            'Erreur inattendue lors de l\'appel à getCurrentPosition.'));
      }
    }

    return completer.future;
  }

  /// --- Implémentation MOBILE ---
  Future<LocationData> _getNativePosition() async {
    try {
      final result =
          await _channel.invokeMapMethod<String, dynamic>('getCurrentPosition');
      if (result == null) {
        throw GeolocationException('Données de position natives non valides.');
      }
      return LocationData(
        latitude: result['latitude'] as double,
        longitude: result['longitude'] as double,
        accuracy: result['accuracy'] as double,
        timestamp: DateTime.parse(result['timestamp'] as String),
      );
    } on PlatformException catch (e) {
      throw GeolocationException(e.message ?? 'Erreur native inconnue',
          code: e.code);
    } catch (e) {
      throw GeolocationException('Erreur inattendue sur la plateforme native.');
    }
  }

  /// Stream de position en temps réel.
  Stream<LocationData> watchPosition() {
    _controller ??= StreamController<LocationData>.broadcast(
      onListen: _startWatching,
      onCancel: _stopWatching,
    );
    return _controller!.stream;
  }

  void _startWatching() {
    if (!kIsWeb) {
      _controller?.addError(UnimplementedError(
          'watchPosition n\'est pas encore implémenté pour le natif.'));
      return;
    }

    if (!isSupported()) {
      _controller?.addError(
          GeolocationException('La géolocalisation n\'est pas supportée.'));
      return;
    }

    debugPrint('🗺️ Démarrage du suivi de position');

    try {
      // CORRIGÉ : La signature de watchPosition est `watchPosition(successCallback, [errorCallback, options])`.
      // Votre code passait les options à la place du callback d'erreur.
      _watchId = web.window.navigator.geolocation.watchPosition(
        // 1. Callback de succès
        (web.GeolocationPosition position) {
          if (_controller?.isClosed == false) {
            final coords = position.coords;
            final loc = LocationData(
              latitude: coords.latitude.toDouble(),
              longitude: coords.longitude.toDouble(),
              accuracy: coords.accuracy.toDouble(),
              timestamp: DateTime.fromMillisecondsSinceEpoch(
                  position.timestamp.toInt()),
            );
            _controller!.add(loc);
          }
        }.toJS,
        // 2. Callback d'erreur (optionnel)
        (web.GeolocationPositionError error) {
          if (_controller?.isClosed == false) {
            _controller!.addError(GeolocationException(error.message,
                code: error.code.toString()));
          }
        }.toJS,
        // 3. Options
        web.PositionOptions(
          enableHighAccuracy: true,
          timeout: 30000,
          maximumAge: 5000,
        ),
      );
    } catch (e) {
      _controller?.addError(
          GeolocationException('Impossible de démarrer le suivi de position.'));
    }
  }

  void _stopWatching() {
    if (_watchId != null) {
      if (kIsWeb) {
        web.window.navigator.geolocation.clearWatch(_watchId!);
      }
      _watchId = null;
      debugPrint('🛑 Arrêt du suivi de position');
    }
  }

  /// Demander la permission de géolocalisation.
  Future<bool> requestPermission() async {
    try {
      await getCurrentPosition();
      return true;
    } catch (e) {
      debugPrint('❌ Permission refusée ou erreur durant la requête: $e');
      return false;
    }
  }

  /// Nettoyer les ressources.
  void dispose() {
    _stopWatching();
    _controller?.close();
    _controller = null;
  }

  /// Méthode publique pour obtenir la position.
  /// Gère automatiquement la redirection vers la bonne plateforme.
  Future<LocationData> getCurrentPosition() async {
    // CORRIGÉ : Logique de plateforme simplifiée.
    if (kIsWeb) {
      return _getCurrentWebPosition();
    } else {
      // Cette branche sera exécutée sur Android, iOS, etc.
      return _getNativePosition();
    }
  }
}
