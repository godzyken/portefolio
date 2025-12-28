import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/generator/data/location_data.dart';
import '../../features/generator/services/location_service.dart';

class UserLocationNotifier extends StreamNotifier<LocationData> {
  StreamSubscription<LocationData>? _subscription;

  @override
  Stream<LocationData> build() {
    ref.onAddListener(() {
      _getPermission;
      developer.log('🚀 Démarrage du stream de localisation');
    });

    ref.onDispose(() {
      _subscription?.cancel();
      developer.log('❌ Arrêt du stream de localisation');
    });

    if (kIsWeb) {
      return _startWebSimulationStream();
    }

    return _startLocationStream();
  }

  Stream<LocationData> get _getPermission async* {
    final locationService = LocationService.instance;

    if (!await locationService.isLocationEnabled()) {
      throw Exception('Services de localisation désactivés');
    }

    final permission = await locationService.checkPermission();
    if (permission != LocationPermissionStatus.always &&
        permission != LocationPermissionStatus.whileInUse) {
      final requested = await locationService.requestPermission();
      if (requested != LocationPermissionStatus.always &&
          requested != LocationPermissionStatus.whileInUse) {
        throw Exception('Permission de localisation refusée');
      }
    }

    yield* locationService.getLocationStream();
  }

  /// Démarre le stream de localisation
  Stream<LocationData> _startLocationStream() async* {
    try {
      final service = LocationService.instance;

      // 1. Vérification des services
      if (!await service.isLocationEnabled()) {
        throw Exception('GPS désactivé sur l\'appareil');
      }
      developer.log('🚀 Démarrage du stream de localisation...');

      // 1. Vérifie si le GPS est activé
      final isEnabled = await service.isLocationEnabled();
      if (!isEnabled) {
        developer.log('⚠️ GPS désactivé');
        throw Exception(
            'Le service de localisation est désactivé. Activez le GPS dans les paramètres.');
      }

      // 2. Vérifie les permissions
      var permission = await service.checkPermission();
      developer.log('📋 Permission actuelle: $permission');

      if (permission == LocationPermissionStatus.denied ||
          permission == LocationPermissionStatus.deniedForever) {
        // Demande la permission
        permission = await service.requestPermission();
        if (permission != LocationPermissionStatus.granted &&
            permission != LocationPermissionStatus.whileInUse) {
          throw Exception(
              'Permission de localisation refusée. Autorisez l\'accès dans les paramètres.');
        }
      }

      // 3. Récupère d'abord la position actuelle (pour un affichage immédiat)
      final currentPos = await service.getCurrentLocation();
      if (currentPos != null) {
        developer.log('📍 Position initiale obtenue');
        yield currentPos;
      }

      // 4. Écoute le stream pour les mises à jour continues
      await for (final position in service.getLocationStream()) {
        developer.log('🔄 Nouvelle position reçue');
        yield position;
      }

      yield* service.getLocationStream();
    } catch (e, stackTrace) {
      developer.log('❌ Erreur dans UserLocationNotifier: $e');
      developer.log('Stack: $stackTrace');

      // ⚠️ IMPORTANT : On rethrow pour que Riverpod gère l'erreur
      // et que le widget puisse l'afficher avec .when(error: ...)
      rethrow;
    }
  }

  /// Force une mise à jour de la position
  Future<void> refresh() async {
    try {
      developer.log('🔄 Rafraîchissement de la position...');
      final position = await LocationService.instance.getCurrentLocation();
      if (position != null) {
        // On invalide le provider pour redémarrer le stream
        ref.invalidateSelf();
      }
    } catch (e) {
      developer.log('❌ Erreur lors du refresh: $e');
    }
  }

  Stream<LocationData> _startWebSimulationStream() async* {
    developer.log('🌐 Mode Web : Démarrage simulation');

    // Position de départ (Paris par défaut)
    double lat = 48.8566;
    double lng = 2.3522;
    double angle = 0.0;

    yield LocationData(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
      accuracy: 0.0,
    );

    // Génère une mise à jour toutes les 3 secondes
    while (true) {
      await Future.delayed(const Duration(seconds: 3));
      angle += 0.1;
      yield LocationData(
        latitude: lat + (0.002 * sin(angle)),
        longitude: lng + (0.002 * cos(angle)),
        timestamp: DateTime.now(),
        accuracy: 0.0,
      );
    }
  }
}

class SatelliteModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

class TourIndexNotifier extends Notifier<int> {
  @override
  int build() => -1; // État initial : visite inactive

  void setIndex(int index) => state = index;

  void stopTour() => state = -1;

  bool get isTourActive => state != -1;
}
