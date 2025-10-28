import 'dart:async';
import 'dart:developer' as developer;

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
      developer.log('🚀 Démarrage du stream de localisation...');

      // 1. Vérifie si le GPS est activé
      final isEnabled = await LocationService.instance.isLocationEnabled();
      if (!isEnabled) {
        developer.log('⚠️ GPS désactivé');
        throw Exception(
            'Le service de localisation est désactivé. Activez le GPS dans les paramètres.');
      }

      // 2. Vérifie les permissions
      final permission = await LocationService.instance.checkPermission();
      developer.log('📋 Permission actuelle: $permission');

      if (permission == LocationPermissionStatus.denied ||
          permission == LocationPermissionStatus.deniedForever) {
        // Demande la permission
        final requested = await LocationService.instance.requestPermission();
        if (requested != LocationPermissionStatus.granted &&
            requested != LocationPermissionStatus.whileInUse) {
          throw Exception(
              'Permission de localisation refusée. Autorisez l\'accès dans les paramètres.');
        }
      }

      // 3. Récupère d'abord la position actuelle (pour un affichage immédiat)
      final currentPos = await LocationService.instance.getCurrentLocation();
      if (currentPos != null) {
        developer.log('📍 Position initiale obtenue');
        yield currentPos;
      }

      // 4. Écoute le stream pour les mises à jour continues
      await for (final position
          in LocationService.instance.getLocationStream()) {
        developer.log('🔄 Nouvelle position reçue');
        yield position;
      }
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
}
