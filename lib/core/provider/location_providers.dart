import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../features/generator/data/location_data.dart';
import '../../features/generator/providers/errors/geolocation_exception.dart';
import '../../features/generator/providers/location_service_provider.dart';
import '../notifier/location_notifiers.dart';
import 'location_settings_provider.dart';

/// 🔹 Provider pour le statut de permission GPS
final locationPermissionProvider =
    FutureProvider<LocationPermissionStatus>((ref) async {
  final service = ref.watch(locationServiceProvider);
  return await service.checkPermission();
});

/// 🔹 Provider pour activer/demander la permission
final requestLocationPermissionProvider =
    FutureProvider<LocationPermissionStatus>((ref) async {
  final service = ref.watch(locationServiceProvider);
  return await service.requestPermission();
});

/// 🔹 Provider pour le flux en temps réel (mise à jour continue)
final locationStreamProvider = StreamProvider.autoDispose<LocationData>((ref) {
  final service = ref.watch(locationServiceProvider);
  final settings = ref.watch(locationSettingsProvider);

  return service.getLocationStream(settings: settings).handleError((e, st) {
    ref
        .read(locationErrorProvier.notifier)
        .setError(e is GeolocationException ? e : null);
  });
});

/// 🔹 Provider pour savoir si le GPS est activé
final isGpsEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(locationServiceProvider);
  return await service.isLocationEnabled();
});

final mapConfigProvider = Provider<MapOptions Function(LatLng)>((ref) {
  return (LatLng userPos) {
    return MapOptions(
      initialCenter: userPos,
      initialZoom: 16.0,
      initialRotation: 0.0,
      initialCameraFit: CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(
              [LatLng(48.85, 2.34), LatLng(48.87, 2.36)])),
      interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          enableMultiFingerGestureRace: true),
      minZoom: 3.0,
      maxZoom: 18.0,
      keepAlive: true,
      backgroundColor: Colors.grey.shade100,
      cameraConstraint: CameraConstraint.contain(
          bounds: LatLngBounds.fromPoints(
              [LatLng(48.85, 2.34), LatLng(48.87, 2.36)])),
    );
  };
});

final userLocationProvider =
    StreamNotifierProvider<UserLocationNotifier, LocationData>(
        UserLocationNotifier.new);

final sigPointsProvider = Provider.family<List<LatLng>, LatLng>((ref, userPos) {
  final rng = Random();
  // 5 points aléatoires autour de l'utilisateur
  return List.generate(5, (index) {
    final dx = (rng.nextDouble() - 0.5) / 500;
    final dy = (rng.nextDouble() - 0.5) / 500;
    return LatLng(userPos.latitude + dx, userPos.longitude + dy);
  });
});

/// 🔹 Points SIG proches basés sur la dernière position utilisateur
final nearbySigPointsProvider = Provider<AsyncValue<List<LatLng>>>((ref) {
  final userLocation = ref.watch(userLocationProvider);

  return userLocation.when(
    data: (pos) {
      final userLatLng = LatLng(pos.latitude, pos.longitude);

      final sigPoints = ref.watch(sigPointsProvider(userLatLng));

      return AsyncValue.data(sigPoints);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) {
      if (kDebugMode) {
        developer.log('Erreur de localisation SIG: $e');
      }
      return AsyncValue.error(e, st);
    },
  );
});
