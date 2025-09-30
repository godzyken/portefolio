import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import '../data/location_data.dart';

/// Service de géolocalisation utilisant l'API Web native du navigateur
/// 100% gratuit et sans dépendances externes
class WebGeolocationService {
  StreamController<LocationData>? _controller;
  int? _watchId;

  /// Vérifie si la géolocalisation est disponible dans le navigateur
  static bool isSupported() {
    if (!kIsWeb) return false;
    try {
      return web.window.navigator.geolocation != null;
    } catch (e) {
      debugPrint('❌ Geolocation API non disponible: $e');
      return false;
    }
  }

  /// Obtenir la position actuelle (snapshot unique)
  Future<LocationData?> getCurrentPosition() async {
    if (!isSupported()) {
      debugPrint('❌ Géolocalisation non supportée');
      return null;
    }

    final completer = Completer<LocationData?>();

    try {
      web.window.navigator.geolocation.getCurrentPosition(
        (web.GeolocationPosition position) {
          final loc = LocationData(
            latitude: position.coords.latitude,
            longitude: position.coords.longitude,
            accuracy: position.coords.accuracy,
            timestamp: DateTime.fromMillisecondsSinceEpoch(
              position.timestamp.toInt(),
            ),
          );
          debugPrint('✅ Position obtenue: ${loc.latitude}, ${loc.longitude}');
          completer.complete(loc);
        }.toJS,
        (web.GeolocationPositionError error) {
          debugPrint('❌ Erreur géolocalisation: ${error.message}');
          completer.completeError(error.message);
        }.toJS,
        web.PositionOptions(
          enableHighAccuracy: true,
          timeout: 10000, // 10 secondes
          maximumAge: 0,
        ),
      );
    } catch (e) {
      debugPrint('❌ Erreur getCurrentPosition: $e');
      completer.complete(null);
    }

    return completer.future;
  }

  /// Stream de position en temps réel
  Stream<LocationData> watchPosition() {
    _controller ??= StreamController<LocationData>.broadcast(
      onListen: _startWatching,
      onCancel: _stopWatching,
    );
    return _controller!.stream;
  }

  void _startWatching() {
    if (!isSupported()) {
      debugPrint('❌ Géolocalisation non supportée');
      return;
    }

    debugPrint('🗺️ Démarrage du suivi de position');

    try {
      _watchId = web.window.navigator.geolocation.watchPosition(
        (web.GeolocationPosition position) {
          if (_controller != null && !_controller!.isClosed) {
            final loc = LocationData(
              latitude: position.coords.latitude,
              longitude: position.coords.longitude,
              accuracy: position.coords.accuracy,
              timestamp: DateTime.fromMillisecondsSinceEpoch(
                position.timestamp.toInt(),
              ),
            );
            _controller!.add(loc);
            debugPrint(
                '📍 Nouvelle position: ${loc.latitude}, ${loc.longitude}');
          }
        }.toJS,
        (web.GeolocationPositionError error) {
          if (_controller != null && !_controller!.isClosed) {
            _controller!.addError('Erreur: ${error.message}');
            debugPrint('❌ Erreur watchPosition: ${error.message}');
          }
        }.toJS,
        web.PositionOptions(
          enableHighAccuracy: true,
          timeout: 30000, // 30 secondes
          maximumAge: 5000, // 5 secondes de cache max
        ),
      );
    } catch (e) {
      debugPrint('❌ Erreur watchPosition: $e');
      _controller?.addError(e);
    }
  }

  void _stopWatching() {
    if (_watchId != null) {
      try {
        web.window.navigator.geolocation.clearWatch(_watchId!);
        debugPrint('🛑 Arrêt du suivi de position');
      } catch (e) {
        debugPrint('❌ Erreur clearWatch: $e');
      }
      _watchId = null;
    }
    _controller?.close();
    _controller = null;
  }

  /// Demander la permission de géolocalisation
  Future<bool> requestPermission() async {
    if (!isSupported()) {
      debugPrint('❌ Géolocalisation non supportée');
      return false;
    }

    try {
      // Sur Web, la permission est demandée automatiquement
      // lors du premier appel à getCurrentPosition ou watchPosition
      final pos = await getCurrentPosition();
      return pos != null;
    } catch (e) {
      debugPrint('❌ Permission refusée: $e');
      return false;
    }
  }

  /// Nettoyer les ressources
  void dispose() {
    _stopWatching();
  }
}
