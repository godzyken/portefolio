import 'package:flutter/foundation.dart';

import '../data/location_data.dart';

abstract class LocationService {
  static LocationService get instance => _getLocationService();

  Future<LocationPermissionStatus> checkPermission();
  Future<LocationPermissionStatus> requestPermission();
  Future<LocationData?> getCurrentLocation();
  Stream<LocationData> getLocationStream();
  Future<bool> isLocationEnabled();
}

// Implementation pour différentes plateformes
LocationService _getLocationService() {
  if (kIsWeb) {
    return _WebLocationService();
  } else if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    return _MobileLocationService();
  } else {
    return _StubLocationService();
  }
}

// === Implementation Web ===
class _WebLocationService extends LocationService {
  @override
  Future<LocationPermissionStatus> checkPermission() async {
    // Logique de vérification des permissions web
    return LocationPermissionStatus.denied;
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    try {
      if (kIsWeb) {
        // Utilisation de dart:html si disponible
        return LocationPermissionStatus.whileInUse;
      }
      return LocationPermissionStatus.denied;
    } catch (e) {
      return LocationPermissionStatus.denied;
    }
  }

  @override
  Future<LocationData?> getCurrentLocation() async {
    // Pour le web, on peut utiliser l'API navigator.geolocation
    // ou retourner une position simulée pour le développement
    return LocationData(
      latitude: 48.8566, // Paris par défaut
      longitude: 2.3522,
      accuracy: 100.0,
      timestamp: DateTime.now(),
    );
  }

  @override
  Stream<LocationData> getLocationStream() async* {
    // Stream simulé pour le web
    while (true) {
      await Future.delayed(const Duration(seconds: 5));
      final location = await getCurrentLocation();
      if (location != null) {
        yield location;
      }
    }
  }

  @override
  Future<bool> isLocationEnabled() async => true;
}

// === Implementation Mobile (stub pour l'instant) ===
class _MobileLocationService extends LocationService {
  @override
  Future<LocationPermissionStatus> checkPermission() async {
    // Implementation avec permission_handler ou logique native
    return LocationPermissionStatus.whileInUse;
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    return LocationPermissionStatus.whileInUse;
  }

  @override
  Future<LocationData?> getCurrentLocation() async {
    // Position simulée - à remplacer par logique native
    return LocationData(
      latitude: 48.8566,
      longitude: 2.3522,
      accuracy: 10.0,
      timestamp: DateTime.now(),
    );
  }

  @override
  Stream<LocationData> getLocationStream() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      final location = await getCurrentLocation();
      if (location != null) {
        yield location;
      }
    }
  }

  @override
  Future<bool> isLocationEnabled() async => true;
}

// === Implementation Stub ===
class _StubLocationService extends LocationService {
  @override
  Future<LocationPermissionStatus> checkPermission() async =>
      LocationPermissionStatus.denied;

  @override
  Future<LocationPermissionStatus> requestPermission() async =>
      LocationPermissionStatus.denied;

  @override
  Future<LocationData?> getCurrentLocation() async => null;

  @override
  Stream<LocationData> getLocationStream() async* {
    // Stream vide
  }

  @override
  Future<bool> isLocationEnabled() async => false;
}
